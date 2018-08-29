"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: projects backup and related features
"""

import os
import platform
import subprocess
import datetime as dt
import fnmatch
import shutil
from utils import pcom
from utils import backup_cfg

LOG = pcom.gen_logger(__name__)

class BackupProc():
    """backup processor for super user"""
    def __init__(self, proj_name):
        self.src_root = os.path.join(backup_cfg.BACKUP_SRC_ROOT, proj_name)
        self.dst_root = os.path.join(backup_cfg.BACKUP_DST_ROOT, proj_name)
    def check_env(self):
        """to check backup env"""
        user = os.environ.get("USER")
        host = platform.node()
        if user != backup_cfg.BACKUP_USER:
            LOG.critical("Sorry, you are not the user who could run project backup")
            raise SystemExit()
        if host != backup_cfg.BACKUP_HOST:
            LOG.critical("Sorry, you are not in the host which could run project backup")
            raise SystemExit()
        if not os.path.isdir(self.src_root):
            LOG.error("backup source directory %s is NA", self.src_root)
            raise SystemExit()
        pcom.mkdir(LOG, self.dst_root)
    def backup_sync(self):
        """to backup sync part of project"""
        LOG.info(":: backup sync part")
        for sync_name in backup_cfg.BACKUP_CFG_SYNC_LST:
            sync_src = os.path.join(self.src_root, sync_name)
            sync_dst = os.path.join(self.dst_root, sync_name)
            if not os.path.exists(sync_src):
                LOG.error("sync source %s is NA", sync_src)
                raise SystemExit()
            LOG.info("rsync from %s to %s", sync_src, sync_dst)
            rsync_str = f"rsync -a --delete {sync_src} {sync_dst}"
            subprocess.run(rsync_str, shell=True, check=True, stdout=subprocess.PIPE)
    def backup_date(self):
        """to backup date auto generation part of project"""
        LOG.info(":: backup date part")
        date_root = os.path.join(self.dst_root, dt.datetime.now().strftime("%Y_%m_%d"))
        pcom.mkdir(LOG, date_root)
        src_work_dir = f"{self.src_root}{os.sep}WORK"
        for user_path in pcom.find_iter(src_work_dir, "*", True, True):
            for block_path in pcom.find_iter(user_path, "*", True, True, ["share"]):
                can_lst = list(pcom.find_iter(block_path, "*"))
                for date_pat in backup_cfg.BACKUP_CFG_DATE_LST:
                    glob_lst = fnmatch.filter(can_lst, os.path.join(block_path, date_pat))
                    glob_tup_lst = [(os.path.getmtime(c_c), c_c) for c_c in glob_lst]
                    if glob_tup_lst:
                        glob_max_tup = max(glob_tup_lst)
                        src_file = glob_max_tup[-1]
                        dst_file = src_file.replace(self.src_root, date_root)
                        LOG.info("backup from %s to %s", src_file, dst_file)
                        pcom.mkdir(LOG, os.path.dirname(dst_file))
                        shutil.copyfile(src_file, dst_file)
    def backup_proj(self):
        """backup top exec function"""
        self.check_env()
        self.backup_sync()
        self.backup_date()

def run_backup(args):
    """to run backup sub cmd"""
    if args.backup_proj_name:
        BackupProc(args.backup_proj_name).backup_proj()
    else:
        LOG.critical("no actions specified in op backup sub cmd")
        raise SystemExit()
