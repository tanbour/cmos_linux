##########################################################################################
# set previous stage dir
##########################################################################################
set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

set pre_flow_data_dir "{{pre.flow_data_dir}}/{{pre.stage}}"
##########################################################################################
#  icc2 setup
##########################################################################################
set blk_name          "{{env.BLK_NAME}}"
{%- if local.use_dc_output_netlist == "true" %}
set blk_netlist_list  "$pre_flow_data_dir/{{env.BLK_NAME}}.v"
{%- else %} 
set blk_netlist_list  "{{env.BLK_NETLIST}}/{{ver.netlist}}/{{env.BLK_NAME}}.v"
{%- endif %} 
{%- if local.use_spg_flow  == "true" %}
set dc_output_icc2_script  "$pre_flow_data_dir/icc2_06/{{env.BLK_NAME}}.icc2_script.tcl"
{%- else %}
set dc_output_icc2_script  ""
{%- endif %}
{%- if local.use_upf == "true" %}
set low_power_file  "{{env.BLK_UPF}}/{{ver.upf}}/{{env.BLK_NAME}}.upf"
{%- endif %} 
{%- if ver.scandef %}
set scandef_file "{{env.BLK_SCANDEF}}/{{ver.scandef}}/{{env.BLK_NAME}}.scandef"
{%- else %}
set scandef_file ""
{%- endif %}
set blk_sdc_dir       "{{env.BLK_SDC}}/{{ver.sdc}}"
set blk_utils_dir     "{{env.PROJ_UTILS}}"
set ocv_mode          "{{local.ocv_mode}}" 
set ndm_tech          "{{liblist.NDM_TECH}}" 
set ndm_std           "{{liblist.NDM_STD}}"
set ndm_mem           "{{liblist.NDM_MEM}}"
set ndm_ip            "{{liblist.NDM_IP}}"
set pre_place_opt_active_scenario_list "{{local.pre_place_opt_active_scenario_list}}"
set def_convert_site_list "{{local.def_convert_site_list}}"
set tcl_mv_setup_file  "{{cur.config_plugins_dir}}/icc2_scripts/common_scripts/mv_setup.tcl"
{%- if liblist.NDM_MEM %} 
set reference_library "{{liblist.NDM_STD}} {{liblist.NDM_TECH}} {{liblist.NDM_MEM}}"
{%- elif liblist.NDM_IP %}
set reference_library "{{liblist.NDM_STD}} {{liblist.NDM_TECH}} {{liblist.NDM_IP}}"
{%- elif liblist.NDM_IP and liblist.NDM_MEM %}
set reference_library "{{liblist.NDM_STD}} {{liblist.NDM_TECH}} {{liblist.NDM_MEM}} {{liblist.NDM_IP}}"
{%- else %}
set reference_library "{{liblist.NDM_STD}} {{liblist.NDM_TECH}}"
{%- endif %}

set write_def_convert_icc2_site_to_lef_site_name_list "{{local.write_def_convert_icc2_site_to_lef_site_name_list}}"
set icc_icc2_gds_layer_mapping_file "{{local.icc_icc2_gds_layer_mapping_file}}"
set TCL_PLACEMENT_SPACING_LABEL_RULE_FILE "{{local.tcl_placement_spacing_label_rule_file}}"
set TCL_ICC2_CTS_NDR_RULE_FILE  "{{local.tcl_icc2_cts_ndr_rule_file}}"
##########################################################################################
# reporting_setup
##########################################################################################
set common_report_scenario  "{{local.common_report_scenario}}"
set common_report_pvt       "{{local.common_report_pvt}}"
set common_report_qor       "{{local.common_report_qor}}"
set common_report_timing    "{{local.common_report_timing}}"
set common_report_constraint "{{local.common_report_constraint}}"
set common_report_congestion_map    "{{local.common_report_congestion_map}}"
set common_report_threshold_voltage_group "{{local.common_report_threshold_voltage_group}}"
set common_report_power      "{{local.common_report_power}}"
set common_report_mv_path    "{{local.common_report_mv_path}}"
set common_report_utilization "{{local.common_report_utilization}}"
set common_report_units       "{{local.common_report_units}}"
set common_report_detail_timing "{{local.common_report_detail_timing}}"
set fp_report_zero_interconnect_delay_timing "{{local.fp_report_zero_interconnect_delay_timing}}"
set cts_report_clock_tree_info "{{local.cts_report_clock_tree_info}}"
set route_no_si_timing_report   "{{local.route_no_si_timing_report}}"
set route_check_route          "{{local.route_check_route}}"

