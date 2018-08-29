source -v /user/home/i_juliaz/scr/PTADV/timem.tcl 
set DATE_TAG  [exec date "+%Y%m%d_%H%M%S"]

#$#foreach MODE $DMSA_MODES {
#$#	foreach CORNER $DMSA_CORNERS {
#$#	create_scenario -name ${MODE}_${CORNER} -image $SESSION(${MODE}_${CORNER})
#$#	}
#$#}
foreach scenario_name [array names SESSION] {
	create_scenario -name $scenario_name -image $SESSION($scenario_name)
}


set multi_scenario_working_directory ./$ECO_dir
set multi_scenario_merged_error_log  ./$ECO_dir/error_log.txt
remove_host_options
set eco_enable_more_scenarios_than_hosts true

set_host_options -num_processes $PROCESS_NUM -max_cores $MAX_CORE -name run1


start_hosts
report_host_usage -verbose

current_session -all
current_scenario -all
report_multi_scenario_design

set pba_derate_only_mode false
set timing_report_use_worst_parallel_cell_arc true
set pba_recalculate_full_path false
set eco_strict_pin_name_equivalence true

#new add
remote_execute {
	define_user_attribute cell_footprint -class lib_cell -import -type string
	set eco_alternative_cell_attribute_restrictions {cell_footprint}
}
remote_execute {
	set pba_derate_only_mode false
	set timing_report_use_worst_parallel_cell_arc true
	set pba_recalculate_full_path false
	
	### To do cell sizing of the cells with identical pin name
	set eco_strict_pin_name_equivalence true

	set read_parasitics_load_locations true; #default: false
	set eco_allow_filler_cells_as_open_sites true; #default: true
}



###################################
#    MIM Aware ECO setting        #
###################################
printvar eco_enable_mim
set_app_var eco_enable_mim true
set_app_var eco_report_unfixed_reason_max_endpoints 99999
printvar eco_enable_mim


###############################################
#    PT PA(Physical-Aware) ECO Setting        #
###############################################
set DEFS_list ""
foreach module $MODULES {
	lappend DEFS_list ${module}_def_$DEF_OF($module)
}
puts "All DEFS: $DEFS_list"

set_distributed_variables { DEFS_list dont_use_pattern LEF_FILES DONT_TOUCH_MODULE All_FILLER_CELLS VT_RULES}

remote_execute {
	set eco_allow_filler_cells_as_open_sites true
	set eco_report_unfixed_reason_max_endpoints 50
	foreach def $DEFS_list {
		regexp {^(\S+)_def_(\S+)$} $def "" module module_def
		set DEF_OF($module) $module_def
	}
	foreach module [array names DEF_OF] {
		set_eco_options -physical_lib_path $LEF_FILES -physical_design_path $DEF_OF($module) -filler_cell_names $All_FILLER_CELLS -log_file ${module}_lef_def.log -physical_lib_constraint_file $VT_RULES 
		if {$module == $TOP} {
			puts "[get_object_name [current_design]] : TOP Design"
			if {[lsearch $DONT_TOUCH_MODULE $module] != -1} {
				set_dont_touch [current_design] true
				puts "set_dont_touch [get_object_name [current_design]] true"
			} else {
				set_dont_touch [current_design] false
			puts "set_dont_touch [get_object_name [current_design]] false"
			}
		} else {
			set need_to_cat_icc_tcl 1
			set inst_of_module [get_cells -q -filter "ref_name ==$module" -h -q]
			if {[sizeof_collection $inst_of_module]} {
				if {[lsearch $DONT_TOUCH_MODULE $module] != -1} {
					set_dont_touch $inst_of_module true
					puts "set_dont_touch [get_object_name $inst_of_module] true"
				} else {
					set_dont_touch $inst_of_module false
					puts "set_dont_touch [get_object_name $inst_of_module] false"
				}
			}
			if {[sizeof_collection $inst_of_module] > 1} {
				set need_to_cat_icc_tcl 1
				set_eco_options -mim_group [get_object_name $inst_of_module]
				puts "set_eco_options -mim_group [get_object_name $inst_of_module]"
			}
		}
	}
	
	report_eco_option
	report_eco_options > check_eco_options.rpt
	#       source /proj/Mars2/WORK/juliaz/PT/data/set_dont_use.tcl
	set_dont_use [get_lib_cells $dont_use_pattern -q]
	
}
remote_execute {
	#$# --> source /user/home/i_juliaz/scr/PT_ECO/set_dont_touch_ac_cells.tcl
   source -e -v  /proj/IPU-A/WORK/cindyw/pcie/icc2/USER_FILE/pcie_dont_touch_net.tcl
set_false_path -from [all_inputs] -setup
set_false_path -to [all_outputs] -setup
        set_max_transition 0.25 [ current_design ]
        set_max_transition 0.15 -clock_path [all_clocks ]
        report_constraint -nosplit -significant_digits 3 -all_violators -max_transition
}

