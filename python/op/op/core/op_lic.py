#!/usr/bin/env python3
'''
OP license client module
'''

import os
import sys
import re
import json
import getpass
import tempfile
import socket
from textwrap import dedent
from datetime import datetime
from struct import unpack
import psutil
from truepy import License
from utils import pcom

LOG = pcom.gen_logger(__name__)

OP_VERSION = '4.0.0'

PSK = b'preshared_license_key'
CERTS = ('''
    -----BEGIN CERTIFICATE-----
    MIIF9zCCA9+gAwIBAgIJAP4YDA+61z+ZMA0GCSqGSIb3DQEBBQUAMIGRMQswCQYD
    VQQGEwJ6aDERMA8GA1UECAwIU2hhbmdoYWkxETAPBgNVBAcMCFNoYW5naGFpMQ8w
    DQYDVQQKDAZBbGNoaXAxCzAJBgNVBAsMAkRQMRkwFwYDVQQDDBBvcC5hbGNoaXAu
    Y29tLmNuMSMwIQYJKoZIhvcNAQkBFhRndWFueXVfeWlAYWxjaGlwLmNvbTAeFw0x
    ODA0MTMwNzUwMzlaFw0yODAxMTYwNzUwMzlaMIGRMQswCQYDVQQGEwJ6aDERMA8G
    A1UECAwIU2hhbmdoYWkxETAPBgNVBAcMCFNoYW5naGFpMQ8wDQYDVQQKDAZBbGNo
    aXAxCzAJBgNVBAsMAkRQMRkwFwYDVQQDDBBvcC5hbGNoaXAuY29tLmNuMSMwIQYJ
    KoZIhvcNAQkBFhRndWFueXVfeWlAYWxjaGlwLmNvbTCCAiIwDQYJKoZIhvcNAQEB
    BQADggIPADCCAgoCggIBAMl+l/f5bUgNknDXEne/tTZaCAXSEsfBJTGRZ1xrYsnG
    xaQ854JJsZRDrQTa/M+HC88ZWOFAHvIbLO4e44eqM3HdFB0BMbeywDaQChlZsbb2
    H0wlW6StpU+HJb1mmKPKjNnsG/4bJfxen2C1+3zE4b2uizSWGB92WFokOPr5aL+y
    Q47t+eaP2aNvvZ2dJ2LOUSdr3soDXI+gXka9kiaOrzaTHblBdj2ImjqC2qQVeF+S
    lI/BPV5m9g5mfvE1Pg8bWisyWKgmQXQKwIz8TtYgqzdV7hlmeZvlx78v1JqT8rhc
    DAmekAkddPvpClx3Ud2e4pFLGXxpp27xyVeCjeOxGPnxwbW57CHmo0NsxQPntseP
    dBuIMd7va+htnhWc4s4j9492h1wMnVDaYei7tCXzNMB2Tm+NWfow/O1XtGANKgxU
    YHhhn7cORAFNbyh04uo/IxzcQCRdDHjkTG9Mss9ZTr0feuRL/RXYTAIwz5jYfidJ
    U9ieEbt8WjKjOF6GAy4be7uK+1VVM2aTNx3xG2elm3/VTWjPY26g9BBUNYGAYqwk
    yFXSAIoJGcGO5CqJV1PXba2ck6pEIrAbdzXexlqnEW4G2obtV32aQAbvavEfEy+C
    aVEbDV1hTrEs+WYBa49w5+gzG6IoJrCCxBrCQJ9rPBic6tw1eKJ5arXSCq7/rZ3j
    AgMBAAGjUDBOMB0GA1UdDgQWBBTYm7FlhfvNrnWgTrAzdQ0oXsMZazAfBgNVHSME
    GDAWgBTYm7FlhfvNrnWgTrAzdQ0oXsMZazAMBgNVHRMEBTADAQH/MA0GCSqGSIb3
    DQEBBQUAA4ICAQAlQrOh6KNmw8mxugxQaDVmC1BLH/hu+Th4/ZEhHNCyw+U9av5O
    A7EecKOtKmLAXF8IjQNg8oatmOlCcj315Iiz8wnjFBZW1ZFi5P4SsMfmCEOgCHJB
    +mjGTMyqzWFOpCiCt15Nesg73uI5Hj4crYc2/zFve9d3r8nwkeA3BsUFbDO/2jnk
    oPLtwj4Lyj2bfRiqSBo4ODWF1rnIlvoFPm8naVDiElWBSeKu/gD8e0QZRj2p1o5N
    3kE1Cojn72XIbBQAVJR8WhY04iTg3fvxykHpL5JsXZD+mRvA72B39JZJqQc2UYyj
    6qLMgm0LSx5lFOOtLrzc3YoiZRcPdgVRt7IOriSRAwZRyszWvzfCOPllO47pWBkx
    HvvtEoz6ZKMM808xuTdhcpulSzw+cmI/HuCWkgo/IbfVnUBJaHgZcUZ/9jJaykD4
    15phFLJyKzNo2BFv2XaRAIGrfQUz1DxoJgusKfpz1o7zH/3RGcneCDwgX8XWBBCt
    pU5wFmv5mTy5fCmHy/fJafFNqEmq/2l229s8DUHzjpIQ74hRV4YQZM50yMShhROr
    CFAWN6hRAxKol2tdlsTagL3rZJ8Lo0NCtiGiMRmu/79yeR8cgWe1OdvlEPFuaj7G
    CCo+1iDchPoSs4bODTs5qVy6Ei0LFfhdh7bJIf1FVUpvoOj5yixp92QgDQ==
    -----END CERTIFICATE-----
''', )


