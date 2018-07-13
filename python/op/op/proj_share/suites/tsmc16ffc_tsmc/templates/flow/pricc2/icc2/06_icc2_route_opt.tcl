##########################################################################################
# Tool: IC Compiler II
##########################################################################################
puts "Alchip-info : Running script [info script]\n"
set sh_continue_on_error true

##===================================================================##
## SETUP                                                             ##
##===================================================================##
source {{cur.flow_liblist_dir}}/liblist/liblist.tcl
source {{cur.cur_flow_sum_dir}}/{{cur.sub_stage}}.op._job.tcl

set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

set blk_name                                          "{{env.BLK_NAME}}"
set blk_rpt_dir                                       "{{cur.cur_flow_rpt_dir}}"
set blk_utils_dir                                     "{{env.PROJ_UTILS}}"
set pre_flow_data_dir                                 "{{pre.flow_data_dir}}/{{pre.stage}}"
set cur_design_library                                "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"
set icc2_cpu_number                                   "[lindex "${_job_cpu_number}" end]"
set_host_option -max_cores $icc2_cpu_number

set pre_design_library                                "$pre_flow_data_dir/$pre_stage.{{env.BLK_NAME}}.nlib"
set cur_design_library                                "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"

set ocv_mode                                          "{{local.ocv_mode}}" 
set optimization_flow                                 "{{local.optimization_flow}}"
{%- if local.route_opt_active_scenario_list  is string %}
set route_opt_active_scenario_list                    "{{local.route_opt_active_scenario_list}}"
{%- elif local.route_opt_active_scenario_list is sequence %}
set route_opt_active_scenario_list                    "{{local.route_opt_active_scenario_list|join (' ')}}"
{%- endif %}

set route_opt_enable_ccd                              "{{local.route_opt_enable_ccd}}"
set tcl_user_icc2_format_redundant_via_mapping_file   "{{local.tcl_user_icc2_format_redundant_via_mapping_file}}"
set tcl_user_icc_format_redundant_via_mapping_file    "{{local.tcl_user_icc_format_redundant_via_mapping_file}}"
set route_opt_antenna_fixing                          "{{local.route_opt_antenna_fixing}}"
set tcl_antenna_rule_file                             "{{local.tcl_antenna_rule_file}}"
set icc2_route_opt_optimize_double_via                "{{local.icc2_route_opt_optimize_double_via}}"
set concurrent_redundant_via_mode_reserve_space       "{{local.concurrent_redundant_via_mode_reserve_space}}"
set si_enable_analysis                                "{{local.si_enable_analysis}}"
set route_common_threshold_noise_ratio                "{{local.route_common_threshold_noise_ratio}}"
set route_opt_use_usr_write_data_tcl                  "{{local.route_opt_use_usr_write_data_tcl}}"       
set route_opt_write_data                              "{{local.route_opt_write_data}}"
set route_opt_create_abstract                         "{{local.route_opt_create_abstract}}"
set route_opt_name_prefix                             "{{local.route_opt_name_prefix}}"
set route_opt_write_gds                               "{{local.route_opt_write_gds}}"
set enable_route_opt_reporting                        "{{local.enable_route_opt_reporting}}"
set use_usr_common_scripts_connect_pg_net_tcl         "{{local.use_usr_common_scripts_connect_pg_net_tcl}}"
set write_def_convert_icc2_site_to_lef_site_name_list "{{local.write_def_convert_icc2_site_to_lef_site_name_list}}"
set icc_icc2_gds_layer_mapping_file                   "{{local.icc_icc2_gds_layer_mapping_file}}"

