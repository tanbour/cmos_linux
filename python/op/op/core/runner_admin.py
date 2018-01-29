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
        LOG.info(":: generating op project level configs and templates ...")
        env_boot.EnvBoot.__init__(self)
        dst_cfg_dir = os.path.expandvars(settings.PROJ_CFG_DIR)
        if os.path.isdir(dst_cfg_dir):
            LOG.info(
                f" project config dir {dst_cfg_dir} already exists, continue to initialize "
                f"the project will overwrite the current project configs"
            )
            pcom.cfm()
            shutil.rmtree(dst_cfg_dir, True)
        shutil.copytree(settings.OP_CFG, dst_cfg_dir)
        dst_tmp_dir = os.path.expandvars(settings.PROJ_TMP_DIR)
        if os.path.isdir(dst_tmp_dir):
            LOG.info(
                f" project template dir {dst_tmp_dir} already exists, continue to initialize "
                f"the project will overwrite the current project templates"
            )
            pcom.cfm()
            shutil.rmtree(dst_tmp_dir)
        shutil.copytree(settings.OP_TMP, dst_tmp_dir)
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
            blk_cfg_dir = os.path.expandvars(settings.BLK_CFG_DIR)
            for proj_cfg in self.proj_cfg_lst:
                blk_cfg = proj_cfg.replace(
                    os.path.expandvars(settings.PROJ_CFG_DIR), blk_cfg_dir)
                pcom.mkdir(LOG, os.path.dirname(blk_cfg))
                with open(proj_cfg) as pcf, open(blk_cfg, "w") as bcf:
                    for line in pcf:
                        bcf.write(f"# {line}")
            blk_plg_dir = os.path.expandvars(settings.BLK_PLG_DIR)
            shutil.copytree(os.path.expandvars(settings.PROJ_PLG_DIR), blk_plg_dir)
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

def run_admin(args):
    """to run admin sub cmd"""
    admin_proc = AdminProc()
    if args.admin_list_proj:
        admin_proc.list_proj()
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
    elif args.admin_lib:
        LOG.info(
            f":: generating library mapping links and files, "
            f"which will overwrite all the existed library mapping links and files ..."
        )
        pcom.cfm()
        admin_proc.fill_lib()
    else:
        LOG.critical("no actions specified in op admin sub cmd")
        raise SystemExit()
