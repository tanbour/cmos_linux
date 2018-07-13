"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: projects initialization and related features
"""

import os
import re
import shutil
import json
import fnmatch
import texttable
from utils import pcom
from utils import settings
from utils import env_boot
from core import proj_repo
from core import lib_map

LOG = pcom.gen_logger(__name__)

class AdminProc(env_boot.EnvBoot, proj_repo.ProjRepo, lib_map.LibMap):
    """admin processor for start up projects"""
    def __init__(self):
        proj_repo.ProjRepo.__init__(self)
        lib_map.LibMap.__init__(self)
    def fill_proj(self):
        """to fill project config and template dir after initialization"""
        LOG.info(f":: filling project {self.repo_dic['init_proj_name']} repo ...")
        proj_gi_file = f"{self.repo_dic['repo_dir']}{os.sep}.gitignore"
        with open(proj_gi_file, "w") as g_f:
            g_f.write(settings.GITIGNORE)
        proj_flg_file = f"{self.repo_dic['repo_dir']}{os.sep}{settings.FLG_FILE}"
        LOG.info(f"generating op project flag file {settings.FLG_FILE}")
        with open(proj_flg_file, "w") as f_f:
            f_f.write(self.repo_dic["init_proj_name"])
        LOG.info("generating op project level configs and templates")
        env_boot.EnvBoot.__init__(self)
        suite_dict = dict(enumerate(os.listdir(os.path.expandvars(settings.OP_PROJ))))
        pcom.pp_list(suite_dict)
        index_str = f"please input from {list(suite_dict)} to specify the suite for project"
        while True:
            index_rsp = input(f"{index_str}{os.linesep}--> ")
            if index_rsp.isdigit() and int(index_rsp) in suite_dict:
                break
            else:
                LOG.warning("please input a correct index")
        suite_name = suite_dict[int(index_rsp)]
        suite_dst_dir = os.path.expandvars(settings.PROJ_SHARE)
        if os.path.isdir(suite_dst_dir):
            LOG.info(
                f"project share dir {suite_dst_dir} already exists, continue to initialize "
                f"the project will overwrite the current project configs, templates and plugins")
            pcom.cfm()
            shutil.rmtree(suite_dst_dir, True)
        shutil.copytree(f"{settings.OP_PROJ}{os.sep}{suite_name}", suite_dst_dir)
        self.boot_env()
        utils_dst_dir = self.ced.get("PROJ_UTILS", "")
        if not utils_dst_dir:
            LOG.error("project level proj.cfg env PROJ_UTILS is not defined")
            raise SystemExit()
        if os.path.isdir(utils_dst_dir):
            LOG.info(
                f"project utils dir {utils_dst_dir} already exists, continue to initialize "
                f"the project will overwrite the current project utils")
            pcom.cfm()
            shutil.rmtree(utils_dst_dir, True)
        shutil.copytree(settings.OP_UTILS, utils_dst_dir)
        for prex_dir_k in (
                self.cfg_dic["proj"]["prex_admin_dir"]
                if "prex_admin_dir" in self.cfg_dic["proj"] else {}):
            prex_dir = pcom.rd_cfg(self.cfg_dic["proj"], "prex_admin_dir", prex_dir_k, True)
            LOG.info(f"generating pre-set admin directory {prex_dir}")
            pcom.mkdir(LOG, prex_dir)
        LOG.info(
            "please perform the git commit and git push actions "
            "after project and block items are settled down")
    def fill_blocks(self, blk_lst):
        """to fill blocks config dir after initialization"""
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        for blk_name in blk_lst:
            LOG.info(f":: filling block {blk_name} ...")
            os.environ["BLK_NAME"] = blk_name
            os.environ["BLK_ROOT"] = blk_root_dir = f"{self.ced['PROJ_ROOT']}{os.sep}{blk_name}"
            pcom.mkdir(LOG, blk_root_dir)
            proj_cfg_dir = os.path.expandvars(settings.PROJ_CFG_DIR).rstrip(os.sep)
            blk_cfg_dir = os.path.expandvars(settings.BLK_CFG_DIR).rstrip(os.sep)
            for cfg_kw in self.cfg_dic:
                if cfg_kw == "proj":
                    continue
                proj_cfg = f"{proj_cfg_dir}{os.sep}{cfg_kw}.cfg"
                blk_cfg = f"{blk_cfg_dir}{os.sep}{cfg_kw}.cfg"
                LOG.info(f"generating block config {blk_cfg}")
                pcom.mkdir(LOG, os.path.dirname(blk_cfg))
                with open(proj_cfg) as pcf, open(blk_cfg, "w") as bcf:
                    for line in pcom.gen_pcf_lst(pcf):
                        bcf.write(line)
            for dir_cfg_kw in self.dir_cfg_dic:
                if dir_cfg_kw == "lib":
                    continue
                proj_dir_cfg = f"{proj_cfg_dir}{os.sep}{dir_cfg_kw}"
                blk_dir_cfg = f"{blk_cfg_dir}{os.sep}{dir_cfg_kw}{os.sep}DEFAULT"
                LOG.info(f"generating block config directory {blk_dir_cfg}")
                if os.path.isdir(blk_dir_cfg):
                    LOG.info(
                        f"block level config directory {blk_dir_cfg} already exists, "
                        f"please confirm to overwrite it")
                    pcom.cfm()
                shutil.rmtree(blk_dir_cfg, True)
                shutil.copytree(proj_dir_cfg, blk_dir_cfg)
                for blk_cfg in pcom.find_iter(blk_dir_cfg, "*.cfg", cur_flg=True):
                    with open(blk_cfg) as ocf:
                        blk_lines = pcom.gen_pcf_lst(ocf)
                    with open(blk_cfg, "w") as ncf:
                        for line in blk_lines:
                            ncf.write(line)
            proj_share_dir = os.path.expandvars(settings.PROJ_SHARE).rstrip(os.sep)
            proj_blk_cmn_dir = f"{proj_share_dir}{os.sep}block_common"
            blk_cmn_dir = f"{blk_root_dir}{os.sep}block_common"
            if not os.path.isdir(proj_blk_cmn_dir):
                continue
            if os.path.isdir(blk_cmn_dir):
                LOG.info(
                    f"block level common directory {blk_cmn_dir} already exists, "
                    f"please confirm to overwrite it")
                pcom.cfm()
            shutil.rmtree(blk_cmn_dir, True)
            shutil.copytree(proj_blk_cmn_dir, blk_cmn_dir)
    def update_blocks(self, blk_lst):
        """to obtain blocks input data from release directory"""
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        LOG.info(":: updating blocks ...")
        for data_src in list(
                pcom.find_iter(self.ced["PROJ_RELEASE_TO_BLK"], "*", True))+list(
                    pcom.find_iter(self.ced["PROJ_RELEASE_TO_BLK"], "*")):
            blk_name = os.path.basename(data_src).split(os.extsep)[0]
            if not blk_name:
                continue
            if blk_lst:
                if blk_name not in blk_lst:
                    continue
            blk_tar = data_src.replace(
                self.ced["PROJ_RELEASE_TO_BLK"], f"{self.ced['PROJ_ROOT']}{os.sep}{blk_name}")
            LOG.info(f"linking block files {blk_tar} from {data_src}")
            pcom.mkdir(LOG, os.path.dirname(blk_tar))
            if not os.path.exists(blk_tar):
                os.symlink(data_src, blk_tar)
            elif os.path.islink(blk_tar):
                os.remove(blk_tar)
                os.symlink(data_src, blk_tar)
    def fill_lib(self):
        """a function wrapper for inherited LibProc function"""
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        LOG.info(":: library mapping ...")
        pcom.mkdir(LOG, self.ced["PROJ_LIB"])
        self.link_file(
            self.ced["PROJ_LIB"], self.dir_cfg_dic["lib"]["DEFAULT"], self.cfg_dic)
        self.gen_liblist(
            self.ced["PROJ_LIB"], self.ced["PROJ_LIB"],
            self.dir_cfg_dic["lib"]["DEFAULT"]["liblist"], self.cfg_dic["lib"]["DEFAULT"])
    def check_release(self):
        """to check all released information"""
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        LOG.info(":: release info checking ...")
        relz_lst = []
        for relz_file in pcom.find_iter(
                f"{self.ced['PROJ_RELEASE_TO_TOP']}{os.sep}.json", "*.json"):
            with open(relz_file) as r_f:
                relz_dic = json.load(r_f)
            relz_lst.append(relz_dic)
        LOG.info("all released block info")
        pcom.pp_list(relz_lst)
        relz_blk_lst = [c_c.get("block", "") for c_c in relz_lst]
        table_rows = [["Block", "Release Status", "Owner", "Time"]]
        for blk_dir in pcom.find_iter(self.ced["PROJ_ROOT"], "*", True, True, [".git", "share"]):
            blk_name = os.path.basename(blk_dir)
            owner_set = set()
            time_set = set()
            for relz_dic in relz_lst:
                if relz_dic.get("block", "") == blk_name:
                    owner_set.add(relz_dic.get("user", ""))
                    time_set.add(relz_dic.get("time", ""))
            table_rows.append(
                [blk_name, "Ready", owner_set, time_set] if blk_name in relz_blk_lst else [
                    blk_name, "N/A", "N/A", "N/A"])
        table = texttable.Texttable()
        table.set_cols_width([30, 15, 15, 30])
        table.add_rows(table_rows)
        relz_table = table.draw()
        LOG.info(f"release status table:{os.linesep}{relz_table}")
    def release(self):
        """to generate release directory"""
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        LOG.info(":: release content generating ...")
        for relz_json_file in pcom.find_iter(
                f"{self.ced['PROJ_RELEASE_TO_TOP']}{os.sep}.json", "*.json"):
            LOG.info(f"generating release of {relz_json_file}")
            with open(relz_json_file) as rjf:
                relz_dic = json.load(rjf)
            relz_path = os.sep.join(
                [relz_dic["proj_root"], relz_dic["block"], "run",
                 relz_dic["rtl_netlist"], relz_dic["flow"]])
            relz_file_lst = list(pcom.find_iter(relz_path, "*"))
            for relz_k in self.cfg_dic["proj"]["release"]:
                for relz_v in pcom.rd_cfg(self.cfg_dic["proj"], "release", relz_k):
                    relz_pattern = (
                        f"{relz_path}{os.sep}*{relz_dic['stage']}*"
                        f"{os.path.splitext(relz_dic['sub_stage'])[0]}*{relz_v}")
                    match_relz_lst = fnmatch.filter(relz_file_lst, relz_pattern)
                    if not match_relz_lst:
                        LOG.warning(f"no {relz_k} {relz_v} files found")
                    else:
                        LOG.info(f"copying {relz_k} {relz_v} files")
                    for relz_file in match_relz_lst:
                        dst_dir = os.sep.join(
                            [self.ced["PROJ_RELEASE_TO_TOP"], relz_dic["block"],
                             self.ced["DATE"], relz_k])
                        pcom.mkdir(LOG, dst_dir)
                        if relz_v.endswith("/*"):
                            dst_file = re.sub(
                                rf".*?(?={relz_v[:-2]})", f"{dst_dir}{os.sep}{relz_dic['block']}",
                                relz_file)
                        else:
                            dst_file = f"{dst_dir}{os.sep}{relz_dic['block']}{relz_v}"
                        pcom.mkdir(LOG, os.path.dirname(dst_file))
                        shutil.copyfile(relz_file, dst_file)
            os.remove(relz_json_file)

def run_admin(args):
    """to run admin sub cmd"""
    admin_proc = AdminProc()
    if args.admin_list_proj:
        admin_proc.gen_all_proj()
        admin_proc.list_proj()
    elif args.admin_list_lab:
        admin_proc.gen_all_proj()
        admin_proc.list_lab()
    elif args.admin_proj_name:
        admin_proc.gen_all_proj()
        admin_proc.repo_proj(args.admin_proj_name)
        admin_proc.fill_proj()
    elif args.admin_block_lst:
        LOG.info(
            f"generating block level directories and configs of {args.admin_block_lst}, "
            f"which will overwrite all the existed block level configs ...")
        pcom.cfm()
        admin_proc.fill_blocks(args.admin_block_lst)
        admin_proc.update_blocks(args.admin_block_lst)
    elif args.admin_update_blk is not None:
        LOG.info(
            "updating all block level directories according to RELEASE directory, "
            "which will overwrite the existed block files ...")
        pcom.cfm()
        admin_proc.update_blocks(args.admin_update_blk)
    elif args.admin_lib:
        LOG.info(
            "generating library mapping links and files, "
            "which will overwrite all the existed library mapping links and files ...")
        pcom.cfm()
        admin_proc.fill_lib()
    elif args.admin_release_check:
        admin_proc.check_release()
    elif args.admin_release:
        admin_proc.release()
    else:
        LOG.critical("no actions specified in op admin sub cmd")
        raise SystemExit()