if {$FIX_POWER} {
	remote_execute {
		set eco_dir FIX_POWER
		set i 1
		while {[file exists $eco_dir]} {
			set eco_dir ${eco_dir}_$i
			incr i
		}
		exec mkdir -p $eco_dir
		set power_dir $eco_dir
	}
	if { $VTH_SWAPPING } {
		remote_execute {
			define_user_attribute eco_pattern -class lib_cell -type string
			set vt_cells [get_lib_cell {*/*CPDULVT}]
			foreach_in_collection vt $vt_cells     {
				set pattern [get_attribute -class lib_cell $vt base_name]
				set pattern [regsub ULVT [get_attribute -class lib_cell $vt base_name] ""]
				append pattern "ULVT"
				set_user_attribute $vt eco_pattern $pattern
				echo $pattern
			}
			set vt_cells [get_lib_cell {*/*CPDLVT}]  
			foreach_in_collection vt $vt_cells     {
				set pattern [get_attribute -class lib_cell $vt base_name]
				set pattern [regsub LVT [get_attribute -class lib_cell $vt base_name] ""]
				append pattern "LVT"
				set_user_attribute $vt eco_pattern $pattern
				echo $pattern
			}
			set vt_cells [get_lib_cell {*/*CPD}]
			foreach_in_collection vt $vt_cells     {
				set pattern [get_attribute -class lib_cell $vt base_name]
				set pattern [regsub RVT [get_attribute -class lib_cell $vt base_name] ""]
				append pattern "RVT"
				set_user_attribute $vt eco_pattern $pattern
				echo $pattern
			}
			echo "#Before VTH Swapping:" > $eco_dir/fix_eco_power_cell_usage.preopt.report
			report_cell_usage -attribute eco_pattern -pattern_priority {RVT LVT ULVT} >> $eco_dir/fix_eco_power_cell_usage.preopt.report
		}
		set ECO_TAG VTH_SWAPPING
		set eco_instance_name_prefix "ECO_INST_${ECO_TAG}_${DATE_TAG}"
		set eco_net_name_prefix      "ECO_NET_${ECO_TAG}_${DATE_TAG}"
		set_distributed_variables { ECO_TAG eco_instance_name_prefix eco_instance_name_prefix }
		#$#set_distributed_variables {FIX_POWER_CMD(VTH_SWAPPING)}
		set i 0
		foreach cmd $FIX_POWER_CMD($ECO_TAG) {
			timem START_${ECO_TAG}_${i}
			puts $cmd
			eval $cmd
			timem END_${ECO_TAG}_${i}
			incr i
		}
		remote_execute {
			echo "#After VTH Swapping:" >> $eco_dir/fix_eco_power_cell_usage.preopt.report
			report_cell_usage -attribute eco_pattern -pattern_priority {RVT LVT ULVT} >> $eco_dir/fix_eco_power_cell_usage.preopt.report
		}
	}
	if {$DOWNSIZING} {
		set ECO_TAG DOWNSIZING
		set eco_instance_name_prefix "ECO_INST_${ECO_TAG}_${DATE_TAG}"
		set eco_net_name_prefix      "ECO_NET_${ECO_TAG}_${DATE_TAG}"
		set_distributed_variables { ECO_TAG eco_instance_name_prefix eco_instance_name_prefix }
		#$#set_distributed_variables {FIX_POWER_CMD(DOWNSIZING)}
		set i 0
		foreach cmd $FIX_POWER_CMD($ECO_TAG) {
			timem START_${ECO_TAG}_${i}
			puts $cmd
			eval $cmd
			timem END_${ECO_TAG}_${i}
			incr i
		}
	}
	if {$REMOVE_BUFFER} {
		set ECO_TAG REMOVE_BUFFER
		set eco_instance_name_prefix "ECO_INST_${ECO_TAG}_${DATE_TAG}"
		set eco_net_name_prefix      "ECO_NET_${ECO_TAG}_${DATE_TAG}"
		set_distributed_variables { ECO_TAG eco_instance_name_prefix eco_instance_name_prefix }
		#$#set_distributed_variables {FIX_POWER_CMD(REMOVE_BUFFER)}
		set i 0
		foreach cmd $FIX_POWER_CMD($ECO_TAG) {
			timem START_${ECO_TAG}_${i}
			puts $cmd
			eval $cmd
			timem END_${ECO_TAG}_${i}
			incr i
		}
		remote_execute {
			echo "" > $eco_dir/done_remove_buff_fix_power
		}
	}
	if {$VTH_SWAPPING || $DOWNSIZING || $REMOVE_BUFFER} {
		if {$SAVE_SESSION_FIX_POWER} {
			remote_execute {
				save_session $eco_dir/${SESSION}.w_io_session
				exec touch $eco_dir/session_done
			}
		}
		
		remote_execute {
			if { ${STA_MODE} == "max" || ${STA_MODE} == "dft" } {
				report_timing -pba_mode path -derate -nets -input_pins -nosplit -significant_digits 3 \
				-max_paths 9999999 -slack_lesser_than 0 -nworst 1 \
				-delay_type max -path_type full -crosstalk_delta \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.setup.w_io.rpt
				exec /usr/bin/perl /proj/IPU-A/template/PTSI/PTSI_16ffc_ll_SBOCV_TEMP/SCR/check_violation_summary.pl \
				$eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.setup.w_io.rpt \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.setup.w_io.rpt.summary
			} else {
				report_timing -pba_mode path -derate -nets -input_pins -nosplit -significant_digits 3 \
				-max_paths 9999999 -slack_lesser_than 0 -nworst 1 \
				-delay_type min -path_type full -crosstalk_delta \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.hold.w_io.rpt
				exec /usr/bin/perl /proj/IPU-A/template/PTSI/PTSI_16ffc_ll_SBOCV_TEMP/SCR/check_violation_summary.pl \
				$eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.hold.w_io.rpt \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.hold.w_io.rpt.summary
			}
			
			set ECO_PRE FIX_POWER
			write_changes -format icctcl -output $eco_dir/ECO_${ECO_PRE}_icc.tcl
			write_changes -format text -output $eco_dir/ECO_${ECO_PRE}_text.tcl
			if {[llength [array names DEF_OF]] > 1} {
				foreach block [array names DEF_OF] {
					exec perl /user/home/i_juliaz/scr/PT_ECO/size_cell_n_remove_buf.pl $eco_dir/${block}.*ECO_${ECO_PRE}_icc.tcl > $eco_dir/${block}_eco_innovus_${ECO_PRE}.tcl
				}
			} else {
				exec perl /user/home/i_juliaz/scr/PT_ECO/size_cell_n_remove_buf.pl $eco_dir/ECO_${ECO_PRE}_icc.tcl > $eco_dir/eco_innovus_${ECO_PRE}.tcl
			}
		}
	}
}

if {$FIX_DRC} {
	remote_execute {
		set eco_dir FIX_DRC
		set i 1
		while {[file exists $eco_dir]} {
			set eco_dir ${eco_dir}_$i
			incr i
		}
		exec mkdir -p $eco_dir
	}
	
	if {$FIX_SLEW} {
		remote_execute {
			set_max_fanout 40 [ current_design ]
			remove_max_transition [all_clocks ]
			set_max_transition $MAX_DATA_SLEW [ current_design ]
			set_max_transition $MAX_CLK_SLEW -clock_path [all_clocks ]
			
			report_constraint -nosplit -significant_digits 3 -all_violators -verbose -max_transition > $eco_dir/b4_fix_tran.rpt
		} 
		set ECO_TAG FIX_SLEW
		set eco_instance_name_prefix "ECO_INST_${ECO_TAG}_${DATE_TAG}"
		set eco_net_name_prefix      "ECO_NET_${ECO_TAG}_${DATE_TAG}"
		set_distributed_variables { ECO_TAG eco_instance_name_prefix eco_instance_name_prefix }
		#$#set_distributed_variables {FIX_DRC_CMD(FIX_SLEW)}
		set i 0
		foreach cmd $FIX_DRC_CMD($ECO_TAG) {
			timem START_${ECO_TAG}_${i}
			puts $cmd
			eval $cmd
			timem END_${ECO_TAG}_${i}
			incr i
		}
		remote_execute {
			report_constraint -nosplit -significant_digits 3 -all_violators -verbose -max_transition > $eco_dir/after_fix_tran.rpt
		}
	}
	if {$FIX_CAP} {
		remote_execute {
			report_constraint -nosplit -significant_digits 3 -all_violators -verbose -max_capacitance > $eco_dir/b4_fix_cap.rpt
			exec perl /proj/IPU-A/template/PTSI/PTSI_16ffc_ll_SBOCV_TEMP/SCR/check_max_capacitance.pl $eco_dir/b4_fix_cap.rpt > $eco_dir/b4_fix_cap.rpt.sum
		}
		set ECO_TAG FIX_CAP
		set eco_instance_name_prefix "ECO_INST_${ECO_TAG}_${DATE_TAG}"
		set eco_net_name_prefix      "ECO_NET_${ECO_TAG}_${DATE_TAG}"
		set_distributed_variables { ECO_TAG eco_instance_name_prefix eco_instance_name_prefix }
		#$#set_distributed_variables {FIX_DRC_CMD(FIX_CAP)}
		set i 0
		foreach cmd $FIX_DRC_CMD($ECO_TAG) {
			timem START_${ECO_TAG}_${i}
			puts $cmd
			eval $cmd
			timem END_${ECO_TAG}_${i}
			incr i
		}       
		remote_execute {
			report_constraint -nosplit -significant_digits 3 -all_violators -verbose -max_capacitance > $eco_dir/after_fix_cap.rpt
			exec perl /proj/IPU-A/template/PTSI/PTSI_16ffc_ll_SBOCV_TEMP/SCR/check_max_capacitance.pl $eco_dir/after_fix_cap.rpt > $eco_dir/b4_fix_cap.rpt.sum
		}
	}
	if {$FIX_FANOUT} {
		remote_execute {
			report_constraint -nosplit -significant_digits 3 -all_violators -verbose -max_fanout > $eco_dir/b4_fix_fanout.rpt
			exec perl /proj/IPU-A/template/PTSI/PTSI_16ffc_ll_SBOCV_TEMP/SCR/check_max_fanout.pl $eco_dir/b4_fix_fanout.rpt > $eco_dir/b4_fix_fanout.rpt.sum
		}
		set ECO_TAG FIX_FANOUT
		set eco_instance_name_prefix "ECO_INST_${ECO_TAG}_${DATE_TAG}"
		set eco_net_name_prefix      "ECO_NET_${ECO_TAG}_${DATE_TAG}"
		set_distributed_variables { ECO_TAG eco_instance_name_prefix eco_instance_name_prefix }
		set i 0
		foreach cmd $FIX_DRC_CMD($ECO_TAG) {
			timem START_${ECO_TAG}_${i}
			puts $cmd
			eval $cmd
			timem END_${ECO_TAG}_${i}
			incr i
		}
		remote_execute {
			report_constraint -nosplit -significant_digits 3 -all_violators -verbose -max_fanout > $eco_dir/after_fix_fanout.rpt
			exec perl /proj/IPU-A/template/PTSI/PTSI_16ffc_ll_SBOCV_TEMP/SCR/check_max_fanout.pl $eco_dir/after_fix_fanout.rpt > $eco_dir/after_fix_fanout.rpt.sum
		}
	}
	if {$FIX_NOISE} {
		remote_execute {
			report_noise -all_violators -verbose > $eco_dir/b4_fix_noise.rpt
			exec perl /user/home/geraldh/my_script/PT_relevant/get_noise_report.pl $eco_dir/b4_fix_noise.rpt > $eco_dir/b4_fix_noise.rpt.sum
		}
		set ECO_TAG FIX_NOISE
		set eco_instance_name_prefix "ECO_INST_${ECO_TAG}_${DATE_TAG}"
		set eco_net_name_prefix      "ECO_NET_${ECO_TAG}_${DATE_TAG}"
		set_distributed_variables { ECO_TAG eco_instance_name_prefix eco_instance_name_prefix }
		set i 0
		foreach cmd $FIX_DRC_CMD($ECO_TAG) {
			timem START_${ECO_TAG}_${i}
			puts $cmd
			eval $cmd
			timem END_${ECO_TAG}_${i}
			incr i
		}
		remote_execute {
			report_noise -all_violators -verbose > $eco_dir/after_fix_noise.rpt
			exec perl /user/home/geraldh/my_script/PT_relevant/get_noise_report.pl $eco_dir/after_fix_noise.rpt > $eco_dir/after_fix_noise.rpt.sum
		}
	}

	if {$FIX_SLEW || $FIX_CAP || $FIX_FANOUT || $FIX_NOISE} {
		if {$SAVE_SESSION_FIX_DRC} {
			remote_execute {
				save_session $eco_dir/${SESSION}.w_io_session
				exec touch $eco_dir/session_done
			}
		}
		
		remote_execute {
			if { ${STA_MODE} == "max" || ${STA_MODE} == "dft" } {
				report_timing -pba_mode path -derate -nets -input_pins -nosplit -significant_digits 3 \
				-max_paths 9999999 -slack_lesser_than 0 -nworst 1 \
				-delay_type max -path_type full -crosstalk_delta \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.setup.w_io.rpt
				exec /usr/bin/perl /proj/IPU-A/template/PTSI/PTSI_16ffc_ll_SBOCV_TEMP/SCR/check_violation_summary.pl \
				$eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.setup.w_io.rpt \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.setup.w_io.rpt.summary
			} else {
				report_timing -pba_mode path -derate -nets -input_pins -nosplit -significant_digits 3 \
				-max_paths 9999999 -slack_lesser_than 0 -nworst 1 \
				-delay_type min -path_type full -crosstalk_delta \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.hold.w_io.rpt
				exec /usr/bin/perl /proj/IPU-A/template/PTSI/PTSI_16ffc_ll_SBOCV_TEMP/SCR/check_violation_summary.pl \
				$eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.hold.w_io.rpt \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.hold.w_io.rpt.summary
			}
			
			set ECO_PRE FIX_DRC
			write_changes -format icctcl -output $eco_dir/ECO_${ECO_PRE}_icc.tcl
			write_changes -format text -output $eco_dir/ECO_${ECO_PRE}_text.tcl
			if {[info exists power_dir]} {
				if {[file exists $power_dir/done_remove_buff_fix_power]} {
					exec diff $power_dir/ECO_FIX_POWER_text.tcl $eco_dir/ECO_${ECO_PRE}_text.tcl  > $eco_dir/final_ECO_${ECO_PRE}_text.tcl
				}
			}
		}
		remote_execute {
			if {[llength [array names DEF_OF]] > 1} {
				exec mkdir -p $eco_dir/ECO_INN_FILE
				if {[file exists $eco_dir/final_ECO_${ECO_PRE}_text.tcl] == 1} {
					exec perl /user/home/i_juliaz/scr/PT_ECO/panel_deal_with_pt_eco_timing_text.pl $eco_dir/final_ECO_${ECO_PRE}_text.tcl $eco_dir/EACH_BLOCK_ECO_TEXT
				} else {
					exec perl /user/home/i_juliaz/scr/PT_ECO/panel_deal_with_pt_eco_timing_text.pl $eco_dir/ECO_${ECO_PRE}_text.tcl $eco_dir/EACH_BLOCK_ECO_TEXT
				}
				foreach block [array names DEF_OF] {
					if {![file exists $eco_dir/${block}_ECO_${ECO_PRE}_icc.tcl]} {
						continue
						redirect blocks_icc_not_exists.rpt {puts "$eco_dir/${block}_ECO_${ECO_PRE}_icc.tcl isn't exists."}
					}
					exec perl  /user/home/i_juliaz/scr/PT_ECO/deal_with_pt_eco_timing_icc_tcl_v3.pl $eco_dir/${block}_ECO_${ECO_PRE}_icc.tcl $block $eco_dir
					foreach b_module [get_attribute [get_cells -q -filter "ref_name ==$block" -h] full_name] {
						exec perl /user/home/i_juliaz/scr/PT_ECO/deal_with_pt_eco_timing_text_tcl_v3.pl $eco_dir/${block}_add_buffs_location.rpt $eco_dir/${block}_set_cells_location.rpt $eco_dir/${block}_insert_buffs_location.rpt $eco_dir/EACH_BLOCK_ECO_TEXT/${b_module}.text.rpt > $eco_dir/temp_${b_module}_eco_innovus_${ECO_PRE}.tcl
						sh cat $eco_dir/temp_${b_module}_eco_innovus_${ECO_PRE}.tcl  $eco_dir/${block}_inn_ecoChange_cell.tcl > $eco_dir/ECO_INN_FILE/${b_module}_eco_innovus_${ECO_PRE}.tcl
					}
				}
			} else {
				exec perl /user/home/i_juliaz/scr/PT_ECO/deal_with_pt_eco_timing_icc_tcl_v3.pl $eco_dir/ECO_${ECO_PRE}_icc.tcl $ECO_PRE $eco_dir
				if {[file exists $eco_dir/final_ECO_${ECO_PRE}_text.tcl] == 1} {
					exec perl /user/home/i_juliaz/scr/PT_ECO/deal_with_pt_eco_timing_text_tcl_v3.pl $eco_dir/${ECO_PRE}_add_buffs_location.rpt $eco_dir/${ECO_PRE}_set_cells_location.rpt $eco_dir/${ECO_PRE}_insert_buffs_location.rpt $eco_dir/final_ECO_${ECO_PRE}_text.tcl > $eco_dir/temp_partial_eco_innovus_${ECO_PRE}.tcl
					sh cat $eco_dir/temp_partial_eco_innovus_${ECO_PRE}.tcl $eco_dir/${ECO_PRE}_inn_ecoChange_cell.tcl > $eco_dir/partial_eco_innovus_${ECO_PRE}.tcl
					#exec perl /user/home/i_juliaz/scr/PT_ECO/uniq_ecoChangeCell.pl $eco_dir/temp_partial_eco_innovus_${ECO_PRE}.tcl > $eco_dir/partial_eco_innovus_${ECO_PRE}.tcl
				} else {
					exec perl /user/home/i_juliaz/scr/PT_ECO/deal_with_pt_eco_timing_text_tcl_v3.pl $eco_dir/${ECO_PRE}_add_buffs_location.rpt $eco_dir/${ECO_PRE}_set_cells_location.rpt $eco_dir/${ECO_PRE}_insert_buffs_location.rpt $eco_dir/ECO_${ECO_PRE}_text.tcl > $eco_dir/temp_eco_innovus_${ECO_PRE}.tcl
					sh cat $eco_dir/temp_eco_innovus_${ECO_PRE}.tcl $eco_dir/${ECO_PRE}_inn_ecoChange_cell.tcl > $eco_dir/eco_innovus_${ECO_PRE}.tcl
					#exec perl /user/home/i_juliaz/scr/PT_ECO/uniq_ecoChangeCell.pl $eco_dir/temp_eco_innovus_${ECO_PRE}.tcl > $eco_dir/eco_innovus_${ECO_PRE}.tcl
				}
			}
		}
	}
}

if {$FIX_TIMING} {
	remote_execute {
		set eco_dir FIX_TIMING
		set i 1
		while {[file exists $eco_dir]} {
			set eco_dir ${eco_dir}_$i
			incr i
		}
		exec mkdir -p $eco_dir
	}
	if {$FIX_SETUP} {
		set ECO_TAG FIX_SETUP
		set eco_instance_name_prefix "ECO_INST_${ECO_TAG}_${DATE_TAG}"
		set eco_net_name_prefix      "ECO_NET_${ECO_TAG}_${DATE_TAG}"
		set i 0 
		set_distributed_variables { ECO_TAG eco_instance_name_prefix eco_instance_name_prefix }
		#$#set_distributed_variables {FIX_TIMING_CMD(FIX_SETUP)}
		foreach cmd $FIX_TIMING_CMD($ECO_TAG) {
			timem START_${ECO_TAG}_${i}
			puts $cmd
			eval $cmd
			timem END_${ECO_TAG}_${i}
			incr i
		}
	}
	if {$FIX_HOLD} {
		set ECO_TAG FIX_HOLD
		set eco_instance_name_prefix "ECO_INST_${ECO_TAG}_${DATE_TAG}"
		set eco_net_name_prefix      "ECO_NET_${ECO_TAG}_${DATE_TAG}"
		set i 0
		set_distributed_variables { ECO_TAG eco_instance_name_prefix eco_instance_name_prefix }
		#$#set_distributed_variables {FIX_TIMING_CMD(FIX_HOLD)}
		foreach  cmd $FIX_TIMING_CMD($ECO_TAG) {
			timem START_${ECO_TAG}_${i}
			puts $cmd
			eval $cmd
			timem END_${ECO_TAG}_${i}
			incr i
		}
	}
	
	if {$FIX_HOLD || $FIX_SETUP} {
		if {$SAVE_SESSION_FIX_TIMING} {
			remote_execute {
				save_session $eco_dir/${SESSION}.w_io_session
				exec touch $eco_dir/session_done
			}
		}
		
		remote_execute {
			if { ${STA_MODE} == "max" || ${STA_MODE} == "dft" } {
				report_timing -pba_mode path -derate -nets -input_pins -nosplit -significant_digits 3 \
				-max_paths 9999999 -slack_lesser_than 0 -nworst 1 \
				-delay_type max -path_type full -crosstalk_delta \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.setup.w_io.rpt
				exec /usr/bin/perl /proj/IPU-A/template/PTSI/PTSI_16ffc_ll_SBOCV_TEMP/SCR/check_violation_summary.pl \
				$eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.setup.w_io.rpt \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.setup.w_io.rpt.summary
			} else {
				report_timing -pba_mode path -derate -nets -input_pins -nosplit -significant_digits 3 \
				-max_paths 9999999 -slack_lesser_than 0 -nworst 1 \
				-delay_type min -path_type full -crosstalk_delta \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.hold.w_io.rpt
				exec /usr/bin/perl /proj/IPU-A/template/PTSI/PTSI_16ffc_ll_SBOCV_TEMP/SCR/check_violation_summary.pl \
				$eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.hold.w_io.rpt \
				> $eco_dir/${TOP}.${OP_MODE}.${STA_COND}.${XTK}.hold.w_io.rpt.summary
			}
			
			set ECO_PRE FIX_TIMING
			write_changes -format icctcl -output $eco_dir/ECO_${ECO_PRE}_icc.tcl
			write_changes -format text -output $eco_dir/ECO_${ECO_PRE}_text.tcl
			if {[info exists power_dir]} {
				if {[file exists $power_dir/done_remove_buff_fix_power]} {
					exec diff $power_dir/ECO_FIX_POWER_text.tcl $eco_dir/ECO_${ECO_PRE}_text.tcl  > $eco_dir/final_ECO_${ECO_PRE}_text.tcl
				}
			}
		}
		remote_execute {
			if {[llength [array names DEF_OF]] > 1} {
				exec mkdir -p $eco_dir/ECO_INN_FILE
				if {[file exists $eco_dir/final_ECO_${ECO_PRE}_text.tcl] == 1} {
					exec perl /user/home/i_juliaz/scr/PT_ECO/panel_deal_with_pt_eco_timing_text.pl $eco_dir/final_ECO_${ECO_PRE}_text.tcl $eco_dir/EACH_BLOCK_ECO_TEXT
				} else {
					exec perl /user/home/i_juliaz/scr/PT_ECO/panel_deal_with_pt_eco_timing_text.pl $eco_dir/ECO_${ECO_PRE}_text.tcl $eco_dir/EACH_BLOCK_ECO_TEXT
				}
				foreach block [array names DEF_OF] {
					if {![file exists $eco_dir/${block}_ECO_${ECO_PRE}_icc.tcl]} {
						continue
						redirect blocks_icc_not_exists.rpt {puts "$eco_dir/${block}_ECO_${ECO_PRE}_icc.tcl isn't exists."}
					}
					exec perl  /user/home/i_juliaz/scr/PT_ECO/deal_with_pt_eco_timing_icc_tcl_v3.pl $eco_dir/${block}_ECO_${ECO_PRE}_icc.tcl $block $eco_dir
					foreach b_module [get_attribute [get_cells -q -filter "ref_name ==$block" -h] full_name] {
						exec perl /user/home/i_juliaz/scr/PT_ECO/deal_with_pt_eco_timing_text_tcl_v3.pl $eco_dir/${block}_add_buffs_location.rpt $eco_dir/${block}_set_cells_location.rpt $eco_dir/${block}_insert_buffs_location.rpt $eco_dir/EACH_BLOCK_ECO_TEXT/${b_module}.text.rpt > $eco_dir/temp_${b_module}_eco_innovus_${ECO_PRE}.tcl
						sh cat $eco_dir/temp_${b_module}_eco_innovus_${ECO_PRE}.tcl  $eco_dir/${block}_inn_ecoChange_cell.tcl > $eco_dir/ECO_INN_FILE/${b_module}_eco_innovus_${ECO_PRE}.tcl
					}
				}
			} else {
				exec perl /user/home/i_juliaz/scr/PT_ECO/deal_with_pt_eco_timing_icc_tcl_v3.pl $eco_dir/ECO_${ECO_PRE}_icc.tcl $ECO_PRE $eco_dir
				if {[file exists $eco_dir/final_ECO_${ECO_PRE}_text.tcl] == 1} {
					exec perl /user/home/i_juliaz/scr/PT_ECO/deal_with_pt_eco_timing_text_tcl_v3.pl $eco_dir/${ECO_PRE}_add_buffs_location.rpt $eco_dir/${ECO_PRE}_set_cells_location.rpt $eco_dir/${ECO_PRE}_insert_buffs_location.rpt $eco_dir/final_ECO_${ECO_PRE}_text.tcl > $eco_dir/temp_partial_eco_innovus_${ECO_PRE}.tcl
					sh cat $eco_dir/temp_partial_eco_innovus_${ECO_PRE}.tcl $eco_dir/${ECO_PRE}_inn_ecoChange_cell.tcl > $eco_dir/partial_eco_innovus_${ECO_PRE}.tcl
					#exec perl /user/home/i_juliaz/scr/PT_ECO/uniq_ecoChangeCell.pl $eco_dir/temp_partial_eco_innovus_${ECO_PRE}.tcl > $eco_dir/partial_eco_innovus_${ECO_PRE}.tcl
				} else {
					exec perl /user/home/i_juliaz/scr/PT_ECO/deal_with_pt_eco_timing_text_tcl_v3.pl $eco_dir/${ECO_PRE}_add_buffs_location.rpt $eco_dir/${ECO_PRE}_set_cells_location.rpt $eco_dir/${ECO_PRE}_insert_buffs_location.rpt $eco_dir/ECO_${ECO_PRE}_text.tcl > $eco_dir/temp_eco_innovus_${ECO_PRE}.tcl
					sh cat $eco_dir/temp_eco_innovus_${ECO_PRE}.tcl $eco_dir/${ECO_PRE}_inn_ecoChange_cell.tcl > $eco_dir/eco_innovus_${ECO_PRE}.tcl
					#exec perl /user/home/i_juliaz/scr/PT_ECO/uniq_ecoChangeCell.pl $eco_dir/temp_eco_innovus_${ECO_PRE}.tcl > $eco_dir/eco_innovus_${ECO_PRE}.tcl
				}
			}
		}
	}
}	
exec touch PTADV_done
exit
