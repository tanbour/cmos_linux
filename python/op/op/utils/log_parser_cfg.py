"""
Author: tsukasa minato @ OnePiece Platform Group
Email: minato@alchip.com
Description: log & report parser config
"""

PARSER_CFG_DIC = {
    "syn": {
        "syn.tcl": {
            "dc_qor_max_key": "06_qor.rpt",
            "dc_qor_max_key_type": "single",
            "dc_qor_max_key_exp_lst": [
                r'^\s*Design\s+WNS:\s*(?P<MAX_WNS>([-+]?\d+\.\d*))\s+TNS:\s*(?P<MAX_TNS>([-+]?\d+\.\d*))\s+Number of Violating Paths:\s*(?P<MAX_NVP>\d+)',
            ],
            "dc_qor_max_key_tpl": """{
                "timing_setup_wns": {{MAX_WNS}},
                "timing_setup_tns": {{MAX_TNS}},
                "timing_setup_nvp": {{MAX_NVP}},
            }""",

            "dc_qor_min_key": "06_qor.rpt",
            "dc_qor_min_key_type": "single",
            "dc_qor_min_key_exp_lst": [
                r'^\s*Design \(Hold\)\s+WNS:\s*(?P<MIN_WNS>([-+]?\d+\.\d*))\s+TNS:\s*(?P<MIN_TNS>([-+]?\d+\.\d*))\s+Number of Violating Paths:\s*(?P<MIN_NVP>\d+)',
            ],
            "dc_qor_min_key_tpl": """{
                "timing_hold_wns": {{MIN_WNS}},
                "timing_hold_tns": {{MIN_TNS}},
                "timing_hold_nvp": {{MIN_NVP}},
            }""",

            "dc_cell_count_key": "06_qor.rpt",
            "dc_cell_count_key_type": "single",
            "dc_cell_count_key_exp_lst": [
                r'^\s*Hierarchical Cell Count:\s*(?P<count_hier_cell>(\d+))',
                r'^\s*Hierarchical Port Count:\s*(?P<count_hier_port>(\d+))',
                r'^\s*Leaf Cell Count:\s*(?P<count_leaf_cell>(\d+))',
                r'^\s*Buf Cell Count:\s*(?P<count_buf_cell>(\d+))',
                r'^\s*Inv Cell Count:\s*(?P<count_inv_cell>(\d+))',
                r'^\s*CT Buf/Inv Cell Count:\s*(?P<count_ct_buf_cell>(\d+))',
                r'^\s*Combinational Cell Count:\s*(?P<count_combi_cell>(\d+))',
                r'^\s*Sequential Cell Count:\s*(?P<count_seq_cell>(\d+))',
                r'^\s*Macro Count:\s*(?P<count_macro_cell>(\d+))',
            ],
            "dc_cell_count_key_tpl": """{
                "count_hier_cell": {{count_hier_cell or 0}},
                "count_hier_port": {{count_hier_port or 0}},
                "count_leaf_cell": {{count_leaf_cell or 0}},
                "count_buf_cell": {{count_buf_cell or 0}},
                "count_inv_cell": {{count_inv_cell or 0}},
                "count_ct_buf_cell": {{count_ct_buf_cell or 0}},
                "count_combi_cell": {{count_combi_cell or 0}},
                "count_seq_cell": {{count_seq_cell or 0}},
                "count_macro_cell": {{count_macro_cell or 0}},
            }""",

            "dc_area_key": "06_qor.rpt",
            "dc_area_key_type": "single",
            "dc_area_key_exp_lst": [
                r'\s*Combinational Area:\s*(?P<area_combi>\d+\.\d*)',
                r'\s*Noncombinational Area:\s*(?P<area_non_combi>\d+\.\d*)',
                r'\s*Total Buffer Area:\s*(?P<area_buf>\d+\.\d*)',
                r'\s*Total Inverter Area:\s*(?P<area_inv>\d+\.\d*)',
                r'\s*Macro/Black Box Area:\s*(?P<area_macro>\d+\.\d*)',
                r'\s*Net Area:\s*(?P<area_nets>\d+\.\d*)',
                r'\s*Cell Area:\s*(?P<area_cell>\d+\.\d*)',
                r'\s*Design Area:\s*(?P<area_design>\d+\.\d*)',
            ],
            "dc_area_key_tpl": """{
                "area_combi": {{area_combi or 0.0}},
                "area_non_combi": {{area_non_combi or 0.0}},
                "area_buf": {{area_buf or 0.0}},
                "area_inv": {{area_inv or 0.0}},
                "area_macro": {{area_macro or 0.0}},
                "area_nets": {{area_nets or 0.0}},
                "area_cell": {{area_cell or 0.0}},
                "area_design": {{area_design or 0.0}},
            }""",

            "dc_design_rules_key": "06_qor.rpt",
            "dc_design_rules_key_type": "single",
            "dc_design_rules_key_exp_lst": [
                r'\s*Total Number of Nets:\s*(?P<num_nets>(\d+))',
                r'\s*Nets With Violations:\s*(?P<nets_violations>(\d+))',
                r'\s*Max Trans Violations:\s*(?P<max_trans_violations>(\d+))',
                r'\s*Max Cap Violations:\s*(?P<max_cap_violations>(\d+))',
            ],
            "dc_design_rules_key_tpl": """{
                "num_nets": {{num_nets or 0}},
                "nets_violations": {{nets_violations or 0}},
                "nets_max_tran": {{max_trans_violations or 0}},
                "nets_max_cap": {{max_cap_violations or 0}},
            }""",

            "dc_power_key": "06_power.rpt",
            "dc_power_key_type": "single",
            "dc_power_key_exp_lst": [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "dc_power_key_tpl": """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "dc_misc_server_key": "dc_misc",
            "dc_misc_server_key_type": "single",
            "dc_misc_server_key_exp_lst": [
                r'\s*Hostname:\s*(?P<server>\S+)',
            ],
            "dc_misc_server_key_tpl": """{
                "server": "{{server}}",
            }""",

            "dc_misc_key": "dc_misc",
            "dc_misc_key_type": "single",
            "dc_misc_key_exp_lst": [
                r'^Memory usage for this session (?P<max_memory>\d+) Mbytes.',
                r'^CPU usage for this session (?P<elapsed>\d+) seconds ',
            ],
            "dc_misc_key_tpl": """{
                "max_memory": {{max_memory or 0}},
                "elapsed" : float("%.1f"%({{elapsed or 0}} / 60.0)),
            }""",

        },
    },

    "pr": {
        "01_fp.tcl": {
            "placement_overview_img": "01_fp.placement_overview.png",
            "hier_placement_overview_img": "01_fp.hier_placement_overview.png",
            "powerplan_img": "01_fp.powerplan.png",
            "icc2_qor_key": "01_fp.qor.rpt",
            "icc2_qor_key_type": "multi",
            "icc2_qor_key_exp_lst": [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl": """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",
        },
        "02_place.tcl": {
            "placement_overview_img": "02_place.placement_overview.png",
            "hier_placement_overview_img": "02_place.hier_placement_overview.png",
            "pin_density_img": "02_place.pin_density.png",
            "cell_density_img": "02_place.cell_density.png",
            "congestion_img": "02_place.congestion.png",

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

            "icc2_power_key": "02_place.power.rpt",
            "icc2_power_key_type": "single",
            "icc2_power_key_exp_lst": [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl": """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key": "02_place.constraint.rpt",
            "icc2_const_scenario_key_type": "single",
            "icc2_const_scenario_key_exp_lst": [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key": "02_place.constraint.rpt",
            "icc2_max_tran_key_type": "single",
            "icc2_max_tran_key_exp_lst": [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl": """{
                "max_transition_{{icc2_scenario}}": {{max_transition}},
            }""",


            "icc2_max_cap_key": "02_place.constraint.rpt",
            "icc2_max_cap_key_type": "single",
            "icc2_max_cap_key_exp_lst": [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl": """{
                "max_capasitance_{{icc2_scenario}}": {{max_capacitance}},
            }""",


            "icc2_qor_key": "02_place.qor.rpt",
            "icc2_qor_key_type": "multi",
            "icc2_qor_key_exp_lst": [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl": """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key": "02_place.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type": "multi",
            "icc2_cell_area_key_exp_lst": [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl": """{
                "area_{{vt}}_area": {{area}},
                "area_{{vt}}_ratio": {{ratio}},
            }""",


            "icc2_utilization_key": "02_place.utilization.rpt",
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
        "03_clock.tcl" : {
            "placement_overview_img": "03_clock.placement_overview.png",
            "hier_placement_overview_img": "03_clock.hier_placement_overview.png",
            "pin_density_img": "03_clock.pin_density.png",
            "cell_density_img": "03_clock.cell_density.png",
            "congestion_img": "03_clock.congestion.png",

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

            "icc2_power_key": "03_clock.power.rpt",
            "icc2_power_key_type": "single",
            "icc2_power_key_exp_lst": [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl": """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key": "03_clock.constraint.rpt",
            "icc2_const_scenario_key_type": "single",
            "icc2_const_scenario_key_exp_lst": [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key": "03_clock.constraint.rpt",
            "icc2_max_tran_key_type": "single",
            "icc2_max_tran_key_exp_lst": [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl": """{
                "max_transition_{{icc2_scenario}}": {{max_transition}},
            }""",


            "icc2_max_cap_key": "03_clock.constraint.rpt",
            "icc2_max_cap_key_type": "single",
            "icc2_max_cap_key_exp_lst": [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl": """{
                "max_capasitance_{{icc2_scenario}}": {{max_capacitance}},
            }""",


            "icc2_qor_key": "03_clock.qor.rpt",
            "icc2_qor_key_type": "multi",
            "icc2_qor_key_exp_lst": [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl": """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key": "03_clock.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type": "multi",
            "icc2_cell_area_key_exp_lst": [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl": """{
                "area_{{vt}}_area": {{area}},
                "area_{{vt}}_ratio": {{ratio}},
            }""",


            "icc2_utilization_key": "03_clock.utilization.rpt",
            "icc2_utilization_key_type": "single",
            "icc2_utilization_key_exp_lst": [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl": """{
                "utilization": {{utilization}},
            }""",


            "icc2_routing_violation_key": "03_clock.check_routes.rpt",
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
        "04_clock_opt.tcl" : {
            "placement_overview_img": "04_clock_opt.placement_overview.png",
            "hier_placement_overview_img": "04_clock_opt.hier_placement_overview.png",
            "pin_density_img": "04_clock_opt.pin_density.png",
            "cell_density_img": "04_clock_opt.cell_density.png",
            "congestion_img": "04_clock_opt.congestion.png",

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

            "icc2_power_key": "04_clock_opt.power.rpt",
            "icc2_power_key_type": "single",
            "icc2_power_key_exp_lst": [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl": """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key": "04_clock_opt.constraint.rpt",
            "icc2_const_scenario_key_type": "single",
            "icc2_const_scenario_key_exp_lst": [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key": "04_clock_opt.constraint.rpt",
            "icc2_max_tran_key_type": "single",
            "icc2_max_tran_key_exp_lst": [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl": """{
                "max_transition_{{icc2_scenario}}": {{max_transition}},
            }""",


            "icc2_max_cap_key": "04_clock_opt.constraint.rpt",
            "icc2_max_cap_key_type": "single",
            "icc2_max_cap_key_exp_lst": [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl": """{
                "max_capasitance_{{icc2_scenario}}": {{max_capacitance}},
            }""",


            "icc2_qor_key": "04_clock_opt.qor.rpt",
            "icc2_qor_key_type": "multi",
            "icc2_qor_key_exp_lst": [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl": """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key": "04_clock_opt.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type": "multi",
            "icc2_cell_area_key_exp_lst": [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl": """{
                "area_{{vt}}_area": {{area}},
                "area_{{vt}}_ratio": {{ratio}},
            }""",


            "icc2_utilization_key": "04_clock_opt.utilization.rpt",
            "icc2_utilization_key_type": "single",
            "icc2_utilization_key_exp_lst": [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl": """{
                "utilization": {{utilization}},
            }""",


            "icc2_routing_violation_key": "04_clock_opt.check_routes.rpt",
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

        "05_route.tcl" : {
            "placement_overview_img": "05_route.placement_overview.png",
            "hier_placement_overview_img": "05_route.hier_placement_overview.png",
            "congestion_img": "05_route.congestion.png",
            "check_drc_img": "05_route.check_drc.png",
            "pin_density_img": "05_route.pin_density.png",
            "cell_density_img": "05_route.cell_density.png",
            "powerplan_img": "05_route.powerplan.png",
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

            "icc2_power_key": "05_route.power.rpt",
            "icc2_power_key_type": "single",
            "icc2_power_key_exp_lst": [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl": """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key": "05_route.constraint.rpt",
            "icc2_const_scenario_key_type": "single",
            "icc2_const_scenario_key_exp_lst": [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key": "05_route.constraint.rpt",
            "icc2_max_tran_key_type": "single",
            "icc2_max_tran_key_exp_lst": [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl": """{
                "max_transition_{{icc2_scenario}}": {{max_transition}},
            }""",


            "icc2_max_cap_key": "05_route.constraint.rpt",
            "icc2_max_cap_key_type": "single",
            "icc2_max_cap_key_exp_lst": [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl": """{
                "max_capasitance_{{icc2_scenario}}": {{max_capacitance}},
            }""",


            "icc2_qor_key": "05_route.qor.rpt",
            "icc2_qor_key_type": "multi",
            "icc2_qor_key_exp_lst": [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl": """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key": "05_route.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type": "multi",
            "icc2_cell_area_key_exp_lst": [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl": """{
                "area_{{vt}}_area": {{area}},
                "area_{{vt}}_ratio": {{ratio}},
            }""",


            "icc2_utilization_key": "05_route.utilization.rpt",
            "icc2_utilization_key_type": "single",
            "icc2_utilization_key_exp_lst": [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl": """{
                "utilization": {{utilization}},
            }""",


            "icc2_routing_violation_key": "05_route.check_routes.rpt",
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
        "06_route_opt.tcl" : {
            "placement_overview_img": "06_route_opt.placement_overview.png",
            "hier_placement_overview_img": "06_route_opt.hier_placement_overview.png",
            "congestion_img": "06_route_opt.congestion.png",
            "check_drc_img": "06_route_opt.check_drc.png",
            "pin_density_img": "06_route_opt.pin_density.png",
            "cell_density_img": "06_route_opt.cell_density.png",

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

            "icc2_power_key": "06_route_opt.power.rpt",
            "icc2_power_key_type": "single",
            "icc2_power_key_exp_lst": [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl": """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key": "06_route_opt.constraint.rpt",
            "icc2_const_scenario_key_type": "single",
            "icc2_const_scenario_key_exp_lst": [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key": "06_route_opt.constraint.rpt",
            "icc2_max_tran_key_type": "single",
            "icc2_max_tran_key_exp_lst": [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl": """{
                "max_transition_{{icc2_scenario}}": {{max_transition}},
            }""",


            "icc2_max_cap_key": "06_route_opt.constraint.rpt",
            "icc2_max_cap_key_type": "single",
            "icc2_max_cap_key_exp_lst": [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl": """{
                "max_capasitance_{{icc2_scenario}}": {{max_capacitance}},
            }""",


            "icc2_qor_key": "06_route_opt.qor.rpt",
            "icc2_qor_key_type": "multi",
            "icc2_qor_key_exp_lst": [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl": """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key": "06_route_opt.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type": "multi",
            "icc2_cell_area_key_exp_lst": [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl": """{
                "area_{{vt}}_area": {{area}},
                "area_{{vt}}_ratio": {{ratio}},
            }""",


            "icc2_utilization_key": "06_route_opt.utilization.rpt",
            "icc2_utilization_key_type": "single",
            "icc2_utilization_key_exp_lst": [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl": """{
                "utilization": {{utilization}},
            }""",


            "icc2_routing_violation_key": "06_route_opt.check_routes.rpt",
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
        "08_finish.tcl" : {
            "placement_overview_img": "08_finish.placement_overview.png",
            "hier_placement_overview_img": "08_finish.hier_placement_overview.png",
            "congestion_img": "08_finish.congestion.png",
            "check_drc_img": "08_finish.check_drc.png",
            "pin_density_img": "08_finish.pin_density.png",
            "cell_density_img": "08_finish.cell_density.png",

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

            "icc2_power_key": "08_finish.power.rpt",
            "icc2_power_key_type": "single",
            "icc2_power_key_exp_lst": [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl": """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key": "08_finish.constraint.rpt",
            "icc2_const_scenario_key_type": "single",
            "icc2_const_scenario_key_exp_lst": [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key": "08_finish.constraint.rpt",
            "icc2_max_tran_key_type": "single",
            "icc2_max_tran_key_exp_lst": [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl": """{
                "max_transition_{{icc2_scenario}}": {{max_transition}},
            }""",


            "icc2_max_cap_key": "08_finish.constraint.rpt",
            "icc2_max_cap_key_type": "single",
            "icc2_max_cap_key_exp_lst": [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl": """{
                "max_capasitance_{{icc2_scenario}}": {{max_capacitance}},
            }""",


            "icc2_qor_key": "08_finish.qor.rpt",
            "icc2_qor_key_type": "multi",
            "icc2_qor_key_exp_lst": [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl": """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key": "08_finish.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type": "multi",
            "icc2_cell_area_key_exp_lst": [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl": """{
                "area_{{vt}}_area": {{area}},
                "area_{{vt}}_ratio": {{ratio}},
            }""",


            "icc2_utilization_key": "08_finish.utilization.rpt",
            "icc2_utilization_key_type": "single",
            "icc2_utilization_key_exp_lst": [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl": """{
                "utilization": {{utilization}},
            }""",


            "icc2_routing_violation_key": "08_finish.check_routes.rpt",
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

            "star_open_net_key": "ext.star_sum",
            "star_open_net_key_type": "single",
            "star_open_net_key_exp_lst": [
                r'^WARNING: found open net\(s\) in the design'
            ],
            "star_open_net_key_tpl": """{
                "ext_open_net" : True
            }""",


            "star_short_net_key": "ext.star_sum",
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

            "pt_w_io_qor_key": "w_io.rpt",
            "pt_w_io_qor_key_type": "multi",
            "pt_w_io_qor_key_exp_lst": [
                r'\s+\*\s+\*\s+(?P<NVE>\d+)\s+(?P<WNS>[-+]?\d+\.\d*)\s+(?P<TNS>[-+]?\d+\.\d*)\s*$',
            ],
            "pt_w_io_qor_key_tpl": """{
                "timing_wns" : "{{WNS}}",
                "timing_tns" : "{{TNS}}",
                "timing_nve" : "{{NVE}}",
            }""",

            "pt_wo_io_qor_key": "wo_io.rpt",
            "pt_wo_io_qor_key_type": "multi",
            "pt_wo_io_qor_key_exp_lst": [
                r'\s+\*\s+\*\s+(?P<NVE>\d+)\s+(?P<WNS>[-+]?\d+\.\d*)\s+(?P<TNS>[-+]?\d+\.\d*)\s*$',
            ],
            "pt_wo_io_qor_key_tpl": """{
                "timing_wns" : "{{WNS}}",
                "timing_tns" : "{{TNS}}",
                "timing_nve" : "{{NVE}}",
            }""",

            "pt_max_tran_key": "report_constraint.max_transition.rpt",
            "pt_max_tran_key_type": "single",
            "pt_max_tran_key_exp_lst": [
                r'\sTotal transition error\s*=\s*(?P<max_transition>\d+)\s*',
            ],
            "pt_max_tran_key_tpl": """{
                "max_transition": {{max_transition}},
            }""",


            "pt_max_cap_key": "report_constraint.max_capacitance.rpt",
            "pt_max_cap_key_type": "single",
            "pt_max_cap_key_exp_lst": [
                r'\sTotal capacitance error\s*=\s*(?P<max_capacitance>\d+)\s*',
            ],
            "pt_max_cap_key_tpl": """{
                "max_capasitance": {{max_capacitance}},
            }""",


            "pt_clock_key": "clock_timing.skew.rpt",
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
