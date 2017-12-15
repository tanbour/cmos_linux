#!/usr/bin/env python3

import os
import re
import argparse
import shutil
import requests

def gen_args_top():
    parser = argparse.ArgumentParser()
    h_str = ("input flow name")
    parser.add_argument('-f', dest='flow_name', required=True, help=h_str)
    h_str = ("input report file")
    parser.add_argument('-r', dest='rpt_file', required=True, help=h_str)
    return parser.parse_args()

args = gen_args_top()
base_url = "http://op.alchip.com.cn:8000"
# base_url = "http://localhost:8000"
if not os.path.isfile(args.rpt_file):
    os.sys.exit(f"report file {args.rpt_file} is NA")
with open(args.rpt_file) as r_f:
    content = r_f.read()
    con_stage_lst = re.findall(rf"(.*){os.linesep}={{15,}}{os.linesep}((?:.|{os.linesep})*?)(?=.*{os.linesep}={{15,}}{os.linesep}|$)", content)
    proj_name = owner_name = block_name = version_name = ""
    for index, (stage_title, stage_info) in enumerate(con_stage_lst):
        if not stage_title:
            continue
        if "DB paths: " in stage_info:
            proj_name, owner_name, block_name, version_name = re.search(r"DB paths: .*?/(\w+)/WORK/(\w+)/(\w+)/(\w+)", stage_info).groups()
        else:
            stage_title = stage_title.strip()
            stage_name = re.search(r"(.*)\s+(status summary table|summary|congestion)", stage_title).group(1)
            stage_info = stage_info.strip()
            data_dic = {"status": "passed"}
            if "P&R (icc2)" in stage_title and "summary" in stage_title:
                stage_info = re.sub(rf"\+-{{8,}}.*{os.linesep}.*outlook.*{os.linesep}", "", stage_info)
                stage_info = re.sub(rf"\+-{{8,}}.*{os.linesep}.*cell density.*{os.linesep}", "", stage_info)
                stage_info = re.sub(rf"\.\. _img.*", "", stage_info, flags=re.DOTALL)
                data_dic["stage_info"] = stage_info
            elif "P&R (icc2)" in stage_title and "congestion" in stage_title:
                stage_name = f"{stage_name} congestion"
                pr_lst = re.split(rf"{os.linesep}+", stage_info)
                for pr_index, line in enumerate(pr_lst):
                    line = line.strip()
                    if not line:
                        continue
                    if line.startswith(".."):
                        src_img = re.search("file://(/.*)", line).group(1)
                        if not os.path.isfile(src_img):
                            os.sys.exit(f"file {src_img} is NA")
                        tar_base_dir = re.sub(
                            r"\W", "_",
                            f"{proj_name}__{block_name}__{version_name}__{args.flow_name}__{stage_name}")
                        tar_dir = f"/proj/onepiece4/op_site/op_site/static/op_images/{tar_base_dir}"
                        tar_img = f"{tar_dir}{os.sep}{os.path.basename(src_img)}"
                        url_img = tar_img.replace("/proj/onepiece4/op_site/op_site", "")
                        os.makedirs(tar_dir, exist_ok=True)
                        shutil.copyfile(src_img, tar_img)
                        data_dic[f"{pr_index:02} {pr_lst[pr_index-1]} img"] = f"<br><img src='{url_img}'>"
            elif "StarRCXT" in stage_title:
                stage_info = re.sub(rf"\+-{{8,}}.*{os.linesep}.*outlook.*{os.linesep}", "", stage_info)
                data_dic["stage_info"] = stage_info
            elif "STA (PT)" in stage_title:
                sta_lst = stage_info.split(os.linesep)
                se_tup = ()
                for line in sta_lst:
                    line = line.strip()
                    if not line:
                        continue
                    if "Outlook" not in line:
                        continue
                    outlook_pat = re.search(r"\|\s+Outlook\s+", line)
                    se_tup = (outlook_pat.start(), outlook_pat.end())
                if se_tup:
                    for se_index, line in enumerate(sta_lst):
                        line = line.strip()
                        if not line:
                            continue
                        sta_lst[se_index] = line[:se_tup[0]]+line[se_tup[1]:]
                stage_info = f"{os.linesep}".join(sta_lst)
                data_dic["stage_info"] = stage_info
            else:
                data_dic["stage_info"] = stage_info
            if not all((stage_name, proj_name, block_name, version_name, args.flow_name)):
                os.sys.exit(f"necessary name variable is NA")
            stage_dic = {"name": f"{index:02} {stage_name}", "proj": proj_name, "block": block_name, "version": version_name, "owner": owner_name, "flow": args.flow_name, "data": data_dic}
            print(stage_dic)
            query_url = f"{base_url}/be_rpt/op/stages/"
            requests.post(query_url, json=stage_dic)
    flow_dic = {"proj": proj_name, "block": block_name, "version": version_name, "owner": owner_name, "name": args.flow_name, "data": {"status": "passed"}}
    query_url = f"{base_url}/be_rpt/op/flows/"
    requests.post(query_url, json=flow_dic)
