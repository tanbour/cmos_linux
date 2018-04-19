"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: backup config
"""

# BACKUP_USER = "openlava"
BACKUP_USER = "root"
BACKUP_HOST = "R710-06"
BACKUP_SRC_ROOT = "/proj"
BACKUP_DST_ROOT = "/proj/IDC_PROJ_BK"
BACKUP_CFG_SYNC_LST = ["RELEASE"]
BACKUP_CFG_DATE_LST = [
    "*/run/*/syn/*.v",
    "*/run/*/syn/*.svf",
    "*/run/*/pr/*.v.gz",
    "*/run/*/pr/*.def.gz",
    "*/run/*/pr/*.sdc",
]
