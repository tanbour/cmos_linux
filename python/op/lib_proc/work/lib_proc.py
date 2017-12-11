#!/usr/bin/env python

import os
import re
import glob
import itertools
import jinja2
import copy
import pcom

exec_path = os.path.realpath(__file__)
exec_dir = os.path.dirname(exec_path)
link_base_dir = f"{exec_dir}{os.sep}link_dir"

tree_cfg = pcom.gen_cfg([f"{exec_dir}{os.sep}tree.cfg"])
link_cfg = pcom.gen_cfg([f"{exec_dir}{os.sep}link.cfg"])

lib_path = pcom.rd_cfg(link_cfg, "proj", "lib_path", True)
tree_map = pcom.rd_cfg(tree_cfg, lib_path, "path_mapping", True)
tm_temp = jinja2.Template(tree_map)

def link_src_dst(src_file, dst_dir):
    if not os.path.isfile(src_file):
        print(f"info: link src file {src_file} is not a file")
        return
    dst_file = f"{dst_dir}{os.sep}{os.path.basename(src_file)}"
    if os.path.islink(dst_file):
        os.unlink(dst_file)
    elif os.path.isfile(dst_file):
        print(f"warning: link dst file {dst_file} is not a link")
        return
    else:
        os.makedirs(dst_dir, exist_ok=True)
    print(f"linking src file {src_file} as dst file {dst_file}")
    os.symlink(src_file, dst_file)

for sec_name, link_sec in link_cfg.items():
    if sec_name in ("proj", "DEFAULT"):
        continue
    if "dst_path" not in link_sec:
        raise Exception(f"dst_path option not in section {sec_name}")
    dst_path = pcom.rd_cfg(link_cfg, sec_name, "dst_path", True, r_flg=True)
    tp_temp = jinja2.Template(dst_path)
    opt_k_lst = []
    opt_v_lst = []
    for opt_k, opt_v in link_sec.items():
        if not opt_v:
            raise Exception(f"option value of {opt_k} from link {sec_name} is NA")
        opt_k_lst.append(opt_k)
        opt_v_lst.append(pcom.rd_cfg(link_cfg, sec_name, opt_k))
    for opt_tup in itertools.product(*opt_v_lst):
        var_glob_dic = {}
        var_re_dic = {}
        for index, opt_v in enumerate(opt_tup):
            var_glob_dic[opt_k_lst[index]] = opt_v
            if "*" in opt_v:
                var_re_dic[opt_k_lst[index]] = opt_v.replace(
                    "*", f"(?P<{opt_k_lst[index]}>[^{os.sep}]*)")
        tree_map_str = tm_temp.render(var_glob_dic)
        glob_str = f"{lib_path}{os.sep}{tree_map_str}{os.sep}**"
        if "{{" in glob_str:
            raise Exception(f"search path {glob_str} has unassigned variable")
        glob_lst = glob.glob(glob_str, recursive=True)
        if var_re_dic:
            var_glob_cp_dic = copy.copy(var_glob_dic)
            var_glob_cp_dic.update(var_re_dic)
            tree_map_re_str = f"{lib_path}{os.sep}{tm_temp.render(var_glob_cp_dic)}"
            for glob_file in glob_lst:
                var_glob_cp_dic.update(re.search(tree_map_re_str, glob_file).groupdict())
                dst_path_str = tp_temp.render(var_glob_cp_dic)
                link_src_dst(glob_file, f"{dst_path_str}")
        else:
            dst_path_str = tp_temp.render(var_glob_dic)
            for glob_file in glob_lst:
                link_src_dst(glob_file, f"{dst_path_str}")
