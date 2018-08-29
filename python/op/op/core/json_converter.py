"""
Author : laval
Email : lavall@alchip.com
Description : a class of mailproc
"""

import os
import json
from utils import settings
from utils import pcom

LOG = pcom.gen_logger(__name__)

class JsonConverter():
    """convert information into json for auto-send mail"""
    def __init__(self, user_lst, title, content, fn_str):
        """Initialization parameters"""
        self.user_lst = user_lst
        self.title = title
        self.content = content
        self.fn_str = fn_str
    def gen_json_file(self):
        """convert information into json file"""
        infor_dic = {}
        infor_dic['user'] = []
        for mail_domain in settings.MAIL_DOMAIN_LST:
            for user_name in self.user_lst:
                infor_dic['user'].append(f"{user_name}{mail_domain}")
        pcom.mkdir(LOG, settings.AUTO_MAIL_DIR)
        file_name = os.path.join(settings.AUTO_MAIL_DIR, f"{self.fn_str}.json")
        infor_dic['title'] = self.title
        infor_dic['content'] = self.content
        with open(file_name, 'w') as write_json:
            json.dump(infor_dic, write_json)