##########################################################################################
# mcmm_setup
##########################################################################################
## scenario settings
set tech_ndm                           "{{local.tech_ndm}}";# *fill tech_ndm name, example tech_only,remember it's not tech ndm library path! only tech ndm name is OK.
{%- if local.scenario_list is string %}
set scenario_list                      "{{local.scenario_list}}";# *fill scenario table 
{%- elif local.scenario_list is sequence %}
set scenario_list                      "{{local.scenario_list|join (' ')}}";# *fill scenario table 
{%- endif %}
{%- if local.process_list is string %}
set process_list                       "{{local.process_list}}";# *fill process table, example 1 0.9
{%- elif local.process_list is sequence %}
set process_list                       "{{local.process_list|join (' ')}}";# *fill process table, example 1 0.9
{%- endif %}
{%- if local.process_label_list is string %}
set process_label_list                 "{{local.process_label_list}}";#optional,fill process label table, example fast slow
{%- elif local.process_label_list is sequence %}
set process_label_list                 "{{local.process_label_list|join (' ')}}";#optional,fill process label table, example fast slow
{%- endif %}
{%- if local.scenario_status_leakage_power is string %}
set scenario_status_leakage_power      "{{local.scenario_status_leakage_power}}";#optional,fill setup table with true/false
{%- elif local.scenario_status_leakage_power is sequence %}
set scenario_status_leakage_power      "{{local.scenario_status_leakage_power|join (' ')}}";#optional,fill setup table with true/false
{%- endif %}
{%- if local.scenario_status_dynamic_power is string %}
set scenario_status_dynamic_power      "{{local.scenario_status_dynamic_power}}";#optional,fill setup table with true/false
{%- elif local.scenario_status_dynamic_power is sequence %}
set scenario_status_dynamic_power      "{{local.scenario_status_dynamic_power|join (' ')}}";#optional,fill setup table with true/false
{%- endif %}
{%- if local.scenario_status_max_transition is string %}
set scenario_status_max_transition     "{{local.scenario_status_max_transition}}";#optional,fill setup table with true/false
{%- elif local.scenario_status_max_transition is sequence %}
set scenario_status_max_transition     "{{local.scenario_status_max_transition|join (' ')}}";#optional,fill setup table with true/false
{%- endif %}
{%- if local.scenario_status_max_capacitance is string %}
set scenario_status_max_capacitance    "{{local.scenario_status_max_capacitance}}";#optional,fill setup table with true/false
{%- elif local.scenario_status_max_capacitance is sequence %}
set scenario_status_max_capacitance    "{{local.scenario_status_max_capacitance|join (' ')}}";#optional,fill setup table with true/false
{%- endif %}
{%- if local.voltage_list is string %}
set voltage_list                       "{{local.voltage_list}}";# *fill voltage1 table, example "{VDD-0.9 VSS-0.0 VDDH-1.16}"
{%- elif local.voltage_list is sequence %}
set voltage_list                       "{{local.voltage_list|join (' ')}}";# *fill voltage1 table, example "{VDD-0.9 VSS-0.0 VDDH-1.16}"
{%- endif %}

