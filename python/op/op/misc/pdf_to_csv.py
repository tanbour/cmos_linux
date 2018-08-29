#!/usr/bin/env python3
"""
Author: laval @ OnePiece Platform Group
Email: lavall@alchip.com
Description: Extract content from PDF to a csv file
"""

import os
import csv
import logging
import argparse
import fitz
import texttable

SEP_LIST = [['']*9 for i in range(6)]
# filter for type1
CONTENT_LST = ['VOLTAGE VARIATION', 'TEMPERATURE VARIATION', 'HOLD TIME UNCERTAINTY']
#filter for type2
FILTER_STR = "Voltage/Temperature Margin Reference"

def gen_tmp(input_file, output_file):
    """convert pdf to log format"""
    doc = fitz.open(input_file)
    doc_num = doc.pageCount
    with open(output_file, 'w', encoding="utf-8") as fp_tmp:
        if ARGS.start_end_pages:
            start_num = ARGS.start_end_pages[0]-1
            end_num = ARGS.start_end_pages[1]
        else:
            start_num = 0
            end_num = doc_num
        for i in range(start_num, end_num):
            page = doc.loadPage(i)
            logging.info("Processing the contents of the %s page", i+1)
            text = page.getText()
            fp_tmp.write(text)

def gen_csv_t1(pdf_file, output_file, input_file):
    """gen csv file"""
    filter_num = 0
    lst = []
    doc = fitz.open(pdf_file)
    toc = doc.getToC()
    for t_per in toc:
        lst.append(t_per[1])
    with open(input_file, encoding="utf-8") as fp_tmp, \
         open(output_file, 'w', encoding="utf-8") as fp_csv:
        csvwriter = csv.writer(fp_csv, delimiter=',')
        index_lst = []
        cont_dict = {}
        text = fp_tmp.read()
        cont_lst = text.split("\n")
        for item in lst:
            index_lst.append(cont_lst.index(item))
        for i, value in enumerate(lst):
            if i < len(lst)-1:
                begin_index = index_lst[i] + 1
                end_index = index_lst[i+1]
            cont_dict[value] = cont_lst[begin_index:end_index]
        for con_item in CONTENT_LST:
            for item_tmp in lst:
                if con_item in item_tmp:
                    con_item = item_tmp
            i = 0
            csvwriter.writerow([con_item])
            content = cont_dict[con_item]
            for item in content:
                i += 1
                item_list = item.split(' ')
                if item_list[0] == "Security":
                    item_list = []
                if len(item_list) == 1 and item_list[0] == '0':
                    item_list = []
                if "(mv)" in item_list and con_item == "III. VOLTAGE VARIATION":
                    item_replace = item_list[0] + ' ' + item_list[1] + item_list[2]
                    item_list[0:3] = [item_replace]
                if "(%)" in item_list and con_item == "III. VOLTAGE VARIATION":
                    item_replace = item_list[0] + item_list[1]
                    item_list[0:2] = [item_replace]
                if len(item_list) > 4 and con_item == "IV. TEMPERATURE VARIATION":
                    describe_str = " ".join(item_list)
                    item_list = [describe_str]
                if "(%)" in item_list and con_item == "IV. TEMPERATURE VARIATION":
                    item_replace = item_list[-3] + " " + item_list[-2] + item_list[-1]
                    item_list[-3:] = [item_replace]
                if con_item == "V. HOLD TIME UNCERTAINTY":
                    if i < 7:
                        item_list = []
                    if i == 7:
                        item_list = ["Corner", "pin", "slew(ns)", "Hold margin(ns)",
                                     "pin", "slew(ns)", "Hold margin(ns)"]
                if len(item_list) > filter_num:
                    filter_num = len(item_list)
                if item_list:
                    csvwriter.writerow(item_list)
            for per_sep_lst in SEP_LIST:
                csvwriter.writerow(per_sep_lst)
    return filter_num

