"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: CfgProc class for processing multiple level cfgs
"""

import os
from utils import pcom
from utils import env_boot

LOG = pcom.gen_logger(__name__)

class CfgProc(env_boot.EnvBoot):
    """cfg processor for op"""
    def __init__(self, blk_name, admin_flg=False):
        super(CfgProc, self).__init__()
        if admin_flg:
            os.makedirs(f"{self.ced['PROJ_ROOT']}{os.sep}{blk_name}", exist_ok=True)
        self.boot_env(blk_name)
        self.admin_flg = admin_flg
    def proc_cfg(self):
        """to process project and block configs for both user mode and admin mode"""
        for proj_cfg in pcom.find_iter(self.ced["PROJ_SHARE_CFG"], "proj_*", cur_flg=True):
            cfg_kw = os.path.splitext(os.path.basename(proj_cfg))[0][5:]
            blk_cfg = f"{self.ced['BLK_CFG']}{os.sep}blk_{cfg_kw}.cfg"
            if self.admin_flg:
                os.makedirs(os.path.dirname(blk_cfg), exist_ok=True)
                with open(proj_cfg) as pcf, open(blk_cfg, "w") as bcf:
                    for line in pcf:
                        bcf.write(f"# {line}")
            else:
                if not os.path.isfile(blk_cfg):
                    LOG.warning(f"block config file {blk_cfg} is NA")
                self.cfg_dic[cfg_kw] = pcom.gen_cfg([proj_cfg, blk_cfg])
    def proc_tmp(self):
        """to process project templates to generate output files"""
        for cfg_k, cfg_v in self.cfg_dic.items():
            if cfg_k == "cmn":
                continue
            for proj_tmp in pcom.find_iter(
                    f"{self.ced['PROJ_SHARE_TMP']}{os.sep}{cfg_k}", "*"):
                tar_file = proj_tmp.replace(
                    self.ced["PROJ_SHARE_TMP"], self.ced["OUTPUT_SRC"])
                pcom.ren_tempfile(
                    proj_tmp, tar_file, {"CED": self.ced, "cfg": cfg_v})
