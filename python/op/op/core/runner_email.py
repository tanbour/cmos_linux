"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: projects initialization and related features
"""

import os
import datetime as dt
from utils import settings
from utils import pcom
from core import json_converter as jc

LOG = pcom.gen_logger(__name__)

class EmailProc(object):
    """base class of email processor"""
    def proc_local_rpt(self, local_rpt):
        """to process local report and send emails"""
        if not os.path.isfile(local_rpt):
            LOG.error("report file {local_rpt} is NA")
            raise SystemExit()
        user_dic = {}
        dt_str = str(dt.datetime.now())
        with open(local_rpt) as lrf:
            for line in lrf:
                var_dic = {}
                for var_kv in line.split(";"):
                    var_k, var_v = var_kv.split(":", 1)
                    var_dic[var_k.strip()] = var_v.strip()
                if "User" not in var_dic or not var_dic["User"]:
                    LOG.error("no user info provided in line {line} of file {local_rpt}")
                    raise SystemExit()
                if "HOST" not in var_dic or not var_dic["HOST"]:
                    LOG.error("no host info provided in line {line} of file {local_rpt}")
                    raise SystemExit()
                v_user = var_dic["User"]
                v_host = var_dic["HOST"]
                if v_user in user_dic:
                    if v_host in user_dic[v_user]:
                        user_dic[v_user][v_host].append(line)
                    else:
                        user_dic[v_user][v_host] = [line]
                else:
                    user_dic[v_user] = {v_host: [line]}
        for v_user, v_user_dic in user_dic.items():
            for v_host, v_host_lst in v_user_dic.items():
                title_str = (
                    f"[IT][DP] Jobs running more than 15 days on {v_host} {dt_str.split()[0]}")
                info_str = os.linesep.join(v_host_lst)
                con_str = (os.linesep*2).join(
                    [f"Hi {v_user},",
                     f"Please be noticed your job is running more thant 15 days. "
                     f"You need to check if it is useful or not.",
                     f"{info_str}",
                     f"You can use 'otop {v_host}' to check your jobs and ask "
                     f"openlava@alchip.com team to kill it if not useful.",
                     f"---------{os.linesep}Thanks,{os.linesep}Daniel"
                    ])
                fn_str = f"op_local_rpt_{v_user}_{v_host}_{pcom.re_str(dt_str)}"
                jc.JsonConverter(
                    [v_user]+settings.LOCAL_RPT_CMN_LST,
                    title_str, con_str, fn_str).gen_json_file()

def run_email(args):
    """to run init sub cmd"""
    e_p = EmailProc()
    if args.email_local_rpt:
        e_p.proc_local_rpt(args.email_local_rpt)
    else:
        LOG.critical("no actions specified in op email sub cmd")
        raise SystemExit()
