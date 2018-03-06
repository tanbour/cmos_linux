##########################################################################################
# Tool: IC Compiler II
# Alchip Onepiece
##########################################################################################
puts "Alchip-info : Running script [info script]\n"

#set pre_stage icc2_fp
#set cur_stage icc2_fp

set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

##mkdir tool output dirctory
set cur_flow_data_dir "{{cur.flow_data_dir}}/{{cur.stage}}"
set pre_flow_data_dir "{{pre.flow_data_dir}}/{{pre.stage}}"
set cur_flow_rpt_dir "{{cur.flow_rpt_dir}}/{{cur.stage}}"
set cur_flow_log_dir "{{cur.flow_log_dir}}/{{cur.stage}}"
set cur_flow_sum_dir "{{cur.flow_sum_dir}}/{{cur.stage}}"

exec mkdir -p $cur_flow_data_dir
exec mkdir -p $cur_flow_rpt_dir
exec mkdir -p $cur_flow_log_dir
exec mkdir -p $cur_flow_sum_dir

set BLK_NAME          "{{env.BLK_NAME}}"

{%- if local.use_dc_output_netlist == "true" %}
set BLK_NETLIST_LIST  "$pre_flow_data_dir/{{env.BLK_NAME}}.v"
{%- else %} 
set BLK_NETLIST_LIST  "{{env.BLK_NETLIST}}/{{ver.netlist}}/{{env.BLK_NAME}}.v"
{%- endif %} 
set BLK_SDC_DIR       "{{env.BLK_SDC}}/{{ver.sdc}}"
set OCV_MODE          "{{local.ocv_mode}}" 
set NDM_TECH          "{{liblist.NDM_TECH}}" 
set NDM_STD           "{{liblist.NDM_STD}}"

set reference_library "{{liblist.NDM_STD}} {{liblist.NDM_TECH}}"
set cur_design_library "$cur_flow_data_dir/$cur_stage.{{env.BLK_NAME}}.nlib"

source {{cur.flow_liblist_dir}}/liblist/liblist.tcl 

##back up database
set bak_date [exec date +%m%d]
if {[file exist ${cur_design_library}] } {
if {[file exist  ${cur_design_library}_bak_${bak_date}] } {
exec rm -rf ${cur_design_library}_bak_${bak_date}
}
exec mv -f ${cur_design_library} ${cur_design_library}_bak_${bak_date}
}
## create lib
create_lib \
    -use_technology_lib {{liblist.NDM_TECH}} \
    -ref_libs $reference_library \
    $cur_design_library

open_lib $cur_design_library

##read verilog
read_verilog -top {{env.BLK_NAME}}  $BLK_NETLIST_LIST
current_block {{env.BLK_NAME}}
link_block
save_lib

##setup constraint
#read_sdc {{env.BLK_SDC}}/{{ver.sdc}}{{env.BLK_NAME}}.func.sdc

#set_voltage  0.72 -object VDD
#set_voltage  0 -object VSS
source  -e -v "{{cur.config_plugins_dir}}/icc2_scripts/mcmm/mcmm.tcl"
{% if local.fix_io_hold == "true" %}
foreach scenario [get_object_name [get_scenarios -filter "active == true"]] {
puts "Alchip-info : set IO hold false path to scenario $scenario "

set_false_path -hold -from [all_inputs] -to [all_outputs]
#}
{% else %}
puts "Alchip-info : IO hold is not set be false path to scenario  "
{% endif %}

########################################################################
## Additional timer related setups : create path groups 	
########################################################################
set_app_options -name time.enable_io_path_groups -value true  

###report
{%- if local.enable_report == "true" %}
redirect -tee $cur_flow_rpt_dir/{{env.BLK_NAME}}.report_timing  {report_timing}
{%- endif %}

###auto floorplan
{%- if local.auto_fp == "true" %} 
initialize_floorplan
write_def  -compress gzip $cur_flow_data_dir/$cur_stage.{{env.BLK_NAME}}.def
{%- else %}
read_def {{env.BLK_FP}}/{{ver.fp}}/{{env.BLK_NAME}}.def.gz
{%- endif %}
place_pin -self

###create placement
set_app_option -list {place.coarse.continue_on_missing_scandef true}
create_placement 

start_gui
sh sleep 10
stop_gui
####save_database
save_block -as {{env.BLK_NAME}}
save_block -as {{env.BLK_NAME}}/${cur_stage}
save_lib

exit

