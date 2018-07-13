######################################################################
# Tool: IC Compiler II
######################################################################
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
{%- if local.clock_active_scenario_list is string %}
set clock_active_scenario_list                        "{{local.clock_active_scenario_list}}"
{%- elif local.clock_active_scenario_list is sequence %}
set clock_active_scenario_list                        "{{local.clock_active_scenario_list|join (' ')}}"
{%- endif %}

set clock_enable_ccd                                  "{{local.clock_enable_ccd}}"
set clock_opt_cts_name_prefix                         "{{local.clock_opt_cts_name_prefix}}"
set enable_clock_reporting                            "{{local.enable_clock_reporting}}"
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
{% if local.clock_active_scenario_list != "" %} 
set_scenario_status -active false [get_scenarios -filter active]
set_scenario_status -active true $clock_active_scenario_list
{%- else %}
set_scenario_status -active true [all_scenarios]
{% endif %}  

###==================================================================##
## Additional timer related setups :cts uncertainty                  ##
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
## clock settings                                                    ##
##===================================================================##
## Reset all app options in current block------------------------------
reset_app_options -block [current_block] *

puts "Alchip-info: settings icc2_settings/icc2_common.tcl"
{% include  'icc2/icc2_settings/icc2_common.tcl' %} 

puts "Alchip-info: settings icc2_settings/icc2_clock.tcl "
{% include  'icc2/icc2_settings/icc2_clock.tcl' %} 

puts "Alchip-info: Sourcing  tsmc16ffpgl settings"
{% include 'icc2/tsmc16ffpgl_settings/tsmc16ffpgl_settings.tcl'%} 

puts "Alchip-info: Sourcing  set_lib_cell_purpose.tcl"
source -e -v "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/set_lib_cell_purpose.tcl"

## clock opt cts name prefix-------------------------------------------
{%- if local.clock_opt_cts_name_prefix %}
## re-define clock opt cts name prefix-------------------------------------------
set_app_options -name cts.common.user_instance_name_prefix -value "{{local.clock_opt_cts_name_prefix}}"
if {[get_app_option_value -name clock_opt.flow.enable_ccd]} {
  # If CCD is enabled, set both opt and cts user prefix as it can work on both data and clock paths
  set_app_options -name opt.common.user_instance_name_prefix -value {{local.clock_opt_cts_name_prefix}}_ccd
}
{% endif %}
###==================================================================##
## Enable AOCV or POCV                                               ##
##===================================================================##
{%- if local.ocv_mode == "aocv" %} 
set_app_options -name time.aocvm_enable_analysis -value true ;# default false
{%- elif local.ocv_mode == "pocv" %} 
set_app_options -name  time.pocvm_enable_analysis -value true ; ;# default false
{%- else %}
set_app_options -name time.aocvm_enable_analysis -value false ;# default false
set_app_options -name  time.pocvm_enable_analysis -value false ; ;# default false
{% endif %}

###==================================================================##
## Pre-clock  customizations                                         ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/03_clock/00_usr_pre_clock.tcl

###==================================================================##
## Pre-CTS checks                                                    ##
##===================================================================##
## Check for netlist, constraints, or setup issues that could hurt CTS results---------------
redirect -file $blk_rpt_dir/$cur_stage.pre_cts_check_clock_tree.rpt {check_clock_tree}
## Report CTS constraints and settings that have been applied--------------------------------
redirect -file $blk_rpt_dir/$cur_stage.pre_cts_clock_settings.rpt {report_clock_settings}

## report clock start non default app options--------------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.start.rpt {report_app_options -non_default}

###==================================================================##
## clock buid clock tree run command                                 ##
##===================================================================##
{#- source usr clock tree synthesis command file from plugins #}
{%- if local.use_usr_clock_cmd_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/03_clock/01_usr_clock_cmd.tcl
save_block
{%- else %}
puts "Alchip-info: Running clock_opt -from build_clock -to route_clock command"
clock_opt -from build_clock -to route_clock
{%- endif %}

###==================================================================##
## post clock customizations                                         ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/03_clock/00_usr_post_clock.tcl

###==================================================================##
## Propagate all clocks                                              ##
##===================================================================##
#  This should be used only when additional modes/scenarios are activated after CTS is done.
#  Get inactive scenarios, activate them, mark them as propagated, and then deactivate them.
if {[sizeof_collection [get_scenarios -filter active==false -quiet]] > 0} {
      set active_scenarios [get_scenarios -filter active]
      set inactive_scenarios [get_scenarios -filter active==false]

      set_scenario_status -active false [get_scenarios $active_scenarios]
      set_scenario_status -active true [get_scenarios $inactive_scenarios]

      synthesize_clock_trees -propagate_only ;# only works on active scenarios
      set_scenario_status -active true [get_scenarios $active_scenarios]
      set_scenario_status -active false [get_scenarios $inactive_scenarios]
}

## Connect pg net------------------------------------------------------

{%- if local.use_usr_common_scripts_connect_pg_net_tcl == "true" %}
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/connect_pg_net.tcl
{%- else %}
puts "Alchip-info: Running connect_pg_net command"
connect_pg_net -automatic
{%- endif %}

## remove_clock_gating_check after build clock tree-------------------
remove_clock_gating_check

## save design ---------------------------------------------------------
save_block
save_block -as {{env.BLK_NAME}}

###==================================================================##
## output data                                                       ##
##===================================================================##
## Write SPEF
{%- if local.write_spef_by_tool  == "true" %}
{% include 'icc2/icc2_write_spef.tcl' %}
{%- endif %}

{%- if local.clock_use_usr_write_data_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/03_clock/08_usr_write_data.tcl
{%- else %}
{%- if local.clock_write_data == "true" %} 
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
{%- endif %}

## report clock end non default app options----------------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.end.rpt {report_app_options -non_default}

## generate early touch file-------------------------------------------
exec touch {{cur.cur_flow_sum_dir}}/${cur_stage}.{{env.BLK_NAME}}.early_complete

## create abstract----------------------------------------------------
{%- if local.clock_create_abstract == "true" %}
open_block {{env.BLK_NAME}} 
create_abstract
create_frame
save_lib
{%- endif %}

## Report-------------------------------------------------------------
{%- if local.clock_use_usr_report_tcl == "true" %}
source -v {{cur.config_plugins_dir}}/icc2_scripts/03_clock/09_usr_clock_report.tcl
{%- else %}
set REPORT_QOR_SCRIPT {{env.PROJ_UTILS}}/icc2_utils/report_qor.tcl
{%- if local.enable_clock_reporting == "true" %} 
puts "Alchip-info: Sourcing [which $REPORT_QOR_SCRIPT]"
source -v -e $REPORT_QOR_SCRIPT
{%- endif %}
{%- endif %}
source -v -e {{env.PROJ_UTILS}}/icc2_utils/snapshot.tcl

###==================================================================##
## exit icc2                                                         ##
##===================================================================##
puts "Alchip-info : Completed script [info script]\n"


