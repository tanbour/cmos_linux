"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: base class for booting inital project and block env variables
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
    def __init__(self, blk_name=None, admin_flg=False):
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
        if blk_name:
            if admin_flg:
                os.makedirs(f"{self.ced['PROJ_ROOT']}{os.sep}{blk_name}", exist_ok=True)
            self.ced["BLK_NAME"] = os.environ["BLK_NAME"] = blk_name
            self.ced["BLK_ROOT"] = os.environ["BLK_ROOT"] = find_blk_dir(
                self.ced["PROJ_ROOT"], blk_name)
        self.admin_flg = admin_flg
    def proc_ced(self):
        """to process project and block global env dic used only by op"""
        boot_cfg = os.path.expandvars(f"{settings.BOOT_CFG}")
        if not os.path.isfile(boot_cfg):
            LOG.error(f"boot config file {boot_cfg} is NA")
            raise SystemExit()
        self.cfg_dic = {"cmn": pcom.gen_cfg([boot_cfg])}
        for cmn_sec, cmn_sec_dic in self.cfg_dic["cmn"].items():
            if not cmn_sec.startswith("env_"):
                continue
            for env_key, env_value in cmn_sec_dic.items():
                os.environ[env_key] = os.path.expandvars(env_value)
                self.ced[env_key] = os.path.expandvars(env_value)
    def proc_cfg(self):
        """to process project and block global cfg dic used only by op"""
        for proj_cfg in pcom.find_iter(self.ced["PROJ_SHARE_CFG"], "proj_*", cur_flg=True):
            cfg_kw = os.path.splitext(os.path.basename(proj_cfg))[0][5:]
            blk_cfg = f"{self.ced['BLK_CFG']}{os.sep}blk_{cfg_kw}.cfg"
            if self.admin_flg:
                os.makedirs(os.path.dirname(blk_cfg), exist_ok=True)
                with open(proj_cfg) as pcf, open(blk_cfg, "w") as bcf:
                    for line in pcf:
                        bcf.write(f"# {line}")
            else:
                if not os.path.isfile(blk_cfg):
                    LOG.warning(f"block config file {blk_cfg} is NA")
                self.cfg_dic[cfg_kw] = pcom.gen_cfg([proj_cfg, blk_cfg])
    def boot_env(self):
        """class top exec function"""
        self.proc_ced()
        self.proc_cfg()
