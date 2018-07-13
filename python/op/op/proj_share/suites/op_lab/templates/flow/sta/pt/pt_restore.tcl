######################################################################
## Tool: PrimeTime - Restore 
######################################################################
puts "Alchip-info : Running script [info script]\n"
set cur_stage "{{cur.sub_stage}}"
set cur_stage [lindex [split $cur_stage .] 0]
set pt_restore_scenario "{{local._restore_inst}}"

set pt_cpu_number   "[lindex "{{local._job_restore_cpu_number}}" end]"
set_host_option -max_cores $pt_cpu_number

restore_session {{cur.cur_flow_data_dir}}/${pt_restore_scenario}/{{env.BLK_NAME}}.${pt_restore_scenario}.session
