"""
Author: Tsukasa Minato @ OnePiece Platform Group
Email: minato@alchip.com
Description: clean features
"""

import os
import shutil
import subprocess
from filecmp import dircmp
from core import runner_flow
from utils import pcom
from utils import settings
from utils import env_boot

LOG = pcom.gen_logger(__name__)
VIMDIFF_CMD = "gvimdiff -f"

def merge_files(dcmp):
    """ launch vimdiff for different files """
    for left_only in dcmp.left_only:
        LOG.info(f"only in working dir ({dcmp.left}) : {left_only}")
    for right_only in dcmp.right_only:
        LOG.info(f"only in reference dir ({dcmp.right}) : {right_only}")
        choice = input("Sync to work dir? [y/N]: ").lower()
        src = f"{dcmp.right}/{right_only}"
        dst = f"{dcmp.left}/{right_only}"
        if choice and choice[0] == 'y':
            if os.path.isdir(f"{src}"):
                shutil.copytree(src, dst)
            else:
                shutil.copyfile(src, dst)
        print('')
    for name in dcmp.diff_files:
        LOG.info(f"different file {name} found in {dcmp.left}")
        vimdiff_str = f"{VIMDIFF_CMD} {dcmp.left}/{name} {dcmp.right}/{name}"
        subprocess.run(vimdiff_str, shell=True)
    for sub_dcmp in dcmp.subdirs.values():
        merge_files(sub_dcmp)


def internal_merge_tool(cur_dir, ref_dir):
    """ internal merging tool """
    dcmp = dircmp(cur_dir, ref_dir)
    merge_files(dcmp)


class MergeProc(env_boot.EnvBoot):
    """merge for blocks"""
    def __init__(self):
        super().__init__()
        self.refer_dir = None
        self.tool = None

    def proc_merge(self):
        """ proc to merge with reference directory """
        if not os.path.isdir(self.refer_dir):
            LOG.error(f"reference directory {self.refer_dir} is not found")
            raise SystemExit()

        if self.tool:
            merge_str = f"{self.tool} . {self.refer_dir}"
            try:
                subprocess.run(merge_str, shell=True)
            except OSError:
                LOG.error(f"Execution failed: {merge_str}")
                raise SystemExit()
        else:
            internal_merge_tool(".", self.refer_dir)



def run_merge(args):
    """to run merge sub cmd"""

    m_p = MergeProc()
    m_p.refer_dir = args.refer_dir
    m_p.tool = args.tool

    m_p.proc_merge()
