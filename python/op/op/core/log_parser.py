"""
Author: tsukasa minato @ OnePiece Platform Group
Email: minato@alchip.com
Description: log & report parser
"""

import os
import re
import collections
from jinja2 import Template
from utils import pcom

LOG = pcom.gen_logger(__name__)

class LogParser(object):
    """log & report parser"""

    def __init__(self):
        self.parser_dic = {}
        self.parser = collections.namedtuple(
            'parser', ['path', 'multiline', 'recomp_lst', 'template'])

    def add_parser(self, path, typ, reg_lst, tpl):
        ''' add parser specification '''
        realpath = os.path.realpath(path)
        if not os.path.isfile(realpath):
            LOG.error(f"parsing log file {realpath} is NA")
            raise SystemExit()
        if realpath not in self.parser_dic:
            self.parser_dic[realpath] = []
        multiline = False if typ.lower() == "single" else True
        if reg_lst and isinstance(reg_lst, list):
            recomp_lst = [re.compile(regexp) for regexp in reg_lst if regexp]
        else:
            recomp_lst = multiline = None
        self.parser_dic[realpath].append(self.parser(realpath, multiline, recomp_lst, tpl))

    @classmethod
    def _run_template(cls, tpl_text, raw_dic):
        ''' evaluate template with extracted env '''
        template = Template(tpl_text)
        eval_text = template.render(raw_dic)
        return eval(eval_text)

    @classmethod
    def _update_ext_dic(cls, ext_dic, data):
        ''' update extracted dict with data '''
        ext_dic.update(data)

    def _search_file(self, path, parser_single_lst, parser_multi_lst):
        ''' search pattern for file '''
        LOG.info(f"parsing log file {path}")
        ext_dic = {}
        raw_dic = {"path": path}
        with open(path, 'r') as p_f:
            multi_line = ""
            prev = None
            for line in p_f:
                # match for single
                for parser in parser_single_lst:
                    for recomp in parser.recomp_lst:
                        l_m = recomp.search(line)
                        if l_m:
                            LOG.debug(f"Match: {line}")
                            raw_dic.update(l_m.groupdict())
                            if parser.template:
                                data = self._run_template(parser.template, raw_dic)
                                self._update_ext_dic(ext_dic, data)
                # match for multi-lines
                if not parser_multi_lst:
                    continue
                if prev is None:
                    prev = line
                    continue
                else:
                    multi_line += prev
                    prev = line
                if re.match(r'^[ \t]+\S', line):
                    continue
                for parser in parser_multi_lst:
                    for recomp in parser.recomp_lst:
                        l_m = recomp.search(multi_line)
                        if l_m:
                            LOG.debug(f"Match: {multi_line}")
                            raw_dic.update(l_m.groupdict())
                            if parser.template:
                                data = self._run_template(parser.template, raw_dic)
                                self._update_ext_dic(ext_dic, data)
                multi_line = ""
        return ext_dic

    def run_parser(self):
        ''' run parser specification '''
        ext_dic = {}
        for path, parser_lst in self.parser_dic.items():
            parser_single_lst = []
            parser_multi_lst = []
            for parser in parser_lst:
                if parser.recomp_lst:
                    if not parser.multiline:
                        parser_single_lst.append(parser)
                    else:
                        parser_multi_lst.append(parser)
            if parser_single_lst or parser_multi_lst:
                ext_dic.update(self._search_file(path, parser_single_lst, parser_multi_lst))
        return ext_dic
