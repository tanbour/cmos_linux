#! /usr/bin/env python3
""" to process the dotfiles """
import os
import re
import argparse
import fnmatch
import difflib
import shutil

def gen_args_top():
    parser = argparse.ArgumentParser()
    df_group = parser.add_mutually_exclusive_group()
    h_str = ("applying related dotfiles from repo to $HOME")
    df_group.add_argument("-a", dest="apply_mode", action="store_true", help=h_str)
    h_str = ("backing up related dotfiles from $HOME to repo")
    df_group.add_argument("-b", dest="backup_mode", action="store_true", help=h_str)
    h_str = ("checking and diffing related dotfiles between $HOME and repo")
    df_group.add_argument("-c", dest="check_mode", action="store_true", help=h_str)
    return parser.parse_args()

args = gen_args_top()

if not args.apply_mode and not args.backup_mode and not args.check_mode:
    raise SystemExit("no action to be execuated")

exec_path = os.path.realpath(__file__)
exec_dir = os.path.dirname(exec_path)

if args.apply_mode:
    print("CAUTION: this dotfiles applying action will overwrite your home cfg")
    apply_rsp = input("--> yes or no? ")
    if apply_rsp.strip() not in ("yes", "y"):
        raise SystemExit("never mind")

for root_name, _, file_name_lst in os.walk(f"{exec_dir}{os.sep}dotfiles", followlinks=False):
    for find_name in fnmatch.filter(file_name_lst, "*"):
        repo_file = f"{root_name}{os.sep}{find_name}"
        home_dir = re.sub(r"^.*/dotfiles", os.path.expandvars("$HOME"), root_name)
        home_file = os.path.expandvars(f"{home_dir}{os.sep}{find_name}")
        if args.check_mode:
            with open(repo_file) as rf, open(home_file) as hf:
                home_lines = hf.readlines()
                repo_lines = rf.readlines()
            os.sys.stdout.writelines(
                difflib.unified_diff(home_lines, repo_lines, home_file, repo_file))
        elif args.backup_mode:
            shutil.copyfile(home_file, repo_file)
        elif args.apply_mode:
            shutil.copyfile(repo_file, home_file)
