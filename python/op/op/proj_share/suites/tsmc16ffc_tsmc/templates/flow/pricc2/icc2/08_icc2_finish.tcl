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

set blk_name                                         "{{env.BLK_NAME}}"
set blk_rpt_dir                                      "{{cur.cur_flow_rpt_dir}}"
set blk_utils_dir                                    "{{env.PROJ_UTILS}}"
set pre_flow_data_dir                                "{{pre.flow_data_dir}}/{{pre.stage}}"
set cur_design_library                               "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"
set icc2_cpu_number                                  "[lindex "${_job_cpu_number} end"]"
set_host_option -max_cores $icc2_cpu_number

set pre_design_library                               "$pre_flow_data_dir/$pre_stage.{{env.BLK_NAME}}.nlib"
set cur_design_library                               "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"

set ocv_mode                                         "{{local.ocv_mode}}" 
set optimization_flow                                "{{local.optimization_flow}}"
{%- if local.finish_active_scenario_list  is string %}
set finish_active_scenario_list                      "{{local.finish_active_scenario_list}}"
{%- elif local.finish_active_scenario_list is sequence %}
set finish_active_scenario_list                      "{{local.finish_active_scenario_list|join (' ')}}"
{%- endif %}

set finish_create_metal_fill_runset                   "{{local.finish_create_metal_fill_runset}}"
set finish_create_metal_fill_timing_driven_threshold  "{{local.finish_create_metal_fill_timing_driven_threshold}}"
set finish_drc_icv_runset                             "{{local.finish_drc_icv_runset}}"
set finish_metal_filler_gdcap_prefix                  "{{local.finish_metal_filler_gdcap_prefix}}" 
set finish_metal_filler_dcap_prefix                   "{{local.finish_metal_filler_dcap_prefix}}" 
set finish_non_metal_filler_prefix                    "{{local.finish_non_metal_filler_prefix}}"
set finish_metal_filler_gdcap_cell_list               "{{local.finish_metal_filler_gdcap_cell_list}}"
set finish_metal_filler_dcap_cell_list                "{{local.finish_metal_filler_dcap_cell_list}}"
set finish_non_metal_filler_lib_cell_list             "{{local.finish_non_metal_filler_lib_cell_list}}"
set finish_metal_fller_gdcap_rule                     "{{local.finish_metal_fller_gdcap_rule}}" 
set finish_metal_fller_dcap_rule                      "{{local.finish_metal_fller_dcap_rule}}"
set finish_non_metal_fller_rule                       "{{local.finish_non_metal_fller_rule}}"
set use_usr_metal_fill_cmd_tcl                        "{{local.use_usr_metal_fill_cmd_tcl}}"
set use_usr_filler_cell_insertion_cmd_file            "{{local.use_usr_filler_cell_insertion_cmd_file}}"
set finish_create_metal_fill                          "{{local.finish_create_metal_fill}}"
set metal_fill_insertion_select_layers                "{{local.metal_fill_insertion_select_layers}}"
set finish_use_usr_write_data_tcl                     "{{local.route_opt_use_usr_write_data_tcl}}"       
set finish_use_usr_report_tcl                         "{{local.route_opt_use_usr_write_data_tcl}}"       
set finish_write_data                                 "{{local.route_opt_write_data}}"
set finish_create_abstract                            "{{local.route_opt_create_abstract}}"
set enable_finish_reporting                           "{{local.enable_finish_reporting}}"
set finish_write_gds                                  "{{local.finish_write_gds}}"
set icc_icc2_gds_layer_mapping_file                   "{{local.icc_icc2_gds_layer_mapping_file}}"
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
## copy block and lib from previous stage-------------------------------
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
{% if local.finish_active_scenario_list != "" %} 
set_scenario_status -active false [get_scenarios -filter active]
set_scenario_status -active true $finish_active_scenario_list
{%- else %}
set_scenario_status -active true [all_scenarios]
{% endif %}  

###==================================================================##
## finish settings                                                   ##
##===================================================================##
## Reset all app options in current block------------------------------
reset_app_options -block [current_block] *

puts "Alchip-info: settings icc2_settings/icc2_common.tcl"
{% include  'icc2/icc2_settings/icc2_common.tcl' %} 

puts "Alchip-info: settings icc2_settings/icc2_finish.tcl "
{% include  'icc2/icc2_settings/icc2_finish.tcl' %} 

