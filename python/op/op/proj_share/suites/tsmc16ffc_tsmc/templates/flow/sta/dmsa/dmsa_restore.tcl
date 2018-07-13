####################################
# DMSA Restore Setup               #
####################################

set dmsa_restore_scenario_list      "{{local.dmsa_restore_scenario_list|join (' ')}}"
source {{cur.cur_flow_sum_dir}}/{{cur.sub_stage}}.op._job.tcl
####################################
# DMSA Scenario list               #
####################################

set dmsa_restore_scenario_list $dmsa_restore_scenario_list
set _job_cpu_number [lindex $_job_cpu_number 1]

set process_num [llength $dmsa_restore_scenario_list]
set max_core [expr $process_num * ${_job_cpu_number}]

puts "dmsa use $process_num process and max core $max_core, each process use ${_job_cpu_number} core."

{% for scenario_name in local.dmsa_restore_scenario_list %}
set SCENARIO({{scenario_name}}) {{pre.flow_data_dir}}/sta/{{scenario_name}}/{{env.BLK_NAME}}.{{scenario_name}}.session
{%- endfor %}

{# #foreach dmsa_restore_scenario $dmsa_restore_scenario_list {
#    set SCENARIO($dmsa_restore_scenario) 
# }
#
#set SCENARIO(hold_func_lt_0p9) /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/func-mode/LT0P9_cbest_m25c_SetupHold/OUTPUT/session
#set SCENARIO(hold_func_ml_0p9)    /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/func-mode/ML0P9_rcworst_125c_SetupHold/OUTPUT/session
#set SCENARIO(setup_func_wc_0p9)   /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/func-mode/WC0P9_cworst_125c_SetupHold/OUTPUT/session
#set SCENARIO(setup_func_wcl_0p9)  /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/func-mode/WCL0P9_cworst_m25c_SetupHold/OUTPUT/session 
#set SCENARIO(hold_scan_shift_ml_0p9)  /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/scan_shift-mode/ML0P9_rcworst_125c_SetupHold/OUTPUT/session
#set SCENARIO(hold_scan_shift_lt_0p9)  /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/scan_shift-mode/LT0P9_cbest_m25c_SetupHold/OUTPUT/session 
#set SCENARIO(setup_scan_shift_wc_0p9)   /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/scan_shift-mode/WC0P9_cworst_125c_SetupHold/OUTPUT/session
#set SCENARIO(setup_scan_shift_wcl_0p9) /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/scan_shift-mode/WCL0P9_cworst_m25c_SetupHold/OUTPUT/session
#}
remove_host_options
set_host_options -num_processes $process_num -max_cores $max_core -name run1
report_host_usage -verbose

set multi_scenario_working_directory ./work
set multi_scenario_merged_error_log ./work/error_log.txt

start_hosts
report_host_usage -verbose

foreach scenario_name [array name SCENARIO ] {
	create_scenario -name $scenario_name -image $SCENARIO($scenario_name)
	echo "$scenario_name  $SCENARIO($scenario_name) "
}

current_session -all
current_scenario -all
report_multi_scenario_design

puts "{{env.FIN_STR}}"
