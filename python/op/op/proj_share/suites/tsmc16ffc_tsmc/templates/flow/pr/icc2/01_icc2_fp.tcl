######################################################################
# Tool: IC Compiler II
######################################################################
puts "Alchip-info : Running script [info script]\n"
set sh_continue_on_error true

##===================================================================##
## SETUP                                                             ##
##===================================================================##
set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]
set pre_flow_data_dir "{{pre.flow_data_dir}}/{{pre.stage}}"

source {{cur.flow_liblist_dir}}/liblist/liblist.tcl
source {{cur.cur_flow_sum_dir}}/{{cur.sub_stage}}.op._job.tcl

set blk_name          "{{env.BLK_NAME}}"
set blk_sdc_dir       "{{env.BLK_SDC}}/{{ver.sdc}}"
set blk_rpt_dir       "{{cur.cur_flow_rpt_dir}}"
set blk_utils_dir     "{{env.PROJ_UTILS}}"
set cur_design_library "{{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib"
set icc2_cpu_number   "[lindex "${_job_cpu_number}" end]"
set ocv_mode          "{{local.ocv_mode}}" 

set def_convert_site_list "{{local.def_convert_site_list}}"
set enable_fp_reporting "{{local.enable_fp_reporting}}"
set use_usr_common_scripts_connect_pg_net_tcl "{{local.use_usr_common_scripts_connect_pg_net_tcl}}"
{%- if local.tcl_mv_setup_file %}
set tcl_mv_setup_file  "{{local.tcl_mv_setup_file}}"
{%- else %}
set tcl_mv_setup_file  "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/mv_setup.tcl"
{%- endif %}
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
set ndm_tech          "[glob {{liblist.NDM_TECH}}]" 
set ndm_std           "[glob {{liblist.NDM_STD}}]"
{%- if liblist.NDM_MEM %} 
set ndm_mem           "[glob {{liblist.NDM_MEM}}]"
set reference_library "$ndm_tech $ndm_std $ndm_mem"
{%- elif liblist.NDM_IP %}
set ndm_ip            "[glob {{liblist.NDM_IP}}]"
set reference_library "$ndm_tech $ndm_std $ndm_ip"
{%- elif liblist.NDM_IP and liblist.NDM_MEM %}
set ndm_mem           "[glob {{liblist.NDM_MEM}}]"
set ndm_ip            "[glob {{liblist.NDM_IP}}]"
set reference_library "$ndm_tech $ndm_std $ndm_mem $ndm_ip"
{%- else %}
set reference_library "$ndm_tech $ndm_std"
{%- endif %}

{% include 'icc2/00_icc2_setup.tcl' %}

set_host_option -max_cores $icc2_cpu_number

##===================================================================##
##  Design creation                                                  ##
##===================================================================##

## backup previous database---------------------------------------------
set bak_date [exec date +%m%d]
if {[file exist ${cur_design_library}] } {
if {[file exist  ${cur_design_library}_bak_${bak_date}] } {
exec rm -rf ${cur_design_library}_bak_${bak_date}
}
puts "Alchip-info: The specified ICC2 ndm database is already existing. It will be renamed first."
exec mv -f ${cur_design_library} ${cur_design_library}_bak_${bak_date}
}

## create lib-----------------------------------------------------------
source {{cur.config_plugins_dir}}/icc2_scripts/01_fp/00_usr_pre_create_lib.tcl

create_lib \
    -use_technology_lib {{liblist.NDM_TECH}} \
    -ref_libs $reference_library \
    $cur_design_library

open_lib $cur_design_library

source {{cur.config_plugins_dir}}/icc2_scripts/01_fp/00_usr_post_create_lib.tcl

{%- if local.use_spg_flow == "false" %}
puts "Alchip-info: reading verilog ...... "
read_verilog -top {{env.BLK_NAME}}  $blk_netlist_list
current_block {{env.BLK_NAME}}
link_block

{%- if local.uniquify_netlist == "true" %} 
  uniquify > {{cur.cur_flow_log_dir}}/${cur_stage}.uniquify.log
{%- endif %}

save_lib
{%- elif  local.use_spg_flow == "true" %}
puts "Alchip-info: reading $dc_output_icc2_script for spg_flow ...... "
source  "$dc_output_icc2_script"
{%- endif %}

## load and commit UPF file----------------------------------------------
{%- if local.use_upf == "true" %}
puts "Alchip-info: use_upf is true, block upf will been load"
		load_upf $low_power_file
		commit_upf
		associate_mv_cells -all
{%- else %}
puts "Alchip-info: use_upf is false, block upf will not been load"
{%- endif %}

###==================================================================##
## source mcmm file setup timing constrains                          ##
##===================================================================##
{% include  'icc2/mcmm.tcl' %}

## set io false path---------------------------------------------------
{% if local.fix_io_hold == "false" %}
foreach scenario [get_object_name [get_scenarios -filter "active == true"]] {
puts "Alchip-info : set IO hold false path to scenario $scenario "

current_scenario $scenario
set_false_path -hold -from [all_inputs] 
set_false_path -hold -to [all_outputs]
}
{% else %}
puts "Alchip-info : IO hold is not set be false path to scenario  "
{% endif %}

