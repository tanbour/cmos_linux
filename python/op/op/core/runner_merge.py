"""
Author: Tsukasa Minato @ OnePiece Platform Group
Email: minato@alchip.com
Description: merge features
"""

import os
import shutil
import tempfile
import subprocess
from filecmp import dircmp, cmp
from utils import pcom
from utils import settings
from utils import env_boot

LOG = pcom.gen_logger(__name__)

class MergeProc(env_boot.EnvBoot):
    """merge for blocks"""
    def __init__(self):
        super().__init__()
        self.boot_env()
        self.src_dir = None
        self.dst_dir = None
        self.tool = None

    def merge_file(self):
        """ launch diff for different file """
        proj_cfg_str = f"{os.sep}share{os.sep}"
        src = self.src_dir
        dst = self.dst_dir
        if proj_cfg_str in self.src_dir:
            ntf = tempfile.NamedTemporaryFile("w")
            with open(src) as src_f:
                for line in pcom.gen_pcf_lst(src_f):
                    ntf.write(line)
            ntf.seek(0)
            if not cmp(ntf.name, dst):
                diff_str = f"{self.tool} {ntf.name} {dst}"
                subprocess.run(diff_str, shell=True)
            ntf.close()
        else:
            diff_str = f"{self.tool} {src} {dst}"
            subprocess.run(diff_str, shell=True)

    def merge_files(self, dcmp):
        """ launch diff for different files """
        proj_cfg_str = f"{os.sep}share{os.sep}"
        for right_only in dcmp.right_only:
            if right_only.startswith("."):
                continue
            LOG.info("only in destination dir (%s) : %s", dcmp.right, right_only)
        for left_only in dcmp.left_only:
            if left_only.startswith("."):
                continue
            LOG.info("only in source dir (%s) : %s", dcmp.left, left_only)
            choice = input("Sync to destination dir? [y/N]: ").lower()
            src = f"{dcmp.left}{os.sep}{left_only}"
            dst = f"{dcmp.right}{os.sep}{left_only}"
            if choice and choice[0] == 'y':
                if os.path.isdir(src):
                    shutil.copytree(src, dst)
                elif os.path.isfile(src):
                    pcom.mkdir(LOG, os.path.dirname(dst))
                    if proj_cfg_str in dcmp.left and proj_cfg_str not in dcmp.right:
                        with open(src) as src_f, open(dst, "w") as dst_f:
                            for line in pcom.gen_pcf_lst(src_f):
                                dst_f.write(line)
                    else:
                        shutil.copyfile(src, dst)
        for name in dcmp.diff_files:
            if name.startswith("."):
                continue
            LOG.info("different file %s found in %s", name, dcmp.left)
            src = f"{dcmp.left}{os.sep}{name}"
            dst = f"{dcmp.right}{os.sep}{name}"
            if proj_cfg_str in dcmp.left and proj_cfg_str not in dcmp.right:
                ntf = tempfile.NamedTemporaryFile("w")
                with open(src) as src_f:
                    for line in pcom.gen_pcf_lst(src_f):
                        ntf.write(line)
                ntf.seek(0)
                if not cmp(ntf.name, dst):
                    diff_str = f"{self.tool} {ntf.name} {dst}"
                    subprocess.run(diff_str, shell=True)
                ntf.close()
            else:
                diff_str = f"{self.tool} {src} {dst}"
                subprocess.run(diff_str, shell=True)
        for sub_dcmp in dcmp.subdirs.values():
            self.merge_files(sub_dcmp)

    def proc_merge(self):
        """ proc to merge with reference directory """
        # setting default src/dst directories.
        if not self.src_dir:
            self.src_dir = os.path.expandvars(f"{settings.PROJ_CFG_DIR}{os.sep}flow")
        if not self.dst_dir:
            self.dst_dir = os.getcwd()
        # check src/dst directories.
        if not os.path.isdir(self.src_dir) and not os.path.isfile(self.src_dir):
            LOG.error("source %s is not found", self.src_dir)
            raise SystemExit()
        if not os.path.isdir(self.dst_dir) and not os.path.isfile(self.dst_dir):
            LOG.error("destination %s is not found", self.dst_dir)
            raise SystemExit()
        if (os.path.isdir(self.src_dir) != os.path.isdir(self.dst_dir) or os.path.isfile(
                self.src_dir) != os.path.isfile(self.dst_dir)):
            LOG.error("invalid src/dst specification")
            raise SystemExit()
        self.src_dir = os.path.abspath(self.src_dir)
        self.dst_dir = os.path.abspath(self.dst_dir)
        # run merge
        if os.path.isdir(self.src_dir):
            LOG.info('src dir: %s', self.src_dir)
            LOG.info('dst dir: %s', self.dst_dir)
            LOG.info("please confirm to start merging")
            pcom.cfm()
            dcmp = dircmp(self.src_dir, self.dst_dir)
            self.merge_files(dcmp)
        else:
            LOG.info('src file: %s', self.src_dir)
            LOG.info('dst file: %s', self.dst_dir)
            LOG.info("please confirm to start merging")
            pcom.cfm()
            self.merge_file()

def run_merge(args):
    """to run merge sub cmd"""

    m_p = MergeProc()
    m_p.src_dir = args.src_dir
    m_p.dst_dir = args.dst_dir
    m_p.tool = args.tool

    m_p.proc_merge()
