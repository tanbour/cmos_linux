##########################################################################################
# Tool: IC Compiler II
##########################################################################################
puts "Alchip-info : Running script [info script]\n"
set sh_continue_on_error true

##===================================================================##
## SETUP                                                             ##
##===================================================================##
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/icc2_procs.tcl
source {{env.PROJ_LIB}}/liblist/{{ver.LIB}}.tcl
source {{cur.cur_flow_sum_dir}}/{{cur.sub_stage}}.op._job.tcl
# include 00_icc2_setup.tcl
{% include 'icc2/00_icc2_setup.tcl' %}

set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

set blk_name           "{{env.BLK_NAME}}"
set blk_rpt_dir        "{{cur.cur_flow_rpt_dir}}"
set blk_utils_dir      "{{env.PROJ_UTILS}}"
set blk_proj_cmn       "{{env.PROJ_SHARE_CMN}}"
set pre_flow_data_dir  "{{pre.flow_data_dir}}/{{pre.stage}}"
set cur_design_library "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"
set icc2_cpu_number    "[lindex "${_job_cpu_number}" end]"
set_host_option -max_cores $icc2_cpu_number

set pre_design_library  "$pre_flow_data_dir/$pre_stage.{{env.BLK_NAME}}.nlib"
set cur_design_library  "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"

set ocv_mode                                          "{{local.ocv_mode}}" 
set design_style                                      "{{local.design_style}}"
set lib_cell_height                                    "{{local.lib_cell_height}}"
{%- if local.clock_opt_active_scenario_list is string %}
set  clock_opt_active_scenario_list                   "{{local.clock_opt_active_scenario_list}}"
{%- elif local.clock_opt_active_scenario_list is sequence %}
set clock_opt_active_scenario_list                    "{{local.clock_opt_active_scenario_list|join (' ')}}"
{%- endif %}

set clock_opt_opto_name_prefix                        "{{local.clock_opt_opto_name_prefix}}"
set clock_opt_opto_cto                                "{{local.clock_opt_opto_cto}}"
set clock_opt_opto_cto_name_prefix                    "{{local.clock_opt_opto_cto_name_prefix}}"
set clock_opt_use_usr_write_data_tcl                  "{{local.clock_opt_use_usr_write_data_tcl}}"
set clock_opt_create_abstract                         "{{local.clock_opt_create_abstract}}"
set clock_opt_write_data                              "{{local.clock_opt_write_data}}"
set enable_clock_opt_reporting                        "{{local.enable_clock_opt_reporting}}"
set use_usr_common_scripts_connect_pg_net_tcl         "{{local.use_usr_common_scripts_connect_pg_net_tcl}}"
set write_def_convert_icc2_site_to_lef_site_name_list "{{local.write_def_convert_icc2_site_to_lef_site_name_list}}"
set icc_icc2_gds_layer_mapping_file                   "${ICC_ICC2_GDS_LAYER_MAPPING_FILE}"

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
## copy block and lib from previous stage
copy_lib -from_lib ${pre_design_library} -to_lib ${cur_design_library} -no_design
open_lib ${pre_design_library}
copy_block -from ${pre_design_library}:{{env.BLK_NAME}}/${pre_stage} -to ${cur_design_library}:{{env.BLK_NAME}}/${cur_stage}
close_lib ${pre_design_library}
open_lib ${cur_design_library}
current_block {{env.BLK_NAME}}/${cur_stage}

link_block
save_lib

###==================================================================##
## source mcmm file setup timing constrains                          ##
##===================================================================##
{% if local.clock_opt_load_mcmm == "true" %}
{% include  'icc2/mcmm.tcl' %}
foreach_in_collection scenario [all_scenarios] {
	current_scenario $scenario
	synthesize_clock_trees -propagate_only
	compute_clock_latency
}
{%- endif %}

###==================================================================##
## Timing constraints                                                ##
##===================================================================##
{% if local.clock_opt_active_scenario_list  %} 
set_scenario_status -active false [get_scenarios -filter active]
set_scenario_status -active true $clock_opt_active_scenario_list
## Propagate clocks and compute IO latencies for modes or corners which are not active during clock_opt_cts step
synthesize_clock_trees -propagate_only
compute_clock_latency
{%- else %}
set_scenario_status -active true [all_scenarios]
{% endif %}  

