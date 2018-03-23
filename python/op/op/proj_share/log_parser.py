"""
Author: tsukasa minato @ OnePiece Platform Group
Email: minato@alchip.com
Description: log & report parser
"""

import os
import re
import collections
from jinja2 import Template
from utils import pcom

LOG = pcom.gen_logger(__name__)

class LogParser(object):
    """log & report parser"""

    def __init__(self):
        self.parser_dic = {}
        self.parser = collections.namedtuple(
            'parser', ['path', 'multiline', 'recomp_lst', 'template'])

    def add_parser(self, path, typ, reg_lst, tpl):
        ''' add parser specification '''
        realpath = os.path.realpath(path)
        if not os.path.isfile(realpath):
            LOG.error(f"parsing log file {realpath} is NA")
            raise SystemExit()
        if realpath not in self.parser_dic:
            self.parser_dic[realpath] = []
        multiline = False if typ.lower() == "single" else True
        if reg_lst and isinstance(reg_lst, list):
            recomp_lst = [re.compile(regexp) for regexp in reg_lst if regexp]
        else:
            recomp_lst = multiline = None
        self.parser_dic[realpath].append(self.parser(realpath, multiline, recomp_lst, tpl))

    @classmethod
    def _run_template(cls, tpl_text, raw_dic):
        ''' evaluate template with extracted env '''
        template = Template(tpl_text)
        eval_text = template.render(raw_dic)
        return eval(eval_text)

    @classmethod
    def _update_ext_dic(cls, ext_dic, data):
        ''' update extracted dict with data '''
        ext_dic.update(data)

    def _search_file(self, path, parser_single_lst, parser_multi_lst):
        ''' search pattern for file '''
        LOG.info(f"parsing log file {path}")
        ext_dic = {}
        raw_dic = {}
        with open(path, 'r') as p_f:
            multi_line = ""
            prev = None
            for line in p_f:
                # match for single
                for parser in parser_single_lst:
                    for recomp in parser.recomp_lst:
                        l_m = recomp.search(line)
                        if l_m:
                            LOG.debug(f"Match: {line}")
                            raw_dic.update(l_m.groupdict())
                            if parser.template:
                                data = self._run_template(parser.template, raw_dic)
                                self._update_ext_dic(ext_dic, data)
                # match for multi-lines
                if not parser_multi_lst:
                    continue
                if prev is None:
                    prev = line
                    continue
                else:
                    multi_line += prev
                    prev = line
                if re.match(r'^[ \t]+\S', line):
                    continue
                for parser in parser_multi_lst:
                    for recomp in parser.recomp_lst:
                        l_m = recomp.search(multi_line)
                        if l_m:
                            LOG.debug(f"Match: {multi_line}")
                            raw_dic.update(l_m.groupdict())
                            if parser.template:
                                data = self._run_template(parser.template, raw_dic)
                                self._update_ext_dic(ext_dic, data)
                multi_line = ""
        return ext_dic

    def run_parser(self):
        ''' run parser specification '''
        ext_dic = {}
        for path, parser_lst in self.parser_dic.items():
            parser_single_lst = []
            parser_multi_lst = []
            for parser in parser_lst:
                if parser.recomp_lst:
                    if not parser.multiline:
                        parser_single_lst.append(parser)
                    else:
                        parser_multi_lst.append(parser)
            if parser_single_lst or parser_multi_lst:
                ext_dic.update(self._search_file(path, parser_single_lst, parser_multi_lst))
        return ext_dic



