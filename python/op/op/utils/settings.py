"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: op basic settings
"""

import os

BACKEND = True
BE_URL = "http://op.alchip.com.cn:8000"

FLAG_FILE = ".alchip_proj_root_flg"

OP_ROOT = os.path.dirname(os.path.realpath(__file__))
OP_CFG = f"{OP_ROOT}{os.sep}config"
OP_TEMPLATES = f"{OP_ROOT}{os.sep}templates"

tree_ignore_lst = ["share"]

proj_cmn_cfg = "$PROJ_ROOT/share/config/proj_cmn.cfg"
blk_cmn_cfg = "$BLK_ROOT/share/config/blk_cmn.cfg"
