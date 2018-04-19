"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: op platform top entrence
"""

import argparse
from utils import pcom
from utils import settings
from core import runner_admin
from core import runner_init
from core import runner_flow
from core import runner_backup
from core.op_lic import OPClient

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
        "-p", dest="admin_proj_name",
        help="input the proj name which will be kicked off")
    me_group.add_argument(
        "-b", dest="admin_block_lst", nargs="+",
        help="input the block names to be initialized in the specified project")
    me_group.add_argument(
        "-update_blk", dest="admin_update_blk", nargs="*",
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
        "-p", dest="init_proj_name",
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
        "-init", dest="flow_init_lst", nargs="+",
        help="input flow initial name list to generate flow config files")
    me_group.add_argument(
        "-gen", dest="flow_gen_lst", nargs="*",
        help="toggle and input flows to generate flow run files")
    me_group.add_argument(
        "-run", dest="flow_run_lst", nargs="*",
        help="toggle and input flows to run flow")
    flow_parser.add_argument(
        "-force", dest="flow_force", default=False, nargs="?",
        help="toggle and input begin sub-stage to run force to ignore last status")
    flow_parser.add_argument(
        "-begin", dest="flow_begin", default="",
        help="input begin sub-stage to run")
    flow_parser.add_argument(
        "-no_lib", dest="flow_no_lib", action="store_true",
        help="toggle flows to run flow without liblist generation")
    flow_parser.add_argument(
        "-c", dest="flow_comment", default="",
        help="input flow comments to be shown and distinguished with others")
    me_group.add_argument(
        "-show_var", dest="flow_show_var_lst", nargs="*",
        help="toggle and input flows to list all variables passed to templates")
    me_group.add_argument(
        "-restore", dest="flow_restore", default="",
        help="input flow::stage:sub-stage to restore")
    flow_parser.set_defaults(func=main_flow)

def main_flow(args):
    """flow sub cmd top function"""
    runner_flow.run_flow(args)

def gen_backup_parser(subparsers):
    """to generate backup parser"""
    backup_parser = subparsers.add_parser(
        "backup",
        help="sub cmd about backup project directories")
    me_group = backup_parser.add_mutually_exclusive_group()
    me_group.add_argument(
        "-p", dest="backup_proj_name",
        help="input the proj name which to be backup by super user")
    backup_parser.set_defaults(func=main_backup)

def main_backup(args):
    """backup sub cmd top function"""
    runner_backup.run_backup(args)

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
    gen_backup_parser(subparsers)
    return parser.parse_args()

def main():
    """op top function"""
    args = gen_args_top()
    if args.version:
        print("OnePiece Platform Version: op 4.0.0")
        return
    if not settings.DEBUG:
        opclient = OPClient()
        opclient.set_license_server()
        opclient.checkout_license()
    if hasattr(args, "func"):
        try:
            args.func(args)
        except KeyboardInterrupt:
            LOG.critical("op terminated")
        except SystemExit:
            LOG.critical("op failed")
        else:
            LOG.info("op completed")
    else:
        LOG.critical("sub cmd is NA, please use -h to check all sub cmds")
    if not settings.DEBUG:
        opclient.checkin_license()
