"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: base class for all log parsing
"""

import os
import re
import subprocess
import json
import datetime as dt
from utils import settings
from utils import pcom
from utils import db_if
from utils import log_parser_cfg
from core import log_parser
from core import json_converter as jc

LOG = pcom.gen_logger(__name__)

class FileProc():
    """base class of log processor"""
    def __init__(self, run_dic, f_flg=True):
        self.run_dic = run_dic
        self.ced = ced = run_dic["ced"]
        self.run_file = run_file = self.run_dic.get("file", "")
        self.run_src_file = self.run_dic.get("src", "")
        self.file_dic = {
            "json": f"{run_file}.json",
            "pass": f"{run_file}.pass",
            "fin": f"{run_file}.fin",
            "stat": f"{run_file}.stat"}
        self.db_stage = db_stage = ":".join(
            [run_dic["stage"], run_dic["sub_stage"], run_dic["multi_inst"]])
        self.db_stage_dic = {
            "stage": db_stage, "flow": run_dic["l_flow"], "block": ced["BLK_NAME"],
            "proj": ced["PROJ_NAME"], "owner": ced["USER"],
            "created_time": dt.datetime.now().isoformat(), "status": "running",
            "version": run_dic.get("ver_dic", {}).get("rtl_netlist", ""),
            "f_created_time": ced["DATETIME"].isoformat()}
        self.f_flg = f_flg
        self.log_dic = {}
        self.log_par_env_dic = {}
    def proc_set_log_par_env(self, env_dic):
        """store the environment which the log parser is running on"""
        self.log_par_env_dic.update(env_dic)
    def proc_run_log(self):
        """to process sub stage run log"""
        run_log = f"{self.run_dic['file']}.log"
        if not os.path.isfile(run_log):
            LOG.error("log %s to be processed is NA", run_log)
            return True
        run_filter_dic = self.run_dic.get("filter_dic", {})
        LOG.info("parsing log file %s", run_log)
        fin_str = run_filter_dic.get("fin_str", "")
        err_kw_lst = run_filter_dic.get("err_kw_lst", [])
        wav_kw_lst = run_filter_dic.get("wav_kw_lst", [])
        with open(run_log, errors="replace") as rlf:
            rl_con = rlf.read()
        if not rl_con:
            LOG.error("log file is empty")
            return True
        self.log_dic["fin"] = True if fin_str and fin_str in rl_con else False
        err_lst = []
        if err_kw_lst:
            # err_exp = "|".join([f".*{c_c}.*" for c_c in err_kw_lst if c_c]).strip("|")
            wav_exp = rf"^$|{'|'.join([re.escape(c_c) for c_c in wav_kw_lst if c_c])}".strip("|")
            rl_con_lst = rl_con.split(os.linesep)
            for err_kw in err_kw_lst:
                for line in rl_con_lst:
                    if not line.strip():
                        continue
                    if re.search(f"{err_kw}", line) and not re.search(wav_exp, line):
                        err_lst.append(line)
        if err_lst:
            self.log_dic["status"] = "failed"
            self.log_dic["err_lst"] = err_lst
        elif self.log_dic["fin"]:
            self.log_dic["status"] = "passed"
            self.log_dic["err_lst"] = []
        else:
            self.log_dic["status"] = "failed"
            self.log_dic["err_lst"] = [
                "job not finished due to finished string configured in proj.cfg missing"]
        if settings.MAIL_ALERT:
            fn_str = pcom.re_str(
                f"{self.run_dic['jn_str']}_{self.db_stage_dic['f_created_time']}")
            jc.JsonConverter(
                [self.ced["USER"]],
                f"[OP] {self.log_dic['status']} job {self.run_dic['jn_str']}",
                os.linesep.join(self.log_dic["err_lst"]), fn_str).gen_json_file()
        return False
    def proc_logs(self):
        """to process all logs to dump database"""
        flow_root_dir = self.run_dic.get("flow_root_dir", "")
        stage_name = self.run_dic.get("stage", "")
        sub_stage_name = self.run_dic.get("sub_stage", "")
        inst_name = self.run_dic.get("multi_inst", "")
        block = self.ced["BLK_NAME"]
        pcd = log_parser_cfg.PARSER_CFG_DIC.get(stage_name, {}).get(sub_stage_name, {})
        log_par = log_parser.LogParser()
        self.log_dic["data"] = {}
        for p_k, p_v in pcd.items():
            b_p_v = f'{block}.{p_v}'
            if p_k.endswith("_key"):
                c_paths = list()
                c_paths.append(os.path.join("rpt", stage_name, inst_name, p_v))
                c_paths.append(os.path.join("log", stage_name, inst_name, p_v))
                c_paths.append(os.path.join("log", stage_name, inst_name, b_p_v))
                for r_path in c_paths:
                    key_path = os.path.join(flow_root_dir, r_path)
                    if os.path.isfile(key_path):
                        break
                # key_path = f"{self.run_dic['file']}.log"
                if not os.path.isfile(key_path):
                    LOG.warning("rpt/log file related with %s to be parsed is NA", p_v)
                    continue
                log_par.add_parser(
                    key_path, pcd.get(f"{p_k}_type", ""),
                    pcd.get(f"{p_k}_exp_lst", []), pcd.get(f"{p_k}_tpl", ""))
            elif p_k.endswith("_img"):
                file_path = os.path.join(
                    flow_root_dir, "rpt", stage_name, inst_name, p_v)
                if not os.path.isfile(file_path):
                    LOG.warning("file %s to be uploaded is NA", file_path)
                    continue
                with open(file_path, "rb") as f_p:
                    file_url = db_if.w_file(
                        self.db_stage_dic, {"file_obj": f_p}).get("file_url", "")
                if not file_url:
                    continue
                self.log_dic["data"][f"{p_k}_raw"] = f"<img src='{file_url}'>"
        log_par.set_environment(self.log_par_env_dic)
        self.log_dic["data"].update(log_par.run_parser())
    def proc_run_file(self):
        """to process generated oprun files for running flows"""
        file_mt = os.path.getmtime(self.run_src_file)
        if not os.path.isfile(self.run_src_file):
            LOG.error("run src file %s is NA", self.run_src_file)
            return True
        if not os.path.isfile(self.run_file):
            LOG.error("run file %s is NA", self.run_file)
            return True
        LOG.info(
            ":: running flow %s::%s, op log %s.log ...",
            self.run_dic["flow"], self.db_stage, self.run_file)
        if not self.f_flg and os.path.isfile(self.file_dic["pass"]) and os.path.getmtime(
                self.file_dic["pass"]) > file_mt:
            LOG.info("passed and re-run skipped")
            if os.path.isfile(self.file_dic["json"]) and os.path.getmtime(
                    self.file_dic["json"]) > file_mt:
                with open(self.file_dic["json"]) as j_f:
                    pre_log_dic = json.load(j_f)
                    pre_log_dic["f_created_time"] = self.ced["DATETIME"].isoformat()
                    pre_log_dic["flow"] = self.run_dic["l_flow"]
                    db_if.w_stage(pre_log_dic)
            return False
        db_if.w_stage(self.db_stage_dic)
        if self.f_flg or not os.path.isfile(self.file_dic["fin"]) or os.path.getmtime(
                self.file_dic["fin"]) <= file_mt:
            rfl_str, rfe_str = '', ''
            subproc_info = subprocess.Popen(
                f"source {self.run_file}", shell=True,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            while subproc_info.poll() is None:
                rfl_str_part = subproc_info.stdout.readline().decode()
                rfe_str_part = subproc_info.stderr.readline().decode()
                if rfl_str_part.strip():
                    LOG.info(rfl_str_part.strip(os.linesep))
                if rfe_str_part.strip():
                    LOG.info(rfe_str_part.strip(os.linesep))
                rfl_str += rfl_str_part
                rfe_str += rfe_str_part
            with open(f"{self.run_file}.blog", "w") as rfl, \
                 open(f"{self.run_file}.beer", "w") as rfe:
                rfl.write(rfl_str)
                rfe.write(rfe_str)
        if not os.path.isfile(self.file_dic["stat"]) or os.path.getmtime(
                self.file_dic["stat"]) <= file_mt:
            LOG.error("sub process %s is terminated", self.run_file)
            self.db_stage_dic["status"] = "failed"
            db_if.w_stage(self.db_stage_dic)
            return True
        if self.proc_run_log() is True:
            return True
        try:
            self.proc_logs()
        except Exception as err:
            LOG.error("op log parser internal error: %s", err)
        self.db_stage_dic.update(self.log_dic)
        db_if.w_stage(self.db_stage_dic)
        with open(self.file_dic["json"], "w") as j_f:
            json.dump(self.db_stage_dic, j_f)
        if self.log_dic.get("fin", False):
            open(self.file_dic["fin"], "w").close()
        else:
            if os.path.isfile(self.file_dic["fin"]):
                os.remove(self.file_dic["fin"])
        if self.log_dic.get("status", "") == "passed":
            open(self.file_dic["pass"], "w").close()
            LOG.info("passed")
        else:
            if os.path.isfile(self.file_dic["pass"]):
                os.remove(self.file_dic["pass"])
            LOG.error("failed lines: %s%s", os.linesep, os.linesep.join(self.log_dic["err_lst"]))
            return True
        return False
