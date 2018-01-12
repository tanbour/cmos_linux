"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: projects initialization and related features
"""

import os
from utils import pcom
from core import proj_repo

LOG = pcom.gen_logger(__name__)

class InitProc(proj_repo.ProjRepo):
    """initial processor for projects"""
    def list_proj(self):
        str_lst = [f"{os.linesep}all available projects"]
        str_lst.append("*"*30)
        str_lst.extend(self.all_proj_lst)
        str_lst.append("*"*30)
        LOG.info(os.linesep.join(str_lst))
        LOG.info("list all available projects done")

def run_init(args):
    """to run init sub cmd"""
    init_proc = InitProc()
    if args.init_proj_list:
        init_proc.list_proj()
    elif args.init_proj_name:
        init_proc.repo_proj(args.init_proj_name)
    else:
        LOG.critical("op init sub cmd missing main arguments")
        raise SystemExit()
