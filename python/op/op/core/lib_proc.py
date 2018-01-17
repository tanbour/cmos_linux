"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: base class for processing library mapping
"""

import os
import itertools
import fnmatch
import jinja2
from utils import pcom

LOG = pcom.gen_logger(__name__)

class LibProc(object):
    """base class of library mapping processor"""
    def __init__(self):
        self.match_lst = []
    @classmethod
    def check_sec(cls, str_lst, sec):
        """to check whether particular options in the section or not"""
        for str_item in str_lst:
            if str_item not in sec:
                LOG.critical(f"option {str_item} not in section {sec}")
                raise SystemExit()
    @classmethod
    def check_str(cls, key_str, str_lst):
        """to check whether unassigned variables in search path or not"""
        for str_item in str_lst:
            if key_str in str_item:
                LOG.critical(f"search path {str_item} has unassigned variable")
                raise SystemExit()
    def link_src_dst(self, src_file, dst_dir, src_base):
        """to perform source to destination link action"""
        dst_file = f"{dst_dir}{os.sep}{src_file.replace(src_base, '')}"
        if os.path.islink(dst_file):
            os.unlink(dst_file)
        elif os.path.isfile(dst_file):
            LOG.warning(f"dst file {dst_file} is not a link")
            return
        else:
            os.makedirs(os.path.dirname(dst_file), exist_ok=True)
        os.symlink(src_file, dst_file)
        LOG.info(f"linked src file {src_file} as dst file {dst_file}")
        self.match_lst.append(dst_file)
    def proc_link_cfg(self, lib_src_root, lib_link_cfg_lst):
        """to process project or block lib mapping links"""
        can_lst = list(pcom.find_iter(lib_src_root, "*"))
        for lib_link_cfg in lib_link_cfg_lst:
            sec_dic = {}
            for sec_name, link_sec in lib_link_cfg.items():
                if sec_name == "DEFAULT":
                    continue
                if sec_name in sec_dic:
                    LOG.error(f"section {sec_name} is duplicated")
                    raise SystemExit()
                sec_dic[sec_name] = lib_link_cfg
                self.check_sec(["_path_search", "_pattern_search", "_path_dst"], link_sec)
                path_search = pcom.rd_cfg(
                    lib_link_cfg, sec_name, "_path_search", True, r_flg=True)
                pattern_search = pcom.rd_cfg(
                    lib_link_cfg, sec_name, "_pattern_search", True, r_flg=True)
                path_dst = pcom.rd_cfg(
                    lib_link_cfg, sec_name, "_path_dst", True, r_flg=True)
                opt_k_lst = []
                opt_v_lst = []
                for opt_k, opt_v in link_sec.items():
                    if not opt_v:
                        LOG.critical(f"option value of {opt_k} from link {sec_name} is NA")
                        raise SystemExit()
                    opt_k_lst.append(opt_k)
                    opt_v_lst.append(pcom.rd_cfg(lib_link_cfg, sec_name, opt_k))
                for opt_tup in itertools.product(*opt_v_lst):
                    var_glob_dic = {}
                    for index, opt_v in enumerate(opt_tup):
                        var_glob_dic[opt_k_lst[index]] = opt_v
                    path_search_str = jinja2.Template(path_search).render(var_glob_dic)
                    pattern_search_str = jinja2.Template(pattern_search).render(var_glob_dic)
                    path_dst_str = jinja2.Template(path_dst).render(var_glob_dic)
                    match_str = f"{path_search_str}{os.sep}{pattern_search_str}"
                    self.check_str(
                        "{{", [path_search_str, pattern_search_str, path_dst_str, match_str])
                    for match_file in fnmatch.filter(can_lst, match_str):
                        self.link_src_dst(match_file, path_dst_str, path_search_str)
    def proc_lib_cfg(self, lib_cfg):
        """to process project or block lib mapping cfg"""
        LOG.info("processing library mapping cfg ...")
        for sec_name, map_sec in lib_cfg.items():
            if sec_name == "DEFAULT":
                continue
            for opt_k in map_sec:
                if not opt_k.startswith("_"):
                    continue
                opt_v_lst = []
                for opt_v in pcom.rd_cfg(lib_cfg, sec_name, opt_k):
                    opt_v_lst.extend(fnmatch.filter(self.match_lst, opt_v))
                lib_cfg[sec_name][opt_k] = ", ".join(opt_v_lst)
        LOG.info("done")
