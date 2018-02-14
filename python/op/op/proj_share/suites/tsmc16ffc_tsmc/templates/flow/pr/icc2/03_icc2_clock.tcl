##########################################################################################
# Tool: IC Compiler II
# Alchip Onepiece
# icc2_clock
##########################################################################################
puts "Alchip-info : Running script [info script]\n"

puts "Alchip-info : Running script [info script]\n"

set src_stage icc2_place
set dst_stage icc2_clock

set BLK_NAME          "{{env.BLK_NAME}}"

set src_design_library  "{{pre.flow_data_dir}}/{{env.BLK_NAME}}.${src_stage}.nlib"
set dst_design_library "{{cur.flow_data_dir}}/{{env.BLK_NAME}}.${dst_stage}.nlib"

set clock_cpu_number "{{local.clock_cpu_number}}"
set clock_active_scenario_list "{{local.clock_active_scenario_list}}"

exec mkdir -p {{cur.flow_data_dir}}
exec mkdir -p {{cur.flow_log_dir}}
exec mkdir -p {{cur.flow_rpt_dir}}
exec mkdir -p {{cur.flow_sum_dir}}


##setup host option

set_host_option -max_core $clock_cpu_number

##back up database
set bak_date [exec date +%m%d]
if {[file exist ${dst_design_library}] } {
if {[file exist ${dst_design_library}_bak_${bak_date}] } {
exec rm -rf ${dst_design_library}_bak_${bak_date}
}
exec mv -f ${dst_design_library} ${dst_design_library}_bak_${bak_date}
}
## copy block and lib from previous stage
copy_lib -from_lib ${src_design_library} -to_lib ${dst_design_library} -no_design
open_lib ${src_design_library}
copy_block -from ${src_design_library}:{{env.BLK_NAME}}/${src_stage} -to ${dst_design_library}:{{env.BLK_NAME}}/${dst_stage}
close_lib ${src_design_library}

open_lib ${dst_design_library}

current_block {{env.BLK_NAME}}/${dst_stage}

link_block
save_lib

puts "run icc2_clock"
clock_opt -from build_clock -to route_clock

start_gui 
sh sleep 5
stop_gui

save_block -as {{env.BLK_NAME}}
save_lib

exit

