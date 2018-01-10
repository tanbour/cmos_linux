"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: CfgProc class for processing multiple level cfgs
"""

import os
import copy
from utils import pcom
from utils import env_boot

LOG = pcom.gen_logger(__name__)

class CfgProc(object):
    """cfg processor for op"""
    def __init__(self, blk_name):
        self.ced, self.cfg_dic = env_boot.boot_env(blk_name)
    def proc_cfg(self):
        for proj_cfg in pcom.find_iter(self.ced["PROJ_SHARE_CFG"], "proj_*"):
            cfg_kw = os.path.splitext(os.path.basename(proj_cfg))[0][5:]
            blk_cfg = f"{self.ced['BLK_CFG']}{os.sep}blk_{cfg_kw}.cfg"
            if not os.path.isfile(blk_cfg):
                LOG.warning(f"block config file {blk_cfg} is NA")
            self.cfg_dic[cfg_kw] = pcom.gen_cfg([proj_cfg, blk_cfg])
    def proc_tmp(self):
        for cfg_k, cfg_v in self.cfg_dic.items():
            if cfg_k == "cmn":
                continue
            for proj_tmp in pcom.find_iter(
                    f"{self.ced['PROJ_SHARE_TMP']}{os.sep}{cfg_kw}", "*"):
                tar_file = proj_tmp.replace(
                    self.ced["PROJ_SHARE_TMP"], self.ced["OUTPUT_SRC"])
                pcom.ren_tempfile(
                    proj_tmp, tar_file, {"CED": self.ced, cfg_kw: self.cfg_dic[cfg_kw]})
