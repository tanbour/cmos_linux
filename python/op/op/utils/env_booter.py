"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: EnvBooter class for booting inital env variables
"""

import os
import datetime as dt
import subprocess
import copy
from utils import pcom
from utils import settings

LOG = pcom.gen_logger(__name__)

def find_proj_root(path_str):
    """to find project root directory according to specified file"""
    if path_str == "/":
        LOG.error("it's not in a project repository")
        os.sys.exit()
    elif os.path.isfile(f"{path_str}{os.sep}{pcom.FLAG_FILE}"):
        return path_str
    else:
        return find_proj_root(os.path.dirname(path_str))

def find_module_dir(ced, cfg_dic, module):
    """to find verification module dir according to their subdir config"""
    if module not in settings.tree_ignore_lst:
        for module_dir in pcom.find_iter(ced["PROJ_VERIF"], module, True, True):
            return module_dir
    tree_ignore_str = "|".join(settings.tree_ignore_lst)
    run_str = f"tree -L 1 -d -I '(|{tree_ignore_str}|)' {ced['PROJ_ROOT']}"
    tree_str = subprocess.run(
        run_str, shell=True, check=True, stdout=subprocess.PIPE).stdout.decode()
    LOG.error(f"module {module} is NA; the possible module is {os.linesep}{tree_str}")
    os.sys.exit()

class EnvBooter(object):
    """environment booter for pj"""
    def __init__(self):
        self.ced = {}
        self.cfg_dic = {}
    def boot_env(self):
        """to boot environments used only by op"""
        os.environ["PROJ_ROOT"] = find_proj_root(os.getcwd())
        self.ced = {
            "PROJ_ROOT": os.environ["PROJ_ROOT"],
            "TIME": dt.datetime.now(),
            "USER_NAME": os.environ["USER"]}
        proj_cmn_cfg = os.path.expandvars(settings.proj_cmn_cfg)
        if not os.path.isfile(proj_cfg):
            LOG.error(f"proj config file {proj_cfg} is NA")
            os.sys.exit()
        self.cfg_dic = {"proj": pcom.gen_cfg([proj_cfg])}
        for env_key, env_value in (
                self.cfg_dic["proj"]["boot_env"] if "boot_env" in self.cfg_dic["proj"]
                else {}).items():
            os.environ[env_key] = os.path.expandvars(env_value)
            self.ced[env_key] = os.path.expandvars(env_value)
        return self.ced, self.cfg_dic
    def module_env(self, sim_module):
        """to boot verification module level environments used only by pj"""
        self.boot_env()
        self.ced["MODULE"] = os.environ["MODULE"] = sim_module
        self.ced["PROJ_MODULE"] = os.environ["PROJ_MODULE"] = find_module_dir(
            self.ced, self.cfg_dic, sim_module)
        for env_key, env_value in (
                self.cfg_dic["proj"]["module_env"] if "module_env" in self.cfg_dic["proj"]
                else {}).items():
            os.environ[env_key] = os.path.expandvars(env_value)
            self.ced[env_key] = os.path.expandvars(env_value)
        c_cfg = f"{self.ced['MODULE_CONFIG']}{os.sep}c.cfg"
        if not os.path.isfile(c_cfg):
            c_cfg = ""
        self.cfg_dic["c"] = pcom.gen_cfg([c_cfg])
        simv_cfg = f"{self.ced['MODULE_CONFIG']}{os.sep}simv.cfg"
        if not os.path.isfile(simv_cfg):
            raise Exception(f"simv config file {simv_cfg} is NA")
        self.cfg_dic["simv"] = pcom.gen_cfg([simv_cfg])
        case_cfg = f"{self.ced['MODULE_CONFIG']}{os.sep}case.cfg"
        if not os.path.isfile(case_cfg):
            raise Exception(f"case config file {case_cfg} is NA")
        case_cfg_lst = [case_cfg]
        for cfg_file in pcom.find_iter(self.ced["MODULE_CONFIG"], "case_*.cfg"):
            LOG.info("more case config file %s", cfg_file)
            case_cfg_lst.append(cfg_file)
        case_cfg_lst.reverse()
        self.cfg_dic["case"] = pcom.gen_cfg(case_cfg_lst)
        c_module_env = copy.copy(
            self.cfg_dic["proj"]["env_c"] if "env_c" in self.cfg_dic["proj"] else {})
        simv_module_env = copy.copy(
            self.cfg_dic["proj"]["env_simv"] if "env_simv" in self.cfg_dic["proj"] else {})
        case_module_env = copy.copy(
            self.cfg_dic["proj"]["env_case"] if "env_case" in self.cfg_dic["proj"] else {})
        c_module_env.update(self.cfg_dic["c"]["DEFAULT"])
        simv_module_env.update(self.cfg_dic["simv"]["DEFAULT"])
        case_module_env.update(self.cfg_dic["case"]["DEFAULT"])
        self.cfg_dic["c"]["DEFAULT"] = c_module_env
        self.cfg_dic["simv"]["DEFAULT"] = simv_module_env
        self.cfg_dic["case"]["DEFAULT"] = case_module_env
        return self.ced, self.cfg_dic
