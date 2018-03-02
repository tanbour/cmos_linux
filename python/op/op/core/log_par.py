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
    def parse_run_log(cls, run_log, run_exp_dic):
        """to parse sub stage run log"""
        if not os.path.isfile(run_log):
            LOG.warning(f"log {run_log} to be parsed is NA")
            return {}
        exp_err = run_exp_dic.get("exp_err", "")
        if not exp_err:
            LOG.error(f"log parsing error regular expression for {run_log} is NA")
            raise SystemExit()
        log_dic = {}
        with open(run_log, errors="replace") as rlf:
            rl_con = rlf.read()
        if not rl_con:
            LOG.error(f"log file is empty")
            raise SystemExit()
        err_lst = [c_c for c_c in re.findall(exp_err, rl_con) if c_c]
        if err_lst:
            log_dic["status"] = "failed"
            log_dic["err_lst"] = err_lst
        else:
            log_dic["status"] = "passed"
            log_dic["err_lst"] = []
        return log_dic
