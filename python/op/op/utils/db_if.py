"""
Author: Guanyu Yi @ OnePiece Platform Group
Email: guanyu_yi@alchip.com
Description: database interface
"""

import requests
from utils import pcom
from utils import settings

LOG = pcom.gen_logger(__name__)
BASE_URL = settings.BE_URL

def w_stage(data_dic):
    """to write stage table record"""
    url = f"{BASE_URL}/flow_rpt/runner/stages/"
    rsp_dic = requests.post(url, json=data_dic).json() if settings.BACKEND else {}
    return rsp_dic

def w_flow(data_dic):
    """to write flow table record"""
    url = f"{BASE_URL}/flow_rpt/runner/flows/"
    rsp_dic = requests.post(url, json=data_dic).json() if settings.BACKEND else {}
    return rsp_dic

def w_file(data_dic, file_dic):
    """to write flow table record"""
    url = f"{BASE_URL}/flow_rpt/runner/upload/"
    rsp_dic = requests.post(url, data=data_dic, files=file_dic).json() if settings.BACKEND else {}
    return rsp_dic
