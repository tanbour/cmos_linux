"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: flow related features
"""

import os
import subprocess
from utils import pcom
from utils import settings
from utils import env_boot
from core import lib_proc

LOG = pcom.gen_logger(__name__)

class FlowProc(env_boot.EnvBoot, lib_proc.LibProc):
    """flow processor for blocks"""
    def __init__(self):
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        lib_proc.LibProc.__init__(self)
    def list_env(self):
        """to list all current project or block op environment variables"""
        LOG.info(f"{os.linesep}all op internal env variables")
        pcom.pp_list(self.ced)
    def list_blk(self):
        """to list all possible blocks according to project root dir"""
        tree_ignore_str = "|".join(settings.TREE_IGNORE_LST)
        run_str = f"tree -L 1 -d -I '(|{tree_ignore_str}|)' {self.ced['PROJ_ROOT']}"
        tree_str = subprocess.run(
            run_str, shell=True, check=True, stdout=subprocess.PIPE).stdout.decode()
        LOG.info(f"{os.linesep}all available blocks")
        pcom.pp_list(tree_str, True)
    def list_stage(self):
        """to list all current project or block available stages"""
        LOG.info(f"{os.linesep}all current available stages")
        stage_dic = {}
        for cfg_k, cfg_v in self.cfg_dic.items():
            if cfg_k == "proj" or cfg_k.startswith("lib_"):
                continue
            cfg_v_lst = list(dict(cfg_v))
            cfg_v_lst.remove("DEFAULT")
            stage_dic[cfg_k] = cfg_v_lst
        pcom.pp_list(stage_dic)
    def proc_tmp(self):
        """to process project and block templates to generate output files"""
        for cfg_k, cfg_v in self.cfg_dic.items():
            if cfg_k == "proj":
                continue
            for proj_tmp in pcom.find_iter(
                    f"{self.ced['PROJ_SHARE_TMP']}{os.sep}{cfg_k}", "*"):
                dst_file = proj_tmp.replace(
                    self.ced["PROJ_SHARE_TMP"], self.ced["OUTPUT_SRC"])
                dst_sec = os.path.basename(proj_tmp)
                if dst_sec in cfg_v:
                    LOG.info(f"generating run file {dst_file} ...")
                    cfg_sec = cfg_v[dst_sec]
                    pcom.ren_tempfile(
                        proj_tmp, dst_file,
                        {"proj": self.cfg_dic.get("proj", {}), "CED": self.ced, "cfg": cfg_sec}
                    )
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
        """to process generated oprun files for running flows"""
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
    f_p = FlowProc()
    if args.flow_list_env:
        f_p.list_env()
    elif args.flow_list_blk:
        f_p.list_blk()
    elif args.flow_list_stage:
        f_p.list_stage()
    elif args.flow_gen:
        f_p.proc_tmp()
    elif args.flow_run_lst != None:
        f_p.proc_tmp()
        f_p.proc_run(args.flow_run_lst)
    else:
        LOG.critical("no actions specified in op flow sub cmd")
        raise SystemExit()
