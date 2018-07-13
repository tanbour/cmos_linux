######################################################################
## Tool: IC Compiler II
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
{%- if local.place_opt_active_scenario_list is string %}
set place_opt_active_scenario_list                    "{{local.place_opt_active_scenario_list}}"
{%- elif local.place_opt_active_scenario_list is sequence %}
set place_opt_active_scenario_list                    "{{local.place_opt_active_scenario_list|join (' ')}}"
{%- endif %}

{%- if local.switch_activity_file %}
set switch_activity_file                              "{{local.switch_activity_file}}" 
set switch_activity_file_power_scenario               "{{local.switch_activity_file_power_scenario}}" 
set enable_place_reporting                            "{{local.enable_place_reporting}}"
{%- endif %}

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
open_lib ${cur_design_library}
current_block {{env.BLK_NAME}}/${cur_stage}

link_block
save_lib

###==================================================================##
## Timing constraints                                                ##
##===================================================================##
{% if local.place_opt_active_scenario_list != "" %} 
set_scenario_status -active false [get_scenarios -filter active]
set_scenario_status -active true $place_opt_active_scenario_list
{%- else %}
set_scenario_status -active true [all_scenarios]
{% endif %}  

###==================================================================##
##  Additional timer related setups :prects uncertainty              ##
##===================================================================##
{%- if local.setup_uncertainty %}
set_clock_uncertainty {{local.setup_uncertainty}} -setup [all_clocks ] -scenarios [all_scenarios ]
{%-  endif %}
{%- if local.hold_uncertainty %}
set_clock_uncertainty {{local.hold_uncertainty}} -hold  [all_clocks ] -scenarios [all_scenarios ]
{%-  endif %}


{%- if local.data_transition %}
set_max_transition -data_path {{local.data_transition}} [all_clocks] -scenarios [all_scenarios]
{%- else %}
set_max_transition -data_path 0.25 [all_clocks] -scenarios [all_scenarios]
{%- endif %}
{%- if local.clock_transition %}
set_max_transition -clock_path {{local.clock_transition}} [all_clocks] -scenarios [all_scenarios]
{%- else %}
set_max_transition -clock_path 0.15 [all_clocks] -scenarios [all_scenarios]
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

puts "Alchip-info: Sourcing  tsmc16ffpgl settings"
{% include 'icc2/tsmc16ffpgl_settings/tsmc16ffpgl_settings.tcl'%} 

puts "Alchip-info: Sourcing  set_lib_cell_purpose.tcl"
source -e -v "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/set_lib_cell_purpose.tcl"

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
##  read_saif                                                        ##
##===================================================================##
{%- if local.switch_activity_file %}
	if {$switch_activity_file_power_scenario != ""} {
		set read_saif_cmd "read_saif $switch_activity_file -scenarios $switch_activity_file_power_scenario"
	} else {
		set read_saif_cmd "read_saif $switch_activity_file"
	}
   	if {$switch_activity_file_source_instance != ""} {lappend read_saif_cmd -strip_path $switch_activity_file_source_instance}
	if {$switch_activity_file_target_instance != ""} {lappend read_saif_cmd -path $switch_activity_file_target_instance}
	puts "Alchip-info : $read_saif_cmd"
	eval $read_saif_cmd
{%- endif %}

###==================================================================##
## Pre-place_opt customizations                                      ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/02_place/00_usr_pre_place.tcl

# report place_opt start non default app options-----------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.start.rpt {report_app_options -non_default}

