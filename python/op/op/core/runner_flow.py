"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: flow related features
"""

import os
import pprint
import subprocess
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
                LOG.info(f"generating run file {dst_file} ...")
                dst_sec = os.path.basename(proj_tmp)
                if dst_sec in cfg_v:
                    cfg_sec = cfg_v[dst_sec]
                    pcom.ren_tempfile(
                        proj_tmp, dst_file, {"CED": self.ced, "cfg": cfg_sec})
                    if "_exec_tool" in cfg_sec:
                        with open(f"{dst_file}.oprun", "w") as orf:
                            orf.write(
                                f"{cfg_sec.get('_exec_tool')} {cfg_sec.get('_exec_opts', '')} "
                                f"{dst_file}{os.linesep}"
                            )
                    LOG.info("done")
                else:
                    LOG.warning(
                        f"template {proj_tmp} has not corresponding config section {dst_sec} "
                        f"in config {cfg_k}"
                    )
    def proc_run(self, run_lst):
        oprun_file_lst = []
        if run_lst == []:
            oprun_file_lst.extend(list(pcom.find_iter(self.ced["OUTPUT_SRC"], "*.oprun")))
        else:
            for run_kw in run_lst:
                oprun_file_lst.extend(
                    list(pcom.find_iter(f"{self.ced['OUTPUT_SRC']}{os.sep}{run_kw}", "*.oprun")))
        for oprun_file in oprun_file_lst:
            stage_str = os.path.basename(os.path.dirname(oprun_file))
            LOG.info(f"running stage {stage_str}, oprun file {oprun_file} ...")
            subprocess.Popen(
                f"uxterm -title '{oprun_file}' -hold -e 'source {oprun_file}'", shell=True
            )
            LOG.info("done")

def run_flow(args):
    """to run flow sub cmd"""
    if args.flow_block:
        f_p = FlowProc(args.flow_block)
        f_p.proc_cfg()
        if args.flow_list_env:
            f_p.list_env()
        elif args.flow_gen:
            f_p.proc_tmp()
        elif args.flow_run_lst != None:
            f_p.proc_tmp()
            f_p.proc_run(args.flow_run_lst)
    else:
        LOG.critical("op init sub cmd missing main arguments")
        raise SystemExit()
