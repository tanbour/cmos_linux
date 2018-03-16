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
                ### match for single
                for parser in parser_single_lst:
                    for recomp in parser.recomp_lst:
                        l_m = recomp.search(line)
                        if l_m:
                            LOG.debug(f"Match: {line}")
                            raw_dic.update(l_m.groupdict())
                            if parser.template:
                                data = self._run_template(parser.template, raw_dic)
                                self._update_ext_dic(ext_dic, data)
                ### match for multi-lines
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
        "place.tcl": {
            "icc2_ems_key": "icc2_check_design",
            "icc2_ems_key_type": "single",
            "icc2_ems_key_exp_lst": [
                r'\s+Total\s+(?P<ems_total>\d+)\s+EMS messages : (?P<ems_error>\d+) errors, (?P<ems_warn>\d+) warnings, (?P<ems_info>\d+) info.',
                r'\s+Total\s+(?P<non_ems_total>\d+)\s+non-EMS messages : (?P<non_ems_error>\d+) errors, (?P<non_ems_warn>\d+) warnings, (?P<non_ems_info>\d+) info.'
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
            }"""
        }
    }
}

# if __name__ == '__main__':

#     # tentative config example for [log_parser]
#     icc2_ems_log = '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/icc2.0724/huc_core_sys.icc2_place.default.0724.check_design.pre_clock_tree_stage.log'
#     icc2_ems_key = 'icc2_check_design'
#     icc2_ems_reg = 'single', r'\s+Total\s+(?P<ems_total>\d+)\s+EMS messages : (?P<ems_error>\d+) errors, (?P<ems_warn>\d+) warnings, (?P<ems_info>\d+) info.'
#     icc2_ems_tpl = '''{
#       "ems_total" : {{ems_total}},
#       "ems_error" : {{ems_error}},
#       "ems_warn" : {{ems_warn}},
#       "ems_info" : {{ems_info}}
#     }'''

#     icc2_non_ems_log = '/proj/OP4/SOFTWARE/WORK/minato/beta-2/Anarion/WORK/minato/huc_core_sys/V0720_S0720_F0720/rpt/icc2.0724/huc_core_sys.icc2_place.default.0724.check_design.pre_clock_tree_stage.log'
#     icc2_non_ems_key = 'icc2_check_design'
#     icc2_non_ems_reg = 'single', r'\s+Total\s+(?P<non_ems_total>\d+)\s+non-EMS messages : (?P<non_ems_error>\d+) errors, (?P<non_ems_warn>\d+) warnings, (?P<non_ems_info>\d+) info.'
#     icc2_non_ems_tpl = '''{
#       "non_ems_total" : {{non_ems_total}},
#       "non_ems_error" : {{non_ems_error}},
#       "non_ems_warn" : {{non_ems_warn}},
#       "non_ems_info" : {{non_ems_info}}
#     }'''


#     icc2_constraint_scinario_log = '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.constraint.rep'
#     icc2_constraint_scinario_key = 'icc2_constraint'
#     icc2_constraint_scinario_reg = 'single', r'\s+Scenario:\s+(?P<icc2_scenario>\S+)'

#     icc2_max_transition_log = icc2_constraint_scinario_log
#     icc2_max_transition_key = icc2_constraint_scinario_key
#     icc2_max_transition_reg = 'single', r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)'
#     icc2_max_transition_tpl = '''{
#       "scenario" : "{{icc2_scenario}}",
#       "max_transition" : {{max_transition}}
#     }'''

#     icc2_max_capacitance_log = icc2_constraint_scinario_log
#     icc2_max_capacitance_key = icc2_constraint_scinario_key
#     icc2_max_capacitance_reg = 'single', r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)'
#     icc2_max_capacitance_tpl = '''{
#       "scenario" : "{{icc2_scenario}}",
#       "max_capacitance" : {{max_capacitance}}
#     }'''


#     icc2_qor_log = '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.qor.rep'
#     icc2_qor_key = 'icc2_timing'
#     icc2_qor_reg = 'multi', r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)'
#     icc2_qor_tpl = '''{
#       "scenario" : "{{icc2_scenario}}",
#       "type" : "{{icc2_timingtype.lower()}}",
#       "WNS" : {% if WNS == "--" %}0.0{% else %}{{WNS}}{% endif%},
#       "TNS" : {{TNS}},
#       "NVE" : {{NVE}},
#     }'''


#     icc2_cell_density_log = '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.cell_density.png'
#     icc2_cell_density_key = 'icc2_cell_density'


#     icc2_congestion_log = '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.congestion.png'
#     icc2_congestion_key = 'icc2_congestion'


#     icc2_cell_area_log = '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.threshold_voltage_group.rep'
#     icc2_cell_area_key = 'icc2_cell_area'
#     icc2_cell_area_reg = 'multi', r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)'
#     icc2_cell_area_tpl = '''{
#       "vt" : "{{vt}}",
#       "area" : {{area}},
#       "ratio" : {{ratio}}
#     }'''


#     icc2_utilization_log = '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.utilization.rpt'
#     icc2_utilization_key = 'icc2_utilization'
#     icc2_utilization_reg = 'single', r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)'
#     icc2_utilization_tpl = '''{
#       "utilization" : {{utilization}}
#     }'''


#     icc2_routing_violation_log = '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/rpt/icc2.120460/engine_tile.icc2_route_opt.default.120460.check_routes.log'
#     icc2_routing_violation_key = 'icc2_routing_violation'
#     icc2_routing_violation_reg = 'single', r'^Total number of DRCs = (?P<drc>\d+)'
#     icc2_routing_violation_tpl = '''{
#       "Total" : {{drc}}
#     }'''


#     icc2_misc_server_log = '/proj/OP4/SOFTWARE/WORK/minato/dev/sample/log/icc2.120460/icc2_route_opt.default.120460.log'
#     icc2_misc_server_key = 'icc2_misc'
#     icc2_misc_server_reg = 'single', r'^<<Starting on (?P<server>\S+)>>'

#     icc2_misc_mem_log = icc2_misc_server_log
#     icc2_misc_mem_key = icc2_misc_server_key
#     icc2_misc_mem_reg = 'single', r'^Maximum memory usage for this session: (?P<max_memory>\d+\.\d*) MB'

#     icc2_misc_elapsed_log = icc2_misc_server_log
#     icc2_misc_elapsed_key = icc2_misc_server_key
#     icc2_misc_elapsed_reg = 'single', r'^Elapsed time for this session:\s+(?P<elapsed>\d+) seconds \(\s*(\d+\.\d*)\s*hours\)'
#     icc2_misc_elapsed_tpl = '''{
#       "server" : "{{server}}",
#       "max_memory" : {{max_memory}},
#       "elapsed" : float("%.1f"%({{elapsed}} / 60.0)),
#     }'''



#     # Sample log parsing procedure
#     p = LogParser()

#     # Just example
#     l_dic = locals().copy()
#     for var in l_dic.keys():
#         m = re.match(r'^(icc2_\w+)_log$', var)
#         if m:
#             key = m.groups(1)
#             p.add_parser(l_dic[var], l_dic['%s_key'%key], l_dic.get('%s_reg'%key, None), l_dic.get('%s_tpl'%key, None))

#     ext_dic = p.run_parser()
#     print(json.dumps(ext_dic, indent=4))
