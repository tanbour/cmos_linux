"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: signoff db filling and related features
"""

import os
import collections
import copy
from utils import pcom
from utils import env_boot
from utils import db_if

LOG = pcom.gen_logger(__name__)

class SignoffProc(env_boot.EnvBoot):
    """base class of signoff processor"""
    def __init__(self):
        super().__init__()
        self.boot_env()
    def proc_signoff(self, block_lst):
        """proc to perform singoff database filling"""
        so_dic = collections.defaultdict(dict)
        so_dic_lst = []
        signoff_dic_lst = []
        for sec_k, sec_v in self.cfg_dic.get("signoff", {}).items():
            if sec_k != "DEFAULT":
                continue
            for so_k, so_v in sec_v.items():
                so_k_k, so_k_kk = so_k.rsplit("_", 1)
                so_dic[so_k_k.replace("_", "-")][so_k_kk] = so_v
        for so_name, so_data in so_dic.items():
            so_dic_lst.append({"name": so_name, "data": so_data})
        for block_name in block_lst:
            if not os.path.isdir(f"{self.ced['PROJ_ROOT']}{os.sep}{block_name}"):
                LOG.warning("block %s is NA", block_name)
                continue
            LOG.info("collecting block %s signoff items into database", block_name)
            cp_so_dic_lst = copy.deepcopy(so_dic_lst)
            for so_dic in cp_so_dic_lst:
                so_dic["l_user"] = self.ced["USER"]
                so_dic["proj"] = self.ced["PROJ_NAME"]
                so_dic["block"] = block_name
                signoff_dic_lst.append(so_dic)
        LOG.info(":: filling signoff items into op database...")
        db_if.w_signoff(signoff_dic_lst)

def run_signoff(args):
    """to run signoff sub cmd"""
    s_p = SignoffProc()
    if args.signoff_block_lst:
        s_p.proc_signoff(args.signoff_block_lst)
    else:
        LOG.critical("no actions specified in op email sub cmd")
        raise SystemExit()