## Additional timer related setups : create path groups-----------------
set_app_options -name time.enable_io_path_groups -value true  

## Connect pg net------------------------------------------------------
{%- if local.use_usr_common_scripts_connect_pg_net_tcl == "true" %}
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/connect_pg_net.tcl
{%- else %}
puts "Alchip-info: Running connect_pg_net command"
connect_pg_net -automatic
{%- endif %}

## save design and lib before floorplan 
save_block 
save_block -as {{env.BLK_NAME}}/${cur_stage}
save_lib 

## Pre-Floorplan customizations------------------------------------------
source -e -v  "{{cur.config_plugins_dir}}/icc2_scripts/01_fp/01_usr_pre_fp.tcl"

## source floorplan or manul floorplan-----------------------------------
{%- if local.enable_manual_floorplan == "false" %} 
{%- if local.def_convert_site_list %} 
puts "Alchip-info:read_def read_def -add_def_only_objects all {{env.BLK_FP}}/{{ver.fp}}/{{env.BLK_NAME}}.def.gz -convert_sites { local.def_convert_site_list }"
read_def -add_def_only_objects all {{env.BLK_FP}}/{{ver.fp}}/{{env.BLK_NAME}}.def.gz -convert_sites { local.def_convert_site_list }
{%- else %}
puts "Alchip-info:read_def read_def -add_def_only_objects all {{env.BLK_FP}}/{{ver.fp}}/{{env.BLK_NAME}}.def.gz "
read_def -add_def_only_objects all {{env.BLK_FP}}/{{ver.fp}}/{{env.BLK_NAME}}.def.gz
{%- endif %}
{%- elif local.enable_manual_floorplan == "true" %}
puts  "Alchip-info: manual floorplan is enabled, please start manual work and save block before exit icc2!"
return
{%- endif %}

## read SCANDEF-----------------------------------------------------------
if {[file exists [which $scandef_file]]} {
		read_def $scandef_file	
} 

## MV setup :provide a customized MV script in share/common_scripts/icc2_common_scripts/ directory------------
if {[file exists [which $tcl_mv_setup_file]]} {
	puts "Alchip-info : Sourcing [which $tcl_mv_setup_file]"
	source -v -echo $tcl_mv_setup_file
} 

## Post-Floorplan customizations-------------------------------------------
source -v -e  "{{cur.config_plugins_dir}}/icc2_scripts/01_fp/01_usr_post_fp.tcl"

## Connect pg net------------------------------------------------------
{%- if local.use_usr_common_scripts_connect_pg_net_tcl == "true" %}
source {{env.PROJ_SHARE_CMN}}/icc2_common_scripts/connect_pg_net.tcl
{%- else %}
puts "Alchip-info: Running connect_pg_net command"
connect_pg_net
{%- endif %}

##===================================================================##
## output netlist/def                                                ##
##===================================================================##
## save_database--------------------------------------------------------
save_block -as {{env.BLK_NAME}}
save_block -as {{env.BLK_NAME}}/${cur_stage}
save_lib

{%- if local.use_usr_fp_write_data == "true" %}
source {{cur.config_plugins_dir}}/icc2_scripts/01_fp/08_usr_write_data.tcl 
{%- else %}
{%- if local.fp_write_data == "true" %}
# write_verilog (no pg, and no physical only cells)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all {{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.ori.v
## write_verilog for LVS (with pg, and with physical only cells)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations empty_modules} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.lvs.v
## write_verilog for Formality (with pg, no physical only cells, and no supply statements)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells supply_statements} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.fm.v
## write_verilog for PT (no pg, no physical only cells but with diodes and DCAP for leakage power analysis)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.pt.v

write_def -include_tech_via_definitions -compress gzip {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.def
{% if local.write_def_convert_icc2_site_to_lef_site_name_list != "" %} 
write_def -include_tech_via_definitions -convert_sites { $write_def_convert_icc2_site_to_lef_site_name_list } -compress gzip {{cur.cur_flow_data_dir}}/.${cur_stage}{{env.BLK_NAME}}.def
{%- else %}
write_def -include_tech_via_definitions -compress gzip {{cur.cur_flow_data_dir}}/${cur_stage}.{{env.BLK_NAME}}.def
{%- endif %}
{%- endif %}
{%- endif %}

## generate early touch file---------------------------------------------
exec touch {{cur.cur_flow_sum_dir}}/${cur_stage}.{{env.BLK_NAME}}.early_complete

## Sanity checks and QoR Report------------------------------------------
{%- if local.fp_use_usr_report_tcl == "true" %}
source -v {{cur.config_plugins_dir}}/icc2_scripts/01_fp/09_usr_fp_report.tcl
{%- else %}
{%- if local.enable_fp_reporting == "true" %}
set REPORT_QOR_SCRIPT {{env.PROJ_UTILS}}/icc2_utils/report_qor.tcl
puts "Alchip-info: Sourcing [which $REPORT_QOR_SCRIPT]"
source -v -e $REPORT_QOR_SCRIPT ;# reports with zero interconnect delay
{%- endif %}
{%- endif %}
source -v -e {{env.PROJ_UTILS}}/icc2_utils/snapshot.tcl

###==================================================================##
##  exit icc2                                                        ##
##===================================================================##
puts "Alchip-info : Completed script [info script]\n"
