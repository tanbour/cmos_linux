"""
Author: tsukasa minato @ OnePiece Platform Group
Email: minato@alchip.com
Description: log & report parser config
"""

PARSER_CFG_DIC = {
    "syn" : {
        "syn.tcl" : {
            "dc_qor_max_key" : "06_qor.rpt",
            "dc_qor_max_key_type" : "single",
            "dc_qor_max_key_exp_lst" : [
                r'^\s*Design\s+WNS:\s*(?P<MAX_WNS>([-+]?\d+\.\d*))\s+TNS:\s*(?P<MAX_TNS>([-+]?\d+\.\d*))\s+Number of Violating Paths:\s*(?P<MAX_NVP>\d+)',
            ],
            "dc_qor_max_key_tpl" : """{
                "timing_setup_wns" : {{MAX_WNS}},
                "timing_setup_tns" : {{MAX_TNS}},
                "timing_setup_nvp" : {{MAX_NVP}},
            }""",

            "dc_qor_min_key" : "06_qor.rpt",
            "dc_qor_min_key_type" : "single",
            "dc_qor_min_key_exp_lst" : [
                r'^\s*Design \(Hold\)\s+WNS:\s*(?P<MIN_WNS>([-+]?\d+\.\d*))\s+TNS:\s*(?P<MIN_TNS>([-+]?\d+\.\d*))\s+Number of Violating Paths:\s*(?P<MIN_NVP>\d+)',
            ],
            "dc_qor_min_key_tpl" : """{
                "timing_hold_wns" : {{MIN_WNS}},
                "timing_hold_tns" : {{MIN_TNS}},
                "timing_hold_nvp" : {{MIN_NVP}},
            }""",

            "dc_cell_count_key" : "06_qor.rpt",
            "dc_cell_count_key_type" : "single",
            "dc_cell_count_key_exp_lst" : [
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
            "dc_cell_count_key_tpl" : """{
                "count_hier_cell" : {{count_hier_cell or 0}},
                "count_hier_port" : {{count_hier_port or 0}},
                "count_leaf_cell" : {{count_leaf_cell or 0}},
                "count_buf_cell" : {{count_buf_cell or 0}},
                "count_inv_cell" : {{count_inv_cell or 0}},
                "count_ct_buf_cell" : {{count_ct_buf_cell or 0}},
                "count_combi_cell" : {{count_combi_cell or 0}},
                "count_seq_cell" : {{count_seq_cell or 0}},
                "count_macro_cell" : {{count_macro_cell or 0}},
            }""",

            "dc_area_key" : "06_qor.rpt",
            "dc_area_key_type" : "single",
            "dc_area_key_exp_lst" : [
                r'\s*Combinational Area:\s*(?P<area_combi>\d+\.\d*)',
                r'\s*Noncombinational Area:\s*(?P<area_non_combi>\d+\.\d*)',
                r'\s*Total Buffer Area:\s*(?P<area_buf>\d+\.\d*)',
                r'\s*Total Inverter Area:\s*(?P<area_inv>\d+\.\d*)',
                r'\s*Macro/Black Box Area:\s*(?P<area_macro>\d+\.\d*)',
                r'\s*Net Area:\s*(?P<area_nets>\d+\.\d*)',
                r'\s*Cell Area:\s*(?P<area_cell>\d+\.\d*)',
                r'\s*Design Area:\s*(?P<area_design>\d+\.\d*)',
            ],
            "dc_area_key_tpl" : """{
                "area_combi" : {{area_combi or 0.0}},
                "area_non_combi" : {{area_non_combi or 0.0}},
                "area_buf" : {{area_buf or 0.0}},
                "area_inv" : {{area_inv or 0.0}},
                "area_macro" : {{area_macro or 0.0}},
                "area_nets" : {{area_nets or 0.0}},
                "area_cell" : {{area_cell or 0.0}},
                "area_design" : {{area_design or 0.0}},
            }""",

            "dc_design_rules_key" : "06_qor.rpt",
            "dc_design_rules_key_type" : "single",
            "dc_design_rules_key_exp_lst" : [
                r'\s*Total Number of Nets:\s*(?P<num_nets>(\d+))',
                r'\s*Nets With Violations:\s*(?P<nets_violations>(\d+))',
                r'\s*Max Trans Violations:\s*(?P<max_trans_violations>(\d+))',
                r'\s*Max Cap Violations:\s*(?P<max_cap_violations>(\d+))',
            ],
            "dc_design_rules_key_tpl" : """{
                "num_nets" : {{num_nets or 0}},
                "nets_violations" : {{nets_violations or 0}},
                "nets_max_tran" : {{max_trans_violations or 0}},
                "nets_max_cap" : {{max_cap_violations or 0}},
            }""",

            "dc_power_key" : "06_power.rpt",
            "dc_power_key_type" : "single",
            "dc_power_key_exp_lst" : [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "dc_power_key_tpl" : """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "dc_misc_server_key" : "dc_misc",
            "dc_misc_server_key_type" : "single",
            "dc_misc_server_key_exp_lst" : [
                r'\s*Hostname:\s*(?P<server>\S+)',
            ],
            "dc_misc_server_key_tpl" : """{
                "server" : "{{server}}",
            }""",

            "dc_misc_key" : "dc_misc",
            "dc_misc_key_type" : "single",
            "dc_misc_key_exp_lst" : [
                r'^Memory usage for this session (?P<max_memory>\d+) Mbytes.',
                r'^CPU usage for this session (?P<elapsed>\d+) seconds ',
            ],
            "dc_misc_key_tpl" : """{
                "max_memory" : {{max_memory or 0}},
                "elapsed" : float("%.1f"%({{elapsed or 0}} / 60.0)),
            }""",

        },
    },

    "pr" : {
        "01_fp.tcl" : {
            "placement_overview_img" : "01_fp.placement_overview.png",
            "hier_placement_overview_img" : "01_fp.hier_placement_overview.png",
            "powerplan_img" : "01_fp.powerplan.png",
            "icc2_qor_key" : "01_fp.zero_interconnect.qor.rpt",
            "icc2_qor_key_type" : "multi",
            "icc2_qor_key_exp_lst" : [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl" : """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",
        },
        "02_place.tcl" : {
            "placement_overview_img" : "02_place.placement_overview.png",
            "hier_placement_overview_img" : "02_place.hier_placement_overview.png",
            "pin_density_img" : "02_place.pin_density.png",
            "cell_density_img" : "02_place.cell_density.png",
            "congestion_img" : "02_place.congestion.png",

            "icc2_ems_key" : "icc2_check_design",
            "icc2_ems_key_type" : "single",
            "icc2_ems_key_exp_lst" : [
                r'\s+Total\s+(?P<ems_total>\d+)\s+EMS messages: (?P<ems_error>\d+) errors, '
                r'(?P<ems_warn>\d+) warnings, (?P<ems_info>\d+) info.',
                r'\s+Total\s+(?P<non_ems_total>\d+)\s+non-EMS messages: (?P<non_ems_error>\d+) '
                r'errors, (?P<non_ems_warn>\d+) warnings, (?P<non_ems_info>\d+) info.'
            ],
            "icc2_ems_key_tpl" : """{
                "ems_total" : "{{ems_total}}",
                "ems_error" : "{{ems_error}}",
                "ems_warn" : "{{ems_warn}}",
                "ems_info" : "{{ems_info}}",
                "non_ems_total" : "{{non_ems_total}}",
                "non_ems_error" : "{{non_ems_error}}",
                "non_ems_warn" : "{{non_ems_warn}}",
                "non_ems_info" : "{{non_ems_info}}"
            }""",

            "icc2_power_key" : "02_place.power.rpt",
            "icc2_power_key_type" : "single",
            "icc2_power_key_exp_lst" : [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl" : """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key" : "02_place.constraint.rpt",
            "icc2_const_scenario_key_type" : "single",
            "icc2_const_scenario_key_exp_lst" : [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key" : "02_place.constraint.rpt",
            "icc2_max_tran_key_type" : "single",
            "icc2_max_tran_key_exp_lst" : [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl" : """{
                "max_transition_{{icc2_scenario}}" : {{max_transition}},
            }""",


            "icc2_max_cap_key" : "02_place.constraint.rpt",
            "icc2_max_cap_key_type" : "single",
            "icc2_max_cap_key_exp_lst" : [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl" : """{
                "max_capasitance_{{icc2_scenario}}" : {{max_capacitance}},
            }""",


            "icc2_qor_key" : "02_place.qor.rpt",
            "icc2_qor_key_type" : "multi",
            "icc2_qor_key_exp_lst" : [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl" : """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key" : "02_place.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type" : "multi",
            "icc2_cell_area_key_exp_lst" : [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl" : """{
                "area_{{vt}}_area" : {{area}},
                "area_{{vt}}_ratio" : {{ratio}},
            }""",


            "icc2_utilization_key" : "02_place.utilization.rpt",
            "icc2_utilization_key_type" : "single",
            "icc2_utilization_key_exp_lst" : [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl" : """{
                "utilization" : {{utilization}},
            }""",


            "icc2_routing_violation_key" : "icc2_routing_violation_key",
            "icc2_routing_violation_key_type" : "single",
            "icc2_routing_violation_key_exp_lst" : [
                r'^Total number of DRCs = (?P<drc>\d+)',
            ],
            "icc2_routing_violation_key_tpl" : """{
                "routing_violation" : {{drc}},
            }""",


            "icc2_misc_server_key" : "icc2_misc",
            "icc2_misc_server_key_type" : "single",
            "icc2_misc_server_key_exp_lst" : [
                r'^<<Starting on (?P<server>\S+)>>',
            ],
            "icc2_misc_server_key_tpl" : """{
                "server" : "{{server}}",
            }""",

            "icc2_misc_mem_key" : "icc2_misc",
            "icc2_misc_mem_key_type" : "single",
            "icc2_misc_mem_key_exp_lst" : [
                r'^Maximum memory usage for this session: (?P<max_memory>\d+\.\d*) MB',
            ],
            "icc2_misc_mem_key_tpl" : """{
                "max_memory" : {{max_memory}},
            }""",

            "icc2_misc_elapsed_key" : "icc2_misc",
            "icc2_misc_elapsed_key_type" : "single",
            "icc2_misc_elapsed_key_exp_lst" : [
                r'^Elapsed time for this session:\s+(?P<elapsed>\d+) seconds \(\s*(\d+\.\d*)\s*hours\)',
            ],
            "icc2_misc_elapsed_key_tpl" : """{
                "elapsed" : float("%.1f"%({{elapsed}} / 60.0)),
            }""",
        },
        "03_clock.tcl" : {
            "placement_overview_img" : "03_clock.placement_overview.png",
            "hier_placement_overview_img" : "03_clock.hier_placement_overview.png",
            "pin_density_img" : "03_clock.pin_density.png",
            "cell_density_img" : "03_clock.cell_density.png",
            "congestion_img" : "03_clock.congestion.png",

            "icc2_ems_key" : "icc2_check_design",
            "icc2_ems_key_type" : "single",
            "icc2_ems_key_exp_lst" : [
                r'\s+Total\s+(?P<ems_total>\d+)\s+EMS messages: (?P<ems_error>\d+) errors, '
                r'(?P<ems_warn>\d+) warnings, (?P<ems_info>\d+) info.',
                r'\s+Total\s+(?P<non_ems_total>\d+)\s+non-EMS messages: (?P<non_ems_error>\d+) '
                r'errors, (?P<non_ems_warn>\d+) warnings, (?P<non_ems_info>\d+) info.'
            ],
            "icc2_ems_key_tpl" : """{
                "ems_total" : "{{ems_total}}",
                "ems_error" : "{{ems_error}}",
                "ems_warn" : "{{ems_warn}}",
                "ems_info" : "{{ems_info}}",
                "non_ems_total" : "{{non_ems_total}}",
                "non_ems_error" : "{{non_ems_error}}",
                "non_ems_warn" : "{{non_ems_warn}}",
                "non_ems_info" : "{{non_ems_info}}"
            }""",

            "icc2_power_key" : "03_clock.power.rpt",
            "icc2_power_key_type" : "single",
            "icc2_power_key_exp_lst" : [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl" : """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key" : "03_clock.constraint.rpt",
            "icc2_const_scenario_key_type" : "single",
            "icc2_const_scenario_key_exp_lst" : [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key" : "03_clock.constraint.rpt",
            "icc2_max_tran_key_type" : "single",
            "icc2_max_tran_key_exp_lst" : [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl" : """{
                "max_transition_{{icc2_scenario}}" : {{max_transition}},
            }""",


            "icc2_max_cap_key" : "03_clock.constraint.rpt",
            "icc2_max_cap_key_type" : "single",
            "icc2_max_cap_key_exp_lst" : [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl" : """{
                "max_capasitance_{{icc2_scenario}}" : {{max_capacitance}},
            }""",


            "icc2_qor_key" : "03_clock.qor.rpt",
            "icc2_qor_key_type" : "multi",
            "icc2_qor_key_exp_lst" : [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl" : """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key" : "03_clock.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type" : "multi",
            "icc2_cell_area_key_exp_lst" : [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl" : """{
                "area_{{vt}}_area" : {{area}},
                "area_{{vt}}_ratio" : {{ratio}},
            }""",


            "icc2_utilization_key" : "03_clock.utilization.rpt",
            "icc2_utilization_key_type" : "single",
            "icc2_utilization_key_exp_lst" : [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl" : """{
                "utilization" : {{utilization}},
            }""",


            "icc2_routing_violation_key" : "03_clock.check_routes.rpt",
            "icc2_routing_violation_key_type" : "single",
            "icc2_routing_violation_key_exp_lst" : [
                r'^Total number of DRCs = (?P<drc>\d+)',
            ],
            "icc2_routing_violation_key_tpl" : """{
                "routing_violation" : {{drc}},
            }""",


            "icc2_misc_server_key" : "icc2_misc",
            "icc2_misc_server_key_type" : "single",
            "icc2_misc_server_key_exp_lst" : [
                r'^<<Starting on (?P<server>\S+)>>',
            ],
            "icc2_misc_server_key_tpl" : """{
                "server" : "{{server}}",
            }""",

            "icc2_misc_mem_key" : "icc2_misc",
            "icc2_misc_mem_key_type" : "single",
            "icc2_misc_mem_key_exp_lst" : [
                r'^Maximum memory usage for this session: (?P<max_memory>\d+\.\d*) MB',
            ],
            "icc2_misc_mem_key_tpl" : """{
                "max_memory" : {{max_memory}},
            }""",

            "icc2_misc_elapsed_key" : "icc2_misc",
            "icc2_misc_elapsed_key_type" : "single",
            "icc2_misc_elapsed_key_exp_lst" : [
                r'^Elapsed time for this session:\s+(?P<elapsed>\d+) seconds \(\s*(\d+\.\d*)\s*hours\)',
            ],
            "icc2_misc_elapsed_key_tpl" : """{
                "elapsed" : float("%.1f"%({{elapsed}} / 60.0)),
            }""",
        },
        "04_clock_opt.tcl" : {
            "placement_overview_img" : "04_clock_opt.placement_overview.png",
            "hier_placement_overview_img" : "04_clock_opt.hier_placement_overview.png",
            "pin_density_img" : "04_clock_opt.pin_density.png",
            "cell_density_img" : "04_clock_opt.cell_density.png",
            "congestion_img" : "04_clock_opt.congestion.png",

            "icc2_ems_key" : "icc2_check_design",
            "icc2_ems_key_type" : "single",
            "icc2_ems_key_exp_lst" : [
                r'\s+Total\s+(?P<ems_total>\d+)\s+EMS messages: (?P<ems_error>\d+) errors, '
                r'(?P<ems_warn>\d+) warnings, (?P<ems_info>\d+) info.',
                r'\s+Total\s+(?P<non_ems_total>\d+)\s+non-EMS messages: (?P<non_ems_error>\d+) '
                r'errors, (?P<non_ems_warn>\d+) warnings, (?P<non_ems_info>\d+) info.'
            ],
            "icc2_ems_key_tpl" : """{
                "ems_total" : "{{ems_total}}",
                "ems_error" : "{{ems_error}}",
                "ems_warn" : "{{ems_warn}}",
                "ems_info" : "{{ems_info}}",
                "non_ems_total" : "{{non_ems_total}}",
                "non_ems_error" : "{{non_ems_error}}",
                "non_ems_warn" : "{{non_ems_warn}}",
                "non_ems_info" : "{{non_ems_info}}"
            }""",

            "icc2_power_key" : "04_clock_opt.power.rpt",
            "icc2_power_key_type" : "single",
            "icc2_power_key_exp_lst" : [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl" : """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key" : "04_clock_opt.constraint.rpt",
            "icc2_const_scenario_key_type" : "single",
            "icc2_const_scenario_key_exp_lst" : [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key" : "04_clock_opt.constraint.rpt",
            "icc2_max_tran_key_type" : "single",
            "icc2_max_tran_key_exp_lst" : [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl" : """{
                "max_transition_{{icc2_scenario}}" : {{max_transition}},
            }""",


            "icc2_max_cap_key" : "04_clock_opt.constraint.rpt",
            "icc2_max_cap_key_type" : "single",
            "icc2_max_cap_key_exp_lst" : [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl" : """{
                "max_capasitance_{{icc2_scenario}}" : {{max_capacitance}},
            }""",


            "icc2_qor_key" : "04_clock_opt.qor.rpt",
            "icc2_qor_key_type" : "multi",
            "icc2_qor_key_exp_lst" : [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl" : """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key" : "04_clock_opt.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type" : "multi",
            "icc2_cell_area_key_exp_lst" : [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl" : """{
                "area_{{vt}}_area" : {{area}},
                "area_{{vt}}_ratio" : {{ratio}},
            }""",


            "icc2_utilization_key" : "04_clock_opt.utilization.rpt",
            "icc2_utilization_key_type" : "single",
            "icc2_utilization_key_exp_lst" : [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl" : """{
                "utilization" : {{utilization}},
            }""",


            "icc2_routing_violation_key" : "04_clock_opt.check_routes.rpt",
            "icc2_routing_violation_key_type" : "single",
            "icc2_routing_violation_key_exp_lst" : [
                r'^Total number of DRCs = (?P<drc>\d+)',
            ],
            "icc2_routing_violation_key_tpl" : """{
                "routing_violation" : {{drc}},
            }""",


            "icc2_misc_server_key" : "icc2_misc",
            "icc2_misc_server_key_type" : "single",
            "icc2_misc_server_key_exp_lst" : [
                r'^<<Starting on (?P<server>\S+)>>',
            ],
            "icc2_misc_server_key_tpl" : """{
                "server" : "{{server}}",
            }""",

            "icc2_misc_mem_key" : "icc2_misc",
            "icc2_misc_mem_key_type" : "single",
            "icc2_misc_mem_key_exp_lst" : [
                r'^Maximum memory usage for this session: (?P<max_memory>\d+\.\d*) MB',
            ],
            "icc2_misc_mem_key_tpl" : """{
                "max_memory" : {{max_memory}},
            }""",

            "icc2_misc_elapsed_key" : "icc2_misc",
            "icc2_misc_elapsed_key_type" : "single",
            "icc2_misc_elapsed_key_exp_lst" : [
                r'^Elapsed time for this session:\s+(?P<elapsed>\d+) seconds \(\s*(\d+\.\d*)\s*hours\)',
            ],
            "icc2_misc_elapsed_key_tpl" : """{
                "elapsed" : float("%.1f"%({{elapsed}} / 60.0)),
            }""",
        },

        "05_route.tcl" : {
            "placement_overview_img" : "05_route.placement_overview.png",
            "hier_placement_overview_img" : "05_route.hier_placement_overview.png",
            "congestion_img" : "05_route.congestion.png",
            "check_drc_img" : "05_route.check_drc.png",
            "pin_density_img" : "05_route.pin_density.png",
            "cell_density_img" : "05_route.cell_density.png",
            "powerplan_img" : "05_route.powerplan.png",
            "icc2_ems_key" : "icc2_check_design",
            "icc2_ems_key_type" : "single",
            "icc2_ems_key_exp_lst" : [
                r'\s+Total\s+(?P<ems_total>\d+)\s+EMS messages: (?P<ems_error>\d+) errors, '
                r'(?P<ems_warn>\d+) warnings, (?P<ems_info>\d+) info.',
                r'\s+Total\s+(?P<non_ems_total>\d+)\s+non-EMS messages: (?P<non_ems_error>\d+) '
                r'errors, (?P<non_ems_warn>\d+) warnings, (?P<non_ems_info>\d+) info.'
            ],
            "icc2_ems_key_tpl" : """{
                "ems_total" : "{{ems_total}}",
                "ems_error" : "{{ems_error}}",
                "ems_warn" : "{{ems_warn}}",
                "ems_info" : "{{ems_info}}",
                "non_ems_total" : "{{non_ems_total}}",
                "non_ems_error" : "{{non_ems_error}}",
                "non_ems_warn" : "{{non_ems_warn}}",
                "non_ems_info" : "{{non_ems_info}}"
            }""",

            "icc2_power_key" : "05_route.power.rpt",
            "icc2_power_key_type" : "single",
            "icc2_power_key_exp_lst" : [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl" : """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key" : "05_route.constraint.rpt",
            "icc2_const_scenario_key_type" : "single",
            "icc2_const_scenario_key_exp_lst" : [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key" : "05_route.constraint.rpt",
            "icc2_max_tran_key_type" : "single",
            "icc2_max_tran_key_exp_lst" : [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl" : """{
                "max_transition_{{icc2_scenario}}" : {{max_transition}},
            }""",


            "icc2_max_cap_key" : "05_route.constraint.rpt",
            "icc2_max_cap_key_type" : "single",
            "icc2_max_cap_key_exp_lst" : [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl" : """{
                "max_capasitance_{{icc2_scenario}}" : {{max_capacitance}},
            }""",


            "icc2_qor_key" : "05_route.qor.rpt",
            "icc2_qor_key_type" : "multi",
            "icc2_qor_key_exp_lst" : [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl" : """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key" : "05_route.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type" : "multi",
            "icc2_cell_area_key_exp_lst" : [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl" : """{
                "area_{{vt}}_area" : {{area}},
                "area_{{vt}}_ratio" : {{ratio}},
            }""",


            "icc2_utilization_key" : "05_route.utilization.rpt",
            "icc2_utilization_key_type" : "single",
            "icc2_utilization_key_exp_lst" : [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl" : """{
                "utilization" : {{utilization}},
                "signoffcheck_FP-01-02_report" : "{{path}}",
                "signoffcheck_FP-01-02_result" : {{utilization}},
                "signoffcheck_FP-01-02_judge" : {% if FP_01_02_criteria in signoff and utilization < signoff.FP_01_02_criteria %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_FP-01-02_support" : "{{signoff.FP_01_02_support}}",
                "signoffcheck_FP-01-02_category" : "{{signoff.FP_01_02_category}}",
                "signoffcheck_FP-01-02_owner" : "{{signoff.FP_01_02_owner}}",
                "signoffcheck_FP-01-02_item" : "{{signoff.FP_01_02_item}}",
                "signoffcheck_FP-01-02_description" : "{{signoff.FP_01_02_description}}",
                "signoffcheck_FP-01-02_criteria" : "{{signoff.FP_01_02_criteria}}",
            }""",


            "icc2_routing_violation_key" : "05_route.check_routes.rpt",
            "icc2_routing_violation_key_type" : "single",
            "icc2_routing_violation_key_exp_lst" : [
                r'^Total number of DRCs = (?P<drc>\d+)',
            ],
            "icc2_routing_violation_key_tpl" : """{
                "routing_violation" : {{drc}},
            }""",


            "icc2_misc_server_key" : "icc2_misc",
            "icc2_misc_server_key_type" : "single",
            "icc2_misc_server_key_exp_lst" : [
                r'^<<Starting on (?P<server>\S+)>>',
            ],
            "icc2_misc_server_key_tpl" : """{
                "server" : "{{server}}",
            }""",

            "icc2_misc_mem_key" : "icc2_misc",
            "icc2_misc_mem_key_type" : "single",
            "icc2_misc_mem_key_exp_lst" : [
                r'^Maximum memory usage for this session: (?P<max_memory>\d+\.\d*) MB',
            ],
            "icc2_misc_mem_key_tpl" : """{
                "max_memory" : {{max_memory}},
            }""",

            "icc2_misc_elapsed_key" : "icc2_misc",
            "icc2_misc_elapsed_key_type" : "single",
            "icc2_misc_elapsed_key_exp_lst" : [
                r'^Elapsed time for this session:\s+(?P<elapsed>\d+) seconds \(\s*(\d+\.\d*)\s*hours\)',
            ],
            "icc2_misc_elapsed_key_tpl" : """{
                "elapsed" : float("%.1f"%({{elapsed}} / 60.0)),
            }""",
        },

        "06_route_opt.tcl" : {
            "placement_overview_img" : "06_route_opt.placement_overview.png",
            "hier_placement_overview_img" : "06_route_opt.hier_placement_overview.png",
            "congestion_img" : "06_route_opt.congestion.png",
            "check_drc_img" : "06_route_opt.check_drc.png",
            "pin_density_img" : "06_route_opt.pin_density.png",
            "cell_density_img" : "06_route_opt.cell_density.png",

            "icc2_ems_key" : "icc2_check_design",
            "icc2_ems_key_type" : "single",
            "icc2_ems_key_exp_lst" : [
                r'\s+Total\s+(?P<ems_total>\d+)\s+EMS messages: (?P<ems_error>\d+) errors, '
                r'(?P<ems_warn>\d+) warnings, (?P<ems_info>\d+) info.',
                r'\s+Total\s+(?P<non_ems_total>\d+)\s+non-EMS messages: (?P<non_ems_error>\d+) '
                r'errors, (?P<non_ems_warn>\d+) warnings, (?P<non_ems_info>\d+) info.'
            ],
            "icc2_ems_key_tpl" : """{
                "ems_total" : "{{ems_total}}",
                "ems_error" : "{{ems_error}}",
                "ems_warn" : "{{ems_warn}}",
                "ems_info" : "{{ems_info}}",
                "non_ems_total" : "{{non_ems_total}}",
                "non_ems_error" : "{{non_ems_error}}",
                "non_ems_warn" : "{{non_ems_warn}}",
                "non_ems_info" : "{{non_ems_info}}"
            }""",

            "icc2_power_key" : "06_route_opt.power.rpt",
            "icc2_power_key_type" : "single",
            "icc2_power_key_exp_lst" : [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl" : """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key" : "06_route_opt.constraint.rpt",
            "icc2_const_scenario_key_type" : "single",
            "icc2_const_scenario_key_exp_lst" : [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key" : "06_route_opt.constraint.rpt",
            "icc2_max_tran_key_type" : "single",
            "icc2_max_tran_key_exp_lst" : [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl" : """{
                "max_transition_{{icc2_scenario}}" : {{max_transition}},
            }""",


            "icc2_max_cap_key" : "06_route_opt.constraint.rpt",
            "icc2_max_cap_key_type" : "single",
            "icc2_max_cap_key_exp_lst" : [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl" : """{
                "max_capasitance_{{icc2_scenario}}" : {{max_capacitance}},
            }""",


            "icc2_qor_key" : "06_route_opt.qor.rpt",
            "icc2_qor_key_type" : "multi",
            "icc2_qor_key_exp_lst" : [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl" : """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key" : "06_route_opt.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type" : "multi",
            "icc2_cell_area_key_exp_lst" : [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl" : """{
                "area_{{vt}}_area" : {{area}},
                "area_{{vt}}_ratio" : {{ratio}},
            }""",


            "icc2_utilization_key" : "06_route_opt.utilization.rpt",
            "icc2_utilization_key_type" : "single",
            "icc2_utilization_key_exp_lst" : [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl" : """{
                "utilization" : {{utilization}},
                "signoffcheck_FP-01-02_report" : "{{path}}",
                "signoffcheck_FP-01-02_result" : {{utilization}},
                "signoffcheck_FP-01-02_judge" : {% if FP_01_02_criteria in signoff and utilization < signoff.FP_01_02_criteria %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_FP-01-02_support" : "{{signoff.FP_01_02_support}}",
                "signoffcheck_FP-01-02_category" : "{{signoff.FP_01_02_category}}",
                "signoffcheck_FP-01-02_owner" : "{{signoff.FP_01_02_owner}}",
                "signoffcheck_FP-01-02_item" : "{{signoff.FP_01_02_item}}",
                "signoffcheck_FP-01-02_description" : "{{signoff.FP_01_02_description}}",
                "signoffcheck_FP-01-02_criteria" : "{{signoff.FP_01_02_criteria}}",
            }""",


            "icc2_routing_violation_key" : "06_route_opt.check_routes.rpt",
            "icc2_routing_violation_key_type" : "single",
            "icc2_routing_violation_key_exp_lst" : [
                r'^Total number of DRCs = (?P<drc>\d+)',
            ],
            "icc2_routing_violation_key_tpl" : """{
                "routing_violation" : {{drc}},
            }""",


            "icc2_misc_server_key" : "icc2_misc",
            "icc2_misc_server_key_type" : "single",
            "icc2_misc_server_key_exp_lst" : [
                r'^<<Starting on (?P<server>\S+)>>',
            ],
            "icc2_misc_server_key_tpl" : """{
                "server" : "{{server}}",
            }""",

            "icc2_misc_mem_key" : "icc2_misc",
            "icc2_misc_mem_key_type" : "single",
            "icc2_misc_mem_key_exp_lst" : [
                r'^Maximum memory usage for this session: (?P<max_memory>\d+\.\d*) MB',
            ],
            "icc2_misc_mem_key_tpl" : """{
                "max_memory" : {{max_memory}},
            }""",

            "icc2_misc_elapsed_key" : "icc2_misc",
            "icc2_misc_elapsed_key_type" : "single",
            "icc2_misc_elapsed_key_exp_lst" : [
                r'^Elapsed time for this session:\s+(?P<elapsed>\d+) seconds \(\s*(\d+\.\d*)\s*hours\)',
            ],
            "icc2_misc_elapsed_key_tpl" : """{
                "elapsed" : float("%.1f"%({{elapsed}} / 60.0)),
            }""",
        },

        "08_finish.tcl" : {
            "placement_overview_img" : "08_finish.placement_overview.png",
            "hier_placement_overview_img" : "08_finish.hier_placement_overview.png",
            "congestion_img" : "08_finish.congestion.png",
            "check_drc_img" : "08_finish.check_drc.png",
            "pin_density_img" : "08_finish.pin_density.png",
            "cell_density_img" : "08_finish.cell_density.png",

            "icc2_ems_key" : "icc2_check_design",
            "icc2_ems_key_type" : "single",
            "icc2_ems_key_exp_lst" : [
                r'\s+Total\s+(?P<ems_total>\d+)\s+EMS messages: (?P<ems_error>\d+) errors, '
                r'(?P<ems_warn>\d+) warnings, (?P<ems_info>\d+) info.',
                r'\s+Total\s+(?P<non_ems_total>\d+)\s+non-EMS messages: (?P<non_ems_error>\d+) '
                r'errors, (?P<non_ems_warn>\d+) warnings, (?P<non_ems_info>\d+) info.'
            ],
            "icc2_ems_key_tpl" : """{
                "ems_total" : "{{ems_total}}",
                "ems_error" : "{{ems_error}}",
                "ems_warn" : "{{ems_warn}}",
                "ems_info" : "{{ems_info}}",
                "non_ems_total" : "{{non_ems_total}}",
                "non_ems_error" : "{{non_ems_error}}",
                "non_ems_warn" : "{{non_ems_warn}}",
                "non_ems_info" : "{{non_ems_info}}"
            }""",

            "icc2_power_key" : "08_finish.power.rpt",
            "icc2_power_key_type" : "single",
            "icc2_power_key_exp_lst" : [
                r'\s*Cell Internal Power\s*=\s*(?P<power_cell_internal>\d+\.\d*\s*.W)\b',
                r'\s*Net Switching Power\s*=\s*(?P<power_net_switching>\d+\.\d*\s*.W)\b',
                r'\s*Total Dynamic Power\s*=\s*(?P<power_total_dynamic>\d+\.\d*\s*.W)\b',
                r'\s*Cell Leakage Power\s*=\s*(?P<power_cell_leakage>\d+\.\d*\s*.W)\b',
            ],
            "icc2_power_key_tpl" : """{
                "power_cell_internal" : "{{power_cell_internal}}",
                "power_net_switching" : "{{power_net_switching}}",
                "power_total_dynamic" : "{{power_total_dynamic}}",
                "power_cell_leakage" : "{{power_cell_leakage}}",
            }""",

            "icc2_const_scenario_key" : "08_finish.constraint.rpt",
            "icc2_const_scenario_key_type" : "single",
            "icc2_const_scenario_key_exp_lst" : [
                r'\s+Scenario:\s+(?P<icc2_scenario>\S+)',
            ],


            "icc2_max_tran_key" : "08_finish.constraint.rpt",
            "icc2_max_tran_key_type" : "single",
            "icc2_max_tran_key_exp_lst" : [
                r'\s+Number of max_transition violation\(s\):\s+(?P<max_transition>\d+)',
            ],
            "icc2_max_tran_key_tpl" : """{
                "max_transition_{{icc2_scenario}}" : {{max_transition}},
            }""",


            "icc2_max_cap_key" : "08_finish.constraint.rpt",
            "icc2_max_cap_key_type" : "single",
            "icc2_max_cap_key_exp_lst" : [
                r'\s+Number of max_capacitance violation\(s\):\s+(?P<max_capacitance>\d+)',
            ],
            "icc2_max_cap_key_tpl" : """{
                "max_capasitance_{{icc2_scenario}}" : {{max_capacitance}},
            }""",


            "icc2_qor_key" : "08_finish.qor.rpt",
            "icc2_qor_key_type" : "multi",
            "icc2_qor_key_exp_lst" : [
                r'^(?P<icc2_scenario>([a-zA-Z]\S+(\.|_)\S+|Design))\s+\((?P<icc2_timingtype>(Setup|Hold))\)\s+(?P<WNS>([-+]?\d+\.\d*|--))\s+(?P<TNS>[-+]?\d+\.\d*)\s+(?P<NVE>\d+)',
            ],
            "icc2_qor_key_tpl" : """{
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_wns" : "{{WNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_tns" : "{{TNS}}",
                "timing_{{icc2_timingtype.lower()}}_{{icc2_scenario}}_nve" : "{{NVE}}",
            }""",


            "icc2_cell_area_key" : "08_finish.threshold_voltage_group.rpt",
            "icc2_cell_area_key_type" : "multi",
            "icc2_cell_area_key_exp_lst" : [
                r'^(?P<vt>\S+)\s+(?P<area>\d+\.\d*)\s+\((?P<ratio>\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)\s+(\d+\.\d*)\s+\((\d+\.\d*)%\)',
            ],
            "icc2_cell_area_key_tpl" : """{
                "area_{{vt}}_area" : {{area}},
                "area_{{vt}}_ratio" : {{ratio}},
            }""",


            "icc2_utilization_key" : "08_finish.utilization.rpt",
            "icc2_utilization_key_type" : "single",
            "icc2_utilization_key_exp_lst" : [
                r'^Utilization Ratio:\s+(?P<utilization>\d+\.\d*)',
            ],
            "icc2_utilization_key_tpl" : """{
                "utilization" : {{utilization}},
                "signoffcheck_FP-01-02_report" : "{{path}}",
                "signoffcheck_FP-01-02_result" : {{utilization}},
                "signoffcheck_FP-01-02_judge" : {% if FP_01_02_criteria in signoff and utilization < signoff.FP_01_02_criteria %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_FP-01-02_support" : "{{signoff.FP_01_02_support}}",
                "signoffcheck_FP-01-02_category" : "{{signoff.FP_01_02_category}}",
                "signoffcheck_FP-01-02_owner" : "{{signoff.FP_01_02_owner}}",
                "signoffcheck_FP-01-02_item" : "{{signoff.FP_01_02_item}}",
                "signoffcheck_FP-01-02_description" : "{{signoff.FP_01_02_description}}",
                "signoffcheck_FP-01-02_criteria" : "{{signoff.FP_01_02_criteria}}",
            }""",


            "icc2_routing_violation_key" : "08_finish.check_routes.rpt",
            "icc2_routing_violation_key_type" : "single",
            "icc2_routing_violation_key_exp_lst" : [
                r'^Total number of DRCs = (?P<drc>\d+)',
            ],
            "icc2_routing_violation_key_tpl" : """{
                "routing_violation" : {{drc}},
            }""",


            "icc2_misc_server_key" : "icc2_misc",
            "icc2_misc_server_key_type" : "single",
            "icc2_misc_server_key_exp_lst" : [
                r'^<<Starting on (?P<server>\S+)>>',
            ],
            "icc2_misc_server_key_tpl" : """{
                "server" : "{{server}}",
            }""",

            "icc2_misc_mem_key" : "icc2_misc",
            "icc2_misc_mem_key_type" : "single",
            "icc2_misc_mem_key_exp_lst" : [
                r'^Maximum memory usage for this session: (?P<max_memory>\d+\.\d*) MB',
            ],
            "icc2_misc_mem_key_tpl" : """{
                "max_memory" : {{max_memory}},
            }""",

            "icc2_misc_elapsed_key" : "icc2_misc",
            "icc2_misc_elapsed_key_type" : "single",
            "icc2_misc_elapsed_key_exp_lst" : [
                r'^Elapsed time for this session:\s+(?P<elapsed>\d+) seconds \(\s*(\d+\.\d*)\s*hours\)',
            ],
            "icc2_misc_elapsed_key_tpl" : """{
                "elapsed" : float("%.1f"%({{elapsed}} / 60.0)),
            }""",

        },

    },

    "ext" : {
        "ext.csh" : {

            "star_open_net_key" : "ext.star_sum",
            "star_open_net_key_type" : "single",
            "star_open_net_key_exp_lst" : [
                r'^WARNING: found open net\(s\) in the design'
            ],
            "star_open_net_key_tpl" : """{
                "ext_open_net" : True
            }""",


            "star_short_net_key" : "ext.star_sum",
            "star_short_net_key_type" : "single",
            "star_short_net_key_exp_lst" : [
                r'^WARNING: Found shorted nets'
            ],
            "star_short_net_key_tpl" : """{
                "ext_short_net" : True
            }""",


            "star_misc_server_key" : "star_misc",
            "star_misc_server_key_type" : "single",
            "star_misc_server_key_exp_lst" : [
                r'^Host \.+ (?P<server>\S+)',
            ],
            "star_misc_server_key_tpl" : """{
                "server" : "{{server}}",
            }""",

            "star_misc_mem_key" : "star_misc",
            "star_misc_mem_key_type" : "single",
            "star_misc_mem_key_exp_lst" : [
                r'Done\s+Elp=\d+:\d+:\d+ Cpu=\d+:\d+:\d+\s+Usr=\d+\.\d*\s+Sys=\d+\.\d*\s+Mem=(?P<max_memory>\d+\.\d*)',
            ],
            "star_misc_mem_key_tpl" : """{
                "max_memory" : {{max_memory}},
            }""",

            "star_misc_elapsed_key" : "star_misc",
            "star_misc_elapsed_key_type" : "single",
            "star_misc_elapsed_key_exp_lst" : [
                r'^Overall:\s+Elp=0*(?P<elp_hh>\d+):0*(?P<elp_mm>\d+):0*(?P<elp_ss>\d+)\s+Cpu=0*(?P<cpu_hh>\d+):0*(?P<cpu_mm>\d+):0*(?P<cpu_ss>\d+)',
            ],
            "star_misc_elapsed_key_tpl" : """{
                "elapsed" : float("%.1f"%({{elp_hh}} * 60.0 + {{elp_mm}} + {{elp_ss}} / 60.0)),
            }""",

        },
    },

    "sta" : {
        "sta.tcl" : {

            "pt_w_io_qor_key" : "w_io.rpt",
            "pt_w_io_qor_key_type" : "multi",
            "pt_w_io_qor_key_exp_lst" : [
                r'\s+\*\s+\*\s+(?P<NVE>\d+)\s+(?P<WNS>[-+]?\d+\.\d*)\s+(?P<TNS>[-+]?\d+\.\d*)\s*$',
            ],
            "pt_w_io_qor_key_tpl" : """{
                "timing_wns" : "{{WNS}}",
                "timing_tns" : "{{TNS}}",
                "timing_nve" : "{{NVE}}",
            }""",

            "pt_wo_io_qor_key" : "wo_io.rpt",
            "pt_wo_io_qor_key_type" : "multi",
            "pt_wo_io_qor_key_exp_lst" : [
                r'\s+\*\s+\*\s+(?P<NVE>\d+)\s+(?P<WNS>[-+]?\d+\.\d*)\s+(?P<TNS>[-+]?\d+\.\d*)\s*$',
            ],
            "pt_wo_io_qor_key_tpl" : """{
                "timing_wns" : "{{WNS}}",
                "timing_tns" : "{{TNS}}",
                "timing_nve" : "{{NVE}}",
            }""",

            "pt_max_tran_key" : "report_constraint.max_transition.rpt.summary",
            "pt_max_tran_key_type" : "single",
            "pt_max_tran_key_exp_lst" : [
                r'\sTotal transition error\s*=\s*(?P<violation>\d+)\s*',
            ],
            "pt_max_tran_key_tpl" : """{
                "max_transition" : {{violation}},

                "signoffcheck_CK-01-06_report" : "{{path}}",
                "signoffcheck_CK-01-06_result" : {{violation}},
                "signoffcheck_CK-01-06_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_CK-01-06_support" : "{{signoff.CK_01_06_support}}",
                "signoffcheck_CK-01-06_category" : "{{signoff.CK_01_06_category}}",
                "signoffcheck_CK-01-06_owner" : "{{signoff.CK_01_06_owner}}",
                "signoffcheck_CK-01-06_item" : "{{signoff.CK_01_06_item}}",
                "signoffcheck_CK-01-06_description" : "{{signoff.CK_01_06_description}}",
                "signoffcheck_CK-01-06_criteria" : "{{signoff.CK_01_06_criteria}}",

                "signoffcheck_GE-05-02_report" : "{{path}}",
                "signoffcheck_GE-05-02_result" : {{violation}},
                "signoffcheck_GE-05-02_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-05-02_support" : "{{signoff.GE_05_02_support}}",
                "signoffcheck_GE-05-02_category" : "{{signoff.GE_05_02_category}}",
                "signoffcheck_GE-05-02_owner" : "{{signoff.GE_05_02_owner}}",
                "signoffcheck_GE-05-02_item" : "{{signoff.GE_05_02_item}}",
                "signoffcheck_GE-05-02_description" : "{{signoff.GE_05_02_description}}",
                "signoffcheck_GE-05-02_criteria" : "{{signoff.GE_05_02_criteria}}",

                "signoffcheck_GE-05-03_report" : "{{path}}",
                "signoffcheck_GE-05-03_result" : {{violation}},
                "signoffcheck_GE-05-03_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-05-03_support" : "{{signoff.GE_05_03_support}}",
                "signoffcheck_GE-05-03_category" : "{{signoff.GE_05_03_category}}",
                "signoffcheck_GE-05-03_owner" : "{{signoff.GE_05_03_owner}}",
                "signoffcheck_GE-05-03_item" : "{{signoff.GE_05_03_item}}",
                "signoffcheck_GE-05-03_description" : "{{signoff.GE_05_03_description}}",
                "signoffcheck_GE-05-03_criteria" : "{{signoff.GE_05_03_criteria}}",

            }""",


            "pt_max_cap_key" : "report_constraint.max_capacitance.rpt.summary",
            "pt_max_cap_key_type" : "single",
            "pt_max_cap_key_exp_lst" : [
                r'\sTotal capacitance error\s*=\s*(?P<violation>\d+)\s*',
            ],
            "pt_max_cap_key_tpl" : """{
                "max_capasitance" : {{violation}},

                "signoffcheck_GE-05-01_report" : "{{path}}",
                "signoffcheck_GE-05-01_result" : {{violation}},
                "signoffcheck_GE-05-01_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-05-01_support" : "{{signoff.GE_05_01_support}}",
                "signoffcheck_GE-05-01_category" : "{{signoff.GE_05_01_category}}",
                "signoffcheck_GE-05-01_owner" : "{{signoff.GE_05_01_owner}}",
                "signoffcheck_GE-05-01_item" : "{{signoff.GE_05_01_item}}",
                "signoffcheck_GE-05-01_description" : "{{signoff.GE_05_01_description}}",
                "signoffcheck_GE-05-01_criteria" : "{{signoff.GE_05_01_criteria}}",

            }""",

            "signoffcheck_GE-05-04_key" : "report_constraint.max_fanout.rpt.summary",
            "signoffcheck_GE-05-04_key_type" : "single",
            "signoffcheck_GE-05-04_key_exp_lst" : [
                r'\sTotal fanout error\s*=\s*(?P<violation>\d+)\s*',
            ],
            "signoffcheck_GE-05-04_key_tpl" : """{
                "signoffcheck_GE-05-04_report" : "{{path}}",
                "signoffcheck_GE-05-04_result" : {{violation}},
                "signoffcheck_GE-05-04_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-05-04_support" : "{{signoff.GE_05_04_support}}",
                "signoffcheck_GE-05-04_category" : "{{signoff.GE_05_04_category}}",
                "signoffcheck_GE-05-04_owner" : "{{signoff.GE_05_04_owner}}",
                "signoffcheck_GE-05-04_item" : "{{signoff.GE_05_04_item}}",
                "signoffcheck_GE-05-04_description" : "{{signoff.GE_05_04_description}}",
                "signoffcheck_GE-05-04_criteria" : "{{signoff.GE_05_04_criteria}}",
            }""",


            "pt_clock_key" : "clock_timing.skew.rpt",
            "pt_clock_key_type" : "single",
            "pt_clock_key_exp_lst" : [
                r'\|\s*(?P<clock>\S+)\s*\|\s*(?P<ff_num>\d+)\s*\|\s*(?P<min>[-+]?\d+\.\d*)\s*\|\s*(?P<max>[-+]?\d+\.\d*)\s*\|\s*(?P<skew>[-+]?\d+\.\d*)\s*\|\s*$',
            ],
            "pt_clock_key_tpl" : """{
                "clock_{{clock}}_ff_num" : {{ff_num}},
                "clock_{{clock}}_min" : {{min}},
                "clock_{{clock}}_max" : {{max}},
                "clock_{{clock}}_skew" : {{skew}},
            }""",


            "pt_misc_server_key" : "pt_misc",
            "pt_misc_server_key_type" : "single",
            "pt_misc_server_key_exp_lst" : [
                r'^<<Starting on (?P<server>\w+)>>',
            ],
            "pt_misc_server_key_tpl" : """{
                "server" : "{{server}}",
            }""",


            "pt_misc_mem_key" : "pt_misc",
            "pt_misc_mem_key_type" : "single",
            "pt_misc_mem_key_exp_lst" : [
                r'^Maximum memory usage for this session: (?P<max_memory>\d+\.\d*) MB',
            ],
            "pt_misc_mem_key_tpl" : """{
                "max_memory" : {{max_memory}},
            }""",


            "pt_misc_elapsed_key" : "pt_misc",
            "pt_misc_elapsed_key_type" : "single",
            "pt_misc_elapsed_key_exp_lst" : [
                r'^Elapsed time for this session:\s+(?P<elapsed>\d+) seconds\s*(\(\s*(\d+\.\d*)\s*hours\))?',
            ],
            "pt_misc_elapsed_key_tpl" : """{
                "elapsed" : float("%.1f"%({{elapsed}} / 60.0)),
            }""",

        },
    },


    "pv" : {
        "drc.csh" : {

            "signoffcheck_FP-01-01_key" : "DRC.log",
            "signoffcheck_FP-01-01_key_type" : "single",
            "signoffcheck_FP-01-01_key_exp_lst" : [
                r'^--- DATABASE EXTENT = \[ (?P<x0>-?\d+(\.\d*)?) , (?P<y0>-?\d+(\.\d*)?) \] -> \[ (?P<x1>-?\d+(\.\d*)?) , (?P<y1>-?\d+(\.\d*)?) \]',
            ],
            "signoffcheck_FP-01-01_key_tpl" : """{
                "signoffcheck_FP-01-01_report" : "{{path}}",
                "signoffcheck_FP-01-01_result" : [ {{x0}}, {{y0}}, {{x1}}, {{y1}} ],
                "signoffcheck_FP-01-01_judge" : "N/A",
                "signoffcheck_FP-01-01_support" : "{{signoff.FP_01_01_support}}",
                "signoffcheck_FP-01-01_category" : "{{signoff.FP_01_01_category}}",
                "signoffcheck_FP-01-01_owner" : "{{signoff.FP_01_01_owner}}",
                "signoffcheck_FP-01-01_item" : "{{signoff.FP_01_01_item}}",
                "signoffcheck_FP-01-01_description" : "{{signoff.FP_01_01_description}}",
                "signoffcheck_FP-01-01_criteria" : "{{signoff.FP_01_01_criteria}}",
            }""",

            "signoffcheck_GE-04-09_key" : "DRC.log",
            "signoffcheck_GE-04-09_key_type" : "single",
            "signoffcheck_GE-04-09_key_exp_lst" : [
                r'^--- DATABASE EXTENT = \[ (?P<x0>-?\d+(\.\d*)?) , (?P<y0>-?\d+(\.\d*)?) \] -> \[ (?P<x1>-?\d+(\.\d*)?) , (?P<y1>-?\d+(\.\d*)?) \]',
            ],
            "signoffcheck_GE-04-09_key_tpl" : """{
                "signoffcheck_GE-04-09_report" : "{{path}}",
                "signoffcheck_GE-04-09_result" : [ {{x0}}, {{y0}}, {{x1}}, {{y1}} ],
                "signoffcheck_GE-04-09_judge" : "N/A",
                "signoffcheck_GE-04-09_support" : "{{signoff.GE_04_09_support}}",
                "signoffcheck_GE-04-09_category" : "{{signoff.GE_04_09_category}}",
                "signoffcheck_GE-04-09_owner" : "{{signoff.GE_04_09_owner}}",
                "signoffcheck_GE-04-09_item" : "{{signoff.GE_04_09_item}}",
                "signoffcheck_GE-04-09_description" : "{{signoff.GE_04_09_description}}",
                "signoffcheck_GE-04-09_criteria" : "{{signoff.GE_04_09_criteria}}",
            }""",

            "signoffcheck_GE-08-01_key" : "DRC.rep",
            "signoffcheck_GE-08-01_key_type" : "single",
            "signoffcheck_GE-08-01_key_exp_lst" : [
                r'TOTAL DRC Results Generated:\s*(?P<violation>\d+)',
            ],
            "signoffcheck_GE-08-01_key_tpl" : """{
                "signoffcheck_GE-08-01_report" : "{{path}}",
                "signoffcheck_GE-08-01_result" : {{violation}},
                "signoffcheck_GE-08-01_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-08-01_support" : "{{signoff.GE_08_01_support}}",
                "signoffcheck_GE-08-01_category" : "{{signoff.GE_08_01_category}}",
                "signoffcheck_GE-08-01_owner" : "{{signoff.GE_08_01_owner}}",
                "signoffcheck_GE-08-01_item" : "{{signoff.GE_08_01_item}}",
                "signoffcheck_GE-08-01_description" : "{{signoff.GE_08_01_description}}",
                "signoffcheck_GE-08-01_criteria" : "{{signoff.GE_08_01_criteria}}",
            }""",

            "signoffcheck_GE-08-03_key" : "ANT.rep",
            "signoffcheck_GE-08-03_key_type" : "single",
            "signoffcheck_GE-08-03_key_exp_lst" : [
                r'TOTAL DRC Results Generated:\s*(?P<violation>\d+)',
            ],
            "signoffcheck_GE-08-03_key_tpl" : """{
                "signoffcheck_GE-08-03_report" : "{{path}}",
                "signoffcheck_GE-08-03_result" : {{violation}},
                "signoffcheck_GE-08-03_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-08-03_support" : "{{signoff.GE_08_03_support}}",
                "signoffcheck_GE-08-03_category" : "{{signoff.GE_08_03_category}}",
                "signoffcheck_GE-08-03_owner" : "{{signoff.GE_08_03_owner}}",
                "signoffcheck_GE-08-03_item" : "{{signoff.GE_08_03_item}}",
                "signoffcheck_GE-08-03_description" : "{{signoff.GE_08_03_description}}",
                "signoffcheck_GE-08-03_criteria" : "{{signoff.GE_08_03_criteria}}",
            }""",

            "signoffcheck_GE-08-04_key" : "LVS.log",
            "signoffcheck_GE-08-04_key_type" : "single",
            "signoffcheck_GE-08-04_key_exp_lst" : [
                r'LVS completed. (?P<result>[^.]+)\. See report file:',
            ],
            "signoffcheck_GE-08-04_key_tpl" : """{
                "signoffcheck_GE-08-04_report" : "{{path}}",
                "signoffcheck_GE-08-04_result" : "{{result}}",
                "signoffcheck_GE-08-04_judge" : {% if result == "CORRECT" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-08-04_support" : "{{signoff.GE_08_04_support}}",
                "signoffcheck_GE-08-04_category" : "{{signoff.GE_08_04_category}}",
                "signoffcheck_GE-08-04_owner" : "{{signoff.GE_08_04_owner}}",
                "signoffcheck_GE-08-04_item" : "{{signoff.GE_08_04_item}}",
                "signoffcheck_GE-08-04_description" : "{{signoff.GE_08_04_description}}",
                "signoffcheck_GE-08-04_criteria" : "{{signoff.GE_08_04_criteria}}",
            }""",

            "signoffcheck_GE-08-05_key" : "erc.sum",
            "signoffcheck_GE-08-05_key_type" : "single",
            "signoffcheck_GE-08-05_key_exp_lst" : [
                r'TOTAL ERC RuleCheck Results Generated:\s*(?P<violation>\d+)',
            ],
            "signoffcheck_GE-08-05_key_tpl" : """{
                "signoffcheck_GE-08-05_report" : "{{path}}",
                "signoffcheck_GE-08-05_result" : {{violation}},
                "signoffcheck_GE-08-05_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-08-05_support" : "{{signoff.GE_08_05_support}}",
                "signoffcheck_GE-08-05_category" : "{{signoff.GE_08_05_category}}",
                "signoffcheck_GE-08-05_owner" : "{{signoff.GE_08_05_owner}}",
                "signoffcheck_GE-08-05_item" : "{{signoff.GE_08_05_item}}",
                "signoffcheck_GE-08-05_description" : "{{signoff.GE_08_05_description}}",
                "signoffcheck_GE-08-05_criteria" : "{{signoff.GE_08_05_criteria}}",
            }""",

            "signoffcheck_GE-08-06_key" : "FC.rep",
            "signoffcheck_GE-08-06_key_type" : "single",
            "signoffcheck_GE-08-06_key_exp_lst" : [
                r'TOTAL DRC Results Generated:\s*(?P<violation>\d+)',
            ],
            "signoffcheck_GE-08-06_key_tpl" : """{
                "signoffcheck_GE-08-06_report" : "{{path}}",
                "signoffcheck_GE-08-06_result" : {{violation}},
                "signoffcheck_GE-08-06_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-08-06_support" : "{{signoff.GE_08_06_support}}",
                "signoffcheck_GE-08-06_category" : "{{signoff.GE_08_06_category}}",
                "signoffcheck_GE-08-06_owner" : "{{signoff.GE_08_06_owner}}",
                "signoffcheck_GE-08-06_item" : "{{signoff.GE_08_06_item}}",
                "signoffcheck_GE-08-06_description" : "{{signoff.GE_08_06_description}}",
                "signoffcheck_GE-08-06_criteria" : "{{signoff.GE_08_06_criteria}}",
            }""",

            "signoffcheck__key" : "",
            "signoffcheck__key_type" : "single",
            "signoffcheck__key_exp_lst" : [
                r'',
            ],
            "signoffcheck__key_tpl" : """{
                "signoffcheck__report" : "{{path}}",
                "signoffcheck__result" : {{violation}},
                "signoffcheck__judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck__category" : "{{signoff._category}}",
                "signoffcheck__owner" : "{{signoff._owner}}",
                "signoffcheck__item" : "{{signoff._item}}",
                "signoffcheck__description" : "{{signoff._description}}",
                "signoffcheck__criteria" : "{{signoff._criteria}}",
            }""",

        },
    },

    "signoff" : {
        "01_icc2_signoff.tcl" : {

            "signoffcheck_GE-05-05-S_key" : "check_signal_wire_length.rpt",
            "signoffcheck_GE-05-05-S_key_type" : "single",
            "signoffcheck_GE-05-05-S_key_exp_lst" : [
                r'^Total Wire Length over (?P<criteria>\d+)\s*\(um\) =\s*(?P<violation>\d+)',
            ],
            "signoffcheck_GE-05-05-S_key_tpl" : """{
                "signoffcheck_GE-05-05-S_report" : "{{path}}",
                "signoffcheck_GE-05-05-S_result" : {{violation}},
                "signoffcheck_GE-05-05-S_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-05-05-S_category" : "{{signoff.GE_05_05_category}}",
                "signoffcheck_GE-05-05-S_owner" : "{{signoff.GE_05_05_owner}}",
                "signoffcheck_GE-05-05-S_item" : "{{signoff.GE_05_05_item}}",
                "signoffcheck_GE-05-05-S_description" : "{{signoff.GE_05_05_description}}",
                "signoffcheck_GE-05-05-S_criteria" : "{{signoff.GE_05_05_criteria}}",
            }""",

            "signoffcheck_GE-05-05-C_key" : "check_clock_wire_length.rpt",
            "signoffcheck_GE-05-05-C_key_type" : "single",
            "signoffcheck_GE-05-05-C_key_exp_lst" : [
                r'^Total Clock Wire Length over (?P<criteria>\d+)\s*\(um\) =\s*(?P<violation>\d+)',
            ],
            "signoffcheck_GE-05-05-C_key_tpl" : """{
                "signoffcheck_GE-05-05-C_report" : "{{path}}",
                "signoffcheck_GE-05-05-C_result" : {{violation}},
                "signoffcheck_GE-05-05-C_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-05-05-C_category" : "{{signoff.GE_05_05_category}}",
                "signoffcheck_GE-05-05-C_owner" : "{{signoff.GE_05_05_owner}}",
                "signoffcheck_GE-05-05-C_item" : "{{signoff.GE_05_05_item}}",
                "signoffcheck_GE-05-05-C_description" : "{{signoff.GE_05_05_description}}",
                "signoffcheck_GE-05-05-C_criteria" : "{{signoff.GE_05_05_criteria}}",
            }""",

            "signoffcheck_GE-02-12_key" : "check_tie_connection.rpt",
            "signoffcheck_GE-02-12_key_type" : "single",
            "signoffcheck_GE-02-12_key_exp_lst" : [
                r'Total Tie Fanout over (?P<criteria>\d+) = (?P<violation>\d+)',
            ],
            "signoffcheck_GE-02-12_key_tpl" : """{
                "signoffcheck_GE-02-12_report" : "{{path}}",
                "signoffcheck_GE-02-12_result" : {{violation}},
                "signoffcheck_GE-02-12_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-12_support" : "{{signoff.GE_02_12_support}}",
                "signoffcheck_GE-02-12_category" : "{{signoff.GE_02_12_category}}",
                "signoffcheck_GE-02-12_owner" : "{{signoff.GE_02_12_owner}}",
                "signoffcheck_GE-02-12_item" : "{{signoff.GE_02_12_item}}",
                "signoffcheck_GE-02-12_description" : "{{signoff.GE_02_12_description}}",
                "signoffcheck_GE-02-12_criteria" : "{{signoff.GE_02_12_criteria}}",
            }""",

            "signoffcheck_GE-02-02_key" : "check_open_input_pin.rpt",
            "signoffcheck_GE-02-02_key_type" : "single",
            "signoffcheck_GE-02-02_key_exp_lst" : [
                r'Total open input pin count = (?P<violation>\d+)',
            ],
            "signoffcheck_GE-02-02_key_tpl" : """{
                "signoffcheck_GE-02-02_report" : "{{path}}",
                "signoffcheck_GE-02-02_result" : {{violation}},
                "signoffcheck_GE-02-02_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-02_support" : "{{signoff.GE_02_02_support}}",
                "signoffcheck_GE-02-02_category" : "{{signoff.GE_02_02_category}}",
                "signoffcheck_GE-02-02_owner" : "{{signoff.GE_02_02_owner}}",
                "signoffcheck_GE-02-02_item" : "{{signoff.GE_02_02_item}}",
                "signoffcheck_GE-02-02_description" : "{{signoff.GE_02_02_description}}",
                "signoffcheck_GE-02-02_criteria" : "{{signoff.GE_02_02_criteria}}",
            }""",

            "signoffcheck_ST-02-10_key" : "check_delay_cell_chain.rpt",
            "signoffcheck_ST-02-10_key_type" : "single",
            "signoffcheck_ST-02-10_key_exp_lst" : [
                r'JUST DUMMY NOW (never matches to reports)',
            ],
            "signoffcheck_ST-02-10_key_tpl" : """{
                "signoffcheck_ST-02-10_report" : "{{path}}",
                "signoffcheck_ST-02-10_result" : {{violation}},
                "signoffcheck_ST-02-10_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_ST-02-10_support" : "{{signoff.ST_02_10_support}}",
                "signoffcheck_ST-02-10_category" : "{{signoff.ST_02_10_category}}",
                "signoffcheck_ST-02-10_owner" : "{{signoff.ST_02_10_owner}}",
                "signoffcheck_ST-02-10_item" : "{{signoff.ST_02_10_item}}",
                "signoffcheck_ST-02-10_description" : "{{signoff.ST_02_10_description}}",
                "signoffcheck_ST-02-10_criteria" : "{{signoff.ST_02_10_criteria}}",
            }""",

            "signoffcheck_GE-04-20_key" : "check_filler_area_number.rpt",
            "signoffcheck_GE-04-20_key_type" : "single",
            "signoffcheck_GE-04-20_key_exp_lst" : [
                r'Total Areas: (?P<area>\d+(\.\d+)*);\s+Total Number: (?P<number>\d+)',
            ],
            "signoffcheck_GE-04-20_key_tpl" : """{
                "signoffcheck_GE-04-20_report" : "{{path}}",
                "signoffcheck_GE-04-20_result" : {{area}},
                "signoffcheck_GE-04-20_judge" : "N/A",
                "signoffcheck_GE-04-20_support" : "{{signoff.GE_04_20_support}}",
                "signoffcheck_GE-04-20_category" : "{{signoff.GE_04_20_category}}",
                "signoffcheck_GE-04-20_owner" : "{{signoff.GE_04_20_owner}}",
                "signoffcheck_GE-04-20_item" : "{{signoff.GE_04_20_item}}",
                "signoffcheck_GE-04-20_description" : "{{signoff.GE_04_20_description}}",
                "signoffcheck_GE-04-20_criteria" : "{{signoff.GE_04_20_criteria}}",
            }""",

            "signoffcheck_GE-04-02_key" : "check_dcap_area_number.rpt",
            "signoffcheck_GE-04-02_key_type" : "single",
            "signoffcheck_GE-04-02_key_exp_lst" : [
                r'Total Areas: (?P<area>\d+(\.\d+)*);\s+Total Number: (?P<number>\d+)',
            ],
            "signoffcheck_GE-04-02_key_tpl" : """{
                "signoffcheck_GE-04-02_report" : "{{path}}",
                "signoffcheck_GE-04-02_result" : {{area}},
                "signoffcheck_GE-04-02_judge" : "N/A",
                "signoffcheck_GE-04-02_support" : "{{signoff.GE_04_02_support}}",
                "signoffcheck_GE-04-02_category" : "{{signoff.GE_04_02_category}}",
                "signoffcheck_GE-04-02_owner" : "{{signoff.GE_04_02_owner}}",
                "signoffcheck_GE-04-02_item" : "{{signoff.GE_04_02_item}}",
                "signoffcheck_GE-04-02_description" : "{{signoff.GE_04_02_description}}",
                "signoffcheck_GE-04-02_criteria" : "{{signoff.GE_04_02_criteria}}",
            }""",

            "signoffcheck_GE-04-03_key" : "check_eco_area_number.rpt",
            "signoffcheck_GE-04-03_key_type" : "single",
            "signoffcheck_GE-04-03_key_exp_lst" : [
                r'Total Areas: (?P<area>\d+(\.\d+)*);\s+Total Number: (?P<number>\d+)',
            ],
            "signoffcheck_GE-04-03_key_tpl" : """{
                "signoffcheck_GE-04-03_report" : "{{path}}",
                "signoffcheck_GE-04-03_result" : {{area}},
                "signoffcheck_GE-04-03_judge" : "N/A",
                "signoffcheck_GE-04-03_support" : "{{signoff.GE_04_03_support}}",
                "signoffcheck_GE-04-03_category" : "{{signoff.GE_04_03_category}}",
                "signoffcheck_GE-04-03_owner" : "{{signoff.GE_04_03_owner}}",
                "signoffcheck_GE-04-03_item" : "{{signoff.GE_04_03_item}}",
                "signoffcheck_GE-04-03_description" : "{{signoff.GE_04_03_description}}",
                "signoffcheck_GE-04-03_criteria" : "{{signoff.GE_04_03_criteria}}",
            }""",

            "signoffcheck_GE-04-07_key" : "check_ip_isolation.rpt",
            "signoffcheck_GE-04-07_key_type" : "single",
            "signoffcheck_GE-04-07_key_exp_lst" : [
                r'No isolation buffer inserted on',
            ],
            "signoffcheck_GE-04-07_key_tpl" : """{
                "signoffcheck_GE-04-07_report" : "{{path}}",
                "signoffcheck_GE-04-07_result" : "no isolation buffer",
                "signoffcheck_GE-04-07_judge" : "NG",
                "signoffcheck_GE-04-07_support" : "{{signoff.GE_04_07_support}}",
                "signoffcheck_GE-04-07_category" : "{{signoff.GE_04_07_category}}",
                "signoffcheck_GE-04-07_owner" : "{{signoff.GE_04_07_owner}}",
                "signoffcheck_GE-04-07_item" : "{{signoff.GE_04_07_item}}",
                "signoffcheck_GE-04-07_description" : "{{signoff.GE_04_07_description}}",
                "signoffcheck_GE-04-07_criteria" : "{{signoff.GE_04_07_criteria}}",
            }""",

            "signoffcheck_GE-04-19_key" : "check_ip_isolation.rpt",
            "signoffcheck_GE-04-19_key_type" : "single",
            "signoffcheck_GE-04-19_key_exp_lst" : [
                r'Total IP Wire Length over (?P<criteria>\d+(\.\d+)?)\(um\) = (?P<violation>\d+)',
            ],
            "signoffcheck_GE-04-19_key_tpl" : """{
                "signoffcheck_GE-04-19_report" : "{{path}}",
                "signoffcheck_GE-04-19_result" : {{violation}},
                "signoffcheck_GE-04-19_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-04-19_support" : "{{signoff.GE_04_19_support}}",
                "signoffcheck_GE-04-19_category" : "{{signoff.GE_04_19_category}}",
                "signoffcheck_GE-04-19_owner" : "{{signoff.GE_04_19_owner}}",
                "signoffcheck_GE-04-19_item" : "{{signoff.GE_04_19_item}}",
                "signoffcheck_GE-04-19_description" : "{{signoff.GE_04_19_description}}",
                "signoffcheck_GE-04-19_criteria" : "{{signoff.GE_04_19_criteria}}",
            }""",

            "signoffcheck_GE-04-18_key" : "check_port_isolation.rpt",
            "signoffcheck_GE-04-18_key_type" : "single",
            "signoffcheck_GE-04-18_key_exp_lst" : [
                r'Total Wire Length over (?P<criteria>\d+(\.\d+)?)\(um\) = (?P<violation>\d+)',
            ],
            "signoffcheck_GE-04-18_key_tpl" : """{
                "signoffcheck_GE-04-18_report" : "{{path}}",
                "signoffcheck_GE-04-18_result" : {{violation}},
                "signoffcheck_GE-04-18_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-04-18_support" : "{{signoff.GE_04_18_support}}",
                "signoffcheck_GE-04-18_category" : "{{signoff.GE_04_18_category}}",
                "signoffcheck_GE-04-18_owner" : "{{signoff.GE_04_18_owner}}",
                "signoffcheck_GE-04-18_item" : "{{signoff.GE_04_18_item}}",
                "signoffcheck_GE-04-18_description" : "{{signoff.GE_04_18_description}}",
                "signoffcheck_GE-04-18_criteria" : "{{signoff.GE_04_18_criteria}}",
            }""",

            "signoffcheck_GE-02-03_key" : "check_multi_driver.rpt",
            "signoffcheck_GE-02-03_key_type" : "single",
            "signoffcheck_GE-02-03_key_exp_lst" : [
                r'MULTIPLE_DRIVEN_NET: (?P<multi_drive_net>\d+)',
            ],
            "signoffcheck_GE-02-03_key_tpl" : """{
                "signoffcheck_GE-02-03_report" : "{{path}}",
                "signoffcheck_GE-02-03_result" : {{multi_drive_net}},
                "signoffcheck_GE-02-03_judge" : {% if multi_drive_net == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-03_support" : "{{signoff.GE_02_03_support}}",
                "signoffcheck_GE-02-03_category" : "{{signoff.GE_02_03_category}}",
                "signoffcheck_GE-02-03_owner" : "{{signoff.GE_02_03_owner}}",
                "signoffcheck_GE-02-03_item" : "{{signoff.GE_02_03_item}}",
                "signoffcheck_GE-02-03_description" : "{{signoff.GE_02_03_description}}",
                "signoffcheck_GE-02-03_criteria" : "{{signoff.GE_02_03_criteria}}",
            }""",

            "signoffcheck_CK-01-16_key" : "check_multi_drive_net.rpt",
            "signoffcheck_CK-01-16_key_type" : "single",
            "signoffcheck_CK-01-16_key_exp_lst" : [
                r'^Error',
            ],
            "signoffcheck_CK-01-16_key_tpl" : """{
                "signoffcheck_CK-01-16_report" : "{{path}}",
                "signoffcheck_CK-01-16_result" : "Error",
                "signoffcheck_CK-01-16_judge" : "NG",
                "signoffcheck_CK-01-16_support" : "{{signoff.CK_01_16_support}}",
                "signoffcheck_CK-01-16_category" : "{{signoff.CK_01_16_category}}",
                "signoffcheck_CK-01-16_owner" : "{{signoff.CK_01_16_owner}}",
                "signoffcheck_CK-01-16_item" : "{{signoff.CK_01_16_item}}",
                "signoffcheck_CK-01-16_description" : "{{signoff.CK_01_16_description}}",
                "signoffcheck_CK-01-16_criteria" : "{{signoff.CK_01_16_criteria}}",
            }""",

            "signoffcheck__key" : "",
            "signoffcheck__key_type" : "single",
            "signoffcheck__key_exp_lst" : [
                r'',
            ],
            "signoffcheck__key_tpl" : """{
                "signoffcheck__report" : "{{path}}",
                "signoffcheck__result" : {{violation}},
                "signoffcheck__judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck__category" : "{{signoff._category}}",
                "signoffcheck__owner" : "{{signoff._owner}}",
                "signoffcheck__item" : "{{signoff._item}}",
                "signoffcheck__description" : "{{signoff._description}}",
                "signoffcheck__criteria" : "{{signoff._criteria}}",
            }""",

        },

        "03_pt_signoff.tcl" : {

            "signoffcheck_GE-02-03_key" : "check_multi_driver.rpt",
            "signoffcheck_GE-02-03_key_type" : "single",
            "signoffcheck_GE-02-03_key_exp_lst" : [
                r'MULTIPLE_DRIVEN_NET: (?P<multi_drive_net>\d+)',
            ],
            "signoffcheck_GE-02-03_key_tpl" : """{
                "signoffcheck_GE-02-03_report" : "{{path}}",
                "signoffcheck_GE-02-03_result" : {{multi_drive_net}},
                "signoffcheck_GE-02-03_judge" : {% if multi_drive_net == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-03_support" : "{{signoff.GE_02_03_support}}",
                "signoffcheck_GE-02-03_category" : "{{signoff.GE_02_03_category}}",
                "signoffcheck_GE-02-03_owner" : "{{signoff.GE_02_03_owner}}",
                "signoffcheck_GE-02-03_item" : "{{signoff.GE_02_03_item}}",
                "signoffcheck_GE-02-03_description" : "{{signoff.GE_02_03_description}}",
                "signoffcheck_GE-02-03_criteria" : "{{signoff.GE_02_03_criteria}}",
            }""",

            "signoffcheck_CK-01-16_key" : "check_multi_drive_net.rpt",
            "signoffcheck_CK-01-16_key_type" : "single",
            "signoffcheck_CK-01-16_key_exp_lst" : [
                r'^Error',
            ],
            "signoffcheck_CK-01-16_key_tpl" : """{
                "signoffcheck_CK-01-16_report" : "{{path}}",
                "signoffcheck_CK-01-16_result" : "Error",
                "signoffcheck_CK-01-16_judge" : "NG",
                "signoffcheck_CK-01-16_support" : "{{signoff.CK_01_16_support}}",
                "signoffcheck_CK-01-16_category" : "{{signoff.CK_01_16_category}}",
                "signoffcheck_CK-01-16_owner" : "{{signoff.CK_01_16_owner}}",
                "signoffcheck_CK-01-16_item" : "{{signoff.CK_01_16_item}}",
                "signoffcheck_CK-01-16_description" : "{{signoff.CK_01_16_description}}",
                "signoffcheck_CK-01-16_criteria" : "{{signoff.CK_01_16_criteria}}",
            }""",

            "signoffcheck_GE-02-16_key" : "check_dont_use_cell.rpt",
            "signoffcheck_GE-02-16_key_type" : "single",
            "signoffcheck_GE-02-16_key_exp_lst" : [
                r'^Error',
            ],
            "signoffcheck_GE-02-16_key_tpl" : """{
                "signoffcheck_GE-02-16_report" : "{{path}}",
                "signoffcheck_GE-02-16_result" : "Error",
                "signoffcheck_GE-02-16_judge" : "NG",
                "signoffcheck_GE-02-16_support" : "{{signoff.GE_02_16_support}}",
                "signoffcheck_GE-02-16_category" : "{{signoff.GE_02_16_category}}",
                "signoffcheck_GE-02-16_owner" : "{{signoff.GE_02_16_owner}}",
                "signoffcheck_GE-02-16_item" : "{{signoff.GE_02_16_item}}",
                "signoffcheck_GE-02-16_description" : "{{signoff.GE_02_16_description}}",
                "signoffcheck_GE-02-16_criteria" : "{{signoff.GE_02_16_criteria}}",
            }""",

            "signoffcheck_GE-02-02_key" : "check_open_input_pin.rpt",
            "signoffcheck_GE-02-02_key_type" : "single",
            "signoffcheck_GE-02-02_key_exp_lst" : [
                r'Total open input pin count = (?P<violation>\d+)',
            ],
            "signoffcheck_GE-02-02_key_tpl" : """{
                "signoffcheck_GE-02-02_report" : "{{path}}",
                "signoffcheck_GE-02-02_result" : {{violation}},
                "signoffcheck_GE-02-02_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-02_support" : "{{signoff.GE_02_02_support}}",
                "signoffcheck_GE-02-02_category" : "{{signoff.GE_02_02_category}}",
                "signoffcheck_GE-02-02_owner" : "{{signoff.GE_02_02_owner}}",
                "signoffcheck_GE-02-02_item" : "{{signoff.GE_02_02_item}}",
                "signoffcheck_GE-02-02_description" : "{{signoff.GE_02_02_description}}",
                "signoffcheck_GE-02-02_criteria" : "{{signoff.GE_02_02_criteria}}",
            }""",

            "signoffcheck_GE-06-03_key" : "check_clock_net_xtalk_delta_delay.rpt",
            "signoffcheck_GE-06-03_key_type" : "single",
            "signoffcheck_GE-06-03_key_exp_lst" : [
                r'Total (?P<violation>\d+) violation nets\.',
            ],
            "signoffcheck_GE-06-03_key_tpl" : """{
                "signoffcheck_GE-06-03_report" : "{{path}}",
                "signoffcheck_GE-06-03_result" : {{violation}},
                "signoffcheck_GE-06-03_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-06-03_support" : "{{signoff.GE_06_03_support}}",
                "signoffcheck_GE-06-03_category" : "{{signoff.GE_06_03_category}}",
                "signoffcheck_GE-06-03_owner" : "{{signoff.GE_06_03_owner}}",
                "signoffcheck_GE-06-03_item" : "{{signoff.GE_06_03_item}}",
                "signoffcheck_GE-06-03_description" : "{{signoff.GE_06_03_description}}",
                "signoffcheck_GE-06-03_criteria" : "{{signoff.GE_06_03_criteria}}",
            }""",

            "signoffcheck_GE-02-08_key" : "check_dont_touch_net.rpt",
            "signoffcheck_GE-02-08_key_type" : "single",
            "signoffcheck_GE-02-08_key_exp_lst" : [
                r'\s(?P<violation>\d+) nets have changed',
            ],
            "signoffcheck_GE-02-08_key_tpl" : """{
                "signoffcheck_GE-02-08_report" : "{{path}}",
                "signoffcheck_GE-02-08_result" : {{violation}},
                "signoffcheck_GE-02-08_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-08_support" : "{{signoff.GE_02_08_support}}",
                "signoffcheck_GE-02-08_category" : "{{signoff.GE_02_08_category}}",
                "signoffcheck_GE-02-08_owner" : "{{signoff.GE_02_08_owner}}",
                "signoffcheck_GE-02-08_item" : "{{signoff.GE_02_08_item}}",
                "signoffcheck_GE-02-08_description" : "{{signoff.GE_02_08_description}}",
                "signoffcheck_GE-02-08_criteria" : "{{signoff.GE_02_08_criteria}}",
            }""",

            "signoffcheck_GE-02-07_key" : "check_size_only_cell.rpt",
            "signoffcheck_GE-02-07_key_type" : "single",
            "signoffcheck_GE-02-07_key_exp_lst" : [
                r's(?P<violation>\d+) cell type are changed',
            ],
            "signoffcheck_GE-02-07_key_tpl" : """{
                "signoffcheck_GE-02-07_report" : "{{path}}",
                "signoffcheck_GE-02-07_result" : {{violation}},
                "signoffcheck_GE-02-07_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-07_support" : "{{signoff.GE_02_07_support}}",
                "signoffcheck_GE-02-07_category" : "{{signoff.GE_02_07_category}}",
                "signoffcheck_GE-02-07_owner" : "{{signoff.GE_02_07_owner}}",
                "signoffcheck_GE-02-07_item" : "{{signoff.GE_02_07_item}}",
                "signoffcheck_GE-02-07_description" : "{{signoff.GE_02_07_description}}",
                "signoffcheck_GE-02-07_criteria" : "{{signoff.GE_02_07_criteria}}",
            }""",

            "signoffcheck_CK-01-03_key" : "report_clock_cell_type.rpt",
            "signoffcheck_CK-01-03_key_type" : "single",
            "signoffcheck_CK-01-03_key_exp_lst" : [
                r'Total (?P<violation>\d+) non-symmetric cells used\.',
            ],
            "signoffcheck_CK-01-03_key_tpl" : """{
                "signoffcheck_CK-01-03_report" : "{{path}}",
                "signoffcheck_CK-01-03_result" : {{violation}},
                "signoffcheck_CK-01-03_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_CK-01-03_support" : "{{signoff.CK_01_03_support}}",
                "signoffcheck_CK-01-03_category" : "{{signoff.CK_01_03_category}}",
                "signoffcheck_CK-01-03_owner" : "{{signoff.CK_01_03_owner}}",
                "signoffcheck_CK-01-03_item" : "{{signoff.CK_01_03_item}}",
                "signoffcheck_CK-01-03_description" : "{{signoff.CK_01_03_description}}",
                "signoffcheck_CK-01-03_criteria" : "{{signoff.CK_01_03_criteria}}",
            }""",

            "signoffcheck_CK-01-04_key" : "report_clock_cell_type.rpt",
            "signoffcheck_CK-01-04_key_type" : "single",
            "signoffcheck_CK-01-04_key_exp_lst" : [
                r'Total (?P<violation>\d+) high-vth cells used.',
            ],
            "signoffcheck_CK-01-04_key_tpl" : """{
                "signoffcheck_CK-01-04_report" : "{{path}}",
                "signoffcheck_CK-01-04_result" : {{violation}},
                "signoffcheck_CK-01-04_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_CK-01-04_support" : "{{signoff.CK_01_04_support}}",
                "signoffcheck_CK-01-04_category" : "{{signoff.CK_01_04_category}}",
                "signoffcheck_CK-01-04_owner" : "{{signoff.CK_01_04_owner}}",
                "signoffcheck_CK-01-04_item" : "{{signoff.CK_01_04_item}}",
                "signoffcheck_CK-01-04_description" : "{{signoff.CK_01_04_description}}",
                "signoffcheck_CK-01-04_criteria" : "{{signoff.CK_01_04_criteria}}",
            }""",

            "signoffcheck_CK-01-05_key" : "report_clock_cell_type.rpt",
            "signoffcheck_CK-01-05_key_type" : "single",
            "signoffcheck_CK-01-05_key_exp_lst" : [
                r'Total (?P<violation>\d+) low-drive cells used.',
            ],
            "signoffcheck_CK-01-05_key_tpl" : """{
                "signoffcheck_CK-01-05_report" : "{{path}}",
                "signoffcheck_CK-01-05_result" : {{violation}},
                "signoffcheck_CK-01-05_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_CK-01-05_support" : "{{signoff.CK_01_05_support}}",
                "signoffcheck_CK-01-05_category" : "{{signoff.CK_01_05_category}}",
                "signoffcheck_CK-01-05_owner" : "{{signoff.CK_01_05_owner}}",
                "signoffcheck_CK-01-05_item" : "{{signoff.CK_01_05_item}}",
                "signoffcheck_CK-01-05_description" : "{{signoff.CK_01_05_description}}",
                "signoffcheck_CK-01-05_criteria" : "{{signoff.CK_01_05_criteria}}",
            }""",

            "signoffcheck__key" : "",
            "signoffcheck__key_type" : "single",
            "signoffcheck__key_exp_lst" : [
                r'',
            ],
            "signoffcheck__key_tpl" : """{
                "signoffcheck__report" : "{{path}}",
                "signoffcheck__result" : {{violation}},
                "signoffcheck__judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck__category" : "{{signoff._category}}",
                "signoffcheck__owner" : "{{signoff._owner}}",
                "signoffcheck__item" : "{{signoff._item}}",
                "signoffcheck__description" : "{{signoff._description}}",
                "signoffcheck__criteria" : "{{signoff._criteria}}",
            }""",

        },

        "04_logs_signoff.csh" : {

            "signoffcheck_GE-02-04_key" : "perl.check_netlist.log",
            "signoffcheck_GE-02-04_key_type" : "single",
            "signoffcheck_GE-02-04_key_exp_lst" : [
                r'Number of 1\'b0\s*=\s*(?P<violation0>\d+)',
                r'Number of 1\'b1\s*=\s*(?P<violation1>\d+)',
            ],
            "signoffcheck_GE-02-04_key_tpl" : """{
                "signoffcheck_GE-02-04_report" : "{{path}}",
                "signoffcheck_GE-02-04_result" : {{violation0 or 0}} + {{violation1 or 0}},
                "signoffcheck_GE-02-04_judge" : {% if violation0 == "0" and violation1 == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-04_support" : "{{signoff.GE_02_04_support}}",
                "signoffcheck_GE-02-04_category" : "{{signoff.GE_02_04_category}}",
                "signoffcheck_GE-02-04_owner" : "{{signoff.GE_02_04_owner}}",
                "signoffcheck_GE-02-04_item" : "{{signoff.GE_02_04_item}}",
                "signoffcheck_GE-02-04_description" : "{{signoff.GE_02_04_description}}",
                "signoffcheck_GE-02-04_criteria" : "{{signoff.GE_02_04_criteria}}",
            }""",

            "signoffcheck_GE-02-05_key" : "perl.check_netlist.log",
            "signoffcheck_GE-02-05_key_type" : "single",
            "signoffcheck_GE-02-05_key_exp_lst" : [
                r'Number of assign\s*=\s*(?P<violation>\d+)',
            ],
            "signoffcheck_GE-02-05_key_tpl" : """{
                "signoffcheck_GE-02-05_report" : "{{path}}",
                "signoffcheck_GE-02-05_result" : {{violation}},
                "signoffcheck_GE-02-05_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-05_support" : "{{signoff.GE_02_05_support}}",
                "signoffcheck_GE-02-05_category" : "{{signoff.GE_02_05_category}}",
                "signoffcheck_GE-02-05_owner" : "{{signoff.GE_02_05_owner}}",
                "signoffcheck_GE-02-05_item" : "{{signoff.GE_02_05_item}}",
                "signoffcheck_GE-02-05_description" : "{{signoff.GE_02_05_description}}",
                "signoffcheck_GE-02-05_criteria" : "{{signoff.GE_02_05_criteria}}",
            }""",

            "signoffcheck_GE-02-11_key" : "perl.check_netlist.log",
            "signoffcheck_GE-02-11_key_type" : "single",
            "signoffcheck_GE-02-11_key_exp_lst" : [
                r'Number of assign\s*=\s*(?P<violation>\d+)',
            ],
            "signoffcheck_GE-02-11_key_tpl" : """{
                "signoffcheck_GE-02-11_report" : "{{path}}",
                "signoffcheck_GE-02-11_result" : {{violation}},
                "signoffcheck_GE-02-11_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-11_support" : "{{signoff.GE_02_11_support}}",
                "signoffcheck_GE-02-11_category" : "{{signoff.GE_02_11_category}}",
                "signoffcheck_GE-02-11_owner" : "{{signoff.GE_02_11_owner}}",
                "signoffcheck_GE-02-11_item" : "{{signoff.GE_02_11_item}}",
                "signoffcheck_GE-02-11_description" : "{{signoff.GE_02_11_description}}",
                "signoffcheck_GE-02-11_criteria" : "{{signoff.GE_02_11_criteria}}",
            }""",

            "signoffcheck_GE-02-09_key" : "perl.check_cellsize.log",
            "signoffcheck_GE-02-09_key_type" : "single",
            "signoffcheck_GE-02-09_key_exp_lst" : [
                r'Number of max-size-error =\s*(?P<violation>\d+)',
            ],
            "signoffcheck_GE-02-09_key_tpl" : """{
                "signoffcheck_GE-02-09_report" : "{{path}}",
                "signoffcheck_GE-02-09_result" : {{violation}},
                "signoffcheck_GE-02-09_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-09_support" : "{{signoff.GE_02_09_support}}",
                "signoffcheck_GE-02-09_category" : "{{signoff.GE_02_09_category}}",
                "signoffcheck_GE-02-09_owner" : "{{signoff.GE_02_09_owner}}",
                "signoffcheck_GE-02-09_item" : "{{signoff.GE_02_09_item}}",
                "signoffcheck_GE-02-09_description" : "{{signoff.GE_02_09_description}}",
                "signoffcheck_GE-02-09_criteria" : "{{signoff.GE_02_09_criteria}}",
            }""",

            "signoffcheck_GE-02-10_key" : "perl.check_cellsize.log",
            "signoffcheck_GE-02-10_key_type" : "single",
            "signoffcheck_GE-02-10_key_exp_lst" : [
                r'Number of min-size-error =\s*(?P<violation>\d+)',
            ],
            "signoffcheck_GE-02-10_key_tpl" : """{
                "signoffcheck_GE-02-10_report" : "{{path}}",
                "signoffcheck_GE-02-10_result" : {{violation}},
                "signoffcheck_GE-02-10_judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck_GE-02-10_support" : "{{signoff.GE_02_10_support}}",
                "signoffcheck_GE-02-10_category" : "{{signoff.GE_02_10_category}}",
                "signoffcheck_GE-02-10_owner" : "{{signoff.GE_02_10_owner}}",
                "signoffcheck_GE-02-10_item" : "{{signoff.GE_02_10_item}}",
                "signoffcheck_GE-02-10_description" : "{{signoff.GE_02_10_description}}",
                "signoffcheck_GE-02-10_criteria" : "{{signoff.GE_02_10_criteria}}",
            }""",

            "signoffcheck_GE-08-17_key" : "perl.check_ip_cdl_bus_order.log",
            "signoffcheck_GE-08-17_key_type" : "single",
            "signoffcheck_GE-08-17_key_exp_lst" : [
                r' have disordered bus\.',
            ],
            "signoffcheck_GE-08-17_key_tpl" : """{
                "signoffcheck_GE-08-17_report" : "{{path}}",
                "signoffcheck_GE-08-17_result" : "Error",
                "signoffcheck_GE-08-17_judge" : "NG",
                "signoffcheck_GE-08-17_support" : "{{signoff.GE_08_17_support}}",
                "signoffcheck_GE-08-17_category" : "{{signoff.GE_08_17_category}}",
                "signoffcheck_GE-08-17_owner" : "{{signoff.GE_08_17_owner}}",
                "signoffcheck_GE-08-17_item" : "{{signoff.GE_08_17_item}}",
                "signoffcheck_GE-08-17_description" : "{{signoff.GE_08_17_description}}",
                "signoffcheck_GE-08-17_criteria" : "{{signoff.GE_08_17_criteria}}",
            }""",

            "signoffcheck__key" : "",
            "signoffcheck__key_type" : "single",
            "signoffcheck__key_exp_lst" : [
                r'',
            ],
            "signoffcheck__key_tpl" : """{
                "signoffcheck__report" : "{{path}}",
                "signoffcheck__result" : {{violation}},
                "signoffcheck__judge" : {% if violation == "0" %} "OK" {% else %} "NG" {% endif %},
                "signoffcheck__category" : "{{signoff._category}}",
                "signoffcheck__owner" : "{{signoff._owner}}",
                "signoffcheck__item" : "{{signoff._item}}",
                "signoffcheck__description" : "{{signoff._description}}",
                "signoffcheck__criteria" : "{{signoff._criteria}}",
            }""",

        },
    },
}

PARSER_CFG_DIC["pricc2"] = PARSER_CFG_DIC["pr"]
