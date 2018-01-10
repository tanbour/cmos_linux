"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: op platform main entrence
"""

import os
import argparse
from utils import pcom
from core import init_runner
from core import flow_runner

LOG = pcom.gen_logger(__name__)

def gen_init_parser(subparsers):
    """to generate init parser"""
    init_parser = subparsers.add_parser(
        "init",
        help="sub cmd about generating initial project directories")
    init_parser.add_argument(
        "-list", dest="init_proj_list", action="store_true",
        help="toggle to list all currently available proj names")
    init_parser.add_argument(
        "-list_env", dest="init_env_list", action="store_true",
        help="toggle to list all internal environment variables")
    init_parser.add_argument(
        "-p", dest="init_proj_name", default="",
        help="input the proj name which will be check out from repository")
    init_parser.add_argument(
        "-b", dest="init_block_lst", default=[], nargs="+",
        help="input the block names to be check out in the specified project")
    init_parser.add_argument(
        "-d", dest="init_dir", default="",
        help="input the directory used to contain the project")
    init_parser.set_defaults(func=main_init)

def main_init(args):
    """init sub cmd top function"""
    init_runner.run_init(args)

def gen_flow_parser(subparsers):
    """to generate flow parser"""
    flow_parser = subparsers.add_parser(
        "flow",
        help="sub cmd about run flow")
    flow_parser.add_argument(
        "-gen_tcl", dest="flow_gen_tcl", action="store_true",
        help="toggle to generate flow tcl files")
    flow_parser.add_argument(
        "-d", dest="flow_dir", default="",
        help="input existed flow directory")
    flow_parser.add_argument(
        "-run", dest="flow_run", action="store_true",
        help="toggle to run flow")
    flow_parser.set_defaults(func=main_flow)

def main_flow(args):
    """flow sub cmd top function"""
    flow_runner.run_flow(args)

def gen_args_top():
    """to generate top args help for op"""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-v", dest="version", default=False, action="store_true",
        help="show op version info and exit")
    subparsers = parser.add_subparsers()
    gen_init_parser(subparsers)
    gen_flow_parser(subparsers)
    return parser.parse_args()

def main():
    """op top function"""
    args = gen_args_top()
    if args.version:
        print("OnePiece Platform Version: op 4.0.0")
        return
    if hasattr(args, "func"):
        LOG.info("op commence...")
        args.func(args)
        LOG.info("op complete")
    else:
        LOG.critical("sub cmd is NA, please use -h to check all sub cmds")
