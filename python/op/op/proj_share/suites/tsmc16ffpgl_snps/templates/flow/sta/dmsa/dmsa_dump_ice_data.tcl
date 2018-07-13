set PROCESS_NUM 8
set MAX_CORE 16
set max_path $max_path
set nworst $nworst
set SCENARIO(hold_func_lt_0p9) /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/func-mode/LT0P9_cbest_m25c_SetupHold/OUTPUT/session
set SCENARIO(hold_func_ml_0p9)    /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/func-mode/ML0P9_rcworst_125c_SetupHold/OUTPUT/session
set SCENARIO(setup_func_wc_0p9)   /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/func-mode/WC0P9_cworst_125c_SetupHold/OUTPUT/session
set SCENARIO(setup_func_wcl_0p9)  /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/func-mode/WCL0P9_cworst_m25c_SetupHold/OUTPUT/session 

set SCENARIO(hold_scan_shift_ml_0p9)  /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/scan_shift-mode/ML0P9_rcworst_125c_SetupHold/OUTPUT/session
set SCENARIO(hold_scan_shift_lt_0p9)  /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/scan_shift-mode/LT0P9_cbest_m25c_SetupHold/OUTPUT/session 
set SCENARIO(setup_scan_shift_wc_0p9)   /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/scan_shift-mode/WC0P9_cworst_125c_SetupHold/OUTPUT/session
set SCENARIO(setup_scan_shift_wcl_0p9) /localdisk_r830-03/VP1-CHIP_WORK2/amym/STAR_PT/kung_1023/output/11_pt_spef_sta/scan_shift-mode/WCL0P9_cworst_m25c_SetupHold/OUTPUT/session

remove_host_options
set_host_options -num_processes $PROCESS_NUM -max_cores $MAX_CORE -name run1
report_host_usage -verbose

set eco_enable_more_scenarios_than_hosts true
set multi_scenario_working_directory ./work
set multi_scenario_merged_error_log ./work/error_log.txt

start_hosts
report_host_usage -verbose

foreach scenario_name [array name SCENARIO ] {
	create_scenario -name $scenario_name -image $SCENARIO($scenario_name)
	echo "$scenario_name  $SCENARIO($scenario_name) "
}

set timing_save_pin_arrival_and_slack true
current_session -all
current_scenario -all
report_multi_scenario_design
set_distributed_variables { ice_data_dir max_path nworst}
remote_execute {
		set all_clock_inputs ""
		foreach_in_collection clock [ all_clocks ] {
		  foreach_in_collection source [ get_attribute $clock sources ] {
		    set all_clock_inputs [ add_to_collection $all_clock_inputs $source ]
		  }
		}
		set all_data_inputs [ remove_from_collection [ all_inputs ] $all_clock_inputs ]
		set all_data_outputs [ remove_from_collection [ all_outputs ] $all_clock_inputs ]
		set_false_path -hold -from $all_data_inputs
		set_false_path -hold -to $all_data_outputs
   source /apps/empyrean/icexplorer_2016.12.sp2_lnx26_x86_64/icexplorer_2016.12.sp2_lnx26_x86.64_20170730/library/pt_utils.tcl
   set b [current_scenario] 
   report_scenario_data_for_icexplorer $b  $ice_data_dir
   report_pba_paths_for_icexplorer $b  $ice_data_dir min_max $max_path $nworst
}


