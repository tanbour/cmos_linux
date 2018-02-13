"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: op settings
"""

import os

# op related settings
BACKEND = True
BE_URL = "http://op.alchip.com.cn:8000"

OP_ROOT = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
OP_PROJ = f"{OP_ROOT}{os.sep}ext{os.sep}proj_share"
OP_UTIL = f"{OP_ROOT}{os.sep}ext{os.sep}utils"

# project related settings
FLG_FILE = ".alchip_proj_root_flg"
BLK_IGNORE_LST = ["share"]

BOOT_CFG = f"$PROJ_ROOT{os.sep}share{os.sep}config{os.sep}proj.cfg"

PROJ_SHARE = f"$PROJ_ROOT{os.sep}share"
PROJ_CFG_DIR = f"$PROJ_ROOT{os.sep}share{os.sep}config"
PROJ_TMP_DIR = f"$PROJ_ROOT{os.sep}share{os.sep}templates"
BLK_CFG_DIR = f"$BLK_ROOT{os.sep}config"

PROJ_REPO = "git"
PROJ_URL = "http://cnshscmserver.alchip.com/CN/SoC/api/rest/repositories.json"
Q_U = "op_query"
REPO_AUTH_ERR_STR = "Authentication failed"
REPO_BRANCH_ERR_STR = "Couldn't find remote ref master"