###==================================================================##
## place_opt run command                                             ##
##===================================================================##
{#- source usr place_opt command file from plugins #}
{%- if local.use_usr_place_opt_cmd_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/02_place/01_usr_place_opt_cmd.tcl
save_block
{%- else %}
{#- OPTIMIZATION_FLOW: ttr  : runs two pass place_opt #}
{%- if  local.optimization_flow == "ttr"  %}
## OPTIMIZATION_FLOW: ttr: runs single place_opt-----------------------

{%- if local.use_spg_flow == "true" %}
set_app_options -name place_opt.flow.do_spg -value true
{%- endif %}
place_opt
{%- endif %}
{# OPTIMIZATION_FLOW: qor  : runs two pass place_opt #}
{%- if  local.optimization_flow == "qor"  %}
## OPTIMIZATION_FLOW: qor  : runs two pass place_opt------------------

puts "Alchip-info: Running place_opt -to initial_drc"
place_opt -to initial_drc
puts "Alchip-info: Running update_timing -full"
update_timing -full

puts "Alchip-info: save block for place_opt -to initial_drc"
save_block 

{%- if local.place_opt_optimize_icgs == "true" %} 
set_app_option -name place_opt.flow.optimize_icgs -value true ;# default false
{% if local.place_opt_optimize_icgs_critical_range != "" %} 
set_app_options -name place_opt.flow.optimize_icgs_critical_range -value $place_opt_optimize_icgs_critical_range ;# default 0.75
{%- endif %}
{%- endif %}

puts "Alchip-info: Running create_placement -use_seed_locs -timing_driven -congestion"
create_placement -use_seed_locs -timing_driven -congestion

puts "Alchip-info: save block for create_placement -use_seed_locs -timing_driven -congestion"
save_block 

puts "Alchip-info: Running place_opt -from initial_drc -to initial_opto"
place_opt -from initial_drc -to initial_opto

puts "Alchip-info: save block for place_opt -from initial_drc -to initial_opto"
save_block

puts "Alchip-info: save block for place_opt -from initial_drc -to initial_opto"

{%- if local.place_opt_multibit_banking == "true" %} 
	puts "Alchip-info: Running identify_multibit -register -no_dft_opt -apply"
	identify_multibit -register -no_dft_opt -apply
{%- endif %}

puts "Alchip-info: Running place_opt -from final_place"
place_opt -from final_place

puts "Alchip-info: save block for place_opt -from final_place"
save_block

{%- if local.place_opt_multibit_debanking == "true" %} 
puts "Alchip-info: Running split_multibit -slack_threshold 0"
split_multibit -slack_threshold 0
{%- endif %}
{%- endif %}
{# OPTIMIZATION_FLOW: hplp  : runs two pass place_opt #}
{%- if local.optimization_flow == "hplp" %} 
## OPTIMIZATION_FLOW:  hplp  : runs two pass place_opt-----------------

puts "Alchip-info: Running place_opt -to initial_drc"
place_opt -to initial_drc
puts "Alchip-info: Running update_timing -full"
update_timing -full

puts "Alchip-info: save block for place_opt -to initial_drc"
save_block 

{%- if local.place_opt_optimize_icgs == "true" %} 
set_app_option -name place_opt.flow.optimize_icgs -value true ;# default false
{%- if local.place_opt_optimize_icgs_critical_range != "" %} 
set_app_options -name place_opt.flow.optimize_icgs_critical_range -value $place_opt_optimize_icgs_critical_range ;# default 0.75
{%- endif %}
{%- endif %}

puts "Alchip-info: Running create_placement -use_seed_locs -timing_driven -effort high"
create_placement -use_seed_locs -timing_driven -effort high

puts "Alchip-info: save block for create_placement -use_seed_locs -timing_driven -effort high"
save_block

puts "Alchip-info: Running place_opt -from initial_drc -to initial_opto"
place_opt -from initial_drc -to initial_opto

puts "Alchip-info: save block for place_opt -from initial_drc -to initial_opto"
save_block

{% if local.place_opt_multibit_banking == "true" %} 
	puts "Alchip-info: Running identify_multibit -register -no_dft_opt -apply"
	identify_multibit -register -no_dft_opt -apply
{% endif %}

puts "Alchip-info: Running place_opt -from final_place"
place_opt -from final_place

puts "Alchip-info: save block for place_opt -from final_place"
save_block

{% if local.place_opt_multibit_debanking == "true" %} 
	puts "Alchip-info: Running split_multibit -slack_threshold 0"
	split_multibit -slack_threshold 0
{%- endif %}
{%- endif %}
{# OPTIMIZATION_FLOW: arlp  : runs two pass place_opt #}
{%- if local.optimization_flow == "arlp" %} 
## OPTIMIZATION_FLOW: arlp  : runs two pass place_opt------------------

puts "Alchip-info: Running place_opt -to initial_drc"
place_opt -to initial_drc
puts "Alchip-info: Running update_timing -full"
update_timing -full

puts "Alchip-info: save block for place_opt -to initial_drc"
save_block 

{%- if local.place_opt_optimize_icgs == "true" %} 
set_app_option -name place_opt.flow.optimize_icgs -value true ;# default false
{%- if local.place_opt_optimize_icgs_critical_range != "" %} 
set_app_options -name place_opt.flow.optimize_icgs_critical_range -value $place_opt_optimize_icgs_critical_range ;# default 0.75
{%- endif %}
{%- endif %}
puts "Alchip-info: Running create_placement -use_seed_locs -timing_driven -congestion"
create_placement -use_seed_locs -timing_driven -congestion

puts "Alchip-info: save block for create_placement -use_seed_locs -timing_driven -congestion"
save_block 

puts "Alchip-info: Running place_opt -from initial_drc -to initial_opto"
place_opt -from initial_drc -to initial_opto

puts "Alchip-info: save block for place_opt -from initial_drc -to initial_opto"
save_block

{%- if local.place_opt_multibit_banking == "true" %} 
	puts "Alchip-info: Running identify_multibit -register -no_dft_opt -apply"
	identify_multibit -register -no_dft_opt -apply
{%- endif %}

puts "Alchip-info: Running place_opt -from final_place"
place_opt -from final_place

puts "Alchip-info: save block for place_opt -from final_place"
save_block 

{%- if local.place_opt_multibit_debanking == "true" %} 
	puts "Alchip-info: Running split_multibit -slack_threshold 0"
	split_multibit -slack_threshold 0
{%- endif %}
{%- endif %}
{# OPTIMIZATION_FLOW: hc  : runs two pass place_opt #}
{%- if local.optimization_flow == "hc" %} 
## OPTIMIZATION_FLOW: hc : runs two pass place_opt---------------------

#  CDR: The following is WITH congestion-driven restructuring (CDR) enabled.
#  SPG: For designs starting with SPG input, since seed placement comes from SPG,
#       initial placement of CDR is skipped by enabling place_opt.flow.do_spg during CDR.
{%- if local.place_opt_spg_flow == "false" %} 
puts "RM-info: Running place_opt -to initial_drc"
place_opt -to initial_drc
puts "RM-info: Running update_timing -full"
update_timing -full

puts "Alchip-info: save block for place_opt -to initial_drc"
save_block

{%- else %}
puts "RM-info: For designs starting with SPG input, since seed placement comes from SPG, initial placement of CDR is skipped by setting place_opt.flow.do_spg to true for CDR."
puts "RM-info: set_app_options -name place_opt.flow.do_spg -value true" 
set_app_options -name place_opt.flow.do_spg -value true
puts "RM-info: Running create_placement -congestion_driven_restructuring" 
create_placement -congestion_driven_restructuring
puts "RM-info: set_app_options -name place_opt.flow.do_spg -value false" 
set_app_options -name place_opt.flow.do_spg -value false
puts "RM-info: Running place_opt -from initial_drc -to initial_drc"
place_opt -from initial_drc -to initial_drc	
puts "RM-info: Running update_timing -full"
update_timing -full
puts "Alchip-info: save block for place_opt -to initial_drc"
save_block

{%- endif %}

{%- if local.place_opt_optimize_icgs == "true" %} 
set_app_option -name place_opt.flow.optimize_icgs -value true ;# default false
{%- if local.place_opt_optimize_icgs_critical_range != "" %} 
set_app_options -name place_opt.flow.optimize_icgs_critical_range -value $place_opt_optimize_icgs_critical_range ;# default 0.75
{%- endif %}        
{%- endif %}
puts "Alchip-info: Running create_placement -use_seed_locs -timing_driven -congestion -congestion_effort high -effort high"
create_placement -use_seed_locs -timing_driven -congestion -congestion_effort high -effort high
puts "Alchip-info: Running place_opt -from initial_drc -to initial_opto"
place_opt -from initial_drc -to initial_opto

{%- if local.place_opt_multibit_banking ==  "true" %} 
puts "Alchip-info: Running identify_multibit -register -no_dft_opt -apply"
identify_multibit -register -no_dft_opt -apply
{%- endif %}

puts "Alchip-info: Running place_opt -from final_place"
place_opt -from final_place

{%- if local.place_opt_multibit_debanking == "true" %} 
puts "Alchip-info: Running split_multibit -slack_threshold 0"
split_multibit -slack_threshold 0
{%- endif %}
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
{%- if local.place_opt_refine_opt == "true" %} 
puts "Alchip-info: Running refine_opt command"
refine_opt
puts "Alchip-info: save block for refine_opt"
save_block 
{%- endif %}
{%- if local.refine_opt_enable_exclusive_power_opt == "true" %}
set_app_options -name refine_opt.flow.exclusive -value power
refine_opt
puts "Alchip-info: save block for refine_opt power optimization"
save_block 
{%- endif %}
{%- if local.refine_opt_enable_exclusive_area_opt == "true" %}
set_app_options -name refine_opt.flow.exclusive -value area
refine_opt
puts "Alchip-info: save block for refine_opt area optimization"
save_block 
{%- endif %}
{%- endif %}
source {{cur.config_plugins_dir}}/icc2_scripts/02_place/02_usr_post_refine_opt.tcl

## Connect pg net------------------------------------------------------

{%- if local.use_usr_common_scripts_connect_pg_net_tcl == "true" %}
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/connect_pg_net.tcl
{%- else %}
puts "Alchip-info: Running connect_pg_net command"
connect_pg_net -automatic
{%- endif %}

## save design---------------------------------------------------------
save_block
save_block -as {{env.BLK_NAME}}

###==================================================================##
##  output data                                                      ##
##===================================================================##
## Write SPEF
{%- if local.write_spef_by_tool  == "true" %}
{% include 'icc2/icc2_write_spef.tcl' %}
{%- endif %}

{%- if local.place_use_usr_write_data_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/02_place/08_usr_write_data.tcl
{%- else %}
{%- if local.place_write_data == "true" %} 
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

## report place_opt end non default app options-----------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.end.rpt {report_app_options -non_default}

## generate early touch file-------------------------------------------
exec touch {{cur.cur_flow_sum_dir}}/${cur_stage}.{{env.BLK_NAME}}.early_complete

## create abstract-----------------------------------------------------
{%- if local.place_create_abstract == "true" %}
open_block  {{env.BLK_NAME}} 
create_abstract
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
