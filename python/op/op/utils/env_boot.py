"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: base class for booting inital project and block env variables
"""

import os
import datetime as dt
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

def find_blk_root(path_str, proj_root):
    """to find project block dir according to their dir hierarchy"""
    path_str = path_str.rstrip(os.sep)
    if proj_root not in path_str:
        LOG.error(
            "it's not in a project repository, please cd into one. "
            "If no project initialized, please use op init cmd to initialize one."
        )
        raise SystemExit()
    blk_name = path_str.replace(proj_root, "").strip(os.sep).split(os.sep)[0]
    if proj_root == path_str or blk_name in settings.BLK_IGNORE_LST:
        LOG.info(" not in a block directory, block level features off")
        return ""
    return f"{proj_root}{os.sep}{blk_name}"

class EnvBoot(object):
    """a base class to boot project environments used only by op"""
    def __init__(self):
        env_path = os.getcwd()
        proj_root_dir = find_proj_root(env_path)
        blk_root_dir = find_blk_root(env_path, proj_root_dir)
        try:
            self.ced = {"USER": os.environ["USER"]}
        except KeyError:
            LOG.error("USER env variable is not defined")
            raise SystemExit()
        self.ced["PROJ_ROOT"] = os.environ["PROJ_ROOT"] = proj_root_dir
        with open(f"{proj_root_dir}{os.sep}{settings.FLG_FILE}") as f_f:
            self.ced["PROJ_NAME"] = os.environ["PROJ_NAME"] = pcom.re_str(f_f.read().strip())
        op_dt = dt.datetime.now()
        self.ced["DATETIME"] = op_dt
        self.ced["DATE"] = os.environ["DATE"] = op_dt.strftime("%y%m%d")
        self.ced["TIME"] = os.environ["TIME"] = op_dt.strftime("%H%M%S")
        self.cfg_dic = {}
        self.dir_cfg_dic = {}
        if blk_root_dir:
            self.blk_flg = True
            self.ced["BLK_NAME"] = os.environ["BLK_NAME"] = os.path.basename(blk_root_dir)
            self.ced["BLK_ROOT"] = os.environ["BLK_ROOT"] = blk_root_dir
        else:
            self.blk_flg = False
        # used to provide the default comment options for blocks
        self.proj_cfg_lst = []
    def boot_ver(self):
        """to find version defination in block level config"""
        ver_set = set()
        for cfg_file in pcom.find_iter(
                os.path.expandvars(settings.BLK_CFG_DIR), "*.cfg", cur_flg=True):
            for sec_k, sec_v in pcom.gen_cfg([cfg_file]).items():
                for opt_k, opt_v in sec_v.items():
                    if not opt_v:
                        continue
                    if opt_k.startswith("VERSION_"):
                        if opt_k in ver_set:
                            LOG.error(
                                f"multiple defination of {opt_k} in blk config "
                                f"{cfg_file} {sec_k}"
                            )
                            raise SystemExit()
                        ver_key = opt_k.replace("VERSION_", "").lower()
                        key_dir = f"{self.ced['BLK_ROOT']}{os.sep}{ver_key}{os.sep}{opt_v}"
                        if not os.path.isdir(key_dir):
                            LOG.error(
                                f"{ver_key} version dir {key_dir} is NA, "
                                f"defined in blk config {cfg_file} {sec_k}"
                            )
                            raise SystemExit()
                        if not os.listdir(key_dir):
                            LOG.error(
                                f"{ver_key} version dir {key_dir} is empty, "
                                f"defined in blk config {cfg_file} {sec_k}"
                            )
                            raise SystemExit()
                        ver_set.add(opt_k)
                        self.ced[opt_k] = os.environ[opt_k] = opt_v
    def boot_ced(self):
        """to process project and block global env dic used only by op"""
        boot_cfg = os.path.expandvars(settings.BOOT_CFG)
        if not os.path.isfile(boot_cfg):
            LOG.error(f"boot config file {boot_cfg} is NA")
            raise SystemExit()
        self.cfg_dic = {"proj": pcom.gen_cfg([boot_cfg])}
        if self.blk_flg:
            self.boot_ver()
        for proj_sec_k, proj_sec_v in self.cfg_dic["proj"].items():
            if not proj_sec_k.startswith("env_"):
                continue
            if not self.blk_flg and proj_sec_k != "env_proj":
                continue
            for env_opt_k, env_opt_v in proj_sec_v.items():
                env_opt_v = os.path.expandvars(env_opt_v).rstrip(os.sep)
                os.environ[env_opt_k] = env_opt_v
                self.ced[env_opt_k] = env_opt_v
    def boot_cfg(self):
        """to process project and block global cfg dic used only by op"""
        base_proj_cfg_dir = os.path.expandvars(settings.PROJ_CFG_DIR).rstrip(os.sep)
        base_blk_cfg_dir = os.path.expandvars(settings.BLK_CFG_DIR).rstrip(os.sep)
        for proj_cfg in pcom.find_iter(base_proj_cfg_dir, "*.cfg", cur_flg=True):
            cfg_kw = os.path.splitext(os.path.basename(proj_cfg))[0]
            if cfg_kw == "proj":
                continue
            self.proj_cfg_lst.append(proj_cfg)
            if self.blk_flg:
                blk_cfg = proj_cfg.replace(base_proj_cfg_dir, base_blk_cfg_dir)
                if not os.path.isfile(blk_cfg):
                    LOG.warning(f" block config file {blk_cfg} is NA")
                self.cfg_dic[cfg_kw] = pcom.gen_cfg([proj_cfg, blk_cfg])
            else:
                self.cfg_dic[cfg_kw] = pcom.gen_cfg([proj_cfg])
        # dir cfgs of project level invisible to blocks
        for proj_cfg_dir in pcom.find_iter(base_proj_cfg_dir, "*", True, True):
            cfg_dir_kw = os.path.basename(proj_cfg_dir)
            self.dir_cfg_dic[cfg_dir_kw] = {}
            for proj_cfg in pcom.find_iter(proj_cfg_dir, "*.cfg", cur_flg=True):
                cfg_kw = os.path.splitext(os.path.basename(proj_cfg))[0]
                self.dir_cfg_dic[cfg_dir_kw][cfg_kw] = pcom.gen_cfg([proj_cfg])
    def boot_env(self):
        """class top exec function"""
        LOG.info(":: booting env and processing configs ...")
        self.boot_ced()
        self.boot_cfg()
