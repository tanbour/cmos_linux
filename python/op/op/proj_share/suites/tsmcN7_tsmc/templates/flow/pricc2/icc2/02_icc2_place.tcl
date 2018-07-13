######################################################################
## Tool: IC Compiler II
######################################################################
puts "Alchip-info : Running script [info script]\n"
set sh_continue_on_error true

##===================================================================##
## SETUP                                                             ##
##===================================================================##
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/icc2_procs.tcl
{%- if local.lib_cell_height == "240" %}
source {{env.PROJ_SHARE_CMN}}/process_strategy/liblist/liblist_6T.tcl
{%- elif local.lib_cell_height == "300" %}
source {{env.PROJ_SHARE_CMN}}/process_strategy/liblist/liblist_7d5T.tcl
{%- endif %}
source {{cur.cur_flow_sum_dir}}/{{cur.sub_stage}}.op._job.tcl

set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

set blk_name          "{{env.BLK_NAME}}"
set blk_rpt_dir       "{{cur.cur_flow_rpt_dir}}"
set blk_utils_dir     "{{env.PROJ_UTILS}}"
set blk_proj_cmn      "{{env.PROJ_SHARE_CMN}}"
set pre_flow_data_dir "{{pre.flow_data_dir}}/{{pre.stage}}"
set cur_design_library "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"
set icc2_cpu_number   "[lindex "${_job_cpu_number}" end]"
set_host_option -max_cores $icc2_cpu_number

set pre_design_library  "$pre_flow_data_dir/$pre_stage.{{env.BLK_NAME}}.nlib"
set cur_design_library "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"

set ocv_mode                                             "{{local.ocv_mode}}" 
set design_style                                         "{{local.design_style}}"
set lib_cell_height                                       "{{local.lib_cell_height}}"
set use_abstracts_for_sub_blocks                         "{{local.use_abstracts_for_sub_blocks}}"
set place_opt_active_scenario_list                       "{{local.place_opt_active_scenario_list}}"
set place_opt_optimize_icgs_critical_range               "{{local.place_opt_optimize_icgs_critical_range}}"
set place_opt_refine_opt                                 "{{local.place_opt_refine_op}}"
set place_opt_multibit_banking                           "{{local.place_opt_multibit_banking}}"
set place_opt_multibit_banking_cell_instance_list        "{{local.place_opt_multibit_banking_cell_instance_list}}"
set place_opt_multibit_banking_excluded_instance_list    "{{local.place_opt_multibit_banking_excluded_instance_list}}"
set place_opt_multibit_debanking                         "{{local.place_opt_multibit_debanking}}"
set place_opt_multibit_debanking_cell_instance_list      "{{local.place_opt_multibit_debanking_cell_instance_list}}"
set place_opt_multibit_debanking_excluded_instance_list  "{{local.place_opt_multibit_debanking_excluded_instance_list}}"
set switch_activity_file                                 "{{local.switch_activity_file}}" 
set switch_activity_file_power_scenario                  "{{local.switch_activity_file_power_scenario}}" 
set enable_place_reporting                               "{{local.enable_place_reporting}}"
set use_usr_common_scripts_connect_pg_net_tcl            "{{local.use_usr_common_scripts_connect_pg_net_tcl}}"
set write_def_convert_icc2_site_to_lef_site_name_list    "{{local.write_def_convert_icc2_site_to_lef_site_name_list}}"
set icc_icc2_gds_layer_mapping_file                      "${ICC_ICC2_GDS_LAYER_MAPPING_FILE}"

{% include 'icc2/00_icc2_setup.tcl' %}

###==================================================================##
##  back up database                                                 ##
##  copy block and lib from previous stage                           ## 
##===================================================================##
set bak_date [exec date +%m%d]
if {[file exist ${cur_design_library}] } {
if {[file exist ${cur_design_library}_bak_${bak_date}] } {
exec rm -rf ${cur_design_library}_bak_${bak_date}
}
exec mv -f ${cur_design_library} ${cur_design_library}_bak_${bak_date}
}
## copy block and lib from previous stage ----------------------------
copy_lib -from_lib ${pre_design_library} -to_lib ${cur_design_library} -no_design
open_lib ${pre_design_library}
copy_block -from ${pre_design_library}:{{env.BLK_NAME}}/${pre_stage} -to ${cur_design_library}:{{env.BLK_NAME}}/${cur_stage}
close_lib ${pre_design_library}
open_lib  ${cur_design_library}
current_block {{env.BLK_NAME}}/${cur_stage}

