"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: flow related features
"""

import os
from utils import pcom
from utils import env_boot

LOG = pcom.gen_logger(__name__)

class FlowProc(env_boot.EnvBoot):
    """flow processor for blocks"""
    def __init__(self, args):
        super(FlowProc, self).__init__(args.flow_block)
    def proc_tmp(self):
        """to process project templates to generate output files"""
        for cfg_k, cfg_v in self.cfg_dic.items():
            if cfg_k == "cmn":
                continue
            for proj_tmp in pcom.find_iter(
                    f"{self.ced['PROJ_SHARE_TMP']}{os.sep}{cfg_k}", "*"):
                dst_file = proj_tmp.replace(
                    self.ced["PROJ_SHARE_TMP"], self.ced["OUTPUT_SRC"])
                pcom.ren_tempfile(
                    proj_tmp, dst_file, {"CED": self.ced, "cfg": cfg_v})

def run_flow(args):
    """to run flow sub cmd"""
    if args.flow_block:
        f_p = FlowProc(args.flow_block)
        f_p.proc_cfg()
        if args.flow_gen_tcl:
            f_p.proc_tmp()
    else:
        LOG.critical("op init sub cmd missing main arguments")
        raise SystemExit()
