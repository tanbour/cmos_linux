"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: op basic settings
"""

import os

BACKEND = True
BE_URL = "http://op.alchip.com.cn:8000"

OP_ROOT = os.path.dirname(os.path.realpath(__file__))
OP_CFG = f"{OP_ROOT}{os.sep}config"
OP_TEMPLATES = f"{OP_ROOT}{os.sep}templates"

flag_file = ".alchip_proj_root_flg"
tree_ignore_lst = ["share"]

proj_cfg_dir = "$PROJ_ROOT/share/config"

git_proj_dic = {
    "ff": "git@xsfuture.com:/srv/ff_git.git",
    "hosts": "https://github.com/googlehosts/hosts.git"
}