link_block
save_lib

## For top and intermediate level of hierarchical designs, check the editability of the sub-blocks -----------
{% if local.use_abstracts_for_sub_blocks == "true" %}
foreach_in_collection c [get_blocks -hierarchical] {
		if {[get_editability -blocks ${c}] == true } {
	     	set_editability -blocks ${c} -value false
   	  	}
}
report_editability -blocks [get_blocks -hierarchical]
{%- endif %}

###==================================================================##
## Timing constraints                                                ##
##===================================================================##
{% if local.place_opt_active_scenario_list %} 
set_scenario_status -active false [get_scenarios -filter active]
set_scenario_status -active true $place_opt_active_scenario_list
{%- else %}
set_scenario_status -active true [all_scenarios]
{% endif %}  

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
## place_opt settings                                                ##
##===================================================================##
## Reset all app options in current block------------------------------
reset_app_options -block [current_block] *

puts "Alchip-info: settings icc2_settings/icc2_common.tcl"
{% include  'icc2/icc2_settings/icc2_common.tcl' %} 

puts "Alchip-info: settings icc2_settings/icc2_place.tcl "
{% include  'icc2/icc2_settings/icc2_place.tcl' %} 

puts "Alchip-info: settings icc2_settings/icc2_n7_eval_settings.tcl "
{% include  'icc2/icc2_settings/icc2_n7_eval_settings.tcl' %} 

puts "Alchip-info: source 7nm metal cut settings"
source -e -v "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/init_design.tcl.7nm_t.metal_cut"		

puts "Alchip-info: Sourcing  set_lib_cell_purpose.tcl"
source -e -v "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/set_lib_cell_purpose.tcl"

###==================================================================##
## Enable AOCV or POCV                                               ##
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
##  read_saif                                                        ##
##===================================================================##
{%- if local.switch_activity_file %}
{%- if local.switch_activity_file_power_scenario %}
set read_saif_cmd "read_saif $switch_activity_file -scenarios $switch_activity_file_power_scenario"
{%- else %}
set read_saif_cmd "read_saif $switch_activity_file"
{%- endif %}
{%- if local.switch_activity_file_source_instance %}
lappend read_saif_cmd -strip_path $switch_activity_file_source_instance
{%- endif %}
{%- if local.switch_activity_file_target_instance %}
lappend read_saif_cmd -path $switch_activity_file_target_instance
{%- endif %}
puts "Alchip-info : $read_saif_cmd"
eval $read_saif_cmd
{%- endif %}

##===================================================================##
## apply isolation buffer settings                                   ##
##===================================================================##
set signal_ports  [remove_from_collection [get_ports -filter "port_type == signal"]  [get_ports [get_attribute  [get_clock * -filter "is_virtual == false" ] sources] -quiet]]

set clock_ports [get_ports [get_attribute  [get_clock * -filter "is_virtual == false" ] sources] -quiet]

{% if local.isolate_signal_input_port_libcell %}
redirect -var x {set_isolate_ports -driver "{{local.isolate_signal_input_port_libcell}}" -force [get_ports $signal_ports -filter "port_direction == in"]}
if {[regexp "Error" $x]} {puts "Alchip-Info: No signal ports are direction in"} else {puts "Alchip-Info: all signal ports type input are applied with isolate buffer"}
{%- endif %}
{%- if local.isolate_signal_output_port_libcell %}
redirect -var x {set_isolate_ports -driver "{{local.isolate_signal_out_port_libcell}}" -force [get_ports $signal_ports -filter "port_direction == out"]}
if {[regexp "Error" $x]} {puts "Alchip-Info: No signal ports are direction out"} else {puts "Alchip-Info: all signal ports type output are applied with isolate buffer"}
{%- endif %}
{%- if local.isolate_clock_input_port_libcell %}
redirect -var x {set_isolate_ports -driver "{{local.isolate_clock_input_port_libcell}}" -force [get_ports $clock_ports -filter "port_direction == in"]}
if {[regexp "Error" $x]} {puts "Alchip-Info: No clock ports are direction in"} else {puts "Alchip-Info: all clock ports type input are applied with isolate buffer"}
{%- endif %}
{%- if local.isolate_clock_output_port_libcell %}
redirect -var x {set_isolate_ports -driver "{{local.isolate_clock_output_port_libcell}}" -force [get_ports $clock_ports -filter "port_direction == out"]}
if {[regexp "Error" $x]} {puts "Alchip-Info: No clock ports are direction out"} else {puts "Alchip-Info: all clock ports type output are applied with isolate buffer"}
{%- endif %}

