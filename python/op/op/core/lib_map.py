"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: base class for processing library mapping
"""

import os
import itertools
import fnmatch
import json
import jinja2
from utils import pcom

LOG = pcom.gen_logger(__name__)

class LibMap(object):
    """base class of library mapping processor"""
    def __init__(self):
        self.match_lst = []
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
    def link_lib(self, lib_src_root, lib_dst_root, lib_link_cfg_dic):
        """to process project or block lib mapping links"""
        can_lst = list(pcom.find_iter(lib_src_root, "*"))
        for lib_link_name, lib_link_cfg in lib_link_cfg_dic.items():
            sec_dic = {}
            for sec_name, link_sec in lib_link_cfg.items():
                if sec_name == "DEFAULT":
                    continue
                if sec_name in sec_dic:
                    LOG.error(f"section {sec_name} is duplicated")
                    raise SystemExit()
                sec_dic[sec_name] = lib_link_cfg
                if "_pattern_search" not in link_sec:
                    LOG.error(f"option _pattern_search not in section {sec_name}")
                    raise SystemExit()
                pattern_search = pcom.rd_cfg(
                    lib_link_cfg, sec_name, "_pattern_search", True, r_flg=True)
                opt_k_lst = []
                opt_v_lst = []
                for opt_k, opt_v in link_sec.items():
                    if not opt_v:
                        LOG.error(f"option value of {opt_k} from link {sec_name} is NA")
                        raise SystemExit()
                    opt_k_lst.append(opt_k)
                    opt_v_lst.append(pcom.rd_cfg(lib_link_cfg, sec_name, opt_k))
                for opt_tup in itertools.product(*opt_v_lst):
                    var_glob_dic = {}
                    for index, opt_v in enumerate(opt_tup):
                        var_glob_dic[opt_k_lst[index]] = opt_v
                    pattern_search_str = jinja2.Template(pattern_search).render(var_glob_dic)
                    if "{{" in pattern_search_str:
                        LOG.error(f"search path {pattern_search_str} has unassigned variable")
                        raise SystemExit()
                    for match_file in fnmatch.filter(
                            can_lst, f"{lib_src_root}{os.sep}{pattern_search_str}"):
                        self.link_src_dst(
                            match_file, f"{lib_dst_root}{os.sep}{lib_link_name}", lib_src_root)
        with open(f"{lib_dst_root}{os.sep}.match_lst", "w") as mlf:
            json.dump(self.match_lst, mlf)
