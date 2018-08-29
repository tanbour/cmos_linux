"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: flow related features
"""

import os
import shutil
import subprocess
import json
from fnmatch import fnmatch
from difflib import unified_diff
from filecmp import cmp, dircmp
from multiprocessing import Pool
from utils import pcom
from utils import settings
from utils import env_boot
from utils import db_if
from core import lib_map
from core import file_proc

LOG = pcom.gen_logger(__name__)

def diff_files(dcmp):
    """listing file diff"""
    for left_only in dcmp.left_only:
        LOG.info("only in block config dir.: %s%s%s", dcmp.left, os.sep, left_only)
    for right_only in dcmp.right_only:
        LOG.info("only in proj config dir. : %s%s%s", dcmp.right, os.sep, right_only)
    for name in dcmp.diff_files:
        proj_file = f"{dcmp.right}{os.sep}{name}"
        blk_file = f"{dcmp.left}{os.sep}{name}"
        LOG.info("diff %s ...", blk_file)
        with open(proj_file) as pff, open(blk_file) as bff:
            if fnmatch(name, '*.cfg'):
                proj_file_lines = pcom.gen_pcf_lst(pff)
            else:
                proj_file_lines = pff.readlines()
            blk_file_lines = bff.readlines()
            os.sys.stdout.writelines(
                unified_diff(proj_file_lines, blk_file_lines, fromfile=proj_file, tofile=blk_file))
    for sub_dcmp in dcmp.subdirs.values():
        diff_files(sub_dcmp)

def internal_diff_tool(blk_dir, proj_dir):
    """ internal merging tool """
    dcmp = dircmp(blk_dir, proj_dir)
    diff_files(dcmp)

class FlowProc(env_boot.EnvBoot, lib_map.LibMap):
    """flow processor for blocks"""
    def __init__(self, cfm_yes=False):
        super().__init__()
        self.boot_env()
        self.opvar_lst = []
        self.run_flg = False
        self.force_stage = False
        self.force_dic = False
        self.begin_stage = ""
        self.begin_dic = {}
        self.end_stage = ""
        self.end_dic = {}
        self.restore_stage = ""
        self.restore_dic = {}
        self.comment = ""
        self.cfm_yes = cfm_yes
        self.cfm_flg = False
    def exp_stages_misc(self, s_lst, s_ver_dic, s_err_lst, cfg, sec, p_s=None):
        """to expand stages and misc details of flow config"""
        if sec == "" or p_s == "":
            v_rtl = s_ver_dic.get("rtl", "")
            v_netlist = s_ver_dic.get("netlist", "")
            if not v_rtl and not v_netlist:
                s_err_lst.append("!!!! rtl and netlist version are both NA")
            v_rn = f"r{v_rtl}_n{v_netlist}"
            s_ver_dic['rtl_netlist'] = v_rn
            return s_lst, s_ver_dic, s_err_lst
        if not os.path.isdir(f"{self.ced['BLK_CFG_FLOW']}{os.sep}{sec}"):
            s_err_lst.insert(0, f"!!!! flow {sec} not initialized")
        pre_flow = pcom.rd_cfg(cfg, sec, "pre_flow", True)
        pre_stage = pcom.rd_cfg(cfg, sec, "pre_stage", True)
        stage_lst = pcom.rd_cfg(cfg, sec, "stages")
        for opt_k, opt_v in cfg[sec].items():
            if opt_k.startswith("VERSION_"):
                ver_key = opt_k.replace("VERSION_", "").lower()
                if not opt_v:
                    s_ver_dic[ver_key] = ""
                else:
                    key_dir = f"{self.ced['BLK_ROOT']}{os.sep}{ver_key}{os.sep}{opt_v}"
                    if not os.path.isdir(key_dir):
                        s_err_lst.append(f"!!!! {ver_key} version dir {key_dir} is NA")
                    if not os.listdir(key_dir):
                        s_err_lst.append(f"!!!! {ver_key} version dir {key_dir} is empty")
                    if not s_ver_dic.get(ver_key):
                        s_ver_dic[ver_key] = opt_v
            if opt_k == "LIB" and not s_ver_dic.get("LIB"):
                s_ver_dic["LIB"] = opt_v
        if p_s:
            if p_s not in stage_lst:
                s_err_lst.append(f"!!!! stage {p_s} not in flow {sec}")
            else:
                stage_lst = stage_lst[:stage_lst.index(p_s)+1]
        stage_lst = [
            {"flow": sec, "stage": c_c.split(":")[0].strip(),
             "sub_stage": c_c.split(":")[-1].strip()}
            for c_c in stage_lst if c_c]
        stage_lst.extend(s_lst)
        return self.exp_stages_misc(stage_lst, s_ver_dic, s_err_lst, cfg, pre_flow, pre_stage)
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
    def check_flow_config(self):
        """get all information of flow config"""
        stage_dic_lst_dic = {}
        ver_dic_dic = {}
        err_lst_dic = {}
        for sec_k in self.cfg_dic.get("flow", {}):
            stage_dic_lst_dic[sec_k], ver_dic_dic[sec_k], err_lst_dic[sec_k] = (
                self.exp_stages_misc([], {}, [], self.cfg_dic.get("flow", {}), sec_k))
        return stage_dic_lst_dic, ver_dic_dic, err_lst_dic
    def list_flow(self):
        """to list all current block available flows"""
        if not self.blk_flg:
            LOG.error("it's not in a block directory, please cd into one")
            raise SystemExit()
        LOG.info(":: all current available flows of block")
        lf_dic = {}
        for sec_k in self.cfg_dic.get("flow", {}):
            stage_dic_lst, ver_dic, err_lst = self.exp_stages_misc(
                [], {}, [], self.cfg_dic.get("flow", {}), sec_k)
            v_rn = ver_dic.get('rtl_netlist')
            lf_lst = ["---------- flow stages ----------"]
            lf_time_lst = [0]
            for flow_dic in stage_dic_lst:
                flow_name = flow_dic.get("flow", "")
                stage_name = flow_dic.get("stage", "")
                sub_stage_name = flow_dic.get("sub_stage", "")
                lf_lst.append(f"     {flow_name}::{stage_name}:{sub_stage_name}")
                run_dir = self.ced['BLK_RUN']
                multi_inst_lst = [c_c.strip() for c_c in pcom.rd_cfg(
                    self.dir_cfg_dic.get("flow", {}).get(flow_name, {}).get(stage_name, {}),
                    sub_stage_name, '_multi_inst') if c_c.strip()]
                if multi_inst_lst:
                    tmp_list = []
                    for multi_inst in multi_inst_lst:
                        dst_file = os.path.join(
                            run_dir, v_rn, flow_name, "scripts",
                            stage_name, multi_inst, sub_stage_name)
                        tmp_list.append(
                            os.path.getmtime(dst_file) if os.path.exists(dst_file) else 0)
                    lf_time_lst.append(max(tmp_list))
                else:
                    dst_file = os.path.join(
                        run_dir, v_rn, flow_name, "scripts", stage_name, sub_stage_name)
                    lf_time_lst.append(
                        os.path.getmtime(dst_file) if os.path.exists(dst_file) else 0)
            max_time_index = lf_time_lst.index(max(lf_time_lst))
            if max_time_index:
                lf_lst[max_time_index] = '(->) ' + lf_lst[max_time_index].strip()
            lf_lst.append("---------- flow misc ----------")
            lf_ver_dic = {
                k_k: v_v for k_k, v_v in ver_dic.items()
                if k_k != "LIB" and k_k != "rtl_netlist" and v_v}
            lf_lst.append({"LIB": ver_dic.get("LIB", ""), "VERSIONS": lf_ver_dic})
            if err_lst:
                err_lst.insert(0, "---------- DEFECT ----------")
                err_lst.extend(lf_lst)
                lf_dic[f"{sec_k} (X)"] = err_lst
            else:
                lf_dic[sec_k] = lf_lst
        pcom.pp_list(lf_dic)
    def list_diff(self, flow_name='DEFAULT'):
        """toggle to demonstrate the diff between block level config/plugins
           and proj level config/plugins"""
        if not self.blk_flg:
            LOG.error("it's not in a block directory, please cd into one")
            raise SystemExit()
        LOG.info(":: diff list for the flows ...")
        proj_cfg_dir = self.ced["PROJ_SHARE_CFG"].rstrip(os.sep)
        blk_cfg_dir = self.ced["BLK_CFG"].rstrip(os.sep)
        LOG.info('proj config dir: %s', proj_cfg_dir)
        LOG.info('block config dir: %s', blk_cfg_dir)
        # diff listing for config files
        for cfg_kw in self.cfg_dic:
            if cfg_kw in settings.BLK_CFG_UNFILL_LST:
                continue
            proj_cfg = f"{proj_cfg_dir}{os.sep}{cfg_kw}.cfg"
            blk_cfg = f"{blk_cfg_dir}{os.sep}{cfg_kw}.cfg"
            if not os.path.isfile(blk_cfg):
                LOG.warning("only in proj config dir: %s", proj_cfg)
                continue
            with open(proj_cfg) as pcf, open(blk_cfg) as bcf:
                proj_cfg_lines = pcom.gen_pcf_lst(pcf)
                blk_cfg_lines = bcf.readlines()
                LOG.info('diff %s ...', blk_cfg)
                os.sys.stdout.writelines(
                    unified_diff(proj_cfg_lines, blk_cfg_lines, fromfile=proj_cfg, tofile=blk_cfg))
        # diff listing for config dirs
        for dir_cfg_kw in self.dir_cfg_dic:
            if dir_cfg_kw == "lib":
                continue
            proj_dir_cfg = f"{proj_cfg_dir}{os.sep}{dir_cfg_kw}"
            blk_dir_cfg = f"{blk_cfg_dir}{os.sep}{dir_cfg_kw}{os.sep}{flow_name}"
            LOG.info("diff block config dir. %s", blk_dir_cfg)
            internal_diff_tool(blk_dir_cfg, proj_dir_cfg)
    def init(self, init_lst):
        """to perform flow initialization"""
        if not self.blk_flg:
            LOG.error("it's not in a block directory, please cd into one")
            raise SystemExit()
        for init_name in init_lst:
            LOG.info(":: initializing flow %s directories ...", init_name)
            parent_flow = pcom.rd_cfg(self.cfg_dic.get("flow", {}), init_name, "pre_flow", True)
            if parent_flow:
                src_dir = f"{self.ced['BLK_CFG_FLOW']}{os.sep}{parent_flow}"
                LOG.info("inheriting from %s", parent_flow)
            else:
                src_dir = f"{self.ced['PROJ_SHARE_CFG']}{os.sep}flow"
                LOG.info("inheriting from project share")
            dst_dir = f"{self.ced['BLK_CFG_FLOW']}{os.sep}{init_name}"
            if not os.path.isdir(src_dir):
                LOG.error("parent flow directory %s is NA", src_dir)
                raise SystemExit()
            if os.path.isdir(dst_dir):
                if self.cfm_yes:
                    LOG.warning(
                        "initializing flow directory %s already exists, "
                        "confirmed to overwrite the previous flow config and plugins", dst_dir)
                else:
                    LOG.info(
                        "initializing flow directory %s already exists, "
                        "please confirm to overwrite the previous flow config and plugins", dst_dir)
                    pcom.cfm()
                shutil.rmtree(dst_dir, True)
            shutil.copytree(src_dir, dst_dir)
            if not parent_flow:
                for blk_cfg in pcom.find_iter(dst_dir, "*.cfg", cur_flg=True):
                    with open(blk_cfg) as ocf:
                        blk_lines = pcom.gen_pcf_lst(ocf)
                    with open(blk_cfg, "w") as ncf:
                        for line in blk_lines:
                            ncf.write(line)
    def proc_force(self):
        """to process force dic info"""
        if self.force_stage is None:
            self.force_dic = {}
        elif self.force_stage:
            self.force_dic = {}
            self.force_stage = self.force_stage.strip("""'":""")
            err_log_str = (
                "force sub-stage format is incorrect, "
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
    def proc_begin(self):
        """to process begin info"""
        if self.begin_stage:
            self.begin_stage = self.begin_stage.strip("""'":""")
            err_log_str = (
                "begin sub-stage format is incorrect, "
                "it should be <flow>::<stage>:<sub_stage>")
            try:
                self.begin_dic["flow"], stage_str = self.begin_stage.split("::")
                self.begin_dic["stage"], self.begin_dic["sub_stage"] = stage_str.split(":")
            except ValueError:
                LOG.error(err_log_str)
                raise SystemExit()
            if not all([bool(c_c) for c_c in self.begin_dic.values()]):
                LOG.error(err_log_str)
                raise SystemExit()
    def proc_end(self):
        """to process end info"""
        if self.end_stage:
            self.end_stage = self.end_stage.strip("""'":""")
            err_log_str = (
                "end sub-stage format is incorrect, "
                "it should be <flow>::<stage>:<sub_stage>")
            try:
                self.end_dic["flow"], stage_str = self.end_stage.split("::")
                self.end_dic["stage"], self.end_dic["sub_stage"] = stage_str.split(":")
            except ValueError:
                LOG.error(err_log_str)
                raise SystemExit()
            if not all([bool(c_c) for c_c in self.end_dic.values()]):
                LOG.error(err_log_str)
                raise SystemExit()
    def proc_restore(self):
        """to process restore info"""
        restore_flow = ""
        if self.restore_stage:
            self.restore_stage = self.restore_stage.strip("""'":""")
            err_log_str = (
                "restore sub-stage format is incorrect, "
                "it should be <flow>::<stage>:<sub_stage>")
            try:
                self.restore_dic["flow"], stage_str = self.restore_stage.split("::")
                self.restore_dic["stage"], self.restore_dic["sub_stage"] = stage_str.split(":")
            except ValueError:
                LOG.error(err_log_str)
                raise SystemExit()
            if not all([bool(c_c) for c_c in self.restore_dic.values()]):
                LOG.error(err_log_str)
                raise SystemExit()
            restore_flow = self.restore_dic["flow"]
        if not restore_flow:
            LOG.error("restore flow and stage name is NA")
            raise SystemExit()
        return restore_flow
    def proc_release(self, flow_release_lst):
        """to process release info"""
        relz_blk_json_dir = f"{self.ced['PROJ_RELEASE_TO_TOP']}{os.sep}.json"
        pcom.mkdir(LOG, relz_blk_json_dir)
        for flow_release in flow_release_lst:
            flow_release = flow_release.strip("""'":""")
            err_log_str = (
                "begin sub-stage format is incorrect, "
                "it should be <flow>::<stage>:<sub_stage>")
            flow_relz_dic = {}
            try:
                flow_relz_dic["flow"], stage_str = flow_release.split("::")
                flow_relz_dic["stage"], flow_relz_dic["sub_stage"] = stage_str.split(":")
            except ValueError:
                LOG.error(err_log_str)
                raise SystemExit()
            if not all([bool(c_c) for c_c in flow_relz_dic.values()]):
                LOG.error(err_log_str)
                raise SystemExit()
            _, ver_dic, err_lst = self.exp_stages_misc(
                [], {}, [], self.cfg_dic.get("flow", {}), flow_relz_dic["flow"])
            if err_lst:
                LOG.error("flow %s has the following errors in flow.cfg", flow_relz_dic["flow"])
                pcom.pp_list(err_lst)
                raise SystemExit()
            flow_relz_dic["user"] = self.ced["USER"]
            flow_relz_dic["block"] = self.ced["BLK_NAME"]
            flow_relz_dic["time"] = self.ced["DATETIME"].isoformat()
            flow_relz_dic["rtl_netlist"] = ver_dic.get("rtl_netlist", "")
            flow_relz_dic["proj_root"] = self.ced["PROJ_ROOT"]
            file_name = pcom.re_str("_".join(
                [flow_relz_dic["user"], flow_relz_dic["block"], flow_release]))
            relz_json_file = f"{relz_blk_json_dir}{os.sep}{file_name}.json"
            if os.path.isfile(relz_json_file):
                if self.cfm_yes:
                    LOG.info(
                        "flow %s already released, confimed to overwrite", flow_release)
                else:
                    LOG.info(
                        "flow %s already released, please confirm to overwrite", flow_release)
                    pcom.cfm()
            with open(relz_json_file, "w") as rjf:
                json.dump(flow_relz_dic, rjf)
            LOG.info("flow %s released", flow_release)
    def proc_flow_lst(self, flow_lst):
        """to process flow list from arguments"""
        if not self.blk_flg:
            LOG.error("it's not in a block directory, please cd into one")
            raise SystemExit()
        if not flow_lst:
            flow_lst = ["DEFAULT"]
        for flow in flow_lst:
            if flow not in self.cfg_dic.get("flow", {}):
                LOG.error("flow %s is NA in flow.cfg", flow)
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
        liblist_var_dic = (
            self.load_liblist(self.ced["PROJ_LIB"], self.dir_cfg_dic["lib"]["DEFAULT"])
            if self.ced["PROJ_LIB"] else {})
        pre_stage_dic = {}
        pre_file_mt = 0.0
        force_flg = False
        flow_if_dic = {
            "flow": l_flow, "block": self.ced["BLK_NAME"], "proj": self.ced["PROJ_NAME"],
            "owner": self.ced["USER"], "created_time": self.ced["DATETIME"].isoformat(),
            "status": "running", "comment": self.comment}
        if self.run_flg:
            db_if.w_flow(flow_if_dic)
        flow_dic_lst, flow_ver_dic, flow_err_lst = self.exp_stages_misc(
            [], {}, [], self.cfg_dic.get("flow", {}), l_flow)
        if flow_err_lst:
            LOG.error("flow %s has the following errors in flow.cfg", l_flow)
            pcom.pp_list(flow_err_lst)
            raise SystemExit()
        signoff_dic = pcom.ch_cfg(self.cfg_dic.get("signoff", {})).get("DEFAULT", {})
        if self.force_dic and self.force_dic not in flow_dic_lst:
            LOG.error("force stage %s not in flow %s", self.force_dic, l_flow)
            raise SystemExit()
        if self.begin_dic and self.begin_dic not in flow_dic_lst:
            LOG.error("begin stage %s not in flow %s", self.begin_dic, l_flow)
            raise SystemExit()
        if self.end_dic and self.end_dic not in flow_dic_lst:
            LOG.error("end stage %s not in flow %s", self.end_dic, l_flow)
            raise SystemExit()
        if self.restore_dic and self.restore_dic not in flow_dic_lst:
            LOG.error("restore stage %s not in flow %s", self.restore_dic, l_flow)
            raise SystemExit()
        for flow_dic in flow_dic_lst:
            flow_name = flow_dic.get("flow", "")
            stage_name = flow_dic.get("stage", "")
            sub_stage_name = flow_dic.get("sub_stage", "")
            flow_ver = flow_ver_dic.get("rtl_netlist", "")
            flow_lib = flow_ver_dic.get("LIB", "")
            if not flow_lib:
                LOG.warning("option 'LIB' is NA in section %s of flow.cfg", l_flow)
            elif flow_lib not in liblist_var_dic:
                LOG.warning(
                    "flow LIB %s is not matched with any process of lib/process.cfg", flow_lib)
            # force_flg FSM
            if not force_flg:
                if self.force_dic == {} or self.force_dic == {
                        "flow": flow_name, "stage": stage_name,
                        "sub_stage": sub_stage_name}:
                    force_flg = True
            tmp_file = os.path.join(proj_tmp_dir, "flow", stage_name, sub_stage_name)
            if not os.path.isfile(tmp_file):
                LOG.warning(
                    "template file %s is NA, "
                    "used by flow %s stage %s", tmp_file, flow_name, stage_name)
                continue
            flow_root_dir = f"{self.ced['BLK_RUN']}{os.sep}{flow_ver}{os.sep}{flow_name}"
            local_dic = pcom.ch_cfg(
                self.dir_cfg_dic.get("flow", {}).get(flow_name, {}).get(stage_name, {})).get(
                    sub_stage_name, {})
            stage_dic = {
                "l_flow": l_flow, "flow": flow_name, "stage": stage_name,
                "sub_stage": sub_stage_name, "flow_root_dir": flow_root_dir,
                "flow_liblist_dir": self.ced["BLK_RUN"],
                "flow_scripts_dir": f"{flow_root_dir}{os.sep}scripts",
                "config_plugins_dir":
                f"{self.ced['BLK_CFG_FLOW']}{os.sep}{flow_name}{os.sep}plugins"}
            self.proc_prex(stage_dic)
            self.opvar_lst.append({
                "local": local_dic, "cur": stage_dic, "pre": pre_stage_dic, "ver": flow_ver_dic})
            tmp_dic = {
                "env": self.ced, "local": local_dic,
                "liblist": liblist_var_dic.get(flow_lib, {}),
                "cur": stage_dic, "pre": pre_stage_dic, "ver": flow_ver_dic,
                "signoff": signoff_dic}
            pre_stage_dic = stage_dic
            if self.restore_dic and self.restore_dic != {
                    "flow": flow_name, "stage": stage_name, "sub_stage": sub_stage_name}:
                continue
            if self.restore_dic:
                tmp_dic["cur"]["op_restore"] = "true"
            if self.begin_dic and self.begin_dic != {
                    "flow": flow_name, "stage": stage_name, "sub_stage": sub_stage_name}:
                self.opvar_lst.pop()
                continue
            self.begin_dic = {}
            inst_str = "_restore_inst" if self.restore_dic else "_multi_inst"
            multi_inst_lst = [c_c.strip() for c_c in pcom.rd_cfg(
                self.dir_cfg_dic.get("flow", {}).get(flow_name, {}).get(stage_name, {}),
                sub_stage_name, inst_str) if c_c.strip()]
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
                            self.proc_inst(multi_inst, inst_dic)
                            file_mt_lst.append(self.proc_inst_ex(multi_inst, inst_dic))
                    else:
                        for multi_inst in multi_inst_lst:
                            self.proc_inst(multi_inst, inst_dic)
                        with Pool(settings.MP_POOL, initializer=pcom.sig_init) as mip:
                            file_mt_lst = mip.starmap(
                                self.proc_inst_ex,
                                zip(multi_inst_lst, [inst_dic]*len(multi_inst_lst)))
                except KeyboardInterrupt:
                    flow_if_dic["status"] = "failed"
                    db_if.w_flow(flow_if_dic)
                    db_if.d_flow(flow_if_dic)
                    raise KeyboardInterrupt
                if any([c_c is True for c_c in file_mt_lst if c_c]):
                    flow_if_dic["status"] = "failed"
                    db_if.w_flow(flow_if_dic)
                    db_if.d_flow(flow_if_dic)
                    raise SystemExit()
                pre_file_mt = max(file_mt_lst)
            else:
                for multi_inst in multi_inst_lst:
                    self.proc_inst(multi_inst, inst_dic)
                    self.proc_inst_ex(multi_inst, inst_dic)
            if self.end_dic and self.end_dic == {
                    "flow": flow_name, "stage": stage_name, "sub_stage": sub_stage_name}:
                break
        if self.run_flg:
            flow_if_dic["status"] = "passed"
            db_if.w_flow(flow_if_dic)
    @classmethod
    def _gen_job_tcl(cls, dst_op_file, local_dic):
        """to generate _job variable tcl file"""
        with open(f"{dst_op_file}._job.tcl", "w") as dtf:
            for var_k, var_v in local_dic.items():
                if "_cpu_number" in var_k and isinstance(var_v, str):
                    dtf.write(f'set {var_k} "{var_v}"{os.linesep}')
    def proc_inst(self, multi_inst, inst_dic):
        """to process particular inst"""
        flow_root_dir = inst_dic["stage_dic"]["flow_root_dir"]
        stage_name = inst_dic["stage_dic"]["stage"]
        sub_stage_name = inst_dic["stage_dic"]["sub_stage"]
        if self.restore_dic:
            sub_stage_name = f".restore_{sub_stage_name}"
        dst_file = os.path.join(
            flow_root_dir, "scripts", stage_name, multi_inst,
            sub_stage_name) if multi_inst else os.path.join(
                flow_root_dir, "scripts", stage_name, sub_stage_name)
        inst_dic["tmp_dic"]["local"]["_multi_inst"] = multi_inst
        pcom.mkdir(LOG, os.path.dirname(dst_file))
        LOG.info(":: generating file %s ...", dst_file)
        if os.path.isfile(dst_file):
            shutil.copyfile(dst_file, f"{dst_file}.pre")
        pcom.ren_tempfile(LOG, inst_dic["tmp_file"], dst_file, inst_dic["tmp_dic"])
        if os.path.isfile(f"{dst_file}.pre"):
            pre_cur_same_flg = cmp(f'{dst_file}.pre', dst_file)
            if not pre_cur_same_flg:
                if self.cfm_yes or self.cfm_flg:
                    LOG.warning(
                        "%s is modified, "
                        "confirmed to re-run the stage", os.path.join(multi_inst, sub_stage_name))
                else:
                    LOG.info(
                        "%s is modified, "
                        "pleasse confirm to re-run the stage and the following stages",
                        os.path.join(multi_inst, sub_stage_name))
                    try:
                        pcom.cfm()
                        self.cfm_flg = True
                    except:
                        shutil.copyfile(f"{dst_file}.pre", dst_file)
                        raise
    def proc_inst_ex(self, multi_inst, inst_dic):
        """to execute particular inst """
        flow_root_dir = inst_dic["stage_dic"]["flow_root_dir"]
        flow_name = inst_dic["stage_dic"]["flow"]
        l_flow = inst_dic["stage_dic"]["l_flow"]
        stage_name = inst_dic["stage_dic"]["stage"]
        sub_stage_name = inst_dic["stage_dic"]["sub_stage"]
        local_dic = inst_dic["tmp_dic"]["local"]
        ver_dic = inst_dic["tmp_dic"]["ver"]
        pre_file_mt = inst_dic["pre_file_mt"]
        force_flg = inst_dic["force_flg"]
        file_mt = 0.0
        if self.restore_dic:
            sub_stage_name = f".restore_{sub_stage_name}"
        dst_file = os.path.join(
            flow_root_dir, "scripts", stage_name, multi_inst,
            sub_stage_name) if multi_inst else os.path.join(
                flow_root_dir, "scripts", stage_name, sub_stage_name)
        dst_op_file = os.path.join(
            flow_root_dir, "sum", stage_name, multi_inst,
            f"{sub_stage_name}.op") if multi_inst else os.path.join(
                flow_root_dir, "sum", stage_name, f"{sub_stage_name}.op")
        pcom.mkdir(LOG, os.path.dirname(dst_op_file))
        dst_run_file = f"{dst_op_file}.run"
        if "_exec_cmd" in local_dic:
            self._gen_job_tcl(dst_op_file, local_dic)
            tool_str = local_dic.get("_exec_tool", "")
            jcn_str = (
                local_dic.get("_job_restore_cpu_number", "") if self.restore_dic
                else local_dic.get("_job_cpu_number", ""))
            jr_str = (
                local_dic.get("_job_restore_resource", "") if self.restore_dic
                else local_dic.get("_job_resource", ""))
            jc_str = (
                f"{local_dic.get('_job_cmd', '')} {local_dic.get('_job_queue', '')} "
                f"{jcn_str} {jr_str}" if "_job_cmd" in local_dic else "")
            jn_str = (
                f"{self.ced['USER']}:::{self.ced['PROJ_NAME']}:::{self.ced['BLK_NAME']}:::"
                f"{flow_name}::{stage_name}:{sub_stage_name}:{multi_inst}")
            job_str = f"{jc_str} -J '{jn_str}'" if jc_str else ""
            cmd_str = local_dic.get("_exec_cmd", "")
            with open(dst_op_file, "w") as drf:
                drf.write(
                    f"{tool_str}{os.linesep}{cmd_str} {dst_file}{os.linesep}")
            trash_dir = f"{os.path.dirname(dst_op_file)}{os.sep}.trash"
            pcom.mkdir(LOG, trash_dir)
            with open(dst_run_file, "w") as dbf:
                dbf.write(
                    f"{job_str} xterm -title '{dst_file}' -e 'cd {trash_dir}; "
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
                     "ver_dic": ver_dic, "jn_str": jn_str}, f_flg)
                file_p.proc_set_log_par_env(inst_dic["tmp_dic"])
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
    f_p = FlowProc(args.flow_cfm_yes)
    if args.flow_list_env:
        f_p.list_env()
    elif args.flow_list_blk:
        f_p.list_blk()
    elif args.flow_list_flow:
        f_p.list_flow()
    elif args.flow_list_diff:
        f_p.list_diff(args.flow_list_diff)
    elif args.flow_init_lst:
        f_p.init(args.flow_init_lst)
    elif args.flow_gen_lst is not None:
        f_p.begin_stage = args.flow_begin
        f_p.end_stage = args.flow_end
        f_p.proc_begin()
        f_p.proc_end()
        f_p.proc_flow_lst(args.flow_gen_lst)
    elif args.flow_run_lst is not None:
        f_p.run_flg = True
        f_p.comment = args.flow_comment
        f_p.force_stage = args.flow_force
        f_p.begin_stage = args.flow_begin
        f_p.end_stage = args.flow_end
        f_p.proc_force()
        f_p.proc_begin()
        f_p.proc_end()
        f_p.proc_flow_lst(args.flow_run_lst)
    elif args.flow_show_var_lst is not None:
        f_p.begin_stage = args.flow_begin
        f_p.end_stage = args.flow_end
        f_p.proc_begin()
        f_p.proc_end()
        f_p.proc_flow_lst(args.flow_show_var_lst)
        f_p.show_var()
    elif args.flow_restore:
        f_p.run_flg = True
        f_p.comment = args.flow_comment
        f_p.force_stage = None
        f_p.restore_stage = args.flow_restore
        f_p.proc_force()
        l_flow = f_p.proc_restore()
        f_p.proc_flow_lst([l_flow])
    elif args.flow_release_lst:
        f_p.proc_release(args.flow_release_lst)
    else:
        LOG.critical("no actions specified in op flow sub cmd")
        raise SystemExit()