def lrecv(sock, length):
    ''' receive a message via socket '''
    data = sock.recv(length)
    LOG.debug('lrecv: %s', repr(data))
    if data == '':
        LOG.error('got unexpected EOF from %s', repr(sock.getpeername()))
        raise SystemExit(-1)
    return data

def lsend(sock, data):
    ''' send a message via socket '''
    LOG.debug('lsend: %s', repr(data))
    return sock.sendall(data)

def lget_license(sock):
    ''' get license data from the server which is connecting sock '''
    lengthb = lrecv(sock, 1024)
    length = unpack('i', lengthb)[0]
    lsend(sock, b'ack')
    lic = lrecv(sock, length)
    # create local license file and check it
    temp = tempfile.TemporaryFile()
    temp.write(lic)
    temp.seek(0)
    return License.load(temp, PSK)

def lget_hostids():
    ''' getting list of host IDs of the running server '''
    hostids = set()
    nics = psutil.net_if_addrs()
    nics.pop('lo') # remove loopback since it doesnt have a real mac address
    for i in nics:
        for j in nics[i]:
            if j.family == 17:  # AF_LINK
                hostids.add(''.join(j.address.split(':')).upper())
    return hostids


class OPClient:
    ''' OP license check-out, verify and check-in '''

    def __init__(self):
        self.license = None
        self.license_extra = None
        self.license_server = None
        self.license_sid = None

    def set_license_server(self, op_license=None):
        ''' parse license server specification and store them '''
        if op_license is None:
            if 'OP_LICENSE' in os.environ:
                op_license = os.environ['OP_LICENSE']
            else:
                LOG.error('\'OP_LICENSE\' env. is not defined.')
                raise SystemExit(-1)
        mat = re.match(r'^(\d+)@([.\w]+)$', op_license)
        if not mat:
            LOG.error(f'invalid server specification: {op_license}')
            raise SystemExit(-1)
        self.license_server = (mat[2], int(mat[1]))
        return


    def _connect(self):
        ''' connect to license server and return the socket '''
        if not hasattr(self, 'license_server'):
            self.set_license_server()
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            sock.connect(self.license_server)
        except:
            LOG.error(f'connection refused by the license server: {self.license_server}')
            raise SystemExit(-1)
        return sock


    def __verify_date(self):
        data = self.license.data
        now = datetime.now()
        if data.not_after > now > data.not_before:
            return True
        LOG.error('fail to verify date.')
        return False

    def __verify_hostid(self):
        extra = self.license_extra
        if extra['hostids'] is None or (set(extra['hostids']) & lget_hostids()):
            return True
        LOG.error('fail to verify hostid.')
        return False

    def __verify_version(self):
        extra = self.license_extra
        op_version = globals().get('OP_VERSION', '4.0')
        mat = re.match(r'\d*\.\d*', op_version)
        current = float(mat[0])
        if extra['version'] is None or float(extra['version']) > current:
            return True
        LOG.error('fail to verify version.')
        return False

    def _verify_license(self):
        ''' verify licesne with CERTS '''
        for cert in CERTS:
            try:
                self.license.verify(dedent(cert).encode())
                return self.__verify_date() and self.__verify_hostid() and self.__verify_version()
            except License.InvalidSignatureException:
                continue
        # no certificate to match the license (the license is invalid)
        return False


    def checkout_license(self, feature='OnePiece4'):
        ''' try to checkout license. if it fails, terminate the software '''
        sock = self._connect()
        cmd = 'co %s %s %s'%(getpass.getuser(), socket.gethostname(), feature)
        lsend(sock, cmd.encode())

        # store provided license session ID
        self.license_sid = lrecv(sock, 1024).decode()
        lsend(sock, b'ack')

        # checkout license
        self.license = lget_license(sock)
        self.license_extra = json.loads(self.license.data.extra)
        sock.close()
        LOG.info('license check-out: succeeded')

        # verify license
        if not self._verify_license():
            LOG.error('license verification failed.')
            self.checkin_license()
            sys.exit(-1)

        return True


    def checkin_license(self):
        ''' checkin license. '''
        sock = self._connect()
        cmd = 'ci %s' % self.license_sid
        lsend(sock, cmd.encode())
        msg = lrecv(sock, 1024).decode()
        sock.close()
        LOG.debug(f'license check-in: {msg}')


if __name__ == '__main__':
    import time

    CL = OPClient()

    CL.set_license_server('3661@op.alchip.com.cn')
    CL.checkout_license()

    time.sleep(5)

    CL.checkin_license()

# eof
