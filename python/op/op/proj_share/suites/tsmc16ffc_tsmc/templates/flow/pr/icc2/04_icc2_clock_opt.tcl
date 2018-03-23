##########################################################################################
# Tool: IC Compiler II
##########################################################################################
puts "Alchip-info : Running script [info script]\n"

##===================================================================##
## SETUP                                                             ##
##===================================================================##

source {{cur.flow_scripts_dir}}/pr/00_setup.tcl
source {{cur.flow_liblist_dir}}/liblist/liblist.tcl

set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

set blk_name          "{{env.BLK_NAME}}"
set blk_rpt_dir       "{{cur.cur_flow_rpt_dir}}"
set blk_utils_dir     "{{env.PROJ_UTILS}}"
set pre_flow_data_dir "{{pre.flow_data_dir}}/{{pre.stage}}"
set cur_design_library "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"
set icc2_cpu_number   "[lindex "{{local._job_cpu_number}}" end]"
set_host_option -max_cores $icc2_cpu_number

set pre_design_library  "$pre_flow_data_dir/$pre_stage.{{env.BLK_NAME}}.nlib"
set cur_design_library "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"

set ocv_mode          "{{local.ocv_mode}}" 
set optimization_flow "{{local.optimization_flow}}"
set clock_opt_active_scenario_list "{{local.clock_opt_active_scenario_list}}"
set CLOCK_OPT_ENABLE_CCD "{{local.clock_enable_ccd}}"
set CLOCK_OPT_OPTO_NAME_PREFIX "{{local.clock_opt_opto_name_prefix}}"
set CLOCK_OPT_OPTO_CTO  "{{local.clock_opt_opto_cto}}"
set CLOCK_OPT_OPTO_CTO_NAME_PREFIX "{{local.clock_opt_opto_cto_name_prefix}}"
set clock_opt_use_usr_write_data_tcl "{{local.clock_opt_use_usr_write_data_tcl}}"
set clock_opt_create_abstract "{{local.clock_opt_create_abstract}}"
set clock_opt_write_data "{{local.clock_opt_write_data}}"
set enable_clock_opt_reporting "{{local.enable_clock_opt_reporting}}"
set use_usr_common_scripts_connect_pg_net_tcl "{{local.use_usr_common_scripts_connect_pg_net_tcl}}"
set write_def_convert_icc2_site_to_lef_site_name_list "{{local.write_def_convert_icc2_site_to_lef_site_name_list}}"
set icc_icc2_gds_layer_mapping_file "{{local.icc_icc2_gds_layer_mapping_file}}"
{%- if local.tcl_placement_spacing_label_rule_file %}
set TCL_PLACEMENT_SPACING_LABEL_RULE_FILE "{{local.tcl_placement_spacing_label_rule_file}}"
{%- else %}
set TCL_PLACEMENT_SPACING_LABEL_RULE_FILE "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/placement_spacing_rule.tcl"
{%- endif %}
{%- if local.tcl_icc2_cts_ndr_rule_file %}
set TCL_ICC2_CTS_NDR_RULE_FILE  "{{local.tcl_icc2_cts_ndr_rule_file}}"
{%- else %}
set TCL_ICC2_CTS_NDR_RULE_FILE  "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/icc2_cts_ndr_rule.tcl"
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
## Timing constraints                                                ##
##===================================================================##
{% if local.clock_opt_active_scenario_list != "" %} 
set_scenario_status -active false [get_scenarios -filter active]
set_scenario_status -active true $clock_opt_active_scenario_list
{%- else %}
set_scenario_status -active true [all_scenarios]
{% endif %}  

###==================================================================##
## Additional timer related setups :cts uncertainty                  ##
##===================================================================##

###==================================================================##
## clock settings                                                    ##
##===================================================================##
## Reset all app options in current block------------------------------
reset_app_options -block [current_block] *

puts "Alchip-info: settings icc2_settings/icc2_common.tcl"
{% include  'icc2/icc2_settings/icc2_common.tcl' %} 

puts "Alchip-info: settings icc2_settings/icc2_clock_opt.tcl "
{% include  'icc2/icc2_settings/icc2_clock_opt.tcl' %} 

puts "Alchip-info: Sourcing  tsmc16ffc settings"
{% include 'icc2/tsmc16ffc_settings/tsmc16ffc_settings.tcl'%} 

puts "Alchip-info: Sourcing  set_lib_cell_purpose.tcl"
source -e -v "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/set_lib_cell_purpose.tcl"

## clock opt cts name prefix---------------------------------------------
if {$CLOCK_OPT_OPTO_NAME_PREFIX != ""} {
	set_app_options -name opt.common.user_instance_name_prefix -value $CLOCK_OPT_OPTO_NAME_PREFIX
	if {[get_app_option_value -name clock_opt.flow.enable_ccd]} {
		# If CCD is enabled, set both opt and cts user prefix as CCD can work on both clock and data paths
		set_app_options -name cts.common.user_instance_name_prefix -value ${CLOCK_OPT_OPTO_NAME_PREFIX}cts
	}
}

###==================================================================##
##  Enable AOCV or POCV                                              ##
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
## Pre clock_opt  customizations                                     ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/04_clock_opt/00_usr_pre_clock_opt.tcl

## report clock_opt start non default app options----------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.start.rpt {report_app_options -non_default}

###==================================================================##
## clock opt run command                                             ##
##===================================================================##
{#- source usr post clock tree optimization command file from plugins #}
{%- if local.use_usr_clock_opt_cmd_tcl == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/04_clock_opt/01_usr_clock_opt_cmd.tcl
save_block
{%- else %}
puts "Alchip-info: Running clock_opt -from final_opto command"
clock_opt -from final_opto
{%- endif %}

###==================================================================##
## post clock customizations                                         ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/04_clock_opt/00_usr_post_clock_opt.tcl

###==================================================================##
## Clock routing	                                                 ##
##===================================================================##
route_group -all_clock_nets

###==================================================================##
## Post-route clock tree optimization for non-CCD flow               ##
##===================================================================##
if {$CLOCK_OPT_OPTO_CTO && ![get_app_option_value -name clock_opt.flow.enable_ccd]} {
	if {$CLOCK_OPT_OPTO_CTO_NAME_PREFIX != ""} {
		set_app_options -name cts.common.user_instance_name_prefix -value ${CLOCK_OPT_OPTO_CTO_NAME_PREFIX}
	} 
synthesize_clock_trees -postroute -routed_clock_stage detail
}

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
write_verilog -compress gzip -exclude {leaf_module_declarations pg_objects} -hierarchy all {{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.v

write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations empty_modules} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.pg.v

{% if local.write_def_convert_icc2_site_to_lef_site_name_list != "" %} 
write_def -include_tech_via_definitions -convert_sites { $write_def_convert_icc2_site_to_lef_site_name_list } -compress gzip {{cur.cur_flow_data_dir}}/.${cur_stage}{{env.BLK_NAME}}.def
{%- else %}
write_def -include_tech_via_definitions -compress gzip {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.def
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
create_abstract
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

