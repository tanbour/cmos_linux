"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: flow related features
"""

import os
import shutil
import subprocess
from utils import pcom
from utils import settings
from utils import env_boot
from core import lib_map

LOG = pcom.gen_logger(__name__)

def exp_stages(s_lst, cfg, sec, p_s=None):
    """to expand stages details of flow config"""
    if sec == "" or p_s == "":
        return s_lst
    pre_flow = pcom.rd_cfg(cfg, sec, "pre_flow", True)
    pre_stage = pcom.rd_cfg(cfg, sec, "pre_stage", True)
    stage_lst = pcom.rd_cfg(cfg, sec, "stages")
    if p_s and p_s not in stage_lst:
        LOG.error(f"stage {p_s} not in flow {sec}")
        raise SystemExit()
    if p_s:
        stage_lst = stage_lst[:stage_lst.index(p_s)+1]
    stage_lst = [
        {"flow": sec, "stage": c_c.split(":")[0].strip(), "sub_stage": c_c.split(":")[-1].strip()}
        for c_c in stage_lst if c_c]
    stage_lst.extend(s_lst)
    return exp_stages(stage_lst, cfg, pre_flow, pre_stage)

class FlowProc(env_boot.EnvBoot, lib_map.LibMap):
    """flow processor for blocks"""
    def __init__(self):
        super().__init__()
        self.boot_env()
        self.ver_dic = {}
        self.oprun_lst = []
        self.opvar_lst = []
    def list_env(self):
        """to list all current project or block op environment variables"""
        LOG.info(":: all op internal env variables")
        pcom.pp_list(self.ced)
    def list_blk(self):
        """to list all possible blocks according to project root dir"""
        blk_ignore_str = "|".join(settings.BLK_IGNORE_LST)
        run_str = f"tree -L 1 -d -I '(|{blk_ignore_str}|)' {self.ced['PROJ_ROOT']}"
        tree_str = subprocess.run(
            run_str, shell=True, check=True, stdout=subprocess.PIPE).stdout.decode()
        LOG.info(":: all available blocks")
        pcom.pp_list(tree_str, True)
    def list_flow(self):
        """to list all current block available flows"""
        LOG.info(":: all current available flows of block")
        flow_dic = {}
        for sec_k, sec_v in self.cfg_dic.get("flow", {}).items():
            flow_dic[sec_k] = pcom.rd_sec(sec_v, "stages")
        pcom.pp_list(flow_dic)
    def init(self, init_lst, parent):
        """to perform flow initialization"""
        for init_name in init_lst:
            LOG.info(":: initializing flow directories ...")
            src_dir = f"{self.ced['BLK_CFG_FLOW']}{os.sep}{parent}"
            dst_dir = f"{self.ced['BLK_CFG_FLOW']}{os.sep}{init_name}"
            if not os.path.isdir(src_dir):
                LOG.error(f"parent flow directory {src_dir} is NA")
                raise SystemExit()
            if os.path.isdir(dst_dir):
                LOG.info(
                    f"initialized flow directory {dst_dir} already exists, "
                    f"please confirm to overwrite the previous flow config and plugins")
                pcom.cfm()
                shutil.rmtree(dst_dir, True)
            shutil.copytree(src_dir, dst_dir)
            LOG.info(f"initializing flow {init_name} done")
    def proc_ver(self):
        """to process class flow version directory"""
        for sec_k, sec_v in self.cfg_dic.get("flow", {}).items():
            self.ver_dic[sec_k] = {}
            for opt_k, opt_v in sec_v.items():
                if not opt_v:
                    continue
                if opt_k.startswith("VERSION_"):
                    ver_key = opt_k.replace("VERSION_", "").lower()
                    key_dir = f"{self.ced['BLK_ROOT']}{os.sep}{ver_key}{os.sep}{opt_v}"
                    if not os.path.isdir(key_dir):
                        LOG.error(
                            f"{ver_key} version dir {key_dir} is NA, "
                            f"defined in flow config section {sec_k}")
                        raise SystemExit()
                    if not os.listdir(key_dir):
                        LOG.error(
                            f"{ver_key} version dir {key_dir} is empty, "
                            f"defined in flow config section {sec_k}")
                        raise SystemExit()
                    self.ver_dic[sec_k][ver_key] = opt_v
    def proc_flow_lst(self, flow_lst):
        """to process flow list from arguments"""
        if not self.blk_flg:
            LOG.error("it's not in a block directory, please cd into one")
            raise SystemExit()
        if not flow_lst:
            flow_lst = ["DEFAULT"]
        for flow in flow_lst:
            if flow not in self.cfg_dic.get("flow", {}):
                LOG.error(f"flow {flow} is NA in flow.cfg")
                raise SystemExit()
            self.proc_flow(flow)
    def proc_flow(self, flow):
        """to process particular flow"""
        v_net = self.ver_dic.get(flow, {}).get("netlist", "")
        if not v_net:
            LOG.error(f"netlist version of flow {flow} is NA in flow.cfg")
            raise SystemExit()
        proj_tmp_dir = self.ced["PROJ_SHARE_TMP"].rstrip(os.sep)
        flow_root_dir = f"{self.ced['BLK_RUN']}{os.sep}v{v_net}{os.sep}{flow}"
        prex_dir_sec = (
            self.cfg_dic["proj"]["prex_dir"]
            if "prex_dir" in self.cfg_dic["proj"] else {})
        prex_dir_dic = {}
        for prex_dir_k in prex_dir_sec:
            prex_dir = pcom.ren_tempstr(
                LOG, pcom.rd_sec(prex_dir_sec, prex_dir_k, True),
                {"flow_root_dir": flow_root_dir})
            pcom.mkdir(LOG, prex_dir)
            prex_dir_dic[prex_dir_k] = prex_dir
        flow_liblist_dir = f"{flow_root_dir}{os.sep}liblist"
        liblist_var_dic = self.gen_liblist(
            self.ced["PROJ_LIB"], flow_liblist_dir,
            self.dir_cfg_dic["lib"]["DEFAULT"]["liblist"],
            self.cfg_dic["lib"][flow] if flow in self.cfg_dic["lib"]
            else self.cfg_dic["lib"]["DEFAULT"])
        pre_stage_dic = {}
        for flow_dic in exp_stages([], self.cfg_dic["flow"], flow):
            flow_name = flow_dic.get("flow", "")
            stage_name = flow_dic.get("stage", "")
            sub_stage_name = flow_dic.get("sub_stage", "")
            tmp_file = os.sep.join([proj_tmp_dir, "flow", stage_name, sub_stage_name])
            if not os.path.isfile(tmp_file):
                LOG.warning(
                    f"template file {tmp_file} is NA, "
                    f"used by flow {flow_name} stage {stage_name}")
                continue
            dst_file = os.sep.join([flow_root_dir, "scripts", stage_name, sub_stage_name])
            LOG.info(f":: generating run file {dst_file} ...")
            local_dic = pcom.ch_cfg(
                self.dir_cfg_dic.get("flow", {}).get(flow_name, {}).get(stage_name, {})).get(
                    sub_stage_name, {})
            stage_dic = {
                "flow": flow_name, "stage": stage_name, "sub_stage": sub_stage_name,
                "flow_root_dir": flow_root_dir, "flow_liblist_dir": flow_liblist_dir,
                "flow_scripts_dir": f"{flow_root_dir}{os.sep}scripts",
                "config_plugins_dir":
                f"{self.ced['BLK_CFG_FLOW']}{os.sep}{flow_name}{os.sep}plugins"}
            for prex_dir_k, prex_dir_v in prex_dir_dic.items():
                if prex_dir_k in stage_dic:
                    continue
                stage_dic[prex_dir_k] = prex_dir_v
            tmp_dic = {
                "global": pcom.ch_cfg(self.cfg_dic["proj"]), "env": self.ced,
                "local": local_dic, "liblist": liblist_var_dic,
                "cur": stage_dic, "pre": pre_stage_dic, "ver": self.ver_dic.get(flow, {})}
            pcom.ren_tempfile(LOG, tmp_file, dst_file, tmp_dic)
            if "_exec_tool" in local_dic:
                with open(f"{dst_file}.oprun", "w") as orf:
                    orf.write(
                        f"{local_dic.get('_exec_tool')} {local_dic.get('_exec_opts', '')} "
                        f"{dst_file}{os.linesep}")
                self.oprun_lst.append(f"{dst_file}.oprun")
            self.opvar_lst.append(
                {"local": local_dic, "cur": stage_dic, "pre": pre_stage_dic,
                 "ver": self.ver_dic.get(flow, {})})
            pre_stage_dic = stage_dic
    def proc_run(self):
        """to process generated oprun files for running flows"""
        if not self.blk_flg:
            LOG.error("it's not in a block directory, please cd into one")
            raise SystemExit()
        for oprun_file in self.oprun_lst:
            stage_str = os.path.basename(os.path.dirname(oprun_file))
            LOG.info(f":: running stage {stage_str}, oprun file {oprun_file} ...")
            subprocess.run(
                f"xterm -title '{oprun_file}' -e 'cd {os.path.dirname(oprun_file)}; "
                f"source {oprun_file} | tee {oprun_file}.log'", shell=True)
    def show_var(self):
        """to show all variables used in templates"""
        LOG.info(f":: all templates used env variables")
        pcom.pp_list(self.opvar_lst)

def run_flow(args):
    """to run flow sub cmd"""
    f_p = FlowProc()
    if args.flow_list_env:
        f_p.list_env()
    elif args.flow_list_blk:
        f_p.list_blk()
    elif args.flow_list_flow:
        f_p.list_flow()
    elif args.flow_init_lst:
        f_p.init(args.flow_init_lst, args.flow_parent)
    elif args.flow_gen_lst != None:
        f_p.proc_ver()
        f_p.proc_flow_lst(args.flow_gen_lst)
    elif args.flow_run_lst != None:
        f_p.proc_ver()
        f_p.proc_flow_lst(args.flow_run_lst)
        f_p.proc_run()
    elif args.flow_show_var_lst != None:
        f_p.proc_ver()
        f_p.proc_flow_lst(args.flow_show_var_lst)
        f_p.show_var()
    else:
        LOG.critical("no actions specified in op flow sub cmd")
        raise SystemExit()