###==================================================================##
## Pre-place_opt customizations                                      ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/02_place/00_usr_pre_place.tcl

# report place_opt start non default app options-----------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.start.rpt {report_app_options -non_default *}

###==================================================================##
## place_opt run command                                             ##
##===================================================================##
{#- source usr place_opt command file from plugins #}
{%- if local.use_usr_place_opt_cmd_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/02_place/01_usr_place_opt_cmd.tcl
save_block
{%- else %}
{%- if local.design_style == "top" %}
set_timing_paths_disabled_blocks  -all_sub_blocks
{%- endif %}
## Clock NDR modeling at place_opt------------------------------------
{%- if local.place_opt_optimize_icgs == "true" or local.place_opt_trial_cts == "true" %}
puts "RM-info: Running mark_clock_trees -routing_rules to model clock NDR impact during place_opt"
mark_clock_trees -routing_rules
{%- endif %}

## Two pass place_opt -------------------------------------------------
## First pass ---------------------------------------------------------

{%- if local.use_spg_flow == "true" %}
create_placement -incremental ;# runs embedded CDR
{%- endif %}
{%- if local.use_spg_flow == "false" %}
## Flow with non-SPG inputs (use_spg_flow set to false)
puts "RM-info: Running create_placement"
create_placement
puts "RM-info: Running create_placement -buffering_aware_timing_driven"
create_placement -buffering_aware_timing_driven
puts "RM-info: Running place_opt -from initial_drc -to initial_drc"
place_opt -from initial_drc -to initial_drc
puts "RM-info: Running update_timing -full"
update_timing -full
save_block
{%- endif %}

## Second pass: by using create_placement -incremental and place_opt -from initial_drc--------
{% if local.place_opt_trial_cts == "true" and local.place_opt_optimize_icgs == "false" %}
## Trial clock tree  (optional) --------------------------------------------------------------
set_app_options -name place_opt.flow.trial_clock_tree -value true ;# default false
{%- endif  %}

#  timing-driven ICG splitting (initial_opto phase), and clock-aware placement (final_place phase)
{% if local.place_opt_optimize_icgs == "true" %}
## ICG optimization  (optional) ---------------------------------------------------------------
#  timing-driven ICG splitting (initial_opto phase), and clock-aware placement (final_place phase)
set_app_option -name place_opt.flow.optimize_icgs -value true ;# default false
{%- if local.place_opt_optimize_icgs_critical_range %}
set_app_options -name place_opt.flow.optimize_icgs_critical_range -value {{local.place_opt_optimize_icgs_critical_range}} ;# default 0.75
{%- endif %}
{%- endif %}

puts "RM-info: Running create_placement -incremental -timing_driven -congestion"
{# Note: to increase the congestion alleviation effort, add -congestion_effort high #}
create_placement -incremental -timing_driven -congestion

puts "RM-info: Running place_opt -from initial_drc -to initial_opto"
place_opt -from initial_drc -to initial_opto

save_block
{%- if local.place_opt_multibit_banking == "true" %}
## Multi-bit banking (optional) ---------------------------------------------------------------
set identify_multibit_cmd "identify_multibit -register -no_dft_opt -apply"
{%- if local.place_opt_multibit_banking_cell_instance_list %}
lappend identify_multibit_cmd -cells $place_opt_multibit_banking_cell_instance_list
{%- endif %}
{%- if  local.place_opt_multibit_banking_excluded_instance_list %}
lappend identify_multibit_cmd -exclude_instance $place_opt_multibit_banking_excluded_instance_list
{%- endif %}
puts "RM-info: Running $identify_multibit_cmd"
eval $identify_multibit_cmd
{%- endif %}

puts "RM-info: Running place_opt -from final_place"
place_opt -from final_place
save_block
{%- if local.place_opt_multibit_debanking == "true" %}
## Multi-bit de-banking (optional) ------------------------------------------------------------
set split_multibit_cmd "split_multibit -slack_threshold 0"
{%- if local.place_opt_multibit_debanking_cell_instance_list %}
lappend split_multibit_cmd -cells $place_opt_multibit_debanking_cell_instance_list
{%- endif %}
{%- if local.place_opt_multibit_debanking_excluded_instance_list %}
lappend split_multibit_cmd -exclude_instance $place_opt_multibit_debanking_excluded_instance_list
{%- endif %}
puts "RM-info: Running $split_multibit_cmd"
eval $split_multibit_cmd
puts "RM-info: Running refine_opt"
refine_opt
{%- endif %}
{%- endif %}

###==================================================================##
##  Post-place_opt customizations                                    ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/02_place/00_usr_post_place.tcl

###==================================================================##
## refine_opt                                                        ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/02_place/02_usr_pre_refine_opt.tcl
{#- source usr refine_opt command file from plugins #}
{%- if local.use_usr_refine_opt_cmd_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/02_place/03_usr_refine_opt_cmd.tcl
{%- else %}
{%- if local.place_opt_refine_opt == "refine_opt" %} 
puts "Alchip-info: Running refine_opt command"
refine_opt
puts "Alchip-info: save block for refine_opt"
save_block
{%- elif local.place_opt_refine_opt == "path_opt" %}
puts "RM-info: Running refine_opt -from final_path_opt command"
refine_opt -from final_path_opt
puts "Alchip-info: save block for refine_opt "
save_block
{%- elif local.place_opt_refine_opt == "power" %}
puts "RM-info: Running refine_opt exclusive power optimization"
set_app_options -name refine_opt.flow.exclusive -value power
refine_opt
puts "Alchip-info: save block for refine_opt "
save_block
{%- elif local.place_opt_refine_opt == "area" %}
puts "RM-info: Running refine_opt exclusive area recovery"
set_app_options -name refine_opt.flow.exclusive -value area
refine_opt 
puts "Alchip-info: save block for refine_opt "
save_block
{%- endif %}
{%- endif %}

source {{cur.config_plugins_dir}}/icc2_scripts/02_place/02_usr_post_refine_opt.tcl

## Connect pg net------------------------------------------------------

{%- if local.use_usr_common_scripts_connect_pg_net_tcl == "true" %}
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/connect_pg_net.tcl
{%- else %}
puts "Alchip-info: Running connect_pg_net command"
connect_pg_net
{%- endif %}

## save design---------------------------------------------------------
save_block
save_block -as {{env.BLK_NAME}}

###==================================================================##
##  output data                                                      ##
##===================================================================##
{%- if local.place_use_usr_write_data_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/02_place/08_usr_write_data.tcl
{%- else %}
{%- if local.place_write_data == "true" %} 
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

## report place_opt end non default app options-----------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.end.rpt {report_app_options -non_default}

## generate early touch file-------------------------------------------
exec touch {{cur.cur_flow_sum_dir}}/${cur_stage}.{{env.BLK_NAME}}.early_complete

## create abstract-----------------------------------------------------
{%- if local.place_create_abstract == "true" %}
open_block  {{env.BLK_NAME}} 
create_abstract -read_only
create_frame
save_lib
{%- endif %}

## Report ------------------------------------------------------------
{%- if local.place_use_usr_report_tcl == "true" %}
source -v {{cur.config_plugins_dir}}/icc2_scripts/02_place/09_usr_place_report.tcl
{%- else %}
set REPORT_QOR_SCRIPT {{env.PROJ_UTILS}}/icc2_utils/report_qor.tcl
{%- if local.enable_place_reporting == "true" %} 
puts "Alchip-info: Sourcing [which $REPORT_QOR_SCRIPT]"
source -v -e $REPORT_QOR_SCRIPT
{%- endif %}
{%- endif %}
source -v -e {{env.PROJ_UTILS}}/icc2_utils/snapshot.tcl

###==================================================================##
## exit icc2                                                         ##
##===================================================================##
puts "Alchip-info : Completed script [info script]\n"