{%- if local.tcl_placement_spacing_label_rule_file %}
set TCL_PLACEMENT_SPACING_LABEL_RULE_FILE             "{{local.tcl_placement_spacing_label_rule_file}}"
{%- else %}
set TCL_PLACEMENT_SPACING_LABEL_RULE_FILE             "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/placement_spacing_rule.tcl"
{%- endif %}
{%- if local.tcl_icc2_cts_ndr_rule_file %}
set TCL_ICC2_CTS_NDR_RULE_FILE                        "{{local.tcl_icc2_cts_ndr_rule_file}}"
{%- else %}
set TCL_ICC2_CTS_NDR_RULE_FILE                        "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/icc2_cts_ndr_rule.tcl"
{%- endif %}
{% include 'icc2/00_icc2_setup.tcl' %}
##===================================================================##
## back up database                                                  ##
## copy block and lib from previous stage                            ## 
##===================================================================##
set bak_date [exec date +%m%d]
if {[file exist ${cur_design_library}] } {
if {[file exist ${cur_design_library}_bak_${bak_date}] } {
exec rm -rf ${cur_design_library}_bak_${bak_date}
}
exec mv -f ${cur_design_library} ${cur_design_library}_bak_${bak_date}
}
## copy block and lib from previous stage------------------------------
copy_lib -from_lib ${pre_design_library} -to_lib ${cur_design_library} -no_design
open_lib ${pre_design_library}
copy_block -from ${pre_design_library}:{{env.BLK_NAME}}/${pre_stage} -to ${cur_design_library}:{{env.BLK_NAME}}/${cur_stage}
close_lib ${pre_design_library}
open_lib ${cur_design_library}
current_block {{env.BLK_NAME}}/${cur_stage}

link_block
save_lib

###==================================================================##
## Timing constraints                                                ##
##===================================================================##
{% if local.route_opt_active_scenario_list != "" %} 
set_scenario_status -active false [get_scenarios -filter active]
set_scenario_status -active true $route_opt_active_scenario_list
{%- else %}
set_scenario_status -active true [all_scenarios]
{% endif %}  

###==================================================================##
## Additional timer related setups :postects uncertainty             ##
##===================================================================##
{%- if local.setup_uncertainty %}
set_clock_uncertainty {{local.setup_uncertainty}} -setup [all_clocks ] -scenarios [all_scenarios ]
{%-  endif %}
{%- if local.hold_uncertainty %}
set_clock_uncertainty {{local.hold_uncertainty}} -hold  [all_clocks ] -scenarios [all_scenarios ]
{%-  endif %}


{%- if local.data_transition %}
set_max_transition -data_path {{local.data_transition}} [all_clocks] -scenarios [all_scenarios]
{%- endif %}
{%- if local.clock_transition %}
set_max_transition -clock_path {{local.clock_transition}} [all_clocks] -scenarios [all_scenarios]
{%- endif %}

###==================================================================##
## route opt settings                                                ##
##===================================================================##
## Reset all app options in current block------------------------------
reset_app_options -block [current_block] *

puts "Alchip-info: settings icc2_settings/icc2_common.tcl"
{% include  'icc2/icc2_settings/icc2_common.tcl' %} 

puts "Alchip-info: settings icc2_settings/icc2_route_opt.tcl "
{% include  'icc2/icc2_settings/icc2_route_opt.tcl' %} 

puts "Alchip-info: Sourcing  tsmc16ffc settings"
{% include 'icc2/tsmc16ffc_settings/tsmc16ffc_settings.tcl'%} 

puts "Alchip-info: Sourcing  set_lib_cell_purpose.tcl"
source -e -v "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/set_lib_cell_purpose.tcl"

if {$route_opt_name_prefix != ""} {
	set_app_options -name opt.common.user_instance_name_prefix -value $route_opt_name_prefix
}

###==================================================================##
## Enable AOCV or POCV                                               ##
##===================================================================##
{%- if local.ocv_mode == "aocv" %} 
## Enable the AOCV analysis
set_app_options -name time.aocvm_enable_analysis -value true ;# default false
{%- elif local.ocv_mode == "pocv" %} 
set_app_options -name  time.pocvm_enable_analysis -value true ; ;# default false
{%- else %}
set_app_options -name time.aocvm_enable_analysis -value false ;# default false
set_app_options -name  time.pocvm_enable_analysis -value false ; ;# default false
{% endif %}

