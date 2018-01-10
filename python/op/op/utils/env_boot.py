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
        LOG.error("it's not in a project repository")
        os.sys.exit()
    elif os.path.isfile(f"{path_str}{os.sep}{settings.flag_file}"):
        return path_str
    else:
        return find_proj_root(os.path.dirname(path_str))

def find_module_dir(ced, module):
    """to find verification module dir according to their subdir config"""
    if module not in settings.tree_ignore_lst:
        for module_dir in pcom.find_iter(ced["PROJ_ROOT"], module, True, True):
            return module_dir
    tree_ignore_str = "|".join(settings.tree_ignore_lst)
    run_str = f"tree -L 1 -d -I '(|{tree_ignore_str}|)' {ced['PROJ_ROOT']}"
    tree_str = subprocess.run(
        run_str, shell=True, check=True, stdout=subprocess.PIPE).stdout.decode()
    LOG.error(f"module {module} is NA; the possible module is {os.linesep}{tree_str}")
    os.sys.exit()

def boot_env(blk_name=None):
    """to boot project environments used only by op"""
    os.environ["PROJ_ROOT"] = find_proj_root(os.getcwd())
    ced = {
        "PROJ_ROOT": os.environ["PROJ_ROOT"],
        "TIME": dt.datetime.now(),
        "USER_NAME": os.environ["USER"]}
    proj_cmn_cfg = os.path.expandvars(f"{settings.proj_cfg_dir}{os.sep}proj_cmn.cfg")
    if not os.path.isfile(proj_cfg):
        LOG.error(f"proj config file {proj_cfg} is NA")
        os.sys.exit()
    cfg_dic = {"cmn": pcom.gen_cfg([proj_cmn_cfg])}
    if blk_name:
        env_sec_lst = ["env_proj", "env_blk"]
        ced["BLK_NAME"] = os.environ["BLK_NAME"] = blk_name
        ced["BLK_ROOT"] = os.environ["BLK_ROOT"] = find_module_dir(ced, blk_name)
    else:
        env_sec_lst = ["env_proj"]
    for env_sec in env_sec_lst:
        for env_key, env_value in (
                cfg_dic["cmn"][env_sec] if env_sec in cfg_dic["cmn"] else {}).items():
            os.environ[env_key] = os.path.expandvars(env_value)
            ced[env_key] = os.path.expandvars(env_value)
    return ced, cfg_dic