def gen_csv_t2(output_file, input_file):
    """gen csv file"""
    filter_num = 0
    lst = []
    line_num = 0
    with open(input_file, encoding="utf-8") as fp_tmp, \
         open(output_file, 'w', encoding="utf-8") as fp_csv:
        csvwriter = csv.writer(fp_csv, delimiter=',')
        cont_dict = {}
        filter_lst = []
        cont_lst = fp_tmp.readlines()
        for line in cont_lst:
            line_num += 1
            if FILTER_STR in line.strip():
                lst.append(line_num)
        for item, value in enumerate(lst):
            filter_lst.append(cont_lst[value-1].strip())
            if item < len(lst)-1:
                begin_index = value
                end_index = lst[item+1]-1
            elif item == len(lst)-1:
                begin_index = value
                end_index = len(cont_lst)
            cont_dict[cont_lst[value-1].strip()] = cont_lst[begin_index: end_index]
        for filter_str in filter_lst:
            write_list = [filter_str,]
            csvwriter.writerow(write_list)
            content = cont_dict[filter_str]
            for write_lst in content:
                write_lst = write_lst.strip().split('  ')
                if len(write_lst) == 1 or "Ltd." in write_lst[1]:
                    write_lst = []
                if len(write_lst) == 3:
                    replace_lst = []
                    for per_item in write_lst:
                        tmp_lst = [' ', ' ', per_item, ' ', ' ']
                        replace_lst.extend(tmp_lst)
                    write_lst = replace_lst
                if len(write_lst) > filter_num:
                    filter_num = len(write_lst)
                if write_lst:
                    csvwriter.writerow(write_lst)
            for per_sep_lst in SEP_LIST:
                csvwriter.writerow(per_sep_lst)
    return filter_num

def gen_txt(filter_num, csv_file, txt_file):
    """gen friendly text file"""
    with open(csv_file, encoding="utf-8") as fp_csv, \
         open(txt_file, 'w', encoding="utf-8") as fp_txt:
        cols_width_lst = [15,]
        tmp_wid_lst = [7] * (filter_num - 1)
        cols_width_lst.extend(tmp_wid_lst)
        table = texttable.Texttable()
        table.set_cols_width(cols_width_lst)
        tmp_lst = []
        for row in fp_csv:
            row = row.strip()
            row_list = row.split(',')
            if len(row_list) > filter_num:
                row_list = row_list[0:filter_num]
            elif len(row_list) < filter_num:
                num = filter_num - len(row_list)
                t_l = [' ']*num
                row_list.extend(t_l)
            if row_list[0]:
                tmp_lst.append(row_list)
        table.add_rows(tmp_lst)
        fp_txt.write(table.draw())

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s: %(message)s')
    PARSER = argparse.ArgumentParser()
    PARSER.add_argument("-p", "--path", help="path of the input pdf")
    PARSER.add_argument("-n", "--start_end_pages", nargs=2, type=int)
    PARSER.add_argument("-t", "--type", choices=[1, 2], type=int,
                        help=('1: TSMC STD cell library SBOCV databook,'
                              '2: TSMC foundry signoff guideline.'))
    ARGS = PARSER.parse_args()
    logging.info("Processing file: %s", os.path.basename(ARGS.path))
    TMP_FILE = os.path.basename(ARGS.path).rstrip("pdf") + "log"
    CSV_FILE = os.path.basename(ARGS.path).rstrip("pdf") + "csv"
    TXT_FILE = os.path.basename(ARGS.path).rstrip("pdf") + "txt"
    try:
        if ARGS.type == 1:
            gen_tmp(ARGS.path, TMP_FILE)
            FILTER_NUM = gen_csv_t1(ARGS.path, CSV_FILE, TMP_FILE)
            gen_txt(FILTER_NUM, CSV_FILE, TXT_FILE)
        elif ARGS.type == 2:
            gen_tmp(ARGS.path, TMP_FILE)
            FILTER_NUM = gen_csv_t2(CSV_FILE, TMP_FILE)
            gen_txt(FILTER_NUM, CSV_FILE, TXT_FILE)
    except KeyError:
        pass
    finally:
        os.remove(TMP_FILE)
