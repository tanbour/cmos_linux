"""
Author: Junxiu Liu @ CPU Verification Platform Group
Email: liujx@cpu.com.cn
Description: CacheInit class for generate cache and memory init data
"""

import os
import random
import collections
import pcom

LOG = pcom.gen_logger(__name__)

class CacheInit(object):
    """to generate init cache data"""
    def __init__(self, seed, rlt_dir, cfg_dic, case_name):
        self.seed = seed
        self.rlt_dir = rlt_dir
        self.case_name = case_name
        self.mc_dic = {
            "mem": collections.defaultdict(list),
            "cfg_addr": [],
            "l3": {
                "addr": [],
                "org": collections.defaultdict(list),#{"addr": [data, mesi, [[],[]] ]}
                "rlt_tmp": [],
                "rm": []},
            "l2": {
                "addr": collections.defaultdict(list),
                "cl": collections.defaultdict(list),
                "rm": collections.defaultdict(list)},
            "l1": {
                "l1ia": collections.defaultdict(list),
                "l1da": collections.defaultdict(list),
                "l1dl2_lst": [], "l1il2_lst": [],
                "l1il2_dic": {
                    "c0": collections.defaultdict(list),
                    "c1": collections.defaultdict(list),
                    "c2": collections.defaultdict(list),
                    "c3": collections.defaultdict(list)},
                "l1dl2_dic": {
                    "c0": collections.defaultdict(list),
                    "c1": collections.defaultdict(list),
                    "c2": collections.defaultdict(list),
                    "c3": collections.defaultdict(list)},
                "rm": {
                    "l1i": collections.defaultdict(list),
                    "l1d": collections.defaultdict(list)},
                "cl_l1d": collections.defaultdict(list),
                "cl_l1i": collections.defaultdict(list)}}
        self.rm_dir = f"{rlt_dir}{os.sep}RM"
        os.makedirs(self.rm_dir, exist_ok=True)
        self.ci_dic = cfg_dic["proj"]["cache_init"]
        LOG.info("to read case config file")
        cfg_f = os.path.abspath(os.path.expandvars(cfg_dic["case"][case_name]["cache_init"]))
        self.cfg_dic = pcom.gen_cfg([cfg_f])
        for sect in self.cfg_dic.sections():
            if not sect.startswith("addr__"):
                continue
            self.mc_dic["cfg_addr"].append(sect)
    @classmethod
    def gen_mesi(cls, mtype, mesi):
        """to generate mesi"""
        if mtype == "cores":
            if mesi == "1111":
                mesi_lst = [
                    {"c0": "M", "c1": "I", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "M", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "M", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "I", "c3": "M"},
                    {"c0": "E", "c1": "I", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "E", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "E", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "I", "c3": "E"},
                    {"c0": "S", "c1": "I", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "S", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "S", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "I", "c3": "S"},
                    {"c0": "S", "c1": "S", "c2": "I", "c3": "I"},
                    {"c0": "S", "c1": "I", "c2": "S", "c3": "I"},
                    {"c0": "S", "c1": "I", "c2": "I", "c3": "S"},
                    {"c0": "I", "c1": "S", "c2": "S", "c3": "I"},
                    {"c0": "I", "c1": "S", "c2": "I", "c3": "S"},
                    {"c0": "I", "c1": "I", "c2": "S", "c3": "S"},
                    {"c0": "S", "c1": "S", "c2": "S", "c3": "I"},
                    {"c0": "S", "c1": "S", "c2": "I", "c3": "S"},
                    {"c0": "S", "c1": "I", "c2": "S", "c3": "S"},
                    {"c0": "I", "c1": "S", "c2": "S", "c3": "S"},
                    {"c0": "S", "c1": "S", "c2": "S", "c3": "S"},
                    {"c0": "I", "c1": "I", "c2": "I", "c3": "I"}]
            elif mesi == "0010":
                mesi_lst = [
                    {"c0": "M", "c1": "I", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "M", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "M", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "I", "c3": "M"},
                    {"c0": "E", "c1": "I", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "E", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "E", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "I", "c3": "E"},
                    {"c0": "I", "c1": "I", "c2": "I", "c3": "I"}]
            elif mesi == "0001":
                mesi_lst = [
                    {"c0": "S", "c1": "I", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "S", "c2": "I", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "S", "c3": "I"},
                    {"c0": "I", "c1": "I", "c2": "I", "c3": "S"},
                    {"c0": "S", "c1": "S", "c2": "I", "c3": "I"},
                    {"c0": "S", "c1": "I", "c2": "S", "c3": "I"},
                    {"c0": "S", "c1": "I", "c2": "I", "c3": "S"},
                    {"c0": "I", "c1": "S", "c2": "S", "c3": "I"},
                    {"c0": "I", "c1": "S", "c2": "I", "c3": "S"},
                    {"c0": "I", "c1": "I", "c2": "S", "c3": "S"},
                    {"c0": "S", "c1": "S", "c2": "S", "c3": "I"},
                    {"c0": "S", "c1": "S", "c2": "I", "c3": "S"},
                    {"c0": "S", "c1": "I", "c2": "S", "c3": "S"},
                    {"c0": "I", "c1": "S", "c2": "S", "c3": "S"},
                    {"c0": "S", "c1": "S", "c2": "S", "c3": "S"},
                    {"c0": "I", "c1": "I", "c2": "I", "c3": "I"}]
            else:
                mesi_lst = [{"c0": "I", "c1": "I", "c2": "I", "c3": "I"}]
            return mesi_lst
        elif mtype == "level":
            if mesi == "1111":
                mesi_dic = {
                    "l2l1d": [
                        {"l2": "M", "l1d": "M"}, {"l2": "M", "l1d": "E"}, {"l2": "M", "l1d": "I"},
                        {"l2": "I", "l1d": "M"}, {"l2": "E", "l1d": "M"}],
                    "l2l1i": [
                        {"l2": "E", "l1i": "V"}, {"l2": "E", "l1i": "I"}, {"l2": "I", "l1i": "V"}]}
            elif mesi == "0010":
                mesi_dic = {
                    "l2l1d": [
                        {"l2": "E", "l1d": "E"}, {"l2": "E", "l1d": "I"}, {"l2": "I", "l1d": "E"}],
                    "l2l1i": [
                        {"l2": "E", "l1i": "V"}, {"l2": "E", "l1i": "I"}, {"l2": "I", "l1i": "V"}]}
            elif mesi == "0001":
                mesi_dic = {
                    "l2l1d": [
                        {"l2": "S", "l1d": "S"}, {"l2": "S", "l1d": "I"}, {"l2": "I", "l1d": "S"}],
                    "l2l1i": [
                        {"l2": "S", "l1i": "V"}, {"l2": "S", "l1i": "I"}, {"l2": "I", "l1i": "V"}]}
            else:
                mesi_dic = {
                    "l2l1d": [{"l2": "I", "l1d": "I"}], "l2l1i": [{"l2": "I", "l1i": "I"}]}
            return mesi_dic
    @classmethod
    def gen_rand_bin(cls, bit_num):
        """to generate bin number"""
        data = random.randrange(0, 2**bit_num-1)
        d_bin = bin(data)[2:]
        if len(d_bin) < bit_num:
            d_bin = f"{'0'*(bit_num-len(d_bin))}{d_bin}"
        return d_bin
    @classmethod
    def convert_b_h(cls, str_t, cont_str, sum_rlt):
        """to convert bin to hex or hex to bin"""
        if str_t == "bins":
            value_d = int(cont_str, 2)
            rlt_str = hex(value_d)[2:]
            if len(rlt_str) < sum_rlt:
                rlt_str = f"{'0'*(sum_rlt-len(rlt_str))}{rlt_str}"
        if str_t == "hexs":
            value_d = int(cont_str, 16)
            rlt_str = bin(value_d)[2:]
            if len(rlt_str) < sum_rlt:
                rlt_str = f"{'0'*(sum_rlt-len(rlt_str))}{rlt_str}"
        return rlt_str
    @classmethod
    def write_to_file(cls, str_lst, flg, sum_h, rfile):
        """to write result in file"""
        with open(rfile, "w") as rltf:
            if flg:
                for bin_str in str_lst:
                    hex_str = cls.convert_b_h("bins", bin_str, sum_h)
                    rltf.write(f"{hex_str}{os.linesep}")
            else:
                for hex_str in str_lst:
                    rltf.write(f"{hex_str}{os.linesep}")
    @classmethod
    def gen_l2a_lst(cls, l3ab_lst, l2_set):
        """to generate l2 addr list"""
        l2a_lst = []
        for l2s in range(int(l2_set)):
            l2s = bin(l2s)[2:]
            if len(l2s) < 9:
                l2s = f"{'0'*(9-len(l2s))}{l2s}"
            cnt = 1
            while cnt <= 8:
                addr = random.choice(l3ab_lst)
                if addr[25:34] == l2s and addr not in l2a_lst:
                    l2a_lst.append(addr)
                    cnt = cnt+1
        return l2a_lst
    @classmethod
    def gen_l1da_lst(cls, l3ab_lst, l1_set):
        """to generate l1d addr list"""
        l1da_lst = []
        for l1s in range(l1_set):
            l1s = bin(l1s)[2:]
            if len(l1s) < 6:
                l1s = f"{'0'*(6-len(l1s))}{l1s}"
            fit_l1d = []
            for addr in l3ab_lst:
                if addr[28:34] != l1s:
                    continue
                if addr[0:17] == f"{'0'*17}":
                    fit_l1d.append(addr)
            dcnt = len(fit_l1d)
            if dcnt < 8:
                l1da_lst.extend(fit_l1d)
                LOG.info(f"l1d set{int(l1s, 2)} cache line num is {len(fit_l1d)}")
                while dcnt <= 8:
                    tmp = cls.gen_rand_bin(11)
                    if f"{'0'*17}{tmp}{l1s}" not in fit_l1d:
                        l1da_lst.append(f"{'0'*17}{tmp}{l1s}")
                        dcnt = dcnt+1
            else:
                l1d_cnt = 1
                while l1d_cnt <= 8:
                    addr_tmp = random.choice(fit_l1d)
                    if addr_tmp not in l1da_lst:
                        l1da_lst.append(addr_tmp)
                        l1d_cnt = l1d_cnt+1
        return l1da_lst
    @classmethod
    def gen_l1ia_lst(cls, l3ab_lst, l1_set):
        """to generate l1i addr list"""
        l1ia_lst = []
        for l1s in range(l1_set):
            l1s = bin(l1s)[2:]
            if len(l1s) < 6:
                l1s = f"{'0'*(6-len(l1s))}{l1s}"
            fit_l1i = []
            for addr in l3ab_lst:
                if addr[28:34] != l1s:
                    continue
                if addr[0:17] == f"{'1'*17}":
                    fit_l1i.append(addr)
            icnt = len(fit_l1i)
            if icnt < 8:
                l1ia_lst.extend(fit_l1i)
                LOG.info(f"l1i set{int(l1s, 2)} cache line num is {len(fit_l1i)}")
                while icnt <= 8:
                    tmp = cls.gen_rand_bin(11)
                    if f"{'1'*17}{tmp}{l1s}" not in fit_l1i:
                        l1ia_lst.append(f"{'1'*17}{tmp}{l1s}")
                        icnt = icnt+1
            else:
                l1i_cnt = 1
                while l1i_cnt <= 8:
                    addr_tmp = random.choice(fit_l1i)
                    if addr_tmp not in l1ia_lst:
                        l1ia_lst.append(addr_tmp)
                        l1i_cnt = l1i_cnt+1
        return l1ia_lst
    @classmethod
    def gen_md(cls, ctype, mesi, data):
        """to generate mesi and data"""
        if ctype == "L2":
            if mesi == "M":
                l2m = "11"
                l2d = cls.gen_rand_bin(512)
            elif mesi == "E":
                l2m = "10"
                l2d = data
            elif mesi == "S":
                l2m = "01"
                l2d = data
            else:
                l2m = "00"
                l2d = cls.gen_rand_bin(512)
            return l2m, l2d
        elif ctype == "L1D":
            if mesi == "M":
                l1dm = "011"
                l1dd = cls.gen_rand_bin(512)
            elif mesi == "E":
                l1dm = "010"
                l1dd = data
            elif mesi == "S":
                l1dm = "001"
                l1dd = data
            else:
                l1dm = "000"
                l1dd = cls.gen_rand_bin(512)
            return l1dm, l1dd
        elif ctype == "L1I":
            if mesi == "V":
                l1iv = "1"
                l1id = data
            else:
                l1iv = "0"
                l1id = cls.gen_rand_bin(512)
            return l1iv, l1id
    @classmethod
    def gen_l1d_md(cls, l2ms, l1dms, data):
        """to generate l2/l1d mesi and data"""
        if l2ms == "M":
            if l1dms == "M":
                l1d_m = "011"
                l1d_d = cls.gen_rand_bin(512)
            elif l1dms == "E":
                l1d_m = "010"
                l1d_d = data
            elif l1dms == "I":
                l1d_m = "000"
                l1d_d = cls.gen_rand_bin(512)
        elif l2ms == "E":
            if l1dms == "M":
                l1d_m = "011"
                l1d_d = cls.gen_rand_bin(512)
            elif l1dms == "E":
                l1d_m = "010"
                l1d_d = data
            elif l1dms == "I":
                l1d_m = "000"
                l1d_d = cls.gen_rand_bin(512)
        elif l2ms == "S":
            if l1dms == "S":
                l1d_m = "001"
                l1d_d = data
            elif l1dms == "I":
                l1d_m = "000"
                l1d_d = cls.gen_rand_bin(512)
        else:
            l1d_m, l1d_d = cls.gen_md("L1D", l1dms, data)
        return l1d_m, l1d_d
    @classmethod
    def gen_interwv(cls, data_lst, sum_cl):  #data_lst  [data, tag, mesi, lru]
        """to generate interweave data"""
        d_rlt = []
        for i in range(sum_cl):
            eccd = {"ed": "", "interwv_h": "", "interwv_l": "", "interwv_ed": ""}
            for j in range(16):
                eccd["ed"] = (
                    f"{eccd['ed']}{data_lst[i][0][32*j:32*(j+1)]}{'0'*4}")
            for k in range(288):
                eccd["interwv_h"] = f"{eccd['interwv_h']}{eccd['ed'][0:288][8*k%288+k//36]}"
                eccd["interwv_l"] = f"{eccd['interwv_l']}{eccd['ed'][288:][8*k%288+k//36]}"
            d_iwv = f"{eccd['interwv_h']}{eccd['interwv_l']}"
            for cnt in range(8):
                eccd["interwv_ed"] = f"{eccd['interwv_ed']}{d_iwv[72*cnt:72*(cnt+1)]}"
            if i%2 == 0:
                tm_dic = {"tg": [], "m": [], "iwv_tg": "", "iwv_m": ""}
                for tag in range(58):
                    cur_tg = (
                        f"{data_lst[i+1][1]}{'0'*6}{data_lst[i][1]}{'0'*6}"[2*tag%58+tag//29])
                    tm_dic["iwv_tg"] = f"{tm_dic['iwv_tg']}{cur_tg}"
                tm_dic["tg"].append(tm_dic["iwv_tg"][29:])
                tm_dic["tg"].append(tm_dic["iwv_tg"][0:29])
                for mesi in range(8):
                    cur_mesi = f"{data_lst[i+1][2]}{data_lst[i][2]}"[2*mesi%8+mesi//4]
                    tm_dic["iwv_m"] = f"{tm_dic['iwv_m']}{cur_mesi}"
                tm_dic["m"].append(tm_dic["iwv_m"][4:])
                tm_dic["m"].append(tm_dic["iwv_m"][0:4])
                d_rlt.append(
                    f"{tm_dic['tg'][0]}{eccd['interwv_ed']}{tm_dic['m'][0]}11110{data_lst[i][3]}")
            else:
                d_rlt.append(
                    f"{tm_dic['tg'][1]}{eccd['interwv_ed']}{tm_dic['m'][1]}11110{data_lst[i][3]}")
        return d_rlt
    @classmethod
    def gen_ecc(cls, data, ecc_bits):
        """to generate ecc value"""
        ecc_dic = {
            "p_d": "", "ecc": "", "p_lst": [], "d_tmp": data,
            "power": 0, "power_xor": 0, "ecc_h": 0}
        cnt_num = len(data)+ecc_bits
        for i in range(1, cnt_num):
            if i == pow(2, ecc_dic["power"]):
                ecc_dic["p_d"] = f"{ecc_dic['p_d']}p"
                ecc_dic["power"] = ecc_dic["power"]+1
                continue
            ecc_dic["p_d"] = f"{ecc_dic['p_d']}{ecc_dic['d_tmp'][0]}"
            ecc_dic["d_tmp"] = ecc_dic["d_tmp"][1:]
        for i in range(1, cnt_num):
            if i != pow(2, ecc_dic["power_xor"]):
                continue
            ecc_dic["power_xor"] = ecc_dic["power_xor"]+1
            pi_lst = []
            j = i-1
            while j < cnt_num-1:
                for k in range(0, i):
                    if j+k < cnt_num-1:
                        pi_lst.append(ecc_dic["p_d"][j+k])
                j = j+2*i
            pi_lst = pi_lst[1:]
            p_v = int(pi_lst[0])
            for pi_v in pi_lst[1:]:
                p_v = p_v^int(pi_v)
            ecc_dic["p_lst"].append(p_v)
            for p_d in pi_lst:
                p_v = p_v^int(p_d)
            ecc_dic["ecc"] = f"{ecc_dic['ecc']}{str(p_v)}"
        for digit in ecc_dic["p_lst"]:
            ecc_dic["ecc_h"] = ecc_dic["ecc_h"]^digit
        for str_d in data:
            ecc_dic["ecc_h"] = ecc_dic["ecc_h"]^int(str_d)
        ecc_dic["ecc"] = f"{str(ecc_dic['ecc_h'])}{ecc_dic['ecc']}"
        return ecc_dic["ecc"]
    def gen_mem_data(self):
        """to generate random figure for memory"""
        for _ in range(int(self.ci_dic["l3_set"])*int(self.ci_dic["l3_way"])):
            dl_bin = self.gen_rand_bin(512)
            self.mc_dic["mem"]["l"].append(dl_bin)
            dh_bin = self.gen_rand_bin(512)
            self.mc_dic["mem"]["h"].append(dh_bin)
            self.mc_dic["mem"]["cov"].append("0"*128)
        for cfg_addr in self.mc_dic["cfg_addr"]:
            addrv = cfg_addr.split("__")[1].strip()
            addrv = self.convert_b_h("hexs", addrv, 40)
            ind = int(addrv[21:34], 2)*16+int(self.cfg_dic[cfg_addr]["l3_way"], 16)
            if self.cfg_dic[cfg_addr]["l3_exist"] == "1" and (
                    self.cfg_dic[cfg_addr]["l3_mesi"] == "f"):
                if len(self.cfg_dic[cfg_addr]["l3_data"]) == 128:
                    self.mc_dic["mem"]["cov"][ind] = self.cfg_dic[cfg_addr]["l3_data"]
                else:
                    self.mc_dic["mem"]["cov"][ind] = (
                        f"{'0'*(128-len(self.cfg_dic[cfg_addr]['l3_data']))}"
                        f"{self.cfg_dic[cfg_addr]['l3_data']}")
            else:
                if len(self.cfg_dic[cfg_addr]["mem_data"]) == 128:
                    self.mc_dic["mem"]["cov"][ind] = self.cfg_dic[cfg_addr]["mem_data"]
                else:
                    self.mc_dic["mem"]["cov"][ind] = (
                        f"{'0'*(128-len(self.cfg_dic[cfg_addr]['mem_data']))}"
                        f"{self.cfg_dic[cfg_addr]['mem_data']}")
        LOG.info("to write memory result in file")
        self.write_to_file(self.mc_dic["mem"]["l"], True, 128, f"{self.rlt_dir}{os.sep}00000.dat")
        self.write_to_file(self.mc_dic["mem"]["h"], True, 128, f"{self.rlt_dir}{os.sep}1ffff.dat")
        self.write_to_file(self.mc_dic["mem"]["cov"], False, 0, f"{self.rlt_dir}{os.sep}mem.dat")
    def ow_org(self, c_type, c_dic, swb, c_x):
        """to overwite value from config file"""
        for cfg_addr in self.mc_dic["cfg_addr"]:
            addrv = cfg_addr.split("__")[1].strip()
            addrv = self.convert_b_h("hexs", addrv, 40)
            if c_type == "L3":
                l3_way = self.convert_b_h("hexs", self.cfg_dic[cfg_addr]["l3_way"], 4)
                if self.cfg_dic[cfg_addr]["l3_exist"] == "0" or (
                        addrv[21:34] != swb[0:13] or l3_way != swb[13:]):
                    continue
                c_dic["c_flg"] = True
                c_dic["addr_c"] = addrv[0:34]
                c_dic["m_c"] = self.convert_b_h("hexs", self.cfg_dic[cfg_addr]["l3_mesi"], 4)
                c_dic["lru_c"] = "0" if c_dic["m_c"] == "0100" else "1"
                c_dic["d_c"] = (
                    self.convert_b_h("hexs", self.cfg_dic[cfg_addr]["l3_data"], 512)
                    if c_dic["m_c"] == "1111"
                    else self.convert_b_h("hexs", self.cfg_dic[cfg_addr]["mem_data"], 512))
            elif c_type == "L2":
                if addrv[25:34] != c_dic["addr"][25:34]:
                    continue
                if self.cfg_dic[cfg_addr][f"{c_x}l2_exist"] == "1" and (
                        int(addrv[25:34], 2)*16+int(self.cfg_dic[cfg_addr][f"{c_x}l2_way"], 16)
                        == c_dic["a_ind"]):
                    c_dic["l2d"] = self.convert_b_h(
                        "hexs", self.cfg_dic[cfg_addr][f"{c_x}l2_data"], 512)
                    c_dic["l2m"] = self.convert_b_h(
                        "hexs", self.cfg_dic[cfg_addr][f"{c_x}l2_mesi"], 2)
                    c_dic["l2tg"] = addrv[0:25]
            elif c_type == "L1D":
                if addrv[28:34] != c_dic["addr"][28:34]:
                    continue
                if self.cfg_dic[cfg_addr][f"{c_x}l1d_exist"] == "1" and (
                        (int(addrv[28:34], 2)*16+int(self.cfg_dic[cfg_addr][f"{c_x}l1d_way"], 16))
                        == c_dic["a_ind"]):
                    c_dic["d"] = self.convert_b_h(
                        "hexs", self.cfg_dic[cfg_addr][f"{c_x}l1d_data"], 512)
                    c_dic["m"] = self.convert_b_h(
                        "hexs", self.cfg_dic[cfg_addr][f"{c_x}l1d_mesi"], 512)
                    c_dic["tg"] = addrv[0:28]
            elif c_type == "L1I":
                if addrv[28:34] != c_dic["addr"][28:34]:
                    continue
                if self.cfg_dic[cfg_addr][f"{c_x}l1i_exist"] == "1" and (
                        (int(addrv[28:34], 2)*16+int(self.cfg_dic[cfg_addr][f"{c_x}l1i_way"], 16))
                        == c_dic["a_ind"]):
                    c_dic["d"] = self.convert_b_h(
                        "hexs", self.cfg_dic[cfg_addr][f"{c_x}l1i_data"], 512)
                    c_dic["v"] = self.convert_b_h(
                        "hexs", self.cfg_dic[cfg_addr][f"{c_x}l1i_valid"], 1)
                    c_dic["tg"] = addrv[0:28]
    def gen_l3_data(self):
        """to generate random figure for L3 from memory"""
        for l3s in range(int(self.ci_dic["l3_set"])):
            i_cnt = 0
            for l3w in range(int(self.ci_dic["l3_way"])):
                l3_dic = {
                    "c_flg": False,
                    "addr": "", "d": "", "m": "", "lru": "",
                    "addr_c": "", "d_c": "", "m_c": "", "lru_c": ""}
                l3w_b = (
                    bin(l3w)[2:] if len(bin(l3w)[2:]) == 4
                    else f"{'0'*(4-len(bin(l3w)[2:]))}{bin(l3w)[2:]}")
                l3s_b = bin(l3s)[2:]
                if len(l3s_b) < 13:
                    l3s_b = f"{'0'*(13-len(l3s_b))}{l3s_b}"
                l3_dic["rand_rlt"] = random.choice(["0", "1"])
                l3_dic["addr"] = (
                    f"{'0'*17}{l3w_b}{l3s_b}" if l3_dic["rand_rlt"] == "0"
                    else f"{'1'*17}{l3w_b}{l3s_b}")
                self.mc_dic["l3"]["addr"].append(l3_dic["addr"])
                # 0001:S  0010:E  0100:I  1111:M
                l3_dic["m"] = random.choice(["0001", "0010", "0100", "1111"])
                if  l3_dic["m"] == "0100":
                    l3_dic["d"] = self.gen_rand_bin(512)
                    l3_dic["lru"] = "0"
                elif l3_dic["m"] == "1111":
                    l3_dic["d"] = self.gen_rand_bin(512)
                    l3_dic["lru"] = "1"
                    i_cnt = i_cnt+1
                else:
                    index = int(l3s_b, 2)*16+int(l3w_b, 2)
                    l3_dic["d"] = (
                        self.mc_dic["mem"]["l"][index] if l3_dic["rand_rlt"] == "0"
                        else self.mc_dic["mem"]["h"][index])
                    l3_dic["lru"] = "1"
                    i_cnt = i_cnt+1
                if i_cnt == 16:
                    l3_dic["lru"] = "0"
                self.mc_dic["l3"]["org"][l3_dic["addr"]].append(l3_dic["d"])
                self.mc_dic["l3"]["org"][l3_dic["addr"]].append(l3_dic["m"])
                self.mc_dic["l3"]["org"][l3_dic["addr"]].append(
                    random.choice(self.gen_mesi("cores", l3_dic["m"])))
                self.ow_org("L3", l3_dic, f"{l3s_b}{l3w_b}", "")
                l3_rm = {
                    "d": "", "tg": "", "m": "",
                    "s": self.convert_b_h("bins", l3s_b[2:], 3)}
                if l3_dic["c_flg"]:
                    temp_lst = [l3_dic["d_c"], l3_dic["addr_c"][0:23], l3_dic["m_c"]]
                    l3_rm["tg"] = self.convert_b_h("bins", l3_dic["addr_c"][0:23], 6)
                    l3_rm["m"] = self.convert_b_h("bins", l3_dic["m_c"], 1)
                    for i in range(8):
                        rmd_temp = self.convert_b_h("bins", l3_dic["d_c"][64*i:64*(i+1)], 16)
                        l3_rm["d"] = f"0x{rmd_temp},{l3_rm['d']}"
                else:
                    temp_lst = [l3_dic["d"], l3_dic["addr"][0:23], l3_dic["m"]]
                    l3_rm["tg"] = self.convert_b_h("bins", l3_dic["addr"][0:23], 6)
                    l3_rm["m"] = self.convert_b_h("bins", l3_dic["m"], 1)
                    for i in range(8):
                        rmd_temp = self.convert_b_h("bins", l3_dic["d"][64*i:64*(i+1)], 16)
                        l3_rm["d"] = f"0x{rmd_temp},{l3_rm['d']}"
                temp_lst.append(l3_dic["lru"]) #[data, tag, mesi, lru]
                self.mc_dic["l3"]["rlt_tmp"].append(temp_lst)
                self.mc_dic["l3"]["rm"].append(
                    f"0x{l3_rm['tg']},0x{l3_rm['s']},{l3_rm['d']}0x{l3_rm['m']},"
                    f"0xf,0x{l3_dic['lru']}")
        LOG.info("to generate interwave result")
        l3_cline_lst = self.gen_interwv(
            self.mc_dic["l3"]["rlt_tmp"], int(self.ci_dic["l3_set"])*int(self.ci_dic["l3_way"]))
        LOG.info("to write l3 result in file")
        # 615bits   tag_ecc:29  data:512  ecc:64  mesi:4  corevalid:5  lru:1
        self.write_to_file(l3_cline_lst, True, 154, f"{self.rlt_dir}{os.sep}l3.dat")
        self.write_to_file(
            self.mc_dic["l3"]["rm"], False, 0, f"{self.rm_dir}{os.sep}{self.case_name}_l3")
    def gen_cores_addr(self):
        """to generate cores l2/l1d/l1i addr_lst"""
        l3a_lst = list(self.mc_dic["l3"]["org"].keys())
        if self.cfg_dic["flag"]["addr"] == "block":
            LOG.info("to generate l2 addr from l3 in blocks")
            self.mc_dic["l2"]["addr"]["c0"].extend(
                self.gen_l2a_lst(self.mc_dic["l3"]["addr"][0:32768], int(self.ci_dic["l2_set"])))
            self.mc_dic["l2"]["addr"]["c1"].extend(
                self.gen_l2a_lst(
                    self.mc_dic["l3"]["addr"][32768:65536], int(self.ci_dic["l2_set"])))
            self.mc_dic["l2"]["addr"]["c2"].extend(
                self.gen_l2a_lst(
                    self.mc_dic["l3"]["addr"][65536:98304], int(self.ci_dic["l2_set"])))
            self.mc_dic["l2"]["addr"]["c3"].extend(
                self.gen_l2a_lst(self.mc_dic["l3"]["addr"][98304:], int(self.ci_dic["l2_set"])))
            LOG.info("to generate l1 addr from l3 in blocks")
            self.mc_dic["l1"]["l1da"]["c0"].extend(
                self.gen_l1da_lst(self.mc_dic["l3"]["addr"][0:32768], int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1da"]["c1"].extend(
                self.gen_l1da_lst(
                    self.mc_dic["l3"]["addr"][32768:65536], int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1da"]["c2"].extend(
                self.gen_l1da_lst(
                    self.mc_dic["l3"]["addr"][65536:98304], int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1da"]["c3"].extend(
                self.gen_l1da_lst(self.mc_dic["l3"]["addr"][98304:], int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1ia"]["c0"].extend(
                self.gen_l1ia_lst(self.mc_dic["l3"]["addr"][0:32768], int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1ia"]["c1"].extend(
                self.gen_l1ia_lst(
                    self.mc_dic["l3"]["addr"][32768:65536], int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1ia"]["c2"].extend(
                self.gen_l1ia_lst(
                    self.mc_dic["l3"]["addr"][65536:98304], int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1ia"]["c3"].extend(
                self.gen_l1ia_lst(self.mc_dic["l3"]["addr"][98304:], int(self.ci_dic["l1_set"])))
        else:
            LOG.info("to generate l2 addr from l3")
            self.mc_dic["l2"]["addr"]["c0"].extend(
                self.gen_l2a_lst(l3a_lst, int(self.ci_dic["l2_set"])))
            self.mc_dic["l2"]["addr"]["c1"].extend(
                self.gen_l2a_lst(l3a_lst, int(self.ci_dic["l2_set"])))
            self.mc_dic["l2"]["addr"]["c2"].extend(
                self.gen_l2a_lst(l3a_lst, int(self.ci_dic["l2_set"])))
            self.mc_dic["l2"]["addr"]["c3"].extend(
                self.gen_l2a_lst(l3a_lst, int(self.ci_dic["l2_set"])))
            LOG.info("to generate l1 addr from l3")
            self.mc_dic["l1"]["l1da"]["c0"].extend(
                self.gen_l1da_lst(l3a_lst, int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1da"]["c1"].extend(
                self.gen_l1da_lst(l3a_lst, int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1da"]["c2"].extend(
                self.gen_l1da_lst(l3a_lst, int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1da"]["c3"].extend(
                self.gen_l1da_lst(l3a_lst, int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1ia"]["c0"].extend(
                self.gen_l1ia_lst(l3a_lst, int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1ia"]["c1"].extend(
                self.gen_l1ia_lst(l3a_lst, int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1ia"]["c2"].extend(
                self.gen_l1ia_lst(l3a_lst, int(self.ci_dic["l1_set"])))
            self.mc_dic["l1"]["l1ia"]["c3"].extend(
                self.gen_l1ia_lst(l3a_lst, int(self.ci_dic["l1_set"])))
    def gen_l2md(self, c_x, l2_dic, c_type, l2l1m_dic):
        """to generate l2 mesi and data"""
        l2l1x = random.choice(l2l1m_dic[f"l2{c_type}"])
        if l2_dic["addr"] not in self.mc_dic["l1"][f"{c_type}a"][c_x]:
            while l2l1x[c_type] != "I":
                l2l1x = random.choice(l2l1m_dic[f"l2{c_type}"])
            l2_dic["l2m"], l2_dic["l2d"] = self.gen_md(
                "L2", l2l1x["l2"], self.mc_dic["l3"]["org"][l2_dic["addr"]][0])
        else:
            self.mc_dic["l1"][f"{c_type}l2_lst"].append(l2_dic["addr"])
            l2l1x = random.choice(l2l1m_dic[f"l2{c_type}"])
            l2_dic["l2m"], l2_dic["l2d"] = self.gen_md(
                "L2", l2l1x["l2"], self.mc_dic["l3"]["org"][l2_dic["addr"]][0])
            if c_type == "l1i":
                if l2l1x["l1i"] == "V":
                    l2_dic["l1iv"] = "1"
                    l2_dic["l1id"] = self.mc_dic["l3"]["org"][l2_dic["addr"]][0]
                else:
                    l2_dic["l1iv"] = "0"
                    l2_dic["l1id"] = self.gen_rand_bin(512)
                self.mc_dic["l1"]["l1il2_dic"][c_x][l2_dic["addr"]].extend(
                    [l2_dic["addr"][0:28], l2_dic["addr"][28:34], l2_dic["l1iv"], l2_dic["l1id"]])
            elif c_type == "l1d":
                l2_dic["l1dm"], l2_dic["l1dd"] = self.gen_l1d_md(
                    l2l1x["l2"], l2l1x["l1d"], self.mc_dic["l3"]["org"][l2_dic["addr"]][0])
                self.mc_dic["l1"]["l1dl2_dic"][c_x][l2_dic["addr"]].extend(
                    [l2_dic["addr"][0:28], l2_dic["addr"][28:34], l2_dic["l1dm"], l2_dic["l1dd"]])
    def gen_l2_data(self, c_x):
        """to generate l2 data"""
        for addr in self.mc_dic["l2"]["addr"][c_x]:
            l2_dic = {
                "l2m": "", "l2d": "", "eccd": "", "l2tg":addr[0:25],
                "a_ind": self.mc_dic["l2"]["addr"][c_x].index(addr), "addr": addr,
                "l1iv": "", "l1id": "", "l1dm": "", "l1dd": ""}
            if self.cfg_dic["flag"]["addr"] == "block":
                l2l1m_dic = self.gen_mesi("level", self.mc_dic["l3"]["org"][addr][1])
            else:
                l2l1m_dic = self.gen_mesi("level", self.mc_dic["l3"]["org"][addr][2][c_x])
            if addr[0:17] == f"{'1'*17}":
                self.gen_l2md(c_x, l2_dic, "l1i", l2l1m_dic)
            elif addr[0:17] == f"{'0'*17}":
                self.gen_l2md(c_x, l2_dic, "l1d", l2l1m_dic)
            self.ow_org("L2", l2_dic, "", c_x)
            rm_dic = {
                "d": "",
                "s": self.convert_b_h("bins", addr[25:34], 3),
                "m": self.convert_b_h("bins", l2_dic["l2m"], 1),
                "tg": self.convert_b_h("bins", l2_dic["l2tg"], 7)}
            for i in range(8):
                d_temp = l2_dic["l2d"][64*i:64*(i+1)]
                rmd = self.convert_b_h("bins", d_temp, 16)
                rm_dic["d"] = f"0x{rmd},{rm_dic['d']}"
                ecc = self.gen_ecc(d_temp, 8)
                for k in range(8):
                    l2_dic["eccd"] = f"{l2_dic['eccd']}{ecc[k]}{d_temp[8*k:8*(k+1)]}"
            self.mc_dic["l2"]["cl"][c_x].append(
                f"{l2_dic['l2tg']}{l2_dic['eccd']}{l2_dic['l2m']}")
            self.mc_dic["l2"]["rm"][c_x].append(
                f"0x{rm_dic['tg']},0x{rm_dic['s']},{rm_dic['d']}0x{rm_dic['m']}")
    def gen_l1d_data(self, c_x):
        """to generate l1d data from l3"""
        for addr in self.mc_dic["l1"]["l1da"][c_x]:
            l1d_dic = {
                "m": "", "d": "", "tg": addr[0:28], "pd": "",
                "addr": addr, "a_ind": self.mc_dic["l1"]["l1da"][c_x].index(addr)}
            l3addr_lst = list(self.mc_dic["l3"]["org"].keys())
            if addr not in l3addr_lst:
                l1d_dic["m"] = "I"
                l1d_dic["d"] = self.gen_rand_bin(512)
            elif addr in self.mc_dic["l1"]["l1dl2_lst"]:
                l1d_dic["m"] = self.mc_dic["l1"]["l1dl2_dic"][c_x][addr][2]
                l1d_dic["d"] = self.mc_dic["l1"]["l1dl2_dic"][c_x][addr][3]
            else:
                if self.cfg_dic["flag"]["addr"] == "block":
                    blk_m = self.gen_mesi("level", self.mc_dic["l3"]["org"][addr][1])
                else:
                    blk_m = self.gen_mesi("level", self.mc_dic["l3"]["org"][addr][2][c_x])
                l2l1d_m = random.choice(blk_m["l2l1d"])
                while l2l1d_m["l2"] != "I":
                    l2l1d_m = random.choice(blk_m["l2l1d"])
                l1d_dic["m"], l1d_dic["d"] = self.gen_md(
                    "L1D", l2l1d_m["l1d"], self.mc_dic["l3"]["org"][addr][0])
            self.ow_org("L1D", l1d_dic, "", c_x)
            for i in range(64):
                parity0 = "0" if (l1d_dic["d"][8*i:8*(i+1)].count("1"))%2 == 0 else "1"
                l1d_dic["pd"] = (
                    f"{l1d_dic['pd']}{l1d_dic['d'][8*i:8*(i+1)]}{parity0}")
            self.mc_dic["l1"]["cl_l1d"][c_x].append(
                f"{l1d_dic['tg']}{l1d_dic['pd']}{l1d_dic['m']}")
            rm_l1d = {
                "d": "", "m": self.convert_b_h("bins", l1d_dic["m"], 1),
                "s": self.convert_b_h("bins", addr[28:34], 2),
                "tg": self.convert_b_h("bins", l1d_dic["tg"], 7)}
            for i in range(8):
                temp_d = self.convert_b_h("bins", l1d_dic["d"][64*i:64*(i+1)], 16)
                rm_l1d["d"] = f"0x{temp_d},{rm_l1d['d']}"
            self.mc_dic["l1"]["rm"]["l1d"][c_x].append(
                f"0x{rm_l1d['tg']},0x{rm_l1d['s']},{rm_l1d['d']}0x{rm_l1d['m']}")
    def gen_l1i_data(self, c_x):
        """to generate l1i data from l3"""
        for addr in self.mc_dic["l1"]["l1ia"][c_x]:
            l1i_dic = {
                "v": "", "d": "", "tg": addr[0:28], "addr": addr,
                "a_ind": self.mc_dic["l1"]["l1ia"][c_x].index(addr)}
            if addr not in self.mc_dic["l3"]["org"]:
                l1i_dic["v"] = "I"
                l1i_dic["d"] = self.gen_rand_bin(512)
            if addr in self.mc_dic["l1"]["l1il2_lst"]:
                l1i_dic["v"], l1i_dic["d"] = self.gen_md(
                    "L1I", self.mc_dic["l1"]["l1il2_dic"][c_x][addr][2],
                    self.mc_dic["l1"]["l1il2_dic"][c_x][addr][3])
            else:
                if self.cfg_dic["flag"]["addr"] == "block":
                    l2l1i_m = self.gen_mesi("level", self.mc_dic["l3"]["org"][addr][1])
                else:
                    l2l1i_m = self.gen_mesi("level", self.mc_dic["l3"]["org"][addr][2][c_x])
                l2l1im = random.choice(l2l1i_m["l2l1i"])
                while l2l1im["l2"] != "I":
                    l2l1im = random.choice(l2l1i_m["l2l1i"])
                l1i_dic["v"], l1i_dic["d"] = self.gen_md(
                    "L1I", l2l1im["l1i"], self.mc_dic["l3"]["org"][addr][0])
            self.ow_org("L1I", l1i_dic, "", c_x)
            rm_l1i = {
                "d": "",
                "s": self.convert_b_h("bins", f"{addr[28:34]}", 2),
                "tg": self.convert_b_h("bins", l1i_dic["tg"], 7),
                "v": l1i_dic["v"]}
            pari = {"tag": "0" if l1i_dic["tg"].count("1")%2 == 0 else "1", "d": ""}
            for i in range(8):
                temp_d0 = self.convert_b_h("bins", l1i_dic["d"][64*i:64*(i+1)], 16)
                rm_l1i["d"] = f"0x{temp_d0},{rm_l1i['d']}"
                dp_dic = {"p": "", "d": l1i_dic["d"][64*i:64*(i+1)]}
                for k in range(8):
                    dp_dic["p"] = (
                        f"{dp_dic['p']}0" if dp_dic['d'][8*k:8*(k+1)].count("1")%2 == 0
                        else f"{dp_dic['p']}1")
                pari["d"] = f"{pari['d']}{dp_dic['p']}{dp_dic['d']}"
            self.mc_dic["l1"]["cl_l1i"][c_x].append(
                f"{l1i_dic['tg']}{pari['tag']}{pari['d']}{l1i_dic['v']}")
            self.mc_dic["l1"]["rm"]["l1i"][c_x].append(
                f"0x{rm_l1i['tg']},0x{rm_l1i['s']},{rm_l1i['d']}0x{rm_l1i['v']}")
    def init_cache(self):
        """to init memory and cache"""
        if self.seed:
            random.seed(self.seed)
        LOG.info("to generate memory data")
        self.gen_mem_data()
        LOG.info("to generate l3 data")
        self.gen_l3_data()
        LOG.info("to generate cores l2/l1 addr list")
        self.gen_cores_addr()
        LOG.info("to generate l2 data from l3")
        self.gen_l2_data("c0")
        self.gen_l2_data("c1")
        self.gen_l2_data("c2")
        self.gen_l2_data("c3")
        # 603bits   tag:25  data:512  ecc:64  mesi:2
        self.write_to_file(
            self.mc_dic["l2"]["cl"]["c0"], True, 151, f"{self.rlt_dir}{os.sep}c0l2.dat")
        self.write_to_file(
            self.mc_dic["l2"]["cl"]["c1"], True, 151, f"{self.rlt_dir}{os.sep}c1l2.dat")
        self.write_to_file(
            self.mc_dic["l2"]["cl"]["c2"], True, 151, f"{self.rlt_dir}{os.sep}c2l2.dat")
        self.write_to_file(
            self.mc_dic["l2"]["cl"]["c3"], True, 151, f"{self.rlt_dir}{os.sep}c3l2.dat")
        self.write_to_file(
            self.mc_dic["l2"]["rm"]["c0"], False, 0, f"{self.rm_dir}{os.sep}{self.case_name}_l2_c0")
        self.write_to_file(
            self.mc_dic["l2"]["rm"]["c1"], False, 0, f"{self.rm_dir}{os.sep}{self.case_name}_l2_c1")
        self.write_to_file(
            self.mc_dic["l2"]["rm"]["c2"], False, 0, f"{self.rm_dir}{os.sep}{self.case_name}_l2_c2")
        self.write_to_file(
            self.mc_dic["l2"]["rm"]["c3"], False, 0, f"{self.rm_dir}{os.sep}{self.case_name}_l2_c3")
        LOG.info("to generate l1d data from l3")
        self.gen_l1d_data("c0")
        self.gen_l1d_data("c1")
        self.gen_l1d_data("c2")
        self.gen_l1d_data("c3")
        LOG.info("to write l1d result in file")
        # 606bits   tag:28  data:512  parity:64  mesi:2
        self.write_to_file(
            self.mc_dic["l1"]["cl_l1d"]["c0"], True, 152, f"{self.rlt_dir}{os.sep}c0l1d.dat")
        self.write_to_file(
            self.mc_dic["l1"]["cl_l1d"]["c1"], True, 152, f"{self.rlt_dir}{os.sep}c1l1d.dat")
        self.write_to_file(
            self.mc_dic["l1"]["cl_l1d"]["c2"], True, 152, f"{self.rlt_dir}{os.sep}c2l1d.dat")
        self.write_to_file(
            self.mc_dic["l1"]["cl_l1d"]["c3"], True, 152, f"{self.rlt_dir}{os.sep}c3l1d.dat")
        self.write_to_file(
            self.mc_dic["l1"]["rm"]["l1d"]["c0"], False, 0,
            f"{self.rm_dir}{os.sep}{self.case_name}_l1d_c0_p0")
        self.write_to_file(
            self.mc_dic["l1"]["rm"]["l1d"]["c1"], False, 0,
            f"{self.rm_dir}{os.sep}{self.case_name}_l1d_c1_p0")
        self.write_to_file(
            self.mc_dic["l1"]["rm"]["l1d"]["c2"], False, 0,
            f"{self.rm_dir}{os.sep}{self.case_name}_l1d_c2_p0")
        self.write_to_file(
            self.mc_dic["l1"]["rm"]["l1d"]["c3"], False, 0,
            f"{self.rm_dir}{os.sep}{self.case_name}_l1d_c3_p0")
        LOG.info("to generate l1i data from l3")
        self.gen_l1i_data("c0")
        self.gen_l1i_data("c1")
        self.gen_l1i_data("c2")
        self.gen_l1i_data("c3")
        LOG.info("to write l1i result in file")
        # 606bits   tag:28  data:512  parity:65  valid:1
        self.write_to_file(
            self.mc_dic["l1"]["cl_l1i"]["c0"], True, 152, f"{self.rlt_dir}{os.sep}c0l1i.dat")
        self.write_to_file(
            self.mc_dic["l1"]["cl_l1i"]["c1"], True, 152, f"{self.rlt_dir}{os.sep}c1l1i.dat")
        self.write_to_file(
            self.mc_dic["l1"]["cl_l1i"]["c2"], True, 152, f"{self.rlt_dir}{os.sep}c2l1i.dat")
        self.write_to_file(
            self.mc_dic["l1"]["cl_l1i"]["c3"], True, 152, f"{self.rlt_dir}{os.sep}c3l1i.dat")
        self.write_to_file(
            self.mc_dic["l1"]["rm"]["l1i"]["c0"], False, 0,
            f"{self.rm_dir}{os.sep}{self.case_name}_l1i_c0_p0")
        self.write_to_file(
            self.mc_dic["l1"]["rm"]["l1i"]["c1"], False, 0,
            f"{self.rm_dir}{os.sep}{self.case_name}_l1i_c1_p0")
        self.write_to_file(
            self.mc_dic["l1"]["rm"]["l1i"]["c2"], False, 0,
            f"{self.rm_dir}{os.sep}{self.case_name}_l1i_c2_p0")
        self.write_to_file(
            self.mc_dic["l1"]["rm"]["l1i"]["c3"], False, 0,
            f"{self.rm_dir}{os.sep}{self.case_name}_l1i_c3_p0")
