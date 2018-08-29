"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: op settings
"""

import os

# op related settings
DEBUG = False

BACKEND = True if not DEBUG else False
MAIL_ALERT = True if not DEBUG else False

BE_URL = "http://op.alchip.com.cn:8000"
# BE_URL = "http://localhost:8000"
# BE_URL = "http://utah:8000"

OP_ROOT = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
OP_PROJ = f"{OP_ROOT}{os.sep}proj_share{os.sep}suites"
OP_UTILS = f"{OP_ROOT}{os.sep}proj_share{os.sep}utils"

# project related settings
FLG_FILE = ".alchip_proj_root_flg"
BLK_IGNORE_LST = ["share"]
BLK_CFG_UNFILL_LST = ["proj", "signoff"]
GITIGNORE = f"run/{os.linesep}*.sw[op]{os.linesep}"

BOOT_CFG = f"$PROJ_ROOT{os.sep}share{os.sep}config{os.sep}proj.cfg"

PROJ_SHARE = f"$PROJ_ROOT{os.sep}share"
PROJ_CFG_DIR = f"$PROJ_ROOT{os.sep}share{os.sep}config"
BLK_CFG_DIR = f"$BLK_ROOT{os.sep}config"

PROJ_REPO = "git"
PROJ_URL = "http://cnshscmserver.alchip.com/CN/SoC/api/rest/repositories.json"
Q_U = "op_query"
REPO_AUTH_ERR_STR_LST = ["Authentication failed", "401 while accessing"]
REPO_BRANCH_ERR_STR_LST = [
    "Couldn't find remote ref master",
    "error: pathspec 'master' did not match any file"]

MP_POOL = 48

# json proc
MAIL_DOMAIN_LST = ['@alchip.com']
AUTO_MAIL_DIR = '/alchip/home/public/op/mail_alert/'
LOCAL_RPT_CMN_LST = ["openlava"]
# AUTO_MAIL_DIR = '/tmp/mail_tmp'
