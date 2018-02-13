##########################################################################################
# Tool: IC Compiler II
# Alchip Onepiece
# icc2_clock_opt
##########################################################################################
puts "Alchip-info : Running script [info script]\n"

set src_stage icc2_clock
set dst_stage icc2_clock_opt

set BLK_NAME          "{{env.BLK_NAME}}"

set src_design_library  "{{env.RUN_DATA}}/{{env.BLK_NAME}}.${src_stage}.nlib"
set dst_design_library "{{env.RUN_DATA}}/{{env.BLK_NAME}}.${dst_stage}.nlib"

set clock_opt_cpu_number "{{local.clock_opt_cpu_number}}"
set clock_opt_active_scenario_list "{{local.clock_opt_active_scenario_list}}"

exec mkdir -p {{env.RUN_DATA}}
exec mkdir -p {{env.RUN_LOG}}
exec mkdir -p {{env.RUN_RPT}}


##setup host option

set_host_option -max_core $clock_opt_cpu_number

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



puts "run icc2_clock_opt"

clock_opt -from final_opto

start_gui
sh sleep 5
stop_gui

save_block -as {{env.BLK_NAME}}
save_lib

exit
