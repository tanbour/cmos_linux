########################################################################
# set timing_clock_gating_propagate_enable fasle ; if this variable is set to false, only the clock path can be propagated to downstream, the gating path can not, 015769
# VARIABLES
# GCS setting
set read_parasitics_load_locations true
set report_default_significant_digits 3 ; # default = 2
set case_analysis_sequential_propagation never
set timing_report_unconstrained_paths true
set timing_non_unate_clock_compatibility true
set timing_enable_max_capacitance_set_case_analysis true
set timing_early_launch_at_borrowing_latches false
set timing_crpr_threshold_ps 1
set timing_crpr_remove_clock_to_data_crp true ; # important
set timing_crpr_remove_muxed_clock_crp false ; # important variable, if there are dynamicly switching clocks (mux), this variable should be set to false, refer to 019947
set timing_edge_specific_source_latency true
set sh_new_variable_message "false" ; # default = "true"
set case_analysis_propagate_through_icg  "false"
set timing_remove_clock_reconvergence_pessimism  "true"
set timing_clock_reconvergence_pessimism normal
set power_enable_analysis true
set si_xtalk_exit_on_max_iteration_count 2
# Error: si_xtalk_exit_on_max_iteration_count_incr has been made obsolete since the 2016.12 release of PrimeTime and is no longer supported. (PT-008)
#set si_xtalk_exit_on_max_iteration_count_incr 2
# set_host_option -max 8
# change to true
set timing_input_port_default_clock          "false"
# set sdc_save_source_file_information	"true"

# some Ganesha PT_SI setting
set sh_enable_page_mode false
set link_create_black_boxes false
# set timing_global_derate_compatibility "true" ; # default = "false"
set lib_thresholds_per_lib                    true
set default_oc_per_lib                        true
set svr_keep_unconnected_nets                 true
set timing_dynamic_loop_breaking              false
set multi_core_enable_analysis                true

### env (Sony request)
set timing_enable_preset_clear_arcs             false
set timing_disable_internal_inout_cell_paths    true
set timing_disable_internal_inout_net_arcs      true
set timing_enable_multiple_clocks_per_reg       true
set timing_disable_clock_gating_checks          false
set timing_disable_recovery_removal_checks      false
#aocv setting
#add in criteria# set timing_aocvm_enable_analysis true
#add in criteria# set timing_aocvm_analysis_mode combined_launch_capture_depth
#add in criteria# set timing_pocvm_enable_analysis  true
#add in criteria# set timing_pocvm_corner_sigma  3
#add in criteria# set timing_pocvm_report_sigma  3
#add in criteria# set timing_enable_slew_variation  true
# for PT after vL.2016.06
set timing_enable_cumulative_incremental_derate true
##set timing_pocvm_use_normalized_reporting true



# sta setting for SI, from TSMC
set si_enable_analysis                                     TRUE
set si_xtalk_delay_analysis_mode                           all_path_edges ; # all_paths. all_path_edges is less pessimistic than the all_paths mode, while at the same time is safe for signoff.
set si_xtalk_double_switching_mode                         clock_network  ; # disabled. Comment: Used to detect double switching on clock network
set si_ccs_use_gate_level_simulation                       TRUE		  ; # true
# set si_filter_accum_aggr_noise_peak_ratio                  0.05		  ; # 0.03. An aggressor net, along with its coupling capacitors, is filtered  when: The accumulated peak voltage of voltage bumps induced on the victim by aggressor to the victim net divided by VCC is less than the value specified with the si_filter_accum_aggr_noise_peak_ratio variable.
set si_filter_accum_aggr_noise_peak_ratio                  0.03		  ; # change back to 0.03
set si_xtalk_composite_aggr_noise_peak_ratio               0.05		  ; # 0.01. The default value is 0.01, which means all the aggressor nets with crosstalk bump to VDD ratio less than 0.01 is selected into the composite aggressor group. Comment: which is optimistic or realistic compared with 0.05?
set si_noise_update_status_level                           high		  ; # none. Controls the number of progress messages displayed during the noise update process. Comment: No impact on delay calculation

## update 0901 suggested by doni 
set si_noise_composite_aggr_mode                           disabled ;# statistical	  ; # disabled.

