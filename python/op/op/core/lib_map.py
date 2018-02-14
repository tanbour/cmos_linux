"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: base class for processing library mapping
"""

import os
import re
import fnmatch
import json
from utils import pcom

LOG = pcom.gen_logger(__name__)

class LibMap(object):
    """base class of library mapping processor"""
    def __init__(self):
        self.match_lst = []
    def link_src_dst(self, src_file, dst_dir, src_base):
        """to perform source to destination link action"""
        dst_file = src_file.replace(src_base.rstrip(os.sep), dst_dir.rstrip(os.sep))
        if os.path.islink(dst_file):
            os.unlink(dst_file)
        elif os.path.isfile(dst_file):
            LOG.warning(f"dst file {dst_file} is not a link")
            self.match_lst.append(dst_file)
            return
        else:
            pcom.mkdir(LOG, os.path.dirname(dst_file))
        os.symlink(src_file, dst_file)
        LOG.info(f"linked src file {src_file} as dst file {dst_file}")
        self.match_lst.append(dst_file)
    def link_file(self, dst_root, lib_dir_cfg_dic, cfg_dic):
        """to process project or block lib mapping links"""
        LOG.info(f":: library mapping and files linking ...")
        for lib_file, lib_file_cfg in lib_dir_cfg_dic.items():
            if lib_file == "liblist":
                continue
            can_root = pcom.rd_cfg(cfg_dic["proj"], "lib", lib_file, True)
            can_tar = pcom.rd_cfg(cfg_dic["proj"], "lib", f"{lib_file}_dst", True)
            if not can_root:
                LOG.error(
                    f"library mapping search root path of {lib_file} "
                    f"is not defined in proj.cfg")
                raise SystemExit()
            if not can_tar:
                LOG.error(f"no {lib_file} destination directory specified in {lib_file}.cfg")
                raise SystemExit()
            pcom.mkdir(LOG, can_tar)
            can_ignore_lst = pcom.rd_cfg(cfg_dic["proj"], "lib", f"{lib_file}_ignore")
            can_lst = [
                c_c for c_c in pcom.find_iter(can_root, "*")
                if not any([ccc in c_c for ccc in can_ignore_lst])]
            for link_sec_k, link_sec_v in lib_file_cfg.items():
                if link_sec_k == "DEFAULT":
                    continue
                if "_pattern_search" not in link_sec_v:
                    LOG.error(
                        f"option _pattern_search not in section {link_sec_k} of file {lib_file}")
                    raise SystemExit()
                pattern_search = pcom.rd_cfg(
                    lib_file_cfg, link_sec_k, "_pattern_search", True)
                var_lst = re.findall(r"{{(.*?)}}", pattern_search)
                for var_dic in pcom.prod_vs_iter(var_lst, link_sec_v):
                    pattern_search_str = pcom.ren_tempstr(LOG, pattern_search, var_dic)
                    for match_file in fnmatch.filter(
                            can_lst, f"{can_root}{os.sep}{pattern_search_str}"):
                        self.link_src_dst(match_file, can_tar, can_root)
        match_lst_file = f"{dst_root}{os.sep}.match_lst"
        LOG.info(f":: generating library map list file {match_lst_file} ...")
        with open(match_lst_file, "w") as mlf:
            json.dump(self.match_lst, mlf, indent=4)
    @classmethod
    def gen_liblist(cls, map_root, liblist_root, liblist_cfg, lib_sec):
        """to generate project or block liblist files"""
        match_lst_file = f"{map_root}{os.sep}.match_lst"
        LOG.info(f":: loading library map list file {match_lst_file} ...")
        try:
            with open(match_lst_file) as mlf:
                lib_match_lst = json.load(mlf)
        except FileNotFoundError:
            LOG.warning(f"library map list file not generated in {map_root}")
            return {}
        liblist_dir = f"{liblist_root}{os.sep}liblist"
        pcom.mkdir(LOG, liblist_dir)
        var_name_line_dic = {}
        try:
            custom_dic = {
                c_k: pcom.rd_cfg(liblist_cfg, "custom", c_k)
                for c_k in liblist_cfg["custom"]}
        except KeyError:
            custom_dic = {}
        if "var" not in liblist_cfg:
            LOG.error("var section is NA in liblist.cfg")
            raise SystemExit()
        for var_name in liblist_cfg["var"]:
            if var_name in custom_dic:
                match_file_lst = custom_dic[var_name]
            else:
                match_file_lst = []
                for match_pattern in pcom.rd_cfg(liblist_cfg, "var", var_name):
                    var_lst = re.findall(r"{{(.*?)}}", match_pattern)
                    for var_dic in pcom.prod_vs_iter(var_lst, lib_sec):
                        match_file_lst.extend(fnmatch.filter(
                            lib_match_lst, pcom.ren_tempstr(LOG, match_pattern, var_dic)))
            var_name_line_dic[var_name] = match_file_lst
        LOG.info(f":: generating library liblist files in {liblist_dir} ...")
        #file generation and liblist dic generation for templates
        liblist_var_dic = {}
        tcl_line_lst = []
        for var_name, match_file_lst in var_name_line_dic.items():
            liblist_var_dic[var_name] = f" \\{os.linesep} ".join(match_file_lst)
            tcl_value_str = f" \\{os.linesep}{' '*(6+len(var_name))}".join(match_file_lst)
            tcl_line_lst.append(f'set {var_name} "{tcl_value_str}"')
        with open(f"{liblist_dir}{os.sep}liblist.tcl", "w") as lltf:
            lltf.write(os.linesep.join(tcl_line_lst))
        return liblist_var_dic