puts "Alchip-info: Sourcing  tsmc16ffc settings"
{% include 'icc2/tsmc16ffc_settings/tsmc16ffc_settings.tcl'%} 

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
## Pre finish  customizations                                        ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/08_finish/00_usr_pre_finish.tcl

## report route start non default app options--------------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.start.rpt {report_app_options -non_default}

###==================================================================##
## Filler cell insertion                                             ##
##===================================================================##
{#- source usr filler cell insertion command file from plugins #}
{%- if use_usr_filler_cell_insertion_cmd_file == "true" %} 
source -v {{cur.config_plugins_dir}}/icc2_scripts/08_finish/01_usr_finish_filler_cell_insertion_cmd.tcl
{%- else %}
## Metal filler (GDCAP cells)------------------------------------------
{%- if local.finish_metal_filler_gdcap_cell_list != "" %} 
	set create_stdcell_filler_gdcap_metal_cmd "create_stdcell_filler -lib_cell [list $finish_metal_filler_gdcap_cell_list]"
	{%- if local.finish_metal_filler_gdcap_prefix %}
    lappend create_stdcell_filler_gdcap_metal_cmd -prefix $finish_metal_filler_gdcap_prefix
	{%- endif %}
    {%- if local.finish_metal_fller_gdcap_rule %}
	lappend create_stdcell_filler_gdcap_metal_cmd -rule { {{local.finish_metal_fller_gdcap_rule}} } 
    {%- endif %}
    puts "Alchip-info : $create_stdcell_filler_gdcap_metal_cmd"
	eval {	eval ${create_stdcell_filler_gdcap_metal_cmd} }
	connect_pg_net -automatic
	remove_stdcell_fillers_with_violation
{%- endif %}
## Metal filler (DCAP cells)----------------------------------------------
{%- if local.finish_metal_filler_dcap_cell_list %}
	set create_stdcell_filler_dcap_metal_cmd "create_stdcell_filler -lib_cell [list $finish_metal_filler_dcap_cell_list]"
	{%- if local.finish_metal_filler_dcap_prefix %}
		lappend create_stdcell_filler_dcap_metal_cmd -prefix $finish_metal_filler_dcap_prefix
	{%- endif %}
	{%- if local.finish_metal_fller_dcap_rule %}
	lappend create_stdcell_filler_dcap_metal_cmd -rule { {{local.finish_metal_fller_dcap_rule}} }
    {%- endif %}
    puts "Alchip-info : $create_stdcell_filler_dcap_metal_cmd"
	eval {	eval ${create_stdcell_filler_dcap_metal_cmd} }
	connect_pg_net -automatic
	remove_stdcell_fillers_with_violation
{%- endif %}
## Non-metal filler ----------------------------------------------------------
{%- if local.finish_non_metal_filler_lib_cell_list %}
	set create_stdcell_filler_non_metal_cmd "create_stdcell_filler -lib_cell [list $finish_non_metal_filler_lib_cell_list]"
	{%- if local.chip_finish_non_metal_filler_prefix %}
		lappend create_stdcell_filler_non_metal_cmd -prefix $finish_non_metal_filler_prefix
	{%- endif %}
	{%- if local.finish_non_metal_fller_rule %}
	lappend create_stdcell_filler_non_metal_cmd -rule { {{local.finish_non_metal_fller_rule}} }
    {%- endif %}
    puts "Alchip-info : $create_stdcell_filler_non_metal_cmd"
	eval {	eval ${create_stdcell_filler_non_metal_cmd} }
	connect_pg_net -automatic
{%- endif %}

# To remove filler cells in the design :
# remove_cells [get your_filler_cells]
{%- endif %}
###==================================================================##
## Metal fill creation                                               ##
##===================================================================##
{#- source usr metal fill insertion command file from plugins #}
{%- if use_usr_metal_fill_cmd_tcl == "true" %} 
source -v {{cur.config_plugins_dir}}/icc2_scripts/08_finish/02_usr_finish_metal_fill_cmd.tcl
{%- else %}
{%- if local.finish_create_metal_fill == "true" %}
	set create_metal_fill_cmd "signoff_create_metal_fill"
	{%- if local.metal_fill_insertion_select_layers %}
	lappend create_metal_fill_cmd -select_layers { {{local.metal_fill_insertion_select_layers}} }
    {%- endif %}
## Metal fill creation with timing-driven------------------------------
	{%- if local.finish_create_metal_fill_timing_driven_threshold %}
	lappend create_metal_fill_cmd -timing_preserve_setup_slack_threshold {{local.finish_create_metal_fill_timing_driven_threshold}}
	{%- endif %}
	puts "Alchip-info: Running $create_metal_fill_cmd"
	eval $create_metal_fill_cmd
    puts "Alchip-info: save block after metal fill insertion with ICV"
	save_block -as dummy_done 

	set_extraction_options -real_metalfill_extraction floating
{%- endif %}
{%- endif %}

## post finish customizations----------------------------------------------
source -v {{cur.config_plugins_dir}}/icc2_scripts/08_finish/00_usr_post_finish.tcl

## Connect pg net------------------------------------------------------

{%- if local.use_usr_common_scripts_connect_pg_net_tcl == "true" %}
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/connect_pg_net.tcl
{%- else %}
puts "Alchip-info: Running connect_pg_net command"
connect_pg_net -automatic
{%- endif %}

## save design---------------------------------------------------------------
save_block
save_block -as {{env.BLK_NAME}}

###==================================================================##
##  output data                                                      ##
##===================================================================##
## Write SPEF
{%- if local.write_spef_by_tool  == "true" %}
{% include 'icc2/icc2_write_spef.tcl' %}
{%- endif %}

{%- if local.finish_use_usr_write_data_tcl == "true" %}
source -v {{cur.config_plugins_dir}}/icc2_scripts/08_finish/08_usr_write_data.tcl
{%- else %}
{%- if local.finish_write_data == "true" %} 
# write_verilog (no pg, and no physical only cells)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all {{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.ori.v
## write_verilog for LVS (with pg, and with physical only cells)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations empty_modules} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lvs.v
## write_verilog for Formality (with pg, no physical only cells, and no supply statements)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells supply_statements} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.fm.v
## write_verilog for PT (no pg, no physical only cells but with diodes and DCAP for leakage power analysis)
{%- if local.finish_metal_filler_gdcap_cell_list or local.finish_metal_filler_dcap_cell_list %}
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all -force_reference { {{local.finish_metal_filler_gdcap_cell_list}} {{local.finish_metal_filler_dcap_cell_list}}  } {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.pt.v 
{%- else %}
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.pt.v
{%- endif %}

{%- if local.write_def_convert_icc2_site_to_lef_site_name_list != "" %} 
write_def -include_tech_via_definitions -convert_sites { $write_def_convert_icc2_site_to_lef_site_name_list } -compress gzip {{cur.cur_flow_data_dir}}/.${cur_stage}{{env.BLK_NAME}}.def
{%- else %}
write_def -include_tech_via_definitions -compress gzip {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.def
{%- endif %}
{%- endif %}

{%- if local.finish_write_gds == "true" %}
write_gds -compress -fill include -hierarchy top -keep_data_type -layer_map $icc_icc2_gds_layer_mapping_file -output_pin all   -long_names -layer_map_format icc2 {{cur.cur_flow_data_dir}}/$cur_stage.$blk_name.gds
{%- endif %}
{%- endif %}

## report route opt end non default app options ---------------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.end.rpt {report_app_options -non_default}

## generate early touch file-----------------------------------------------
exec touch {{cur.cur_flow_sum_dir}}/${cur_stage}.{{env.BLK_NAME}}.early_complete

## create abstract----------------------------------------------------------
{%- if local.finish_create_abstract == "true" %}
open_block {{env.BLK_NAME}} 
create_abstract
create_frame
save_lib
{%- endif %}

## Report--------------------------------------------------------------------
{%- if local.finish_use_usr_report_tcl == "true" %}
source -v {{cur.config_plugins_dir}}/icc2_scripts/08_finish/09_usr_finish_report.tcl
{%- else %}
set REPORT_QOR_SCRIPT {{env.PROJ_UTILS}}/icc2_utils/report_qor.tcl
{%- if local.enable_finish_reporting == "true" %} 
puts "Alchip-info: Sourcing [which $REPORT_QOR_SCRIPT]"
source -v -e $REPORT_QOR_SCRIPT
{%- endif %}
{%- endif %}
source -v -e {{env.PROJ_UTILS}}/icc2_utils/snapshot.tcl

###==================================================================##
## exit icc2                                                         ##
##===================================================================##
puts "Alchip-info : Completed script [info script]\n"



