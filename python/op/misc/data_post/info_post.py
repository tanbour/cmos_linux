#!/usr/bin/env python3

import os
import re
import requests

# base_url = "http://op.alchip.com.cn:8000"
base_url = "http://localhost:8000"

proj_dic_lst = [
    {
        "name": "MX6300",
        "owner": "klinsmanz",
        "data": {
            "Process": "28hpcp",
            "Foundary": "TSMC",
            "Chip Size": "2.1x3.1",
            "Gate Count": "6M",
            "TO Schedule": "2017/12/E",
            "Design Phase": "FDR",
            "Metal Scheme": "SP8M5X2ZUTRDL",
            "No. of Blocks": 1
        }
    },
    {
        "name": "hash_top",
        "owner": "yuntaoliao",
        "data": {
            "Process": "16ffp",
            "Foundary": "TSMC",
            "Chip Size": "0.4x0.4",
            "Gate Count": "691K",
            "TO Schedule": "2017/12/E",
            "Design Phase": "FDR",
            "Metal Scheme": "1P11M_2Xa1Xd3Xe2Y2R",
            "No. of Blocks": 1
        }
    }
]
for proj_dic in proj_dic_lst:
    query_url = f"{base_url}/be_rpt/op/projs/"
    requests.post(query_url, json=proj_dic)

block_dic_lst = [
    {
        "name": "engine_tile",
        "proj": "MX6300",
        "owner": "simonz",
        "data": {
            "Block Size": "2.1x3.1",
            "DFT included": True,
            "Design Phase": "FDR",
            "No. of Versions": 1,
            "Initial Gate Count": "5.5M",
            "Latest Netlist Version": "1114"
        }
    },
    {
        "name": "hash_top",
        "proj": "hash_top",
        "owner": "simonz",
        "data": {
            "Block Size": "0.4x0.4",
            "DFT included": True,
            "Design Phase": "FDR",
            "No. of Versions": 1,
            "Initial Gate Count": "650K",
            "Latest Netlist Version": "1123"
        }
    }
]
for block_dic in block_dic_lst:
    query_url = f"{base_url}/be_rpt/op/blocks/"
    requests.post(query_url, json=block_dic)

version_dic_lst = [
    {
        "name": "V1114_S1114_F1110",
        "block": "engine_tile",
        "proj": "MX6300",
        "owner": "simonz",
        "data": {
            "WNS/TNS": "-0.00/-0.00",
            "Block Size": "2.1x3.1",
            "DFT included": True,
            "Design Phase": "FDR",
            "No. of Flows": 1,
            "Route DRC No.": "27",
            "Violations No.": "3",
            "Netlist Version": "1114",
            "Initial Gate Count": "5.5M"
        }
    },
    {
        "name": "V1123_S1123_F1123",
        "block": "hash_top",
        "proj": "hash_top",
        "owner": "simonz",
        "data": {
            "WNS/TNS": "-0.08/-1.08",
            "Block Size": "0.4x0.4",
            "DFT included": True,
            "Design Phase": "FDR",
            "No. of Flows": 1,
            "Route DRC No.": "4",
            "Violations No.": "4824",
            "Netlist Version": "1123",
            "Initial Gate Count": "650K"
        }
    }
]
for version_dic in version_dic_lst:
    query_url = f"{base_url}/be_rpt/op/versions/"
    requests.post(query_url, json=version_dic)
