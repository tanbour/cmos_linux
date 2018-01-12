"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: function set for booting inital env variables
"""

import os
import datetime as dt
import subprocess
from utils import pcom
from utils import settings

LOG = pcom.gen_logger(__name__)

def find_proj_root(path_str):
    """to find project root directory according to specified file"""
    if path_str == "/":
        LOG.error(
            "it's not in a project repository, please cd into one. "
            "If no project initialized, please use op init cmd to initialize one."
        )
        raise SystemExit()
    elif os.path.isfile(f"{path_str}{os.sep}{settings.FLG_FILE}"):
        return path_str
    else:
        return find_proj_root(os.path.dirname(path_str))

def find_blk_dir(proj_root, blk):
    """to find project block dir according to their dir hierarchy"""
    if blk not in settings.TREE_IGNORE_LST:
        for blk_dir in pcom.find_iter(proj_root, blk, True, True):
            return blk_dir
    tree_ignore_str = "|".join(settings.TREE_IGNORE_LST)
    run_str = f"tree -L 1 -d -I '(|{tree_ignore_str}|)' {proj_root}"
    tree_str = subprocess.run(
        run_str, shell=True, check=True, stdout=subprocess.PIPE).stdout.decode()
    LOG.error(f"block {blk} is NA; the possible blocks are {os.linesep}{tree_str}")
    raise SystemExit()

class EnvBoot(object):
    """a base class to boot project environments used only by op"""
    def __init__(self):
        proj_root_dir = find_proj_root(os.getcwd())
        os.environ["PROJ_ROOT"] = proj_root_dir
        with open(f"{proj_root_dir}{os.sep}{settings.FLG_FILE}") as f_f:
            os.environ["PROJ_NAME"] = pcom.re_str(f_f.read().strip())
        self.ced = {
            "TIME": dt.datetime.now(),
            "USER": os.environ["USER"],
            "PROJ_ROOT": os.environ["PROJ_ROOT"],
            "PROJ_NAME": os.environ["PROJ_NAME"]
        }
        self.cfg_dic = {}
    def boot_env(self, blk_name=None):
        """to boot project and block environments used only by op"""
        boot_cfg = os.path.expandvars(f"{settings.BOOT_CFG}")
        if not os.path.isfile(boot_cfg):
            LOG.error(f"boot config file {boot_cfg} is NA")
            raise SystemExit()
        self.cfg_dic = {"cmn": pcom.gen_cfg([boot_cfg])}
        if blk_name:
            env_sec_lst = ["env_proj", "env_blk"]
            self.ced["BLK_NAME"] = os.environ["BLK_NAME"] = blk_name
            self.ced["BLK_ROOT"] = os.environ["BLK_ROOT"] = find_blk_dir(
                self.ced["PROJ_ROOT"], blk_name)
        else:
            env_sec_lst = ["env_proj"]
        for env_sec in env_sec_lst:
            for env_key, env_value in (
                    self.cfg_dic["cmn"][env_sec]
                    if env_sec in self.cfg_dic["cmn"] else {}).items():
                os.environ[env_key] = os.path.expandvars(env_value)
                self.ced[env_key] = os.path.expandvars(env_value)
