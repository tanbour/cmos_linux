%REPL_OP4
source  "$FLOW_BRANCH_DIR/$BLOCK_NAME.sys_setting.tcl"
source  "$FLOW_BRANCH_DIR/$BLOCK_NAME.dir.dmsa"
source  "$FLOW_BRANCH_DIR/$BLOCK_NAME.400_liblist_setup.tcl"
source  "$FLOW_BRANCH_DIR/$BLOCK_NAME.100_common_setup.tcl"
source  "$FLOW_BRANCH_DIR/$BLOCK_NAME.200_user_setup.tcl"
REPL_OP4%

####################################
# DMSA Scenario list               #
####################################
%REPL_OP4
set dmsa_dump_scenario_list "$DMSA_DUMP_SCENARIO_LIST"
REPL_OP4%
puts "dmsa use scenario $DMSA_DUMP_SCENARIO_LIST to dump ice timing data"

####################################
# specify process & max_core NUM   #
####################################
set PROCESS_NUM [llength $dmsa_dump_scenario_list]
#set MAX_CORE [expr $PROCESS_NUM * 8] ;# if max core num more than 16, need PrimeTime-ADV license please contact PL
set MAX_CORE 16 ;# By default core is 16, please modify it if necessary
puts "dmsa use $PROCESS_NUM process and max core $MAX_CORE, each process use 8 core."

####################################
#      specify timing data dir     #
####################################
set run_dir [pwd]
sh mkdir -p ${run_dir}/data/${OP4_dst_subdir}/ice_data_dir
set ice_data_dir ${run_dir}/data/${OP4_dst_subdir}/ice_data_dir

%REPL_OP4
set max_path $DMSA_DUMP_MAX_PATH
set nworst $DMSA_DUMP_NWORST
REPL_OP4%

foreach dmsa_dump_scenario $dmsa_dump_scenario_list {
set SCENARIO($dmsa_dump_scenario) $SRC_DATA_DIR/$dmsa_dump_scenario.w_io_session
}

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
set_distributed_variables {ice_data_dir max_path nworst}
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
   set c_scenario [current_scenario]
   report_scenario_data_for_icexplorer $c_scenario  $ice_data_dir
   report_pba_paths_for_icexplorer $c_scenario  $ice_data_dir min_max $max_path $nworst
}

exit
