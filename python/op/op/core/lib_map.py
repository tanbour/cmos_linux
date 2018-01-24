"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: base class for processing library mapping
"""

import os
import itertools
import fnmatch
import json
import copy
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
    @classmethod
    def flat_sec(cls, sec):
        """to flatten section for next step product loop"""
        k_lst = []
        v_lst = []
        for opt_k, opt_v in sec.items():
            if not opt_v:
                LOG.warning(f"option value of {opt_k} is NA")
            k_lst.append(opt_k)
            v_lst.append(pcom.rd_sec(sec, opt_k))
        return k_lst, v_lst
    def link_lib(self, lib_src_root, lib_dst_root, lib_dir_cfg_dic, cfg_dic):
        """to process project or block lib mapping links"""
        for lib_file, lib_file_cfg in lib_dir_cfg_dic.items():
            if lib_file == "liblist":
                continue
            can_path = pcom.rd_cfg(cfg_dic.get("proj", {}), "lib_mapping", lib_file, True)
            if not can_path:
                LOG.error(
                    f"library mapping search root path of {lib_file} "
                    f"is not defined in proj.cfg"
                )
                raise SystemExit()
            can_lst = list(pcom.find_iter(can_path, "*"))
            lib_link_lst = []
            for lib_link, lib_sec in cfg_dic.get("lib", {}).items():
                if not lib_link.startswith(f"link_{lib_file}"):
                    continue
                lib_link_lst.append(lib_sec)
            if not lib_link_lst:
                lib_link_lst.append({})
            for sec_name, link_sec in lib_file_cfg.items():
                if sec_name == "DEFAULT":
                    continue
                if "_pattern_search" not in link_sec:
                    LOG.error(f"option _pattern_search not in section {sec_name}")
                    raise SystemExit()
                pattern_search = pcom.rd_cfg(
                    lib_file_cfg, sec_name, "_pattern_search", True, r_flg=True)
                for lib_link in lib_link_lst:
                    new_link_sec = copy.copy(link_sec)
                    new_link_sec.update(lib_link)
                    opt_k_lst, opt_v_lst = self.flat_sec(new_link_sec)
                    for opt_tup in itertools.product(*opt_v_lst):
                        var_glob_dic = {}
                        for index, opt_v in enumerate(opt_tup):
                            var_glob_dic[opt_k_lst[index]] = opt_v
                        pattern_search_str = pcom.ren_tempstr(LOG, pattern_search, var_glob_dic)
                        for match_file in fnmatch.filter(
                                can_lst, f"{lib_src_root}{os.sep}{pattern_search_str}"):
                            self.link_src_dst(
                                match_file, f"{lib_dst_root}", lib_src_root)
        with open(f"{lib_dst_root}{os.sep}.match_lst", "w") as mlf:
            json.dump(self.match_lst, mlf)
    @classmethod
    def gen_liblist(cls, lib_map_root, lib_dst_root, liblist_cfg, lib_cfg):
        """to generate project or block liblist files"""
        lib_match_file = f"{lib_map_root}{os.sep}.match_lst"
        LOG.info(f"loading library mapping file list {lib_match_file} ...")
        try:
            with open(lib_match_file) as lmf:
                lib_match_lst = json.load(lmf)
        except FileNotFoundError:
            LOG.warning(f"library mapping not generated in {lib_map_root}")
        LOG.info("done")
        liblist_dir = f"{lib_dst_root}{os.sep}liblist"
        LOG.info(f"generating library mapping liblist files in {liblist_dir} ...")
        try:
            os.makedirs(liblist_dir, exist_ok=True)
        except PermissionError as err:
            LOG.error(err)
            raise SystemExit()
        opt_k_lst, opt_v_lst = cls.flat_sec(lib_cfg["liblist"])
        for sec_name, liblist_sec in liblist_cfg.items():
            if sec_name == "DEFAULT":
                continue
            liblist_lst = []
            for s_k in liblist_sec:
                LOG.info(f"processing variable {s_k} in liblist")
                liblist_set_lst = []
                for s_v in pcom.rd_cfg(liblist_cfg, sec_name, s_k):
                    for opt_tup in itertools.product(*opt_v_lst):
                        var_glob_dic = {}
                        for index, opt_v in enumerate(opt_tup):
                            var_glob_dic[opt_k_lst[index]] = opt_v
                        s_v_str = pcom.ren_tempstr(LOG, s_v, var_glob_dic)
                        liblist_set_lst.extend(fnmatch.filter(lib_match_lst, s_v_str))
                value_str = f" \\{os.linesep}{' '*(6+len(s_k))}".join(liblist_set_lst)
                liblist_lst.append(f'set {s_k} "{value_str}"')
            with open(f"{liblist_dir}{os.sep}{sec_name}", "w") as llf:
                llf.write(os.linesep.join(liblist_lst))
        LOG.info(f"done")