###==================================================================##
## Pre route_opt  customizations                                     ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/06_route_opt/00_usr_pre_route_opt.tcl

## report route start non default app options--------------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.start.rpt {report_app_options -non_default}

###==================================================================##
## route_opt run command                                             ##
##===================================================================##
compute_clock_latency

{#- source usr route opt command file from plugins #}
{%- if local.use_usr_route_opt_cmd_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/06_route_opt/01_usr_route_opt_cmd.tcl
save_block
{%- else %}
{%- if local.optimization_flow == "ttr" %}
## OPTIMIZATION_FLOW: TTR------------------------------------------------

puts "Alchip-info: Running route_opt"
route_opt
puts "Alchip-info: save first route_opt block"
save_block
{%- else %}
## OPTIMIZATION_FLOW: QoR|HPLP|ARLP|HC-----------------------------------

puts "Alchip-info: Running first route_opt"
route_opt
puts "Alchip-info: save first route_opt block"
save_block

{%- if local.optimization_flow == "hplp" or  local.optimization_flow == "arlp" %} 
		# [FLOW] hplp and arlp : Additional route_opt is performed
		puts "Alchip-info: Running second route_opt"
		route_opt
        puts "Alchip-info: save second route_opt block"
        save_block
{%- endif %}
##  CCD is disabled for the last route_opt---------------------------------
if {[get_app_option_value -name route_opt.flow.enable_ccd]} {
	set_app_options -name route_opt.flow.enable_ccd -value false
}
## CTO is disabled for the last route_opt----------------------------------
if {[get_app_option_value -name route_opt.flow.enable_cto]} {
	set_app_options -name route_opt.flow.enable_cto -value false
}
## Leakage power optimization is disabled for the last route_opt-----------
if {[get_app_option_value -name route_opt.flow.enable_power]} {
	set_app_options -name route_opt.flow.enable_power -value false
}

set_app_options -name route_opt.flow.size_only_mode -value equal_or_smaller
puts "Alchip-info: Running last route_opt"
route_opt
puts "Alchip-info: save size_only mode route_opt block"
save_block
{%- endif %}
{%- endif %}

###==================================================================##
## Redundant via insertion                                           ##
##===================================================================##
# For designs with advanced nodes where DRC convergence could be a concern
# we recommended redundant via insertion to be done after route_auto/route_opt

{%- if local.tcl_user_icc2_format_redundant_via_mapping_file or local.tcl_user_icc_format_redundant_via_mapping_file %}
add_redundant_vias
{%- endif %}

###==================================================================##
## Targeted endpoint optimization                                    ##
##===================================================================##

## To optimize specific endpoints for setup, hold, or max_tran, specify the endpoints in a file 
#  by using the -setup_endpoints, -hold_endpoints, or -max_transition options
#  For ex, 
#	set_route_opt_target_endpoints -setup_endpoints $your_setup_endpoints_file
#	route_opt

## To adjust the timing at specific endpoints for setup or hold (such as to adjust timing to achieve PT slack), 
#  specify the endpoints and slack information in a file by using the -setup_timing or -hold_timing options
#  For ex, 
#	set_route_opt_target_endpoints -setup_timing $your_setup_timing_file
#	report_qor -summary ;# generate report with adjusted timing before route_opt
#	route_opt
#	report_qor -summary ;# generate report with adjusted timing after route_opt
#	set_route_opt_target_endpoints -reset ;# remove adjusted timing
#	report_qor -summary ;# generate report without adjusted timing after route_opt

###==================================================================##
## post route opt customizations                                     ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/06_route_opt/00_usr_post_route_opt.tcl

###==================================================================##
## detail route fix short                                            ##
##===================================================================##

## Example to resolve short violated nets
#  Note that remove and reroute nets could potentially degrade timing QoR.
#
#  set data [open_drc_error_data -name zroute.err]
#  open_drc_error_data -name zroute.err
#  if { [sizeof_collection [get_drc_errors -quiet -error_data zroute.err -filter "type_name==Short"] ] > 0} {
#      set remove_net ""
#      foreach_in_collection net [get_attr [get_drc_errors -error_data zroute.err -filter "type_name==Short"] objects] {
#          set net_type [get_attr $net net_type]
#         if {$net_type=="signal"} {append_to_collection remove_net $net}
#      }
#      remove_routes -detail_route -nets $remove_net
#      route_eco
#  }

## If there are remaining routing DRCs, you can use the following :
#  route_detail -incremental true -initial_drc_from_input true

## Connect pg net------------------------------------------------------
{%- if local.use_usr_common_scripts_connect_pg_net_tcl == "true" %}
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/connect_pg_net.tcl
{%- else %}
puts "Alchip-info: Running connect_pg_net command"
connect_pg_net -automatic
{%- endif %}

## save design-----------------------------------------------------------
save_block
save_block -as {{env.BLK_NAME}}

###==================================================================##
## output data                                                       ##
##===================================================================##
## Write SPEF
{%- if local.write_spef_by_tool  == "true" %}
{% include 'icc2/icc2_write_spef.tcl' %}
{%- endif %}

{%- if local.route_opt_use_usr_write_data_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/06_route_opt/08_usr_write_data.tcl
{%- else %}
{%- if local.route_opt_write_data == "true" %} 
# write_verilog (no pg, and no physical only cells)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all {{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.ori.v
## write_verilog for LVS (with pg, and with physical only cells)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations empty_modules} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lvs.v
## write_verilog for Formality (with pg, no physical only cells, and no supply statements)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells supply_statements} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.fm.v
## write_verilog for PT (no pg, no physical only cells but with diodes and DCAP for leakage power analysis)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.pt.v

{% if local.write_def_convert_icc2_site_to_lef_site_name_list != "" %} 
write_def -include_tech_via_definitions -convert_sites { $write_def_convert_icc2_site_to_lef_site_name_list } -compress gzip {{cur.cur_flow_data_dir}}/.${cur_stage}{{env.BLK_NAME}}.def
{%- else %}
write_def -include_tech_via_definitions -compress gzip {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.def
{%- endif %}
{%- endif %}

{%- if local.route_opt_write_gds == "true" %}
write_gds -compress -fill include -hierarchy top -keep_data_type -layer_map $icc_icc2_gds_layer_mapping_file -output_pin all   -long_names -layer_map_format icc2 {{cur.cur_flow_data_dir}}/$cur_stage.$blk_name.gds
{%- endif %}
{%- endif %}

## report route opt end non default app options---------------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.end.rpt {report_app_options -non_default}

## generate early touch file----------------------------------------------
exec touch {{cur.cur_flow_sum_dir}}/${cur_stage}.{{env.BLK_NAME}}.early_complete

## create abstract---------------------------------------------------------
{%- if local.route_opt_create_abstract == "true" %}
open_block {{env.BLK_NAME}} 
create_abstract
create_frame
save_lib
{%- endif %}

## Report------------------------------------------------------------------
{%- if local.route_opt_use_usr_report_tcl == "true" %}
source -v {{cur.config_plugins_dir}}/icc2_scripts/06_route_opt/09_usr_route_opt_report.tcl
{%- else %}
set REPORT_QOR_SCRIPT {{env.PROJ_UTILS}}/icc2_utils/report_qor.tcl
{%- if local.enable_route_opt_reporting == "true" %} 
puts "Alchip-info: Sourcing [which $REPORT_QOR_SCRIPT]"
source -v -e $REPORT_QOR_SCRIPT
{%- endif %}
{%- endif %}
source -v -e {{env.PROJ_UTILS}}/icc2_utils/snapshot.tcl

###==================================================================##
## exit icc2                                                         ##
##===================================================================##
puts "Alchip-info : Completed script [info script]\n"


