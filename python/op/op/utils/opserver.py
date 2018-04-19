#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OnePiece License Server Module

Created on Wed Jan 24
@author: minato
"""

import os
import sys
import uuid
import socket
import signal
import errno
import socketserver
import logging
from struct import pack
import psutil
from truepy import License

SRV = None

class OPServerHandler(socketserver.BaseRequestHandler):
    ''' The request handler class for OP license server.
    '''

    def myrecv(self):
        ''' own receiver. (supports text message only) '''
        data = self.request.recv(1024)
        SRV.logger.debug("recv: '%s'", data)
        return data.decode()

    def mysend(self, data):
        ''' sender with debuggin massge '''
        SRV.logger.debug('send: %s', repr(data))
        if isinstance(data, str):
            self.request.sendall(data.encode())
        else:
            self.request.sendall(data)


    def handle_co(self, request):
        ''' Check-out command handler '''
        if len(request) == 4:
            cmd, user, host, feature = request
            self.mysend(SRV.checkout(user, host, feature))
            if self.myrecv() == 'ack':
                self.mysend(pack('i', SRV.rowsize))
                if self.myrecv() == 'ack':
                    self.mysend(SRV.rowlic)
        else:
            self.mysend('parse failed')

    def handle_ci(self, request):
        ''' Check-in command handler '''
        if len(request) == 2:
            cmd, sid = request
            self.mysend(SRV.checkin(sid))
        else:
            self.mysend('parse failed')


    def handle(self):
        ''' License request handler '''
        request = self.myrecv().split()
        if request[0] == 'co':
            self.handle_co(request)
        elif request[0] == 'ci':
            self.handle_ci(request)
        else:
            SRV.logger.warning('Unknown command')


def sigterm_handler(signo, frame):
    ''' signal (SIGTERM) handler '''
    SRV.logger.debug('caught signal: %d', signo)
    sys.exit(0)


def get_hostids():
    ''' getting list of host ID on the running server '''
    hostids = set()
    nics = psutil.net_if_addrs()
    nics.pop('lo') # remove loopback since it doesnt have a real mac address
    for i in nics:
        for j in nics[i]:
            if j.family == 17:    # AF_LINK
                hostids.add(''.join(j.address.split(':')).upper())
    return hostids


class OPServer:
    ''' OP License Server Class.
    '''

    def __init__(self, prog, fg, log_file, log_level):
        global SRV
        self.tcpserver = None
        self.server_name = socket.gethostname()
        self.license_file = ''
        self.lic = None
        self.rowsize = 0
        self.rowlic = ''
        self.psk = b'preshared_license_key'
        self.extra = dict()
        self.feats = dict()
        self.sess = dict()
        self.prog = prog
        self.foreground = fg

        # override log_file option in case of fore_ground mode
        if fg:
            log_file = ''
        self._init_logger(prog, log_file, log_level)

        SRV = self


    def _check_serverid(self):
        ''' return True in case of server ID is not valid '''
        return len(get_hostids() & set(self.extra['serverids'])) == 0


    def _init_logger(self, prog, log_file, log_level):
        ''' initialize log file, level & message format of logger '''
        numeric_level = getattr(logging, log_level.upper(), None)
        self.logger = logging.getLogger(prog)
        self.logger.setLevel(numeric_level)
        formatter = logging.Formatter('%(asctime)s %(name)s [%(levelname)s] %(message)s')
        if log_file:
            # output error messages only to terminal
            handler = logging.StreamHandler()
            handler.setLevel(logging.ERROR)
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)
            # output to log file
            handler = logging.FileHandler(log_file)
            handler.setLevel(numeric_level)
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)
        else:
            # output to terminal
            handler = logging.StreamHandler()
            handler.setLevel(numeric_level)
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)


    def _dump_data(self):
        data = self.lic.data
        self.logger.info('License data:')
        self.logger.info('    Not before : %s', data.not_before.strftime('%Y/%m/%d'))
        self.logger.info('    Not after    : %s', data.not_after.strftime('%Y/%m/%d'))

        extra = self.extra
        self.logger.info('    Host IDs of license server: %s', extra['serverids'])
        #
        hostids = extra.get('hostids')
        if not hostids:
            hostids = 'unlimited'
        #
        self.logger.info('    Servers for software running: %s', hostids)
        #
        version = extra.get('version')
        if not version:
            version = 'unlimited'
        self.logger.info('    Supporting software version: %s', version)
        #
        for feat, cnt in self.feats.items():
            self.logger.info('    Feature: %s (%d)', feat, cnt)

        return


    def start(self, port_number):
        ''' start license server daemon
        '''
        if not self.foreground:
            cid = os.fork()
            # return if not child process.
            if cid:
                return False
        try:
            self.tcpserver = socketserver.TCPServer(
                (self.server_name, port_number),
                OPServerHandler
            )
        except OSError as ose:
            if ose.errno == errno.EADDRINUSE:
                self.logger.error('Port %d already in use. Use another port number.', port_number)
                sys.exit(-1)
            else:
                raise
        signal.signal(signal.SIGTERM, sigterm_handler)
        signal.signal(signal.SIGINT, sigterm_handler)
        try:
            self.logger.info('OP License Server Start on port %d.', port_number)
            self.tcpserver.serve_forever()
        finally:
            self.tcpserver.shutdown()
            self.tcpserver.server_close()
            self.logger.info('OP License Server Stop.')
        return True


    def load_license(self, license_file):
        ''' load the license file and check validation of it.
        '''
        self.logger.info('Loading %s ...', license_file)

        # open license file
        try:
            fid = open(license_file, 'rb')
        except IOError as ioe:
            self.logger.error('I/O error: %s: %s', ioe.strerror, license_file)
            sys.exit(-1)

        # import license file
        try:
            self.lic = License.load(fid, self.psk)
        except License.InvalidSignatureException:
            exc = sys.exc_info()
            self.logger.critical('truepy: %s', str(exc[1]))
            sys.exit(-1)
        fid.close()

        self.license_file = license_file
        self.extra = eval(self.lic.data.extra, {'null' : None})
        self.feats = self.extra['features']

        # dump licenseData
        self._dump_data()

        # checking host ID
        if self._check_serverid():
            self.logger.error(
                'run \'%s\' on valid server has the following host IDs: %s',
                self.prog, repr(self.extra['serverids'])
            )
            sys.exit(-1)

        # load the license file as row data to pass to clients.
        size = os.path.getsize(license_file)
        with open(license_file, 'rb') as fid:
            self.rowsize = size
            self.rowlic = fid.read(size)


    def reload_license(self):
        ''' reload license file (update feature data)
        '''
        self.lic = None
        self.rowsize = 0
        self.rowlic = ''
        self.extra = dict()
        self.feats = dict()
        self.load_license(self.license_file)


    def checkout(self, user, host, feature):
        ''' provide license data for check out request from clients
        '''
        if feature in self.feats:
            sid = uuid.uuid4().hex
            self.sess[sid] = (user, host, feature)
            self.logger.info('co: \'%s\' %s@%s', feature, user, host)
            return sid

        self.logger.warning('Invalid co request: \'%s\' %s@%s', feature, user, host)
        return 'failed'


    def checkin(self, sid):
        ''' license check-in procedure
        '''
        if sid in self.sess:
            user, host, feature = self.sess[sid]
            self.logger.info('ci: \'%s\' %s@%s', feature, user, host)
            del self.sess[sid]
            return 'succeeded'

        self.logger.warning('Invalid session ID: %s', sid)
        return 'failed'