PARSER_CFG_DIC = {
    "pr": {
        # "01_fp.tcl": {
        #     "qor_key": "01_fp.qor.rpt",
        #     "qor_key_type": "multi",
        #     "qor_key_exp_lst": [
        #         r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+'
        #         r'\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))'
        #         r'\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)'
        #     ],
        #     "qor_key_tpl": '''{
        #     "scenario" : "{{icc2_scenario}}",
        #     "type" : "{{icc2_timingtype.lower()}}",
        #     "WNS" : {% if WNS == "--" %}0.0{% else %}{{WNS}}{% endif%},
        #     "TNS" : {{TNS}},
        #     "NVE" : {{NVE}},
        #     }''',
        #     "qor_img": "emacs.png",
        # },
        "place.tcl": {
            "icc2_ems_key": "icc2_check_design",
            "icc2_ems_key_type": "single",
            "icc2_ems_key_exp_lst": [
                r'\s+Total\s+(?P<ems_total>\d+)\s+EMS messages : (?P<ems_error>\d+) errors, '
                r'(?P<ems_warn>\d+) warnings, (?P<ems_info>\d+) info.',
                r'\s+Total\s+(?P<non_ems_total>\d+)\s+non-EMS messages : (?P<non_ems_error>\d+) '
                r'errors, (?P<non_ems_warn>\d+) warnings, (?P<non_ems_info>\d+) info.'
            ],
            "icc2_ems_key_tpl": """{
                "ems_total": "{{ems_total}}",
                "ems_error": "{{ems_error}}",
                "ems_warn": "{{ems_warn}}",
                "ems_info": "{{ems_info}}",
                "non_ems_total" : "{{non_ems_total}}",
                "non_ems_error" : "{{non_ems_error}}",
                "non_ems_warn" : "{{non_ems_warn}}",
                "non_ems_info" : "{{non_ems_info}}"
            }""",


            "icc2_const_scenario_key": "icc2_constraint",
            "icc2_const_scenario_key_type": "single",
            "icc2_const_scenario_key_exp_lst": [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key": "icc2_constraint",
            "icc2_max_tran_key_type": "single",
            "icc2_max_tran_key_exp_lst": [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl": """{
                "max_transition_{{icc2_scenario}}": {{max_transition}},
            }""",


            "icc2_max_cap_key": "icc2_constraint",
            "icc2_max_cap_key_type": "single",
            "icc2_max_cap_key_exp_lst": [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl": """{
                "max_capasitance_{{icc2_scenario}}": {{max_capacitance}},
            }""",


            "icc2_qor_key": "icc2_timing",
            "icc2_qor_key_type": "multi",
            "icc2_qor_key_exp_lst": [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl": """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key": "icc2_cell_area",
            "icc2_cell_area_key_type": "multi",
            "icc2_cell_area_key_exp_lst": [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl": """{
                "area_{{vt}}_area": {{area}},
                "area_{{vt}}_ratio": {{ratio}},
            }""",


            "icc2_utilization_key": "icc2_utilization",
            "icc2_utilization_key_type": "single",
            "icc2_utilization_key_exp_lst": [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl": """{
                "utilization": {{utilization}},
            }""",


            "icc2_routing_violation_key": "icc2_routing_violation_key",
            "icc2_routing_violation_key_type": "single",
            "icc2_routing_violation_key_exp_lst": [
                r'^Total number of DRCs = (?P<drc>\d+)',
            ],
            "icc2_routing_violation_key_tpl": """{
                "routing_violation" : {{drc}},
            }""",


            "icc2_misc_server_key": "icc2_misc",
            "icc2_misc_server_key_type": "single",
            "icc2_misc_server_key_exp_lst": [
                r'^<<Starting on (?P<server>\S+)>>',
            ],
            "icc2_misc_server_key_tpl": """{
                "server" : "{{server}}",
            }""",

            "icc2_misc_mem_key": "icc2_misc",
            "icc2_misc_mem_key_type": "single",
            "icc2_misc_mem_key_exp_lst": [
                r'^Maximum memory usage for this session: (?P<max_memory>\d+\.\d*) MB',
            ],
            "icc2_misc_mem_key_tpl": """{
                "max_memory" : {{max_memory}},
            }""",

            "icc2_misc_elapsed_key": "icc2_misc",
            "icc2_misc_elapsed_key_type": "single",
            "icc2_misc_elapsed_key_exp_lst": [
                r'^Elapsed time for this session:\s+(?P<elapsed>\d+) seconds \(\s*(\d+\.\d*)\s*hours\)',
            ],
            "icc2_misc_elapsed_key_tpl": """{
                "elapsed" : float("%.1f"%({{elapsed}} / 60.0)),
            }""",
        },
    },

    "ext": {
        "ext.csh": {

            "star_open_net_key": "star_open_net",
            "star_open_net_key_type": "single",
            "star_open_net_key_exp_lst": [
                r'^WARNING: found open net\(s\) in the design'
            ],
            "star_open_net_key_tpl": """{
                "ext_open_net" : True
            }""",


            "star_short_net_key": "star_short_net",
            "star_short_net_key_type": "single",
            "star_short_net_key_exp_lst": [
                r'^WARNING: Found shorted nets'
            ],
            "star_short_net_key_tpl": """{
                "ext_short_net" : True
            }""",


            "star_misc_server_key": "star_misc",
            "star_misc_server_key_type": "single",
            "star_misc_server_key_exp_lst": [
                r'^Host \.+ (?P<server>\S+)',
            ],
            "star_misc_server_key_tpl": """{
                "server" : "{{server}}",
            }""",

            "star_misc_mem_key": "star_misc",
            "star_misc_mem_key_type": "single",
            "star_misc_mem_key_exp_lst": [
                r'Done\s+Elp=\d+:\d+:\d+ Cpu=\d+:\d+:\d+\s+Usr=\d+\.\d*\s+Sys=\d+\.\d*\s+Mem=(?P<max_memory>\d+\.\d*)',
            ],
            "star_misc_mem_key_tpl": """{
                "max_memory" : {{max_memory}},
            }""",

            "star_misc_elapsed_key": "star_misc",
            "star_misc_elapsed_key_type": "single",
            "star_misc_elapsed_key_exp_lst": [
                r'^Overall:\s+Elp=0*(?P<elp_hh>\d+):0*(?P<elp_mm>\d+):0*(?P<elp_ss>\d+)\s+Cpu=0*(?P<cpu_hh>\d+):0*(?P<cpu_mm>\d+):0*(?P<cpu_ss>\d+)',
            ],
            "star_misc_elapsed_key_tpl": """{
                "elapsed" : float("%.1f"%({{elp_hh}} * 60.0 + {{elp_mm}} + {{elp_ss}} / 60.0)),
            }""",

        },
    },

    "sta": {
        "sta.tcl": {

            "pt_qor_key": "pt_timing",
            "pt_qor_key_type": "multi",
            "pt_qor_key_exp_lst": [
                r'\s+\*\s+\*\s+(?P<NVE>\d+)\s+(?P<WNS>[-+]?\d+\.\d*)\s+(?P<TNS>[-+]?\d+\.\d*)\s*$',
            ],
            "pt_qor_key_tpl": """{
                "timing_wns" : "{{WNS}}",
                "timing_tns" : "{{TNS}}",
                "timing_nve" : "{{NVE}}",
            }""",


            "pt_max_tran_key": "pt_constraint",
            "pt_max_tran_key_type": "single",
            "pt_max_tran_key_exp_lst": [
                r'\sTotal transition error\s*=\s*(?P<max_transition>\d+)\s*',
            ],
            "pt_max_tran_key_tpl": """{
                "max_transition": {{max_transition}},
            }""",


            "pt_max_cap_key": "pt_constraint",
            "pt_max_cap_key_type": "single",
            "pt_max_cap_key_exp_lst": [
                r'\sTotal capacitance error\s*=\s*(?P<max_capacitance>\d+)\s*',
            ],
            "pt_max_cap_key_tpl": """{
                "max_capasitance": {{max_capacitance}},
            }""",


            "pt_clock_key": "pt_clock",
            "pt_clock_key_type": "single",
            "pt_clock_key_exp_lst": [
                r'\|\s*(?P<clock>\S+)\s*\|\s*(?P<ff_num>\d+)\s*\|\s*(?P<min>[-+]?\d+\.\d*)\s*\|\s*(?P<max>[-+]?\d+\.\d*)\s*\|\s*(?P<skew>[-+]?\d+\.\d*)\s*\|\s*$',
            ],
            "pt_clock_key_tpl": """{
                "clock_{{clock}}_ff_num": {{ff_num}},
                "clock_{{clock}}_min": {{min}},
                "clock_{{clock}}_max": {{max}},
                "clock_{{clock}}_skew": {{skew}},
            }""",


            "pt_misc_server_key": "pt_misc",
            "pt_misc_server_key_type": "single",
            "pt_misc_server_key_exp_lst": [
                r'^<<Starting on (?P<server>\w+)>>',
            ],
            "pt_misc_server_key_tpl": """{
                "server": "{{server}}",
            }""",


            "pt_misc_mem_key": "pt_misc",
            "pt_misc_mem_key_type": "single",
            "pt_misc_mem_key_exp_lst": [
                r'^Maximum memory usage for this session: (?P<max_memory>\d+\.\d*) MB',
            ],
            "pt_misc_mem_key_tpl": """{
                "max_memory": {{max_memory}},
            }""",


            "pt_misc_elapsed_key": "pt_misc",
            "pt_misc_elapsed_key_type": "single",
            "pt_misc_elapsed_key_exp_lst": [
                r'^Elapsed time for this session:\s+(?P<elapsed>\d+) seconds\s*(\(\s*(\d+\.\d*)\s*hours\))?',
            ],
            "pt_misc_elapsed_key_tpl": """{
                "elapsed" : float("%.1f"%({{elapsed}} / 60.0)),
            }""",

        },
    },
}

if __name__ == '__main__':

    print(main())

    def main():
        """main func to test log parser"""
        key_path = {
            "icc2_ems_key": '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/icc2.0724/huc_core_sys.icc2_place.default.0724.check_design.pre_clock_tree_stage.log',

            "icc2_const_scenario_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.constraint.rep',
            "icc2_max_tran_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.constraint.rep',
            "icc2_max_cap_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.constraint.rep',

            "icc2_qor_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.qor.rep',

            "icc2_cell_area_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.threshold_voltage_group.rep',

            "icc2_utilization_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.utilization.rpt',

            "icc2_routing_violation_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.check_routes.log',

            "icc2_misc_server_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/log/icc2.120460/icc2_route_opt.default.120460.log',
            "icc2_misc_mem_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/log/icc2.120460/icc2_route_opt.default.120460.log',
            "icc2_misc_elapsed_key" : '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/log/icc2.120460/icc2_route_opt.default.120460.log',

            "star_open_net_key" : '/proj/TRAINING/OP_LAB/fruit/WORK/simonz/orange/run/v0225/DEFAULT/log/ext/ext.orange.star_sum',
            "star_short_net_key" : '/proj/TRAINING/OP_LAB/fruit/WORK/simonz/orange/run/v0225/DEFAULT/log/ext/ext.orange.star_sum',
            "star_misc_server_key" : '/proj/TRAINING/OP_LAB/fruit/WORK/simonz/orange/run/v0225/DEFAULT/log/ext/ext.orange.star_sum',
            "star_misc_mem_key" : '/proj/TRAINING/OP_LAB/fruit/WORK/simonz/orange/run/v0225/DEFAULT/log/ext/ext.orange.star_sum',
            "star_misc_elapsed_key" : '/proj/TRAINING/OP_LAB/fruit/WORK/simonz/orange/run/v0225/DEFAULT/log/ext/ext.orange.star_sum',

            "pt_qor_key" : '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/pt.0928/func.wc.rcworst_125c.max/timing.func.wc.rcworst_125c.setup.w_io.rep.summary',
            "pt_clock_key" : '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/pt.0928/func.wc.rcworst_125c.max/clock_timing.func.wc.rcworst_125c.latency.rep.summary',
            "pt_max_tran_key" : '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/pt.0928/func.wc.rcworst_125c.max/constraint.max_transition.rep.summary',
            "pt_max_cap_key" : '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/pt.0928/func.wc.rcworst_125c.max/constraint.max_capacitance.rep.summary',
            "pt_misc_server_key" : '/proj/TRAINING/OP_LAB/fruit/WORK/simonz/orange/run/v0225/DEFAULT/sum/sta/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/sta.tcl.op.run.beer',
            "pt_misc_mem_key" : '/proj/TRAINING/OP_LAB/fruit/WORK/simonz/orange/run/v0225/DEFAULT/sum/sta/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/sta.tcl.op.run.log',
            "pt_misc_elapsed_key" : '/proj/TRAINING/OP_LAB/fruit/WORK/simonz/orange/run/v0225/DEFAULT/sum/sta/func.tt0p8v.wcl.cworst_CCworst_T_125c.setup/sta.tcl.op.run.log',

        }

        pcd = PARSER_CFG_DIC.get("pr").get("place.tcl")
        pcd = PARSER_CFG_DIC.get("ext").get("ext.csh")
        pcd = PARSER_CFG_DIC.get("sta").get("sta.tcl")

        l_p = LogParser()

        for p_k, p_v in pcd.items():
            if not p_k.endswith("_key") or not p_v:
                continue
            print(f"Key: {p_k}")
            l_p.add_parser(
                key_path[p_k], pcd.get(f"{p_k}_type", ""),
                pcd.get(f"{p_k}_exp_lst", []), pcd.get(f"{p_k}_tpl", ""))
        return l_p.run_parser()
