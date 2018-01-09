#!/usr/bin/env python

import os
import re
import itertools
import glob
import jinja2
from utils import pcom

exec_path = os.path.realpath(__file__)
exec_dir = os.path.dirname(exec_path)
link_base_dir = f"{exec_dir}{os.sep}link_dir"

link_cfg = pcom.gen_cfg([f"{exec_dir}{os.sep}link_new.cfg"])

def check_sec(str_lst, sec):
    for str_item in str_lst:
        if str_item not in sec:
            raise Exception(f"{str_item} option not in section {sec}")

def check_str(key_str, str_lst):
    for str_item in str_lst:
        if key_str in str_item:
            raise Exception(f"search path {str_item} has unassigned variable")

def link_src_dst(src_file, dst_dir, src_base):
    if not os.path.isfile(src_file):
        print(f"info: link src file {src_file} is not a file")
        return
    dst_file = f"{dst_dir}{os.sep}{src_file.replace(src_base, '')}"
    if os.path.islink(dst_file):
        os.unlink(dst_file)
    elif os.path.isfile(dst_file):
        print(f"warning: link dst file {dst_file} is not a link")
        return
    else:
        os.makedirs(os.path.dirname(dst_file), exist_ok=True)
    print(f"linking src file {src_file} as dst file {dst_file}")
    os.symlink(src_file, dst_file)

for sec_name, link_sec in link_cfg.items():
    if sec_name in ("DEFAULT") or not sec_name.startswith("link_"):
        continue
    check_sec(["_path_search", "_pattern_search", "_path_dst"], link_sec)
    path_search = pcom.rd_cfg(link_cfg, sec_name, "_path_search", True, r_flg=True)
    pattern_search = pcom.rd_cfg(link_cfg, sec_name, "_pattern_search", True, r_flg=True)
    path_dst = pcom.rd_cfg(link_cfg, sec_name, "_path_dst", True, r_flg=True)
    opt_k_lst = []
    opt_v_lst = []
    for opt_k, opt_v in link_sec.items():
        if not opt_v:
            raise Exception(f"option value of {opt_k} from link {sec_name} is NA")
        opt_k_lst.append(opt_k)
        opt_v_lst.append(pcom.rd_cfg(link_cfg, sec_name, opt_k))
    for opt_tup in itertools.product(*opt_v_lst):
        var_glob_dic = {}
        for index, opt_v in enumerate(opt_tup):
            var_glob_dic[opt_k_lst[index]] = opt_v
        path_search_str = jinja2.Template(path_search).render(var_glob_dic)
        pattern_search_str = jinja2.Template(pattern_search).render(var_glob_dic)
        path_dst_str = jinja2.Template(path_dst).render(var_glob_dic)
        glob_str = f"{path_search_str}{os.sep}{pattern_search_str}"
        check_str("{{", [path_search_str, pattern_search_str, path_dst_str, glob_str])
        for glob_file in glob.glob(glob_str, recursive=True):
            link_src_dst(glob_file, path_dst_str, path_search_str)
