"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: flow related features
"""

import os
import shutil
import subprocess
from multiprocessing import Pool
from utils import pcom
from utils import settings
from utils import env_boot
from utils import db_if
from core import lib_map
from core import file_proc

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
        self.opvar_lst = []
        self.run_flg = False
        self.force_stage = False
        self.force_dic = False
        self.lib_flg = True
        self.comment = ""
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
        lf_dic = {}
        for sec_k in self.cfg_dic.get("flow", {}):
            lf_lst = []
            for flow_dic in exp_stages([], self.cfg_dic["flow"], sec_k):
                flow_name = flow_dic.get("flow", "")
                stage_name = flow_dic.get("stage", "")
                sub_stage_name = flow_dic.get("sub_stage", "")
                lf_lst.append(f"{flow_name}::{stage_name}:{sub_stage_name}")
            lf_dic[sec_k] = lf_lst
        pcom.pp_list(lf_dic)
    def init(self, init_lst):
        """to perform flow initialization"""
        if not self.blk_flg:
            LOG.error("it's not in a block directory, please cd into one")
            raise SystemExit()
        for init_name in init_lst:
            if init_name == "DEFAULT":
                continue
            LOG.info(f":: initializing flow {init_name} directories ...")
            parent_flow = pcom.rd_cfg(self.cfg_dic.get("flow", {}), init_name, "pre_flow", True)
            if not parent_flow:
                parent_flow = "DEFAULT"
            src_dir = f"{self.ced['BLK_CFG_FLOW']}{os.sep}{parent_flow}"
            dst_dir = f"{self.ced['BLK_CFG_FLOW']}{os.sep}{init_name}"
            if not os.path.isdir(src_dir):
                LOG.error(f"parent flow directory {src_dir} is NA")
                raise SystemExit()
            if os.path.isdir(dst_dir):
                LOG.info(
                    f"initializing flow directory {dst_dir} already exists, "
                    f"please confirm to overwrite the previous flow config and plugins")
                pcom.cfm()
                shutil.rmtree(dst_dir, True)
            shutil.copytree(src_dir, dst_dir)
    def proc_ver(self):
        """to process class flow version directory"""
        for sec_k, sec_v in self.cfg_dic.get("flow", {}).items():
            self.ver_dic[sec_k] = {}
            for opt_k, opt_v in sec_v.items():
                if opt_k.startswith("VERSION_"):
                    ver_key = opt_k.replace("VERSION_", "").lower()
                    if not opt_v:
                        self.ver_dic[sec_k][ver_key] = ""
                    else:
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
            v_rtl = self.ver_dic[sec_k].get("rtl", "")
            v_netlist = self.ver_dic[sec_k].get("netlist", "")
            v_rn = f"r{v_rtl}_n{v_netlist}"
            if not v_rn:
                LOG.error(f"rtl and netlist version of flow {sec_k} are both NA in flow.cfg")
                raise SystemExit()
            self.ver_dic[sec_k]["rtl_netlist"] = v_rn
    def proc_force(self):
        """to process force dic info"""
        if self.force_stage is None:
            self.force_dic = {}
        elif self.force_stage:
            self.force_dic = {}
            self.force_stage = self.force_stage.strip("""'":""")
            err_log_str = (
                "force begin sub-stage format is incorrect, "
                "it should be <flow>::<stage>:<sub_stage>")
            try:
                self.force_dic["flow"], stage_str = self.force_stage.split("::")
                self.force_dic["stage"], self.force_dic["sub_stage"] = stage_str.split(":")
            except ValueError:
                LOG.error(err_log_str)
                raise SystemExit()
            if not all([bool(c_c) for c_c in self.force_dic.values()]):
                LOG.error(err_log_str)
                raise SystemExit()
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
    def proc_prex(self, stage_dic):
        """to process prex defined directory in proj.cfg"""
        prex_dir_sec = (
            self.cfg_dic["proj"]["prex_dir"]
            if "prex_dir" in self.cfg_dic["proj"] else {})
        prex_dir_dic = {}
        for prex_dir_k in prex_dir_sec:
            prex_dir = pcom.ren_tempstr(
                LOG, pcom.rd_sec(prex_dir_sec, prex_dir_k, True), stage_dic)
            pcom.mkdir(LOG, prex_dir)
            prex_dir_dic[prex_dir_k] = prex_dir
        for prex_dir_k, prex_dir_v in prex_dir_dic.items():
            if prex_dir_k in stage_dic:
                continue
            stage_dic[prex_dir_k] = prex_dir_v
    def proc_flow(self, l_flow):
        """to process particular flow"""
        proj_tmp_dir = self.ced["PROJ_SHARE_TMP"].rstrip(os.sep)
        flow_liblist_dir = os.path.join(self.ced["BLK_RUN"], "liblist")
        liblist_var_dic = self.gen_liblist(
            self.ced["PROJ_LIB"], flow_liblist_dir,
            self.dir_cfg_dic["lib"]["DEFAULT"]["liblist"],
            self.cfg_dic["lib"][l_flow] if l_flow in self.cfg_dic["lib"]
            else self.cfg_dic["lib"]["DEFAULT"], self.lib_flg)
        pre_stage_dic = {}
        pre_file_mt = 0.0
        force_flg = False
        flow_if_dic = {
            "flow": l_flow, "block": self.ced["BLK_NAME"], "proj": self.ced["PROJ_NAME"],
            "owner": self.ced["USER"], "created_time": self.ced["DATETIME"].isoformat(),
            "status": "running", "comment": self.comment}
        if self.run_flg:
            db_if.w_flow(flow_if_dic)
        for flow_dic in exp_stages([], self.cfg_dic["flow"], l_flow):
            flow_name = flow_dic.get("flow", "")
            stage_name = flow_dic.get("stage", "")
            sub_stage_name = flow_dic.get("sub_stage", "")
            flow_ver_dic = self.ver_dic.get(flow_name, {})
            flow_ver = flow_ver_dic.get("rtl_netlist", "")
            # force_flg FSM
            if not force_flg:
                if self.force_dic == {} or self.force_dic == {
                        "flow": flow_name, "stage": stage_name,
                        "sub_stage": sub_stage_name}:
                    force_flg = True
            tmp_file = os.path.join(proj_tmp_dir, "flow", stage_name, sub_stage_name)
            if not os.path.isfile(tmp_file):
                LOG.warning(
                    f"template file {tmp_file} is NA, "
                    f"used by flow {flow_name} stage {stage_name}")
                continue
            flow_root_dir = f"{self.ced['BLK_RUN']}{os.sep}{flow_ver}{os.sep}{flow_name}"
            local_dic = pcom.ch_cfg(
                self.dir_cfg_dic.get("flow", {}).get(flow_name, {}).get(stage_name, {})).get(
                    sub_stage_name, {})
            stage_dic = {
                "l_flow": l_flow, "flow": flow_name, "stage": stage_name,
                "sub_stage": sub_stage_name, "flow_root_dir": flow_root_dir,
                "flow_liblist_dir": flow_liblist_dir,
                "flow_scripts_dir": f"{flow_root_dir}{os.sep}scripts",
                "config_plugins_dir":
                f"{self.ced['BLK_CFG_FLOW']}{os.sep}{flow_name}{os.sep}plugins"}
            self.proc_prex(stage_dic)
            self.opvar_lst.append(
                {"local": local_dic, "cur": stage_dic, "pre": pre_stage_dic,
                 "ver": flow_ver_dic})
            tmp_dic = {
                "global": pcom.ch_cfg(self.cfg_dic["proj"]), "env": self.ced,
                "local": local_dic, "liblist": liblist_var_dic,
                "cur": stage_dic, "pre": pre_stage_dic, "ver": flow_ver_dic}
            pre_stage_dic = stage_dic
            multi_inst_lst = [c_c.strip() for c_c in pcom.rd_cfg(
                self.dir_cfg_dic.get("flow", {}).get(flow_name, {}).get(stage_name, {}),
                sub_stage_name, "_multi_inst") if c_c.strip()]
            if not multi_inst_lst:
                multi_inst_lst = [""]
            inst_dic = {
                "stage_dic": stage_dic, "tmp_dic": tmp_dic,
                "tmp_file": tmp_file, "pre_file_mt": pre_file_mt,
                "force_flg": force_flg}
            if self.run_flg:
                try:
                    if settings.DEBUG:
                        file_mt_lst = []
                        for multi_inst in multi_inst_lst:
                            file_mt_lst.append(self.proc_inst(multi_inst, inst_dic))
                    else:
                        with Pool(settings.MP_POOL, initializer=pcom.sig_init) as mip:
                            file_mt_lst = mip.starmap(
                                self.proc_inst,
                                zip(multi_inst_lst, [inst_dic]*len(multi_inst_lst)))
                except KeyboardInterrupt:
                    flow_if_dic["status"] = "failed"
                    db_if.w_flow(flow_if_dic)
                    raise KeyboardInterrupt
                if any([c_c is True for c_c in file_mt_lst if c_c]):
                    flow_if_dic["status"] = "failed"
                    db_if.w_flow(flow_if_dic)
                    raise SystemExit()
                pre_file_mt = max(file_mt_lst)
            else:
                for multi_inst in multi_inst_lst:
                    self.proc_inst(multi_inst, inst_dic)
        if self.run_flg:
            flow_if_dic["status"] = "passed"
            db_if.w_flow(flow_if_dic)
    def proc_inst(self, multi_inst, inst_dic):
        """to process particular inst"""
        flow_root_dir = inst_dic["stage_dic"]["flow_root_dir"]
        flow_name = inst_dic["stage_dic"]["flow"]
        l_flow = inst_dic["stage_dic"]["l_flow"]
        stage_name = inst_dic["stage_dic"]["stage"]
        sub_stage_name = inst_dic["stage_dic"]["sub_stage"]
        tmp_dic = inst_dic["tmp_dic"]
        local_dic = tmp_dic["local"]
        tmp_file = inst_dic["tmp_file"]
        pre_file_mt = inst_dic["pre_file_mt"]
        force_flg = inst_dic["force_flg"]
        file_mt = 0.0
        dst_file = os.path.join(
            flow_root_dir, "scripts", stage_name, multi_inst,
            sub_stage_name) if multi_inst else os.path.join(
                flow_root_dir, "scripts", stage_name, sub_stage_name)
        dst_op_file = os.path.join(
            flow_root_dir, "sum", stage_name, multi_inst,
            f"{sub_stage_name}.op") if multi_inst else os.path.join(
                flow_root_dir, "sum", stage_name, f"{sub_stage_name}.op")
        dst_run_file = f"{dst_op_file}.run"
        pcom.mkdir(LOG, os.path.dirname(dst_file))
        pcom.mkdir(LOG, os.path.dirname(dst_op_file))
        local_dic["_multi_inst"] = multi_inst
        LOG.info(f":: generating file {dst_file} ...")
        pcom.ren_tempfile(LOG, tmp_file, dst_file, tmp_dic)
        if "_exec_cmd" in local_dic:
            tool_str = local_dic.get("_exec_tool", "")
            job_str = (
                f"{local_dic.get('_job_cmd', '')} {local_dic.get('_job_queue', '')} "
                f"{local_dic.get('_job_cpu_number', '')} "
                f"{local_dic.get('_job_resource', '')}"
                if "_job_cmd" in local_dic else "")
            jn_str = (
                f"""{job_str} -J '{self.ced["USER"]}::{flow_name}::"""
                f"""{stage_name}:{sub_stage_name}:{multi_inst}'""") if job_str else ""
            cmd_str = local_dic.get("_exec_cmd", "")
            with open(dst_op_file, "w") as drf:
                drf.write(
                    f"{tool_str}{os.linesep}{cmd_str} {dst_file}{os.linesep}")
            trash_dir = f"{os.path.dirname(dst_op_file)}{os.sep}.trash"
            pcom.mkdir(LOG, trash_dir)
            with open(dst_run_file, "w") as dbf:
                dbf.write(
                    f"{jn_str} xterm -title '{dst_file}' -e 'cd {trash_dir}; "
                    f"source {dst_op_file} | tee {dst_run_file}.log; "
                    f"touch {dst_run_file}.stat'{os.linesep}")
            err_kw_lst = pcom.rd_cfg(
                self.cfg_dic.get("filter", {}), stage_name, "error_keywords_exp")
            wav_kw_lst = pcom.rd_cfg(
                self.cfg_dic.get("filter", {}), stage_name, "waiver_keywords_exp")
            fin_str = self.ced.get("FIN_STR", "")
            filter_dic = {
                "err_kw_lst": err_kw_lst, "wav_kw_lst": wav_kw_lst, "fin_str": fin_str}
            if self.run_flg:
                file_mt = os.path.getmtime(dst_file)
                f_flg = False if file_mt > pre_file_mt else True
                if force_flg:
                    f_flg = True
                if f_flg:
                    # updated timestamp to fit auto-skip feature
                    os.utime(dst_file)
                    # stages followed up have to be forced run
                    file_mt = os.path.getmtime(dst_file)
                file_p = file_proc.FileProc(
                    {"src": dst_file, "file": dst_run_file, "l_flow": l_flow, "flow": flow_name,
                     "stage": stage_name, "sub_stage": sub_stage_name, "multi_inst": multi_inst,
                     "filter_dic": filter_dic, "flow_root_dir": flow_root_dir, "ced": self.ced,
                     "ver_dic": self.ver_dic.get(flow_name, {})}, f_flg)
                p_run = file_p.proc_run_file()
                if p_run is True:
                    return p_run
        return file_mt
    def show_var(self):
        """to show all variables used in templates"""
        if not self.blk_flg:
            LOG.error("it's not in a block directory, please cd into one")
            raise SystemExit()
        LOG.info(":: all templates used variables")
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
        f_p.init(args.flow_init_lst)
    elif args.flow_gen_lst is not None:
        if args.flow_no_lib:
            f_p.lib_flg = False
        f_p.proc_ver()
        f_p.proc_flow_lst(args.flow_gen_lst)
    elif args.flow_run_lst is not None:
        f_p.run_flg = True
        f_p.comment = args.flow_comment
        f_p.force_stage = args.flow_force
        if args.flow_no_lib:
            f_p.lib_flg = False
        f_p.proc_force()
        f_p.proc_ver()
        f_p.proc_flow_lst(args.flow_run_lst)
    elif args.flow_show_var_lst is not None:
        if args.flow_no_lib:
            f_p.lib_flg = False
        f_p.proc_ver()
        f_p.proc_flow_lst(args.flow_show_var_lst)
        f_p.show_var()
    else:
        LOG.critical("no actions specified in op flow sub cmd")
        raise SystemExit()
