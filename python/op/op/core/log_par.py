"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: base class for all log parsing
"""

import os
import re
from utils import pcom

LOG = pcom.gen_logger(__name__)

class LogParser(object):
    """base class of log parser"""
    @classmethod
    def parse_run_log(cls, run_log, run_filter_dic):
        """to parse sub stage run log"""
        if not os.path.isfile(run_log):
            LOG.error(f"log {run_log} to be parsed is NA")
            return {}
        fin_str = run_filter_dic.get("fin_str", "")
        err_kw_lst = run_filter_dic.get("err_kw_lst", [])
        wav_kw_lst = run_filter_dic.get("wav_kw_lst", [])
        log_dic = {}
        with open(run_log, errors="replace") as rlf:
            rl_con = rlf.read()
        if not rl_con:
            LOG.error("log file is empty")
            return {}
        log_dic["fin"] = True if fin_str and fin_str in rl_con else False
        if not err_kw_lst:
            err_lst = []
        else:
            err_exp = "|".join([f".*{c_c}.*" for c_c in err_kw_lst if c_c]).strip("|")
            wav_exp = rf"^$|{'|'.join([re.escape(c_c) for c_c in wav_kw_lst if c_c])}".strip("|")
            err_lst = [c_c for c_c in re.findall(err_exp, rl_con) if not re.search(wav_exp, c_c)]
        if err_lst:
            log_dic["status"] = "failed"
            log_dic["err_lst"] = err_lst
        else:
            log_dic["status"] = "passed"
            log_dic["err_lst"] = []
        return log_dic
