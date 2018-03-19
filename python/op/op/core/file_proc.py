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
from utils import pcom
from utils import db_if
from core import log_parser

LOG = pcom.gen_logger(__name__)

class FileProc(object):
    """base class of log processor"""
    def __init__(self, run_dic, f_flg=True):
        self.run_dic = run_dic
        self.ced = run_dic["ced"]
        self.run_file = run_file = self.run_dic.get("file", "")
        self.run_src_file = self.run_dic.get("src", "")
        self.file_dic = {
            "json": f"{run_file}.json",
            "pass": f"{run_file}.pass",
            "fin": f"{run_file}.fin",
            "stat": f"{run_file}.stat"}
        self.f_flg = f_flg
        self.log_dic = {}
    def proc_run_log(self):
        """to process sub stage run log"""
        run_log = f"{self.run_dic['file']}.log"
        if not os.path.isfile(run_log):
            LOG.error(f"log {run_log} to be processed is NA")
            return True
        run_filter_dic = self.run_dic.get("filter_dic", {})
        LOG.info(f"parsing log file {run_log}")
        fin_str = run_filter_dic.get("fin_str", "")
        err_kw_lst = run_filter_dic.get("err_kw_lst", [])
        wav_kw_lst = run_filter_dic.get("wav_kw_lst", [])
        with open(run_log, errors="replace") as rlf:
            rl_con = rlf.read()
        if not rl_con:
            LOG.error("log file is empty")
            return True
        self.log_dic["fin"] = True if fin_str and fin_str in rl_con else False
        if not err_kw_lst:
            err_lst = []
        else:
            err_exp = "|".join([f".*{c_c}.*" for c_c in err_kw_lst if c_c]).strip("|")
            wav_exp = rf"^$|{'|'.join([re.escape(c_c) for c_c in wav_kw_lst if c_c])}".strip("|")
            err_lst = [c_c for c_c in re.findall(err_exp, rl_con) if not re.search(wav_exp, c_c)]
        if err_lst:
            self.log_dic["status"] = "failed"
            self.log_dic["err_lst"] = err_lst
        else:
            self.log_dic["status"] = "passed"
            self.log_dic["err_lst"] = []
        return False
    def proc_logs(self):
        """to process all logs to dump database"""
        flow_root_dir = self.run_dic.get("flow_root_dir", "")
        stage_name = self.run_dic.get("stage", "")
        sub_stage_name = self.run_dic.get("sub_stage", "")
        inst_name = self.run_dic.get("multi_inst", "")
        pcd = log_parser.PARSER_CFG_DIC.get(stage_name, {}).get(sub_stage_name, {})
        log_par = log_parser.LogParser()
        for p_k, p_v in pcd.items():
            if not p_k.endswith("key"):
                continue
            sub_stage = os.path.splitext(sub_stage_name)[0]
            key_path = os.path.join(
                flow_root_dir, "rpt", stage_name, inst_name, f"{sub_stage}.{p_v}.rpt")
            # key_path = f"{self.run_dic['file']}.log"
            if not os.path.isfile(key_path):
                LOG.error(f"log file {key_path} to be parsed is NA")
                return True
            log_par.add_parser(
                key_path, pcd.get(f"{p_k}_type", ""),
                pcd.get(f"{p_k}_exp_lst", []), pcd.get(f"{p_k}_tpl", ""))
        self.log_dic["data"] = log_par.run_parser()
        return False
    def proc_run_file(self):
        """to process generated oprun files for running flows"""
        file_mt = os.path.getmtime(self.run_src_file)
        if not os.path.isfile(self.run_src_file):
            LOG.error(f"run src file {self.run_src_file} is NA")
            return True
        if not os.path.isfile(self.run_file):
            LOG.error(f"run file {self.run_file} is NA")
            return True
        db_stage = ":".join(
            [self.run_dic["stage"], self.run_dic["sub_stage"], self.run_dic["multi_inst"]])
        LOG.info(
            f":: running flow {self.run_dic['flow']}::{db_stage}, "
            f"op log {self.run_file}.log ...")
        if not self.f_flg and os.path.isfile(self.file_dic["pass"]) and os.path.getmtime(
                self.file_dic["pass"]) > file_mt:
            LOG.info("passed and re-run skipped")
            if os.path.isfile(self.file_dic["json"]) and os.path.getmtime(
                    self.file_dic["json"]) > file_mt:
                with open(self.file_dic["json"]) as j_f:
                    self.log_dic = json.load(j_f)
                    self.log_dic["f_created_time"] = self.ced["DATETIME"].isoformat()
                    db_if.w_stage(self.log_dic)
            return False
        db_stage_dic = {
            "name": db_stage, "flow": self.run_dic["flow"], "block": self.ced["BLK_NAME"],
            "proj": self.ced["PROJ_NAME"], "owner": self.ced["USER"],
            "created_time": dt.datetime.now().isoformat(), "status": "running",
            "version": self.run_dic.get(
                "ver_dic", {}).get(self.run_dic["flow"], {}).get("netlist", ""),
            "f_created_time": self.ced["DATETIME"].isoformat(), "f_status": "running"}
        db_if.w_stage(db_stage_dic)
        if self.f_flg or not os.path.isfile(self.file_dic["fin"]) or os.path.getmtime(
                self.file_dic["fin"]) <= file_mt:
            with open(f"{self.run_file}.blog", "w") as rfl, \
                 open(f"{self.run_file}.beer", "w") as rfe:
                subprocess.run(f"source {self.run_file}", shell=True, stdout=rfl, stderr=rfe)
        if not os.path.isfile(self.file_dic["stat"]) or os.path.getmtime(
                self.file_dic["stat"]) <= file_mt:
            LOG.error(f"sub process {self.run_file} is terminated")
            db_stage_dic["status"] = "failed"
            db_if.w_stage(db_stage_dic)
            return True
        if self.proc_run_log() is True or self.proc_logs() is True:
            return True
        db_stage_dic.update(self.log_dic)
        db_if.w_stage(db_stage_dic)
        with open(self.file_dic["json"], "w") as j_f:
            json.dump(db_stage_dic, j_f)
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
            LOG.error(f"failed lines: {os.linesep}{os.linesep.join(self.log_dic['err_lst'])}")
            return True
        return False