foreach_in_collection scn [all_scenarios] {
    current_scenario $scn
{%- if local.setup_uncertainty %}
    set_clock_uncertainty {{local.setup_uncertainty}} -setup [all_clocks ] -scenarios $scn
{%-  endif %}
{%- if local.hold_uncertainty %}
    set_clock_uncertainty {{local.hold_uncertainty}} -hold  [all_clocks ] -scenarios $scn
{%-  endif %}
{%- if local.data_transition %}
    set_max_transition -data_path {{local.data_transition}} [all_clocks] -scenarios $scn
{%- endif %}
{%- if local.clock_transition %}
    set_max_transition -clock_path {{local.clock_transition}} [all_clocks] -scenarios $scn
{%- endif %}
}

###==================================================================##
## clock settings                                                    ##
##===================================================================##
## Reset all app options in current block------------------------------
reset_app_options -block [current_block] *

puts "Alchip-info: settings icc2_settings/icc2_common.tcl"
{% include  'icc2/icc2_settings/icc2_common.tcl' %} 

puts "Alchip-info: settings icc2_settings/icc2_clock_opt.tcl "
{% include  'icc2/icc2_settings/icc2_clock_opt.tcl' %} 

puts "Alchip-info: tsmc16ffpgl_settings/tsmc16ffpgl_settings.tcl "
{% include  'icc2/tsmc16ffpgl_settings/tsmc16ffpgl_settings.tcl' %} 

puts "Alchip-info: Sourcing  set_lib_cell_purpose.tcl"
source -e -v "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/set_lib_cell_purpose.tcl"

## clock opt cts name prefix---------------------------------------------
{%- if local.clock_opt_opto_name_prefix %}
set_app_options -name opt.common.user_instance_name_prefix -value $clock_opt_opto_name_prefix
{%- if local.clock_opt_ccd %}
# If CCD is enabled, set both opt and cts user prefix as CCD can work on both clock and data paths
set_app_options -name cts.common.user_instance_name_prefix -value ${clock_opt_opto_name_prefix}_cts
{%- endif %}
{%- endif %}

###==================================================================##
##  Enable AOCV or POCV                                              ##
##===================================================================##
{%- if local.ocv_mode == "aocv" %} 
set_app_options -name time.aocvm_enable_analysis -value true ;# default false
{%- elif local.ocv_mode == "pocv" %} 
set_app_options -name  time.pocvm_enable_analysis -value true ; ;# default false
set_app_options -list {time.enable_slew_variation true}
set_app_options -list {time.ocvm_enable_distance_analysis true}
reset_app_options time.aocvm_enable_analysis 
{%- else %}
set_app_options -name time.aocvm_enable_analysis -value false ;# default false
set_app_options -name  time.pocvm_enable_analysis -value false ; ;# default false
{% endif %}

###==================================================================##
## Pre clock_opt  customizations                                     ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/04_clock_opt/00_usr_pre_clock_opt.tcl

## report clock_opt start non default app options----------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.start.rpt {report_app_options -non_default}

###==================================================================##
## clock opt run command                                             ##
##===================================================================##
{% if local.design_style == "top" %}
set_timing_paths_disabled_blocks  -all_sub_blocks
{%- endif %}

