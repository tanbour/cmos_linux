"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: op platform top entrence
"""

import argparse
from utils import pcom
from core import runner_admin
from core import runner_init
from core import runner_flow

LOG = pcom.gen_logger(__name__)

def gen_admin_parser(subparsers):
    """to generate admin parser"""
    admin_parser = subparsers.add_parser(
        "admin",
        help="sub cmd about kicking off project related actions")
    admin_parser.add_argument(
        "-list", dest="admin_list_proj", action="store_true",
        help="toggle to list all currently available proj names")
    admin_parser.add_argument(
        "-p", dest="admin_proj_name", default="",
        help="input the proj name which will be kicked off")
    admin_parser.add_argument(
        "-b", dest="admin_block_lst", default=[], nargs="+",
        help="input the block names to be initialized in the specified project")
    admin_parser.set_defaults(func=main_admin)

def main_admin(args):
    """init sub cmd top function"""
    runner_admin.run_admin(args)

def gen_init_parser(subparsers):
    """to generate init parser"""
    init_parser = subparsers.add_parser(
        "init",
        help="sub cmd about generating initial project directories")
    init_parser.add_argument(
        "-list", dest="init_list_proj", action="store_true",
        help="toggle to list all currently available proj names")
    init_parser.add_argument(
        "-p", dest="init_proj_name", default="",
        help="input the proj name which will be check out from repository")
    init_parser.set_defaults(func=main_init)

def main_init(args):
    """init sub cmd top function"""
    runner_init.run_init(args)

def gen_flow_parser(subparsers):
    """to generate flow parser"""
    flow_parser = subparsers.add_parser(
        "flow",
        help="sub cmd about run flow")
    flow_parser.add_argument(
        "-b", dest="flow_block", default="",
        help="input block name for running flows")
    flow_parser.add_argument(
        "-list_env", dest="flow_list_env", action="store_true",
        help="toggle to list all internal environment variables")
    flow_parser.add_argument(
        "-gen", dest="flow_gen", action="store_true",
        help="toggle to generate flow run files")
    flow_parser.add_argument(
        "-run", dest="flow_run_lst", default=None, nargs="*",
        help="toggle and input steps to run flow")
    flow_parser.set_defaults(func=main_flow)

def main_flow(args):
    """flow sub cmd top function"""
    runner_flow.run_flow(args)

def gen_args_top():
    """to generate top args help for op"""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-v", dest="version", default=False, action="store_true",
        help="show op version info and exit")
    subparsers = parser.add_subparsers()
    gen_admin_parser(subparsers)
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
        LOG.info("op commence ...")
        args.func(args)
        LOG.info("op complete")
    else:
        LOG.critical("sub cmd is NA, please use -h to check all sub cmds")
