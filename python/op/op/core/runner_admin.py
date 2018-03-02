"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: projects initialization and related features
"""

import os
import shutil
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
        LOG.info(":: filling project {self.repo_dic['init_proj_name']} repo ...")
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
        dst_dir = os.path.expandvars(settings.PROJ_SHARE)
        if os.path.isdir(dst_dir):
            LOG.info(
                f"project share dir {dst_dir} already exists, continue to initialize "
                f"the project will overwrite the current project configs, templates and plugins")
            pcom.cfm()
            shutil.rmtree(dst_dir, True)
        shutil.copytree(f"{settings.OP_PROJ}{os.sep}{suite_name}", dst_dir)
        self.boot_env()
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
            LOG.info(":: filling block {blk_name} ...")
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
                    for line in pcf:
                        if line.strip().startswith("["):
                            bcf.write(line)
                        else:
                            bcf.write(f"# {line}")
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
                        blk_lines = ocf.readlines()
                    with open(blk_cfg, "w") as ncf:
                        for line in blk_lines:
                            if line.strip().startswith("["):
                                ncf.write(line)
                            else:
                                ncf.write(f"# {line}")
    def update_blocks(self, blk_lst):
        """to obtain blocks input data from release directory"""
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        LOG.info(":: updating blocks ...")
        for data_file in pcom.find_iter(self.ced["PROJ_RELEASE"], "*"):
            blk_name = os.path.basename(data_file).split(os.extsep)[0]
            if not blk_name:
                continue
            if blk_lst:
                if blk_name not in blk_lst:
                    continue
            blk_file = data_file.replace(
                self.ced["PROJ_RELEASE"], f"{self.ced['PROJ_ROOT']}{os.sep}{blk_name}")
            LOG.info(f"copying block files {blk_file} from {data_file}")
            pcom.mkdir(LOG, os.path.dirname(blk_file))
            shutil.copyfile(data_file, blk_file)
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
    elif args.admin_update_blk != None:
        LOG.info(
            f"updating all block level directories according to RELEASE directory, "
            f"which will overwrite the existed block files ...")
        pcom.cfm()
        admin_proc.update_blocks(args.admin_update_blk)
    elif args.admin_lib:
        LOG.info(
            f"generating library mapping links and files, "
            f"which will overwrite all the existed library mapping links and files ...")
        pcom.cfm()
        admin_proc.fill_lib()
    else:
        LOG.critical("no actions specified in op admin sub cmd")
        raise SystemExit()
