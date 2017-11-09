#! /usr/bin/env python3

import os
import re
import fnmatch
import json
import xlrd
from nested_dict import nested_dict

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

def map_title(row_lst):
    title_index_lst = []
    for title in table_title_lst:
        if title in row_lst:
            title_index_lst.append(row_lst.index(title))
        elif title in ['命名', '地址', '位宽', '个数', '位域', '域名', '描述', '初始值']:
            raise Exception(f"{title} field is not in table title list, contact me!")
    return title_index_lst

def gen_json_file(sheet, dic):
    with open(f"./{sheet}.json", "w", encoding='utf8') as file:
        str_ = json.dumps(dic, indent=4, separators=(',', ':'), ensure_ascii=False)
        file.write(str(str_))

def excel_transfor_json(reg_data):
    sheet_name_lst = reg_data.sheet_names()
    for sheet_name in sheet_name_lst:
        print(f"{sheet_name} is Running!")
        result_dic = nested_dict()
        reg_name, title_index_lst = "", []
        reg_flag, bit_flag = False, False
        table_sheet = reg_data.sheet_by_name(f'{sheet_name}')
        for row in range(table_sheet.nrows):
            row_lst = table_sheet.row_values(row)
            if row_lst[1] == "命名" or row_lst[0] == "命名":
                reg_name = ""
                reg_flag = True
                title_index_lst = map_title(row_lst)

            if row_lst == list(reversed(row_lst)):
                reg_flag = False
                bit_flag = False

            if reg_flag and bit_flag:
                bits_name = table_sheet.cell(row, title_index_lst[4]).value
                definition = table_sheet.cell(row, title_index_lst[5]).value
                description = table_sheet.cell(row, title_index_lst[6]).value
                reset_value = str(table_sheet.cell(row, title_index_lst[7]).value)
                if row_lst[0] != "":
                    reg_name = table_sheet.cell(row, title_index_lst[0]).value
                    address = table_sheet.cell(row, title_index_lst[1]).value
                    addr_pat = re.match(r"全局地址：(.*)\n+本地地址：(.*)", address)
                    global_address = addr_pat.group(1)
                    if not global_address or global_address == "无":
                        global_address = "NA"
                    local_address = addr_pat.group(2)
                    bit_widths = str(int(table_sheet.cell(row, title_index_lst[2]).value))
                    thread_related = table_sheet.cell(row, title_index_lst[8]).value.strip()
                    if thread_related == "芯片级":
                        thread_related = "chip"
                    elif thread_related == "线程级":
                        thread_related = "thread"
                    elif thread_related == "core级":
                        thread_related = "core"
                    MSR_address = table_sheet.cell(row, title_index_lst[9]).value
                    if MSR_address == "非MSR" or not MSR_address:
                        MSR_address = "NA"
                    if reg_name in result_dic:
                        raise Exception("{reg_name} register name existed in table title list")
                    if not bits_name:
                        result_dic[reg_name] = nested_dict({
                            "SW_visible": "NA",
                            "MSR_address": MSR_address,
                            "global_address": global_address,
                            "local_address": local_address,
                            "32bit/64bit": bit_widths,
                            "thread_related": thread_related,
                            "fields": {}
                        })
                    else:
                        result_dic[reg_name] = nested_dict({
                            "SW_visible": "NA",
                            "MSR_address": MSR_address,
                            "global_address": global_address,
                            "local_address": local_address,
                            "32bit/64bit": bit_widths,
                            "thread_related": thread_related,
                            "fields": {
                                bits_name: {
                                    "RW": "NA",
                                    "definition": definition,
                                    "description": description,
                                    "reset_value": reset_value,
                                    "ucode_reset_value": "NA"
                                }
                            }
                        })
                    if bit_widths == "64bit":
                        addr_lst = address.split("h")
                        addr_int_num = int(f"0x{addr_lst[1]}", 16) + 1
                        address = addr_lst[0] + hex(addr_int_num).replace("0x", "h")
                        result_dic[reg_name]["local_address_hi"] = address
                else:
                    if bits_name in result_dic[reg_name]:
                        raise Exception("{bits_name} existed in {reg_name} register name")
                    result_dic[reg_name]["fields"][bits_name] = {
                        "RW": "NA",
                        "definition": definition,
                        "description": description,
                        "reset_value": reset_value,
                        "ucode_reset_value": "NA"
                    }
            if reg_flag:
                bit_flag = True
        gen_json_file(sheet_name, result_dic)

def main():
    for excel_file in list(find_iter(os.getcwd(), "*.xlsx"))+list(find_iter(os.getcwd(), "*.xls")):
        reg_data = xlrd.open_workbook(excel_file)
        excel_transfor_json(reg_data)

if __name__ == "__main__":
    table_title_lst = ['命名', '地址', '位宽', '个数', '位域',
                       '域名', '描述', '初始值', '线程相关性', 'MSR地址', '备注']
    main()
