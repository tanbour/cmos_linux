"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: fundamental functions and classes
"""

import os
import re
import logging.config
import fnmatch
import configparser
import itertools
import pprint
import psutil
import jinja2

def gen_logger(logger_name, file_flg=False):
    """to generate system loggers"""
    logging_dic = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "color": {
                "format": "{asctime} {levelname} [{name}] {message}",
                "datefmt": "%H:%M:%S",
                "style": "{",
                "class": "utils.pcom.ColoredFormatter"
            },
        },
        "handlers": {
            "console": {
                "level": "INFO",
                "class": "logging.StreamHandler",
                "formatter": "color"
            },
        },
        "loggers": {
            "": {
                "handlers": ["console"],
                "level": "DEBUG"
            }
        }
    }
    if file_flg:
        logging_dic["formatters"].update({
            "common": {
                "format": "{asctime} {name} {funcName} {lineno} [{levelname}] {message}",
                "style": "{"
            }
        })
        logging_dic["handlers"].update({
            "file": {
                "level": "DEBUG",
                "class": "logging.handlers.RotatingFileHandler",
                "formatter": "common",
                "filename": "op.log"
            }
        })
        logging_dic["loggers"][""]["handlers"].append("file")
    logging.config.dictConfig(logging_dic)
    logger = logging.getLogger(logger_name)
    return logger

def gen_cfg(cfg_file_iter, dlts=("=", ":")):
    """to generate op system config by reading config files"""
    config = configparser.ConfigParser(allow_no_value=True, delimiters=dlts)
    config.optionxform = str
    config.SECTCRE = re.compile(r"\[\s*(?P<header>[^]]+?)\s*\]")
    for cfg_file in cfg_file_iter:
        config.read(cfg_file)
    return config

def rd_cfg(cfg, sec, opt, s_flg=False, fbk="", r_flg=False):
    """to read config to get corresponding section and option"""
    value_str = os.path.expandvars(cfg.get(sec, opt, fallback=""))
    if not value_str:
        value_str = fbk
    if r_flg:
        cfg.remove_option(sec, opt)
    split_str = rf"{os.linesep}" if opt.endswith("_opts") else rf",|{os.linesep}"
    cfg_lst = [cc.strip() for cc in re.split(split_str, value_str) if cc]
    return cfg_lst if not s_flg else (cfg_lst[0] if cfg_lst else "")

def rd_sec(sec, opt, s_flg=False, fbk="", r_flg=False):
    """to read section to get corresponding option"""
    value_str = os.path.expandvars(sec.get(opt, fallback=""))
    if not value_str:
        value_str = fbk
    if r_flg:
        sec.pop(opt)
    split_str = rf"{os.linesep}" if opt.endswith("_opts") else rf",|{os.linesep}"
    cfg_lst = [cc.strip() for cc in re.split(split_str, value_str) if cc]
    return cfg_lst if not s_flg else (cfg_lst[0] if cfg_lst else "")

def ch_cfg(cfg):
    """to change cfg into nested dict and making possible lists"""
    cfg_dic = {}
    for sec_k, sec_v in cfg.items():
        cfg_dic[sec_k] = {}
        for opt_k, opt_v in sec_v.items():
            cfg_dic[sec_k][opt_k] = (
                opt_v if "," not in opt_v and os.linesep not in opt_v
                else rd_cfg(cfg, sec_k, opt_k))
    return cfg_dic

def prod_sec_iter(sec):
    """to change section to item dictionary list by product loop"""
    k_lst = []
    v_lst = []
    for opt_k, opt_v in sec.items():
        k_lst.append(opt_k)
        v_lst.append(rd_sec(sec, opt_k))
    for opt_tup in itertools.product(*v_lst):
        item_dic = {}
        for index, opt_v in enumerate(opt_tup):
            item_dic[k_lst[index]] = opt_v
        yield item_dic

def find_iter(path, pattern, dir_flg=False, cur_flg=False, i_str=""):
    """to find dirs and files in specified path recursively"""
    if cur_flg:
        find_lst = os.listdir(path)
        for find_name in fnmatch.filter(find_lst, pattern):
            if i_str and i_str in find_name:
                continue
            root_find_name = os.path.join(path, find_name)
            if os.access(root_find_name, os.R_OK):
                if dir_flg and os.path.isdir(root_find_name):
                    yield root_find_name
                elif not dir_flg and os.path.isfile(root_find_name):
                    yield root_find_name
    else:
        for root_name, dir_name_lst, file_name_lst in os.walk(path, followlinks=False):
            find_lst = dir_name_lst if dir_flg else file_name_lst
            for find_name in fnmatch.filter(find_lst, pattern):
                if i_str and i_str in find_name:
                    continue
                root_find_name = os.path.join(root_name, find_name)
                if os.access(root_find_name, os.R_OK):
                    yield root_find_name

def re_str(i_str):
    """to convert any string into re [A-Za-z0-9_] string"""
    return re.sub(r"\W", "_", i_str)

def cfm(exit_str="action aborted"):
    """to prompt in stdout about the confirmation of actions"""
    apply_rsp = input("--> yes or no? ")
    if apply_rsp.strip() not in ("yes", "ye", "y"):
        raise SystemExit(exit_str)

def pp_list(pp_obj, str_flg=False):
    """to pretty print list infomation"""
    appfix_str = '*'*30
    print(appfix_str)
    if str_flg:
        print(pp_obj)
    else:
        pprint.pprint(pp_obj, width=-1)
    print(appfix_str)

def pterminate(proc_pid):
    """to terminate specified process according to pid"""
    proc = psutil.Process(proc_pid)
    for sub_proc in proc.children(recursive=True):
        sub_proc.terminate()
    proc.terminate()

def pkill(proc_pid):
    """to kill specified process according to pid"""
    proc = psutil.Process(proc_pid)
    for sub_proc in proc.children(recursive=True):
        sub_proc.kill()
    proc.kill()

def ren_tempfile(log, temp_in, temp_out, temp_dic):
    """to render jinja2 template file"""
    try:
        template_loader = jinja2.FileSystemLoader(os.path.dirname(temp_in))
        template_env = jinja2.Environment(loader=template_loader)
        template = template_env.get_template(os.path.basename(temp_in))
        os.makedirs(os.path.dirname(temp_out), exist_ok=True)
        with open(temp_out, "w") as ttf:
            ttf.write(template.render(temp_dic))
    except jinja2.exceptions.TemplateError as err:
        log.error(
            f"generating from template {temp_in} failed, "
            f"and the error is {err}"
        )
        raise SystemExit()
    except PermissionError as err:
        log.error(err)
        raise SystemExit()

def ren_tempstr(log, temp_in, temp_dic):
    """to render jinja2 template string"""
    try:
        temp_out = jinja2.Template(temp_in).render(temp_dic)
    except jinja2.exceptions.TemplateError as err:
        log.error(
            f"generating from template str {temp_in} failed, "
            f"and the error is {err}"
        )
        raise SystemExit()
    else:
        return temp_out

def mkdir(log, path):
    """to mkdir for common usage"""
    try:
        os.makedirs(path, exist_ok=True)
    except PermissionError as err:
        log.error(err)
        raise SystemExit()

class ColoredFormatter(logging.Formatter):
    """op colored logging formatter"""
    def format(self, record):
        log_colors = {
            "DEBUG": "\033[1;35m[DEBUG]\033[1;0m",
            "INFO": "\033[1;34m[INFO]\033[1;0m",
            "WARNING": "\033[1;33m[WARNING]\033[1;0m",
            "ERROR": "\033[1;31m[ERROR]\033[1;0m",
            "CRITICAL": "\033[1;31m[CRITICAL]\033[1;0m"
        }
        level_name = record.levelname
        msg = logging.Formatter.format(self, record)
        return msg.replace(level_name, log_colors.get(level_name, level_name))

class REOpter(object):
    """customized class for reusing regex matching pattern groups"""
    def __init__(self, i_str):
        self.i_str = i_str
        self.re_result = None
    def match(self, re_pat):
        """to reuse regex match method"""
        self.re_result = re_pat.match(self.i_str)
        return bool(self.re_result)
    def search(self, re_pat):
        """to reuse regex search method"""
        self.re_result = re_pat.search(self.i_str)
        return bool(self.re_result)
    def group(self, i):
        """to invoke regex matched group content"""
        return self.re_result.group(i)