# set si_xtalk_composite_aggr_mode                           statistical	  ; # disabled. PrimeTime  SI aggregates the effect of some small aggressors into a single composite aggressor, reducing the computational complexity and improving the performance. Comment: statistical is less pessimistic than statistical
set si_xtalk_composite_aggr_mode disabled ; # change back to disabled
set si_xtalk_composite_aggr_quantile_high_pct              95.45	  ; # 99.73. Sets the desired probability in percentage format that any given real combined bump height is less than or equal to the computed composite aggressor bump height. Comment: 95.45 is optimistic than 99.73.
# The following two variable is used to select nets which need next iteration of PrimeTime SI delay calculations. Comment: More realistic than the default value
set si_xtalk_reselect_delta_delay                          5	  	  ; # 1e+06. 
set si_xtalk_reselect_delta_delay_ratio                    0.95		  ; # 1e+06
set si_xtalk_reselect_time_borrowing_path                  TRUE		  ; # false. Comment: More realistic than the default value
set timing_si_exclude_delta_slew_for_transition_constraint FALSE	  ; # true. When this variable is true, the tool excludes the delta slew from maximum and minimum transition constraint checks. When this variable is false, the transition violations reported is the rough upper bound. Comment: More strict than default value when check slew violation


# sta setting for delay calculation, from TSMC
set delay_calc_waveform_analysis_mode full_design ; # should be set before link design
#Warning: timing_reduce_parallel_cell_arcs will be made obsolete and removed from future releases of PrimeTime starting with the 2017.06 release. (PT-007)
set timing_reduce_parallel_cell_arcs false

# update 0901 suggested by SYS to true
# update 0902 change back to false 
set pba_recalculate_full_path false ;# default is false

set timing_update_status_level high
set write_script_output_lumped_net_annotation true

#
#$#  set si_analysis_logical_correlation_mode  false
#$#  set si_filter_accum_aggr_noise_peak_ratio 0.03
#$#  set si_xtalk_analysis_effort_level        high
#$#  set si_xtalk_reselect_delta_delay         0.02
#$#  set si_xtalk_reselect_critical_path       false
#$#  set si_xtalk_reselect_clock_network       true
#$#  set si_noise_limit_propagation_ratio      0.5
#$#  set si_xtalk_double_switching_mode        clock_network
########################################################################
# MESSAGES
set_message_info -id RC-009 -limit 0
set_message_info -id RC-004 -limit 0
set_message_info -id PARA-006 -limit 0
set_message_info -id PARA-043 -limit 2000

#
# # Warning: Creating virtual clock named '<clock_name>' with no sources. (UITE-121)
# suppress_message UITE-121

# # Warning: Creating a clock on internal pin '<clock_name>'. (UITE-130)
# suppress_message UITE-130

# Warning: Converting clock object '<clock_name>' from ideal to propagated. (UITE-315)
# suppress_message UITE-315

# Warning: Virtual clock '<clock_name>' cannot be made propagated. (UITE-316)
# suppress_message UITE-316

# Warning: Attribute 'sources' does not exist on clock '<clock_name>' (ATTR-3)
# suppress_message ATTR-3
########################################################################
# TCL UTILITIES
#
#  source /proj/Mars2/WORK/vincent/common_data/PTSI_16ffpgl_SBOCV_TEMP/SCR/check_clock_tree_object.tcl
#  source /proj/Mars2/WORK/vincent/common_data/PTSI_16ffpgl_SBOCV_TEMP/SCR/report_cpu_usage.tcl
#  source /proj/Mars2/WORK/vincent/common_data/PTSI_16ffpgl_SBOCV_TEMP/SCR/report_violation.tcl
#  source /proj/Mars2/WORK/vincent/common_data/PTSI_16ffpgl_SBOCV_TEMP/SCR/report_violation_summary.tcl
#  source /proj/Mars2/WORK/vincent/common_data/PTSI_16ffpgl_SBOCV_TEMP/SCR/write_clock_pin_list.tcl
#  source /proj/Mars2/WORK/vincent/common_data/PTSI_16ffpgl_SBOCV_TEMP/SCR/check_clock_cell_type.tcl
