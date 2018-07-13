#! /usr/bin/env python3
"""
json_converter test
"""

import os
import json
import unittest
from utils import settings
from core import json_converter as jc

class TestJsonConverter(unittest.TestCase):
    """test the class of json_converter"""
    def setUp(self):
        self.tmp_file1 = "/tmp/test1.json"
        self.tmp_file2 = "/tmp/test2.json"
        self.tmp_file3 = "/tmp/test3.json"
        self.test_dict1 = {'user':['lavall'],'title':'passed','content':'This is a test'}
        self.test_dict2 = {'user':['lavall'],'title':'passed','content':'This is a test'}
        self.test_dict3 = {'user':['lavall','kevinf'],'title':'passed','content':'This is a test'}
    def test_json_converter(self):
        settings.AUTO_MAIL_DIR = "/tmp"
        jc.JsonConverter(
            self.test_dict1['user'],self.test_dict1['title'],
            self.test_dict1['content'],"test1").gen_json_file()
        jc.JsonConverter(
            self.test_dict2['user'],self.test_dict2['title'],
            self.test_dict2['content'],"test2").gen_json_file()
        jc.JsonConverter(
            self.test_dict3['user'],self.test_dict3['title'],
            self.test_dict3['content'],"test3").gen_json_file()
        with open(self.tmp_file1) as tf1:
            self.assertEqual(
                json.load(tf1),
                {'user':['lavall@alchip.com'],'title':'passed','content':'This is a test'})
        with open(self.tmp_file2) as tf2:
            self.assertEqual(
                json.load(tf2),
                {'user':['lavall@alchip.com'],'title':'passed','content':'This is a test'})
        with open(self.tmp_file3) as tf3:
            self.assertEqual(
                json.load(tf3),
                {'user':['lavall@alchip.com', 'kevinf@alchip.com'],'title':'passed',
                            'content':'This is a test'})
    def tearDown(self):
        os.remove(self.tmp_file1)
        del self.tmp_file1
        os.remove(self.tmp_file2)
        del self.tmp_file2
        os.remove(self.tmp_file3)
        del self.tmp_file3

if __name__ == '__main__':
    unittest.main()
