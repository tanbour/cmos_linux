"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: base class for processing library mapping
"""

import os
import re
import fnmatch
import json
import collections
from utils import pcom

LOG = pcom.gen_logger(__name__)

class LibMap():
    """base class of library mapping processor"""
    def __init__(self):
        self.match_lst = []
    def link_src_dst(self, src_file, dst_dir, src_base):
        """to perform source to destination link action"""
        dst_file = src_file.replace(src_base.rstrip(os.sep), dst_dir.rstrip(os.sep))
        if os.path.islink(dst_file):
            os.unlink(dst_file)
        elif os.path.isfile(dst_file):
            LOG.warning("dst file %s is not a link", dst_file)
            self.match_lst.append(dst_file)
            return
        else:
            pcom.mkdir(LOG, os.path.dirname(dst_file))
        os.symlink(src_file, dst_file)
        LOG.info("linking src file %s as dst file %s", src_file, dst_file)
        self.match_lst.append(dst_file)
    def gen_link_liblist(self, dst_root, lib_dir_cfg_dic):
        """to process project or block lib mapping links"""
        LOG.info(":: library mapping of files linking ...")
        liblist_var_dic = collections.defaultdict(dict)
        for process, process_sec in lib_dir_cfg_dic.get("process", {}).items():
            if process == "DEFAULT":
                continue
            for lib_type, lib_type_sec in lib_dir_cfg_dic.get("search", {}).items():
                if lib_type == "DEFAULT":
                    continue
                can_root = pcom.ren_tempstr(
                    LOG, pcom.rd_sec(lib_type_sec, "src", True), process_sec)
                if not can_root:
                    LOG.warning(
                        "library mapping search root path option 'src' of %s "
                        "is not defined in lib/search.cfg, skipped", lib_type)
                    continue
                elif not os.path.isdir(can_root):
                    LOG.warning(
                        "library mapping search root path %s is NA", can_root)
                    continue
                can_tar = pcom.rd_sec(lib_type_sec, "dst", True)
                if not can_tar:
                    LOG.warning(
                        "library mapping destination directory option 'dst' of %s "
                        "is not defined in lib/search.cfg, skipped", lib_type)
                    continue
                LOG.info("library mapping for part %s", lib_type)
                pcom.mkdir(LOG, can_tar)
                can_ignore_lst = pcom.rd_sec(lib_type_sec, "ignore")
                can_lst = list(pcom.find_iter(can_root, "*", i_lst=can_ignore_lst))
                for lib_type_k in lib_type_sec:
                    if not lib_type_k.startswith("pattern"):
                        continue
                    pattern_search = pcom.rd_sec(lib_type_sec, lib_type_k, True)
                    var_set = set(re.findall(r"{{(.*?)}}", pattern_search))
                    for var_dic in pcom.prod_vs_iter(var_set, process_sec):
                        pattern_search_str = pcom.ren_tempstr(LOG, pattern_search, var_dic)
                        for match_file in fnmatch.filter(
                                can_lst, f"{can_root}{os.sep}{pattern_search_str}"):
                            self.link_src_dst(match_file, can_tar, can_root)
            match_lst_file = f"{dst_root}{os.sep}{process}.match_lst"
            LOG.info("generating library map list file %s", match_lst_file)
            with open(match_lst_file, "w") as mlf:
                json.dump(self.match_lst, mlf, indent=4)
            liblist_dir = f"{dst_root}{os.sep}liblist"
            pcom.mkdir(LOG, liblist_dir)
            var_name_line_dic = {}
            liblist_cfg = lib_dir_cfg_dic.get("liblist", {})
            try:
                custom_dic = {
                    c_k: pcom.rd_cfg(liblist_cfg, f"custom:{process}", c_k)
                    for c_k in liblist_cfg[f"custom:{process}"]}
            except KeyError:
                custom_dic = {}
            if "var" not in liblist_cfg:
                LOG.error("var section is NA in lib/liblist.cfg")
                raise SystemExit()
            for var_name in liblist_cfg["var"]:
                match_file_lst = []
                match_pattern_lst = (
                    custom_dic[var_name] if var_name in custom_dic
                    else pcom.rd_cfg(liblist_cfg, "var", var_name))
                for match_pattern in match_pattern_lst:
                    var_set = set(re.findall(r"{{(.*?)}}", match_pattern))
                    for var_dic in pcom.prod_vs_iter(var_set, process_sec):
                        fnmatch_lst = (
                            [pcom.ren_tempstr(LOG, match_pattern, var_dic)]
                            if var_name in custom_dic
                            else fnmatch.filter(self.match_lst, pcom.ren_tempstr(
                                LOG, match_pattern, var_dic)))
                        match_file_lst.extend(fnmatch_lst)
                var_name_line_dic[var_name] = match_file_lst
            LOG.info("generating library liblist files in %s", liblist_dir)
            #file generation and liblist dic generation for templates
            tcl_line_lst = []
            for var_name, match_file_lst in var_name_line_dic.items():
                liblist_var_dic[process][var_name] = f" \\{os.linesep} ".join(match_file_lst)
                tcl_value_str = f" \\{os.linesep}{' '*(6+len(var_name))}".join(match_file_lst)
                tcl_line_lst.append(f'set {var_name} "{tcl_value_str}"')
            with open(f"{liblist_dir}{os.sep}{process}.tcl", "w") as lltf:
                lltf.write(os.linesep.join(tcl_line_lst))
            self.match_lst = []
        with open(f"{liblist_dir}{os.sep}liblist.json", "w") as lljf:
            json.dump(liblist_var_dic, lljf, indent=4)
    @classmethod
    def load_liblist(cls, liblist_root, lib_dir_cfg_dic):
        """to load flow level liblist json"""
        liblist_dir = f"{liblist_root}{os.sep}liblist"
        try:
            with open(f"{liblist_dir}{os.sep}liblist.json") as lljf:
                liblist_var_dic = json.load(lljf)
        except FileNotFoundError:
            LOG.warning("library mapping generated file is NA")
            liblist_var_dic = {}
        for ll_type, ll_type_sec in lib_dir_cfg_dic.get("liblist", {}).items():
            if not ll_type.startswith("custom"):
                continue
            process = ll_type[7:]
            for cus_k in ll_type_sec:
                match_file_lst = []
                for match_pattern in pcom.rd_sec(ll_type_sec, cus_k):
                    var_set = set(re.findall(r"{{(.*?)}}", match_pattern))
                    for var_dic in pcom.prod_vs_iter(
                            var_set, dict(lib_dir_cfg_dic.get("process", {})).get(process, {})):
                        match_file_lst.extend([pcom.ren_tempstr(LOG, match_pattern, var_dic)])
                if process in liblist_var_dic and cus_k in liblist_var_dic[process]:
                    liblist_var_dic[process][cus_k] = f" \\{os.linesep} ".join(match_file_lst)
        return liblist_var_dic
