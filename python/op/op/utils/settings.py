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
OP_CFG = f"{OP_ROOT}{os.sep}proj_share{os.sep}config"
OP_TMP = f"{OP_ROOT}{os.sep}proj_share{os.sep}templates"

# project related settings
FLG_FILE = ".alchip_proj_root_flg"
BLK_IGNORE_LST = ["share"]

BOOT_CFG = "$PROJ_ROOT/share/config/proj.cfg"

ADMIN_CFG_DIR = "$PROJ_ROOT/share/config"
ADMIN_TMP_DIR = "$PROJ_ROOT/share/templates"
ADMIN_BLK_CFG_DIR = "$BLK_ROOT/config"
ADMIN_BLK_PLG_DIR = "$BLK_ROOT/plugins"

PROJ_REPO = "git"
#TODO to obtain projects list from server
if PROJ_REPO == "git":
    ALL_PROJ_DIC = {
        "ff": "git@xsfuture.com:/srv/ff_git.git",
        "hosts": "https://github.com/googlehosts/hosts.git"
    }
elif PROJ_REPO == "svn":
    ALL_PROJ_DIC = {}
