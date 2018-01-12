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
from core import cfg_proc
from core import proj_repo

LOG = pcom.gen_logger(__name__)

class ProjAdminProc(proj_repo.ProjRepo):
    """admin processor for start up projects"""
    def fill_proj(self):
        proj_flg_file = f"{self.repo_dic['repo_dir']}{os.sep}{settings.FLG_FILE}"
        LOG.info(f"generating op project flag file {settings.FLG_FILE}...")
        if not os.path.isfile(proj_flg_file):
            with open(proj_flg_file, "w") as f_f:
                f_f.write(self.repo_dic["init_proj_name"])
        LOG.info("done")
        LOG.info("generating op project level configs and templates...")
        env_boot.EnvBoot()
        shutil.copytree(settings.OP_CFG, os.path.expandvars(settings.ADMIN_CFG_DIR))
        shutil.copytree(settings.OP_TMP, os.path.expandvars(settings.ADMIN_TMP_DIR))
        LOG.info("done")
        LOG.info(
            f"please cd into the project dir {self.repo_dic['repo_dir']}, "
            f"and then initialize the blocks"
        )

def run_admin(args):
    """to run admin sub cmd"""
    if args.admin_proj_name:
        proj_admin_proc = ProjAdminProc()
        proj_admin_proc.repo_proj(args.admin_proj_name)
        proj_admin_proc.fill_proj()
    elif args.admin_block_lst:
        for admin_blk_name in args.admin_block_lst:
            cfg_proc.CfgProc(admin_blk_name, True).proc_cfg()
    else:
        LOG.critical("op admin sub cmd missing main arguments")
        raise SystemExit()
