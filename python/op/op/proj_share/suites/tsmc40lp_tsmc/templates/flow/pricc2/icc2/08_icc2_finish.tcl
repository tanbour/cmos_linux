##########################################################################################
# Tool: IC Compiler II
##########################################################################################
puts "Alchip-info : Running script [info script]\n"
set sh_continue_on_error true

##===================================================================##
## SETUP                                                             ##
##===================================================================##
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/icc2_procs.tcl
source {{cur.flow_liblist_dir}}/liblist/liblist.tcl
source {{cur.cur_flow_sum_dir}}/{{cur.sub_stage}}.op._job.tcl

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

set ocv_mode                                            "{{local.ocv_mode}}" 
set design_style                                        "{{local.design_style}}"
set lib_cell_height                                      "{{local.lib_cell_height}}"
{%- if local.finish_active_scenario_list is string %}
set  finish_active_scenario_list                        "{{local.finish_active_scenario_list}}"
{%- elif local.finish_active_scenario_list is sequence %}
set finish_active_scenario_list                         "{{local.finish_active_scenario_list|join (' ')}}"
{%- endif %}

set finish_create_metal_fill_runset                     "{{local.finish_create_metal_fill_runset}}"
set use_usr_metal_fill_cmd_tcl                          "{{local.use_usr_metal_fill_cmd_tcl}}"
set use_usr_filler_cell_insertion_cmd_file              "{{local.use_usr_filler_cell_insertion_cmd_file}}"
set finish_create_metal_fill                            "{{local.finish_create_metal_fill}}"
set metal_fill_insertion_select_layers                  "{{local.metal_fill_insertion_select_layers}}"
set finish_use_usr_write_data_tcl                       "{{local.finish_use_usr_write_data_tcl}}"       
set finish_use_usr_report_tcl                           "{{local.finish_use_usr_write_data_tcl}}"       
set finish_write_data                                   "{{local.finish_write_data}}"
set finish_create_abstract                              "{{local.finish_create_abstract}}"
set enable_finish_reporting                             "{{local.enable_finish_reporting}}"
set finish_write_gds                                    "{{local.finish_write_gds}}"
set icc_icc2_gds_layer_mapping_file                     "{{local.icc_icc2_gds_layer_mapping_file}}"
set use_usr_common_scripts_connect_pg_net_tcl           "{{local.use_usr_common_scripts_connect_pg_net_tcl}}"
set write_def_convert_icc2_site_to_lef_site_name_list   "{{local.write_def_convert_icc2_site_to_lef_site_name_list}}"
set icc_icc2_gds_layer_mapping_file                     "${ICC_ICC2_GDS_LAYER_MAPPING_FILE}"

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
## Pre finish  customizations                                        ##
##===================================================================##
source {{cur.config_plugins_dir}}/icc2_scripts/08_finish/00_usr_pre_finish.tcl

## report route start non default app options--------------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.start.rpt {report_app_options -non_default}

{%- if local.design_style == "top" %}
set_timing_paths_disabled_blocks  -all_sub_blocks
{%- endif %}

###==================================================================##
## Filler cell insertion                                             ##
##===================================================================##
{#- source usr filler cell insertion command file from plugins #}
{%- if local.use_usr_filler_cell_insertion_cmd_file == "true" %} 
source -v {{cur.config_plugins_dir}}/icc2_scripts/08_finish/01_usr_finish_filler_cell_insertion_cmd.tcl
{%- else %}
remove_placement_blockages -all
add_GDCAP
add_DCAP
add_Fillers
# To remove filler cells in the design :
# remove_fillers 
connect_pg_net -net VDD [get_pins -phy */VDD]
#connect_pg_net -net VDD [get_pins -phy */VPP]
connect_pg_net -net VSS [get_pins -phy */VSS]
#connect_pg_net -net VSS [get_pins -phy */VBB]
{%- endif %}

puts "Alchip-info: save block after fillers insertion"
save_block

###==================================================================##
## Metal fill creation                                               ##
##===================================================================##
{%- if local.use_usr_metal_fill_cmd_tcl == "true" %} 
# source usr metal fill insertion command file from plugins-------------
source -v {{cur.config_plugins_dir}}/icc2_scripts/08_finish/02_usr_finish_metal_fill_cmd.tcl
{%- else %}
{%- if local.finish_create_metal_fill == "true" %}
## remove_metal_extensions_cut_metals
remove_routing_guides -all -force
remove_routing_blockages -all -force

set_app_options -name signoff.create_metal_fill.runset -value "$finish_create_metal_fill_runset"
set_app_options -name signoff.physical.layer_map_file  -value "$icc_icc2_gds_layer_mapping_file"
set_app_options -name signoff.create_metal_fill.flat -value true ;# default false
set_app_options -name signoff.create_metal_fill.user_defined_options -value "-dp8 -turbo -D USE_ICC2"

signoff_create_metal_fill -select_layers { {{local.metal_fill_insertion_select_layers}} } 

save_block -as dummy_done 

{%- endif %}
{%- endif %}

## post finish customizations----------------------------------------------
source -v {{cur.config_plugins_dir}}/icc2_scripts/08_finish/00_usr_post_finish.tcl

## Connect pg net------------------------------------------------------

{%- if local.use_usr_common_scripts_connect_pg_net_tcl == "true" %}
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/connect_pg_net.tcl
{%- else %}
puts "Alchip-info: Running connect_pg_net command"
connect_pg_net
{%- endif %}

## save design---------------------------------------------------------------
save_block
save_block -as {{env.BLK_NAME}}

###==================================================================##
##  output data                                                      ##
##===================================================================##
{%- if local.finish_use_usr_write_data_tcl == "true" %}
source -v {{cur.config_plugins_dir}}/icc2_scripts/08_finish/08_usr_write_data.tcl
{%- else %}
{%- if local.finish_write_data == "true" %} 
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

{%- if local.finish_write_gds == "true" %}
set_app_options -name  file.gds.contact_prefix -value ${blk_name}_via_
create_cut_metals
write_gds \
          -compress \
          -long_names \
          -unit 2000 \
          -fill include \
          -hierarchy design_lib \
          -keep_data_type \
          -output_pin all \
          -layer_map $icc_icc2_gds_layer_mapping_file \
          -lib_cell_view frame \
          -connect_below_cut_metal \
          -write_default_layers {VIA1 VIA2} \
          -layer_map_format icc_extended \
           {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.gds

write_gds -compress -fill include -hierarchy top -keep_data_type -layer_map $icc_icc2_gds_layer_mapping_file -output_pin all   -long_names -layer_map_format icc2 {{cur.cur_flow_data_dir}}/$cur_stage.$blk_name.gds
{%- endif %}
{%- endif %}
{%- endif %}

## report route opt end non default app options ---------------------------
redirect -tee -file $blk_rpt_dir/$cur_stage.app_options.end.rpt {report_app_options -non_default}

## generate early touch file-----------------------------------------------
exec touch {{cur.cur_flow_sum_dir}}/${cur_stage}.{{env.BLK_NAME}}.early_complete

## create abstract----------------------------------------------------------
{%- if local.finish_create_abstract == "true" %}
open_block {{env.BLK_NAME}} 
create_abstract -read_only
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