###timing derate settings
{%- if local.timing_derate_lib_corner_list is string %}
set timing_derate_lib_corner_list      "{{local.timing_derate_lib_corner_list}}" ;# *fill with corner names, example ss125c 
{%- elif local.timing_derate_lib_corner_list is sequence %}
set timing_derate_lib_corner_list      "{{local.timing_derate_lib_corner_list|join (' ')}}" ;# *fill with corner names, example ss125c 
{%- endif %}
{%- if local.data_net_early_derate_list is string %}
set data_net_early_derate_list         "{{local.data_net_early_derate_list}}" ;# optional,data net early derate for each corner
{%- elif local.data_net_early_derate_list is sequence %}
set data_net_early_derate_list         "{{local.data_net_early_derate_list|join (' ')}}" ;# optional,data net early derate for each corner
{%- endif %}
{%- if local.data_net_late_derate_list is string %}
set data_net_late_derate_list          "{{local.data_net_late_derate_list}}" ;# optional,data net late derate for each corner
{%- elif local.data_net_late_derate_list is sequence %}
set data_net_late_derate_list          "{{local.data_net_late_derate_list|join (' ')}}" ;# optional,data net late derate for each corner
{%- endif %}
{%- if local.clock_net_early_derate_list is string %}
set clock_net_early_derate_list        "{{local.clock_net_early_derate_list}}" ;# optional,clock net early derate for each corner
{%- elif local.clock_net_early_derate_list is sequence %}
set clock_net_early_derate_list        "{{local.clock_net_early_derate_list|join (' ')}}" ;# optional,clock net early derate for each corner
{%- endif %}
{%- if local.clock_net_late_derate_list is string %}
set clock_net_late_derate_list         "{{local.clock_net_late_derate_list}}" ;# optional,clock net late derate for each corner
{%- elif local.clock_net_late_derate_list is sequence %}
set clock_net_late_derate_list         "{{local.clock_net_late_derate_list|join (' ')}}" ;# optional,clock net late derate for each corner
{%- endif %}
##If your design is does not have aocv/pocv table, you can specify bellow table for clock/data path cell derating
##If your design use aocv/pocv table, then you just leave bellow empty
{%- if local.data_cell_early_derate_list is string %}
set data_cell_early_derate_list        "{{local.data_cell_early_derate_list}}" ;# optional, early derate for data path cells
{%- elif local.data_cell_early_derate_list is sequence %}
set data_cell_early_derate_list        "{{local.data_cell_early_derate_list|join (' ')}}" ;# optional, early derate for data path cells
{%- endif %}
{%- if local.data_cell_late_derate_list is string %}
set data_cell_late_derate_list         "{{local.data_cell_late_derate_list}}" ;# optional, late derate for data path cells
{%- elif local.data_cell_late_derate_list is sequence %}
set data_cell_late_derate_list         "{{local.data_cell_late_derate_list|join (' ')}}" ;# optional, late derate for data path cells
{%- endif %}
{%- if local.clock_cell_early_derate_list is string %}
set clock_cell_early_derate_list       "{{local.clock_cell_early_derate_list}}" ;# optional, early derate for clock path cells
{%- elif local.clock_cell_early_derate_list is sequence %}
set clock_cell_early_derate_list       "{{local.clock_cell_early_derate_list|join (' ')}}" ;# optional, early derate for clock path cells
{%- endif %}
{%- if local.clock_cell_late_derate_list is string %}
set clock_cell_late_derate_list        "{{local.clock_cell_late_derate_list}}" ;# optional, late derate for data path cells
{%- elif local.clock_cell_late_derate_list is sequence %}
set clock_cell_late_derate_list        "{{local.clock_cell_late_derate_list|join (' ')}}" ;# optional, late derate for data path cells
{%- endif %}

##some memory cell may need timing derate
{%- if local.mem_list is string %}
set mem_list                           "{{local.mem_list|join (' ')}}" ;# optional, memory's lib cells for derate, example */*RAM64x128*
{%- elif local.mem_list is sequence %}
set mem_list                           "{{local.mem_list}}" ;# optional, memory's lib cells for derate, example */*RAM64x128*
{%- endif %}
{%- if local.scenario_list is string %}
set mem_early_derate_list              "{{local.mem_early_derate_list}}" ;# optional, early derate for listed memories
{%- elif local.mem_early_derate_list is sequence %}
set mem_early_derate_list              "{{local.mem_early_derate_list|join (' ')}}" ;# optional, early derate for listed memories
{%- endif %}
{%- if local.mem_late_derate_list is string %}
set mem_late_derate_list               "{{local.mem_late_derate_list}}" ;# optional, late derate for listed memories
{%- elif local.mem_late_derate_list is sequence %}
set mem_late_derate_list               "{{local.mem_late_derate_list|join (' ')}}" ;# optional, late derate for listed memories
{%- endif %}


