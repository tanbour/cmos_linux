"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: projects initialization and related features
"""

from utils import pcom
from core import proj_repo

LOG = pcom.gen_logger(__name__)

def run_init(args):
    """to run init sub cmd"""
    init_repo = proj_repo.ProjRepo()
    if args.init_list_proj:
        init_repo.list_proj()
    elif args.init_proj_name:
        init_repo.repo_proj(args.init_proj_name)
    else:
        LOG.critical("no actions specified in op init sub cmd")
        raise SystemExit()
