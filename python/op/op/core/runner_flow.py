"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: flow related features
"""

import os
import pprint
from utils import pcom
from utils import env_boot

LOG = pcom.gen_logger(__name__)

class FlowProc(env_boot.EnvBoot):
    """flow processor for blocks"""
    def __init__(self, blk_name):
        super(FlowProc, self).__init__(blk_name)
        self.boot_env()
    def list_env(self):
        """to list all current op environment variables"""
        LOG.info(f"{os.linesep}all op internal env variables")
        pprint.pprint(self.ced)
        LOG.info("done")
    def proc_tmp(self):
        """to process project templates to generate output files"""
        for cfg_k, cfg_v in self.cfg_dic.items():
            if cfg_k == "cmn":
                continue
            for proj_tmp in pcom.find_iter(
                    f"{self.ced['PROJ_SHARE_TMP']}{os.sep}{cfg_k}", "*"):
                dst_file = proj_tmp.replace(
                    self.ced["PROJ_SHARE_TMP"], self.ced["OUTPUT_SRC"])
                LOG.info(f"generating run file {dst_file}...")
                dst_sec = os.path.basename(proj_tmp)
                if dst_sec in cfg_v:
                    pcom.ren_tempfile(
                        proj_tmp, dst_file, {"CED": self.ced, "cfg": cfg_v[dst_sec]})
                    LOG.info("done")
                else:
                    LOG.warning(
                        f"template {proj_tmp} has not corresponding config section {dst_sec} "
                        f"in config {cfg_k}"
                    )

def run_flow(args):
    """to run flow sub cmd"""
    if args.flow_block:
        f_p = FlowProc(args.flow_block)
        f_p.proc_cfg()
        if args.flow_gen_tcl:
            f_p.proc_tmp()
        elif args.flow_list_env:
            f_p.list_env()
        elif args.flow_run:
            f_p.proc_tmp()
            f_p.run()
    else:
        LOG.critical("op init sub cmd missing main arguments")
        raise SystemExit()