{#- source usr post clock tree optimization command file from plugins #}
{%- if local.use_usr_clock_opt_cmd_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/04_clock_opt/01_usr_clock_opt_cmd.tcl
save_block
{%- else %}
puts "RM-info: Running clock_opt -from final_opto -to final_opto command"
clock_opt -from final_opto -to final_opto
{% endif %}
{#-
# Starting from M-2016.12 release, clock_opt "final_opto" phase by default includes clock route patching step,
#  so there's no need to run "route_group -all_clock_nets" right after clock_opt.
#  However, if you manually add a refine_opt command after clock_opt, you should still run route_group
#  to patch the clock routes. For ex,
#	refine_opt
#	route_group -all_clock_nets
-#}

###==================================================================##
## post clock customizations                                         ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/04_clock_opt/00_usr_post_clock_opt.tcl

###==================================================================##
## Post-route clock tree optimization for non-CCD flow               ##
##===================================================================##

{%- if local.clock_opt_opto_cto == "true" and local.clock_opt_ccd == "false" %}
{%- if local.clock_opt_opto_cto_name_prefix %}
set_app_options -name cts.common.user_instance_name_prefix -value ${clock_opt_opto_cto_name_prefix}
{%- endif %} 
synthesize_clock_trees -postroute -routed_clock_stage detail
{%- endif %}

## Connect pg net------------------------------------------------------

{%- if local.use_usr_common_scripts_connect_pg_net_tcl == "true" %}
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/connect_pg_net.tcl
{%- else %}
puts "Alchip-info: Running connect_pg_net command"
connect_pg_net
{%- endif %}

## remove_clock_gating_check after build clock tree---------------------
remove_clock_gating_check

## save design----------------------------------------------------------
save_block
save_block -as {{env.BLK_NAME}}

###==================================================================##
##  output data                                                      ##
##===================================================================##
{%- if local.clock_opt_use_usr_write_data_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/04_clock/08_usr_write_data.tcl
{%- else %}
{%- if local.clock_opt_write_data == "true" %} 
set    no_ref           [get_attribute [get_lib_cell -quiet */PFILLER*/frame] full_name]
append no_ref " "       [get_attribute [get_lib_cell -quiet */PENDCAP_V/frame] full_name]
append no_ref " "       [get_attribute [get_lib_cell -quiet */PENDCAP_H/frame] full_name]
append no_ref " "       [get_attribute [get_lib_cell -quiet */PAD95APB_LF_BU] full_name]
append no_ref " "       [get_attribute [get_lib_cell -quiet */PAD80APB_LF_BU] full_name]
append no_ref " " [join [get_attribute [get_lib_cell -quiet */FILL*/frame] full_name]]
append no_ref " " [join [get_attribute [get_lib_cell -quiet */BOUNDARY*/frame] full_name]]
append no_ref " " [join [get_attribute [get_lib_cell -quiet */TAPCELL*/frame] full_name]]
# write_verilog (no pg, and no physical only cells)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all {{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.ori.v
## write_verilog for LVS (with pg, and with physical only cells)
write_verilog -compress gzip -include {empty_modules pad_cells all_physical_cells pg_netlist}  -force_no_reference $no_ref  {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lvs.v
## write_verilog for Formality (with pg, no physical only cells, and no supply statements)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells supply_statements} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.fm.v
## write_verilog for PT (no pg, no physical only cells but with diodes and DCAP for leakage power analysis)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.pt.v

{% if local.write_def_convert_icc2_site_to_lef_site_name_list != "" %} 
write_def -include_tech_via_definitions -version 5.8 -convert_sites { $write_def_convert_icc2_site_to_lef_site_name_list } -compress gzip {{cur.cur_flow_data_dir}}/.${cur_stage}{{env.BLK_NAME}}.def
{%- else %}
write_def -include_tech_via_definitions -version 5.8 -compress gzip {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.def
{%- endif %}
{%- endif %}
{%- endif %}

## report clock_opt end non default app options-------------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.end.rpt {report_app_options -non_default}

## generate early touch file--------------------------------------------
exec touch {{cur.cur_flow_sum_dir}}/${cur_stage}.{{env.BLK_NAME}}.early_complete

## create abstract-------------------------------------------------------
{%- if local.clock_opt_create_abstract == "true" %}
open_block {{env.BLK_NAME}} 
create_abstract -read_only
create_frame
save_lib
{%- endif %}

## Report-----------------------------------------------------------------
{%- if local.clock_opt_use_usr_report_tcl == "true" %}
source -v {{cur.config_plugins_dir}}/icc2_scripts/04_clock_opt/09_usr_clock_opt_report.tcl
{%- else %}
set REPORT_QOR_SCRIPT {{env.PROJ_UTILS}}/icc2_utils/report_qor.tcl
{%- if local.enable_clock_opt_reporting == "true" %} 
puts "Alchip-info: Sourcing [which $REPORT_QOR_SCRIPT]"
source -v -e $REPORT_QOR_SCRIPT
{%- endif %}
{%- endif %}
source -v -e {{env.PROJ_UTILS}}/icc2_utils/snapshot.tcl

####################################
## exit icc2
####################################
puts "Alchip-info : Completed script [info script]\n"

