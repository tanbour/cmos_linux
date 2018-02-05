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
        proj_flg_file = f"{self.repo_dic['repo_dir']}{os.sep}{settings.FLG_FILE}"
        LOG.info(f":: generating op project flag file {settings.FLG_FILE} ...")
        with open(proj_flg_file, "w") as f_f:
            f_f.write(self.repo_dic["init_proj_name"])
        LOG.info(":: generating op project level configs, templates and plugins ...")
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
                f" project share dir {dst_dir} already exists, continue to initialize "
                f"the project will overwrite the current project configs, templates and plugins"
            )
            pcom.cfm()
            shutil.rmtree(dst_dir, True)
        shutil.copytree(f"{settings.OP_PROJ}{os.sep}{suite_name}", dst_dir)
        LOG.info(
            " please perform the git commit and git push actions "
            "after project and block items are settled down"
        )
    def fill_blocks(self, blk_lst):
        """to fill blocks config dir after initialization"""
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        for blk_name in blk_lst:
            os.environ["BLK_NAME"] = blk_name
            os.environ["BLK_ROOT"] = blk_root_dir = f"{self.ced['PROJ_ROOT']}{os.sep}{blk_name}"
            pcom.mkdir(LOG, blk_root_dir)
            proj_cfg_dir = os.path.expandvars(settings.PROJ_CFG_DIR).rstrip(os.sep)
            blk_cfg_dir = os.path.expandvars(settings.BLK_CFG_DIR).rstrip(os.sep)
            for proj_cfg in self.proj_cfg_lst:
                blk_cfg = proj_cfg.replace(proj_cfg_dir, blk_cfg_dir)
                pcom.mkdir(LOG, os.path.dirname(blk_cfg))
                with open(proj_cfg) as pcf, open(blk_cfg, "w") as bcf:
                    for line in pcf:
                        if line.strip().startswith("["):
                            bcf.write(line)
                        else:
                            bcf.write(f"# {line}")
                LOG.info(f" block config {blk_cfg} generated")
            blk_plg_dir = os.path.expandvars(settings.BLK_PLG_DIR)
            shutil.rmtree(blk_plg_dir, True)
            shutil.copytree(os.path.expandvars(settings.PROJ_PLG_DIR), blk_plg_dir)
            LOG.info(f" block plugins {blk_plg_dir} generated")
    def update_blocks(self, blk_lst):
        """to obtain blocks input data from release directory"""
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        for data_file in pcom.find_iter(self.ced["PROJ_RELEASE"], "*"):
            blk_name = os.path.basename(data_file).split(os.extsep)[0]
            if not blk_name:
                continue
            if blk_lst:
                if blk_name not in blk_lst:
                    continue
            blk_file = data_file.replace(
                self.ced["PROJ_RELEASE"], f"{self.ced['PROJ_ROOT']}{os.sep}{blk_name}")
            pcom.mkdir(LOG, os.path.dirname(blk_file))
            shutil.copyfile(data_file, blk_file)
            LOG.info(f" block files {blk_file} copied from {data_file}")
    def fill_lib(self):
        """a function wrapper for inherited LibProc function"""
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        pcom.mkdir(LOG, self.ced["PROJ_LIB"])
        try:
            self.link_file(
                self.ced["LIB"], self.ced["PROJ_LIB"],
                self.dir_cfg_dic["lib"], self.cfg_dic)
            self.gen_liblist(
                self.ced["PROJ_LIB"], self.ced["PROJ_LIB"],
                self.dir_cfg_dic["lib"]["liblist"], self.cfg_dic["lib"])
        except KeyError as err:
            LOG.error(err)
            raise SystemExit()
    def init_release(self):
        """to initialize the release input dir"""
        env_boot.EnvBoot.__init__(self)
        self.boot_env()
        for input_dir in pcom.rd_cfg(
                self.cfg_dic.get("proj", {}), "release", "input_dir"):
            pcom.mkdir(LOG, f"{self.ced['PROJ_RELEASE']}{os.sep}{input_dir}")
            LOG.info(f" release dir {input_dir} generated")

def run_admin(args):
    """to run admin sub cmd"""
    admin_proc = AdminProc()
    if args.admin_list_proj:
        admin_proc.list_proj()
    elif args.admin_list_lab:
        admin_proc.list_lab()
    elif args.admin_proj_name:
        admin_proc.repo_proj(args.admin_proj_name)
        admin_proc.fill_proj()
    elif args.admin_block_lst:
        LOG.info(
            f":: generating block level directories and configs of {args.admin_block_lst}, "
            f"which will overwrite all the existed block level configs ..."
        )
        pcom.cfm()
        admin_proc.fill_blocks(args.admin_block_lst)
        admin_proc.update_blocks(args.admin_block_lst)
    elif args.admin_update_blk != None:
        LOG.info(
            f":: updating all block level directories according to RELEASE directory, "
            f"which will overwrite the existed block files ..."
        )
        pcom.cfm()
        admin_proc.update_blocks(args.admin_update_blk)
    elif args.admin_lib:
        LOG.info(
            f":: generating library mapping links and files, "
            f"which will overwrite all the existed library mapping links and files ..."
        )
        pcom.cfm()
        admin_proc.fill_lib()
    elif args.admin_init_release:
        LOG.info(f":: initializing release directories ...")
        admin_proc.init_release()
    else:
        LOG.critical("no actions specified in op admin sub cmd")
        raise SystemExit()
