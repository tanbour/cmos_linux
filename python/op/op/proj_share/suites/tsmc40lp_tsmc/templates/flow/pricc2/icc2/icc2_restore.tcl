######################################################################
## Tool: IC Compiler II - Restore 
######################################################################
puts "Alchip-info : Running script [info script]\n"
set cur_stage "{{cur.sub_stage}}"
set cur_stage [lindex [split $cur_stage .] 0]
set cur_path = [exec pwd]
set block_owner_name = [lindex [split [exec pwd] "/"] 4]
set user_name = $env(USER)
if {$user_name != $block_owner_name} {
open_lib {{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib -read_only
} else {
open_lib {{cur.cur_flow_data_dir}}/$cur_stage.{{env.BLK_NAME}}.nlib
}

open_block {{env.BLK_NAME}}/$cur_stage
set icc2_cpu_number   "[lindex "{{local._job_restore_cpu_number}}" end]"
set_host_option -max_cores $icc2_cpu_number
