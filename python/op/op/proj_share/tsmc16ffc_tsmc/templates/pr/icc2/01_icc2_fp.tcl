##########################################################################################
# Tool: IC Compiler II
# Alchip Onepiece
##########################################################################################
puts "Alchip-info : Running script [info script]\n"

set src_stage icc2_fp
set dst_stage icc2_fp

set BLK_NAME          {{env.BLK_NAME}}
set BLK_NETLIST_LIST  {{env.BLK_NETLIST}}/{{env.VERSION_NETLIST}}/{{env.BLK_NAME}}.v

set NDM_TECH          {{liblist.NDM_TECH}} 
set NDM_STD           {{liblist.NDM_STD}}

set reference_library "{{liblist.NDM_STD}} {{liblist.NDM_TECH}}"
set dst_design_library "{{env.RUN_DATA}}/{{env.BLK_NAME}}.${dst_stage}.nlib"

exec mkdir -p {{env.RUN_DATA}}
exec mkdir -p {{env.RUN_LOG}}
exec mkdir -p {{env.RUN_RPT}}

##back up database
set bak_date [exec date +%m%d]
if {[file exist ${dst_design_library}] } {
if {[file exist  ${dst_design_library}_bak_${bak_date}] } {
exec rm -rf ${dst_design_library}_bak_${bak_date}
}
exec mv -f ${dst_design_library} ${dst_design_library}_bak_${bak_date}
}
## create lib
create_lib \
    -use_technology_lib {{liblist.NDM_TECH}} \
    -ref_libs $reference_library \
    $dst_design_library

open_lib $dst_design_library

##read verilog
read_verilog -top {{env.BLK_NAME}}  $BLK_NETLIST_LIST
current_block {{env.BLK_NAME}}
link_block
save_lib

##setup constraint
#read_sdc {{env.BLK_SDC}}/{{env.BLK_NAME}}.func.sdc

#set_voltage  0.72 -object VDD
#set_voltage  0 -object VSS
{% include 'icc2/mcmm.tcl' %}
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
exec mkdir -p {{env.RUN_RPT}}
{%- if local.enable_report == "true" %}
redirect -tee {{env.RUN_RPT}}/{{env.BLK_NAME}}.report_timing  {report_timing}
{%- endif %}

###auto floorplan
{%- if local.auto_fp == "true" %} 
initialize_floorplan
{%- else %}
read_def {{env.BLK_FP}}/{{env.VERSION_FP}}/{{env.BLK_NAME}}.def.gz
{%- endif %}
place_pin -self

###create placement
set_app_option -list {place.coarse.continue_on_missing_scandef true}
create_placement 

start_gui
sh sleep 10
stop_gui
####save_database
save_block -as {{env.BLK_NAME}}/${dst_stage}
save_lib

exit

