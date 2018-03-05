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
    me_group = admin_parser.add_mutually_exclusive_group()
    me_group.add_argument(
        "-list", dest="admin_list_proj", action="store_true",
        help="toggle to list all currently available proj names")
    me_group.add_argument(
        "-list_lab", dest="admin_list_lab", action="store_true",
        help="toggle to list all currently available lab names")
    me_group.add_argument(
        "-p", dest="admin_proj_name", default="",
        help="input the proj name which will be kicked off")
    me_group.add_argument(
        "-b", dest="admin_block_lst", default=[], nargs="+",
        help="input the block names to be initialized in the specified project")
    me_group.add_argument(
        "-update_blk", dest="admin_update_blk", default=None, nargs="*",
        help="toggle or input blocks to update blocks directory according to RELEASE directory")
    me_group.add_argument(
        "-lib", dest="admin_lib", action="store_true",
        help="toggle to generate library mapping links and related files")
    admin_parser.set_defaults(func=main_admin)

def main_admin(args):
    """init sub cmd top function"""
    runner_admin.run_admin(args)

def gen_init_parser(subparsers):
    """to generate init parser"""
    init_parser = subparsers.add_parser(
        "init",
        help="sub cmd about generating initial project directories")
    me_group = init_parser.add_mutually_exclusive_group()
    me_group.add_argument(
        "-list", dest="init_list_proj", action="store_true",
        help="toggle to list all currently available proj names")
    me_group.add_argument(
        "-list_lab", dest="init_list_lab", action="store_true",
        help="toggle to list all currently available lab names")
    me_group.add_argument(
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
        help="sub cmd about running and controlling backend flows")
    me_group = flow_parser.add_mutually_exclusive_group()
    me_group.add_argument(
        "-list_env", dest="flow_list_env", action="store_true",
        help="toggle to list all internal environment variables")
    me_group.add_argument(
        "-list_blk", dest="flow_list_blk", action="store_true",
        help="toggle to list all available blocks")
    me_group.add_argument(
        "-list_flow", dest="flow_list_flow", action="store_true",
        help="toggle to list all available flows")
    me_group.add_argument(
        "-init", dest="flow_init_lst", default=[], nargs="+",
        help="input flow initial name list to generate flow config files")
    me_group.add_argument(
        "-gen", dest="flow_gen_lst", default=None, nargs="*",
        help="toggle and input flows to generate flow run files")
    me_group.add_argument(
        "-run", dest="flow_run_lst", default=None, nargs="*",
        help="toggle and input flows to run flow")
    flow_parser.add_argument(
        "-force", dest="flow_force", action="store_true",
        help="toggle flows to run flow force to ignore the previous status")
    me_group.add_argument(
        "-show_var", dest="flow_show_var_lst", default=None, nargs="*",
        help="toggle and input flows to list all variables passed to templates")
    flow_parser.set_defaults(func=main_flow)

def main_flow(args):
    """flow sub cmd top function"""
    runner_flow.run_flow(args)

def gen_args_top():
    """to generate top args help for op"""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-v", dest="version", action="store_true",
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
        try:
            args.func(args)
        except KeyboardInterrupt:
            LOG.critical("op terminated")
        else:
            LOG.info("op completed")
    else:
        LOG.critical("sub cmd is NA, please use -h to check all sub cmds")
