##################################### MAIN PART ##############################################
set cpu_number [lindex [split "{{local._job_cpu_number}}" " "] 1]
set_host_options -max_cores $cpu_number
# SESSION
file mkdir -p {{cur.flow_scripts_dir}}/.trach/TMP
set  pt_tmp_dir {{cur.flow_scripts_dir}}/.trach/TMP

exec touch {{cur.flow_scripts_dir}}/.trach/.start
if {[info exists VOLT] && [llength $VOLT] > 1} {set VOLT [join $VOLT {_}]}
#set SESSION  "$ALL_SCENARIO_LIST" 
#
#set MODE           [lindex [split $SESSION .] 0]
#set VOLT           [lindex [split $SESSION .] 1]
#set LIB_CORNER     [lindex [split $SESSION .] 2]
#set RC_CORNER      [lindex [split $SESSION .] 3]
#set CHECK_TYPE     [lindex [split $SESSION .] 4]

##mkdir tool output dirctory
set cur_flow_data_dir "{{cur.flow_data_dir}}/{{cur.stage}}"
set pre_flow_data_dir "{{pre.flow_data_dir}}/{{pre.stage}}"
set cur_flow_rpt_dir "{{cur.flow_rpt_dir}}/{{cur.stage}}"
set cur_flow_log_dir "{{cur.flow_log_dir}}/{{cur.stage}}"
set cur_flow_sum_dir "{{cur.flow_sum_dir}}/{{cur.stage}}"

set flow_root_dir "{{cur.flow_root_dir}}"
set run_dir	"$flow_root_dir/.run"

if {![file isdirectory $cur_flow_log_dir]} {file mkdir $cur_flow_log_dir}
if {![file isdirectory $cur_flow_data_dir]} {file mkdir $cur_flow_data_dir}
if {![file isdirectory $cur_flow_rpt_dir]} {file mkdir $cur_flow_rpt_dir}
if {![file isdirectory $cur_flow_sum_dir]} {file mkdir $cur_flow_sum_dir}
if {![file isdirectory $run_dir]} { #file mkdir $run_dir}
if {[file isfile $flow_root_dir/${SESSION}.ready]} {file delete $flow_root_dir/${SESSION}.ready}

########################################################################
# LIBRARY
########################################################################
source {{cur.config_plugins_dir}}/pt_scripts/utility/mv_library_setup.tcl

########################################################################
# PT SETUP
########################################################################

source {{cur.config_plugins_dir}}/pt_scripts/settings/ALCHIP-PT-SignOff-CommonSetting.TSMC.N7.tcl 
########################################################################
# READ DESIGN
########################################################################
file delete -force $cur_flow_log_dir/read_verilog.log
redirect -append $cur_flow_log_dir/read_verilog.log {puts "read_verilog ${VNET}"}
redirect -append $cur_flow_log_dir/read_verilog.log {read_verilog ${VNET}}
foreach type [array names SUB_BLOCKS_CELL_MAP] {
    if {[regexp {verilog} $type]} {
        foreach blk $SUB_BLOCKS_CELL_MAP($type) {
            set SVNET $BLOCK_RELEASE_DIR/$blk/vnet/${blk}.v.gz
            redirect -append $cur_flow_log_dir/read_verilog.log {puts "read_verilog ${SVNET}"}
            redirect -append $cur_flow_log_dir/read_verilog.log {read_verilog ${SVNET}}
        }
    } elseif { [regexp {ilm} $type]} {
        foreach blk $SUB_BLOCKS_CELL_MAP($type) {
            set SVNET $BLOCK_RELEASE_DIR/$blk/ilm/${SESSION}_ILM/${blk}.v.gz
            redirect -append $cur_flow_log_dir/read_verilog.log {puts "read_verilog ${SVNET}"}
            redirect -append $cur_flow_log_dir/read_verilog.log {read_verilog ${SVNET}}
        }
    }
}

current_design ${TOP}
redirect -tee $cur_flow_log_dir/link_design.log {link_design ${TOP}}
puts "current design is [get_attr [current_design] full_name]"

########################################################################
# OPERATING CONDITIONS
#
set_operating_conditions -analysis_type on_chip_variation

########################################################################
# READ SDC
#
if {[info exists GEN_SDF] && $GEN_SDF == "true"} {
    file delete -force $cur_flow_log_dir/read_sdfsdc.${MODE}.log
    foreach sdc $SDC_LIST {
       redirect -append $cur_flow_log_dir/read_sdfsdc.${MODE}.log { source -echo -verbose ${sdc} }
    }
} else {
    file delete -force $cur_flow_log_dir/read_sdc.${MODE}.log
    foreach sdc $SDC_LIST {
       redirect -append $cur_flow_log_dir/read_sdc.${MODE}.log { source -echo -verbose ${sdc} }
    }
}
redirect -append $cur_flow_rpt_dir/input_port_transition.rpt {report_port -drive -nosplit}
redirect -append $cur_flow_rpt_dir/output_port_loading.rpt   {report_port -wire_load -nosplit}

########################################################################
# SIGNOFF_CRITERIA SETTING
#
{% if local.CLK_MODE == "propagated" %} 
    set_propagated_clock [ all_clocks ]
{%- else %}
    remove_propagated_clock [get_clocks *]
{% endif %}

{% if local.GEN_SDF == "true" %} 
    remove_clock_uncertainty -setup [get_clocks *]
    remove_clock_uncertainty -hold [get_clocks *]
{%- else %}
source {{cur.config_plugins_dir}}/pt_scripts/criteria/ALCHIP-PT-SignOff-Criteria.TSMC.N7.tcl  
{%- endif %}

########################################################################
# READ SPEF
#
{% if local.READ_SDF == "true" %} 
    read_sdf -load_delay net $BLOCK_RELEASE_DIR/$TOP/sdf/${TOP}.${RC_CORNER}.sdf.gz
    redirect -tee $cur_flow_log_dir/report_annotated_delay.rpt { report_annotated_delay }
{% else %}
    if {[info exists GEN_SDF] && $GEN_SDF == "true"} {set_si_delay_analysis -ignore_arrival [ get_nets * -hierarchical ]}
    echo "Reading ${SPEF} ..."                                                                    >> $cur_flow_log_dir/read_parasitics.log
    echo "read_parasitics -format ${ANNOTATED_FILE_FORMAT} -keep_capacitive_coupling ${SPEF} ..." >> $cur_flow_log_dir/read_parasitics.log
    read_parasitics -format ${ANNOTATED_FILE_FORMAT} -keep_capacitive_coupling ${SPEF}            >> $cur_flow_log_dir/read_parasitics.log
    if {[info exists SUB_BLOCKS_LOCATIONS_FILE] && [file exists $SUB_BLOCKS_LOCATIONS_FILE]} {
        source $SUB_BLOCKS_LOCATIONS_FILE
    } 
    foreach type [array names SUB_BLOCKS_CELL_MAP] {
        foreach blk $SUB_BLOCKS_CELL_MAP($type) {
            if {[regexp {lib|none|bbox} $type]} {continue}
            foreach_in_collection cell [ get_cells * -hierarchical -filter "ref_name == $blk" -quiet ] {
                set inst_name [ get_attribute $cell full_name ]
                if {[regexp {verilog} $type]} {
                    set SPEF $BLOCK_RELEASE_DIR/$blk/spef/${blk}.${RC_CORNER}.spef.gz
                } elseif { [regexp {ilm} $type]} {
                    set SPEF $BLOCK_RELEASE_DIR/$blk/ilm/${SESSION}_ILM/${blk}.${RC_CORNER}.spef.gz
                }
                if {[info exist hinstflip($inst_name)]&&[info exist hinstorigin($inst_name)]} {
                    set x_offset [format "%.0f" [expr [lindex $hinstorigin($inst_name) 0] * 1000]]
                    set y_offset [format "%.0f" [expr [lindex $hinstorigin($inst_name) 1] * 1000]]
                    echo "Reading ${SPEF} ..."                                                                                  >> $cur_flow_log_dir/read_parasitics.log
                    echo "read_parasitics -format ${ANNOTATED_FILE_FORMAT} -keep_capacitive_coupling -rotation rotate_none -axis_flip $hinstflip($inst_name) -x_offset $x_offset -y_offset $y_offset -path $inst_name ${SPEF}"  >> $cur_flow_log_dir/read_parasitics.log
                    read_parasitics -format ${ANNOTATED_FILE_FORMAT} -keep_capacitive_coupling -rotation rotate_none -axis_flip $hinstflip($inst_name) -x_offset $x_offset -y_offset $y_offset -path $inst_name ${SPEF}         >> $cur_flow_log_dir/read_parasitics.log
                } else {
                    echo "Reading ${SPEF} ..."                                                                                  >> $cur_flow_log_dir/read_parasitics.log
                    echo "read_parasitics -format ${ANNOTATED_FILE_FORMAT} -keep_capacitive_coupling -path $inst_name ${SPEF}"  >> $cur_flow_log_dir/read_parasitics.log
                    read_parasitics -format ${ANNOTATED_FILE_FORMAT} -keep_capacitive_coupling -path $inst_name ${SPEF}         >> $cur_flow_log_dir/read_parasitics.log
                    #doni@Feb07 for PARA-126 Warning#  remove '-increment' option
                }
            }
        }
{%- endif %}
    
    
    report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000                                 > $cur_flow_log_dir/report_annotated_parasitics.rpt
    report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -internal_nets -pin_to_pin_nets > $cur_flow_log_dir/report_annotated_parasitics.internal_nets.pin_to_pin.nets.rpt
    report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -internal_nets -driverless_nets > $cur_flow_log_dir/report_annotated_parasitics.internal_nets.driverless_nets.rpt
    report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -internal_nets -loadless_nets   > $cur_flow_log_dir/report_annotated_parasitics.internal_nets.loadless_nets.rpt
    report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -boundary_nets -pin_to_pin_nets > $cur_flow_log_dir/report_annotated_parasitics.boundary_nets.pin_to_pin.nets.rpt
    report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -boundary_nets -driverless_nets > $cur_flow_log_dir/report_annotated_parasitics.boundary_nets.driverless_nets.rpt
    report_annotated_parasitics -list_not_annotated -constant_arcs -max_nets 10000000 -boundary_nets -loadless_nets   > $cur_flow_log_dir/report_annotated_parasitics.boundary_nets.loadless_nets.rpt
}

{% if local.GEN_SDF == "true" %} 
    write_sdf -version 3.0 -context verilog -compress gzip -significant_digits 3 -input_port_nets -output_port_nets\
	-include {SETUPHOLD RECREM} -exclude {no_condelse clock_tree_path_models} -no_internal_pins  \
	$cur_flow_data_dir/${TOP}.${SESSION}.sdf.gz
    remove_annotated_parasitics -all
    set timing_aocvm_enable_analysis false
    set timing_pocvm_enable_analysis false
    reset_design -timing
    file delete -force $cur_flow_log_dir/read_sdc.${MODE}.log
    foreach sdc $SDC_LIST {
       redirect -append $cur_flow_log_dir/read_sdc.${MODE}.SDF.log { source -echo -verbose ${sdc} }
    }
    {% if local.CLK_MODE == "propagated" %} 
        set_propagated_clock [ all_clocks ]
    {%- else %}
        remove_propagated_clock [get_clocks *]
    {%- endif %}
    remove_clock_uncertainty -setup [get_clocks *]
    remove_clock_uncertainty -hold [get_clocks *]
    read_sdf -load_delay net $cur_flow_data_dir/${TOP}.${SESSION}.sdf.gz
    redirect -tee $cur_flow_log_dir/report_annotated_delay.rpt { report_annotated_delay }

{%- endif %}

########################################################################
# UPDATE TIMING & SAVE SESSION
#
redirect -tee $cur_flow_log_dir/update_timing.log { update_timing }
{% if  local.SAVE_SESSION == "true" %} 
save_session ${TOP}_${SESSION}.session	;# -only_used_libraries
{%- endif %} 

########################################################################
# REPORT (WITH IO)
#
# ======================= report_timing options ========================
set command "report_timing -derate -nets -input_pins -nosplit -significant_digits 3 -slack_lesser_than 0"
if {[info exists XTK]}		{append command " -crosstalk_delta"		} else {}
if {[info exists PBA_MODE]} 	{append command " -pba_mode  $PBA_MODE"    	} else {}
if {[info exists MAX_PATH_NUM]} {append command " -max_paths $MAX_PATH_NUM"	} else {append cmd " -max_paths 9999999"}
if {[info exists NWORST_NUM]}	{append command " -nworst    $NWORST_NUM"	} else {}
if {[info exists PATH_TYPE]}	{append command " -path_type $PATH_TYPE"	} else {}
if {[info exists CHECK_TYPE]} 	{
    if {[regexp {hold} $CHECK_TYPE]} {append command " -delay_type min"} else {append command " -delay_type max"}
}
# ======================= report_timing options ========================
# setup with io or hold with io
eval $command > $cur_flow_rpt_dir/${TOP}.${SESSION}.w_io.rpt
sh /usr/bin/perl {{cur.config_plugins_dir}}/pt_scripts/scripts/check_violation_summary.pl \
     $cur_flow_rpt_dir/${TOP}.${SESSION}.w_io.rpt \
   > $cur_flow_rpt_dir/${TOP}.${SESSION}.w_io.rpt.summary
set new_command $command
append new_command " -variation -derate -transition"
eval $new_command > $cur_flow_rpt_dir/${TOP}.${SESSION}.w_io.rpt.more

########################################################################
# EXPORT (ILM)
#
{% if local.GEN_ILM == "true" %} 
        create_ilm -block_scope -verification_script -parasitics_options { spef input_port_nets constant_nets }
        sh mkdir -p $cur_flow_data_dir/${SESSION}_ILM
        sh mv ${TOP}/ilm.v ${TOP}/${TOP}.v
        sh gzip ${TOP}/${TOP}.v
        sh mv ${TOP}/${TOP}.v.gz $cur_flow_data_dir/${SESSION}_ILM/${TOP}.v.gz
        sh mv ${TOP}/ilm.spef.gz $cur_flow_data_dir/${SESSION}_ILM/${TOP}.${RC_CORNER}.spef.gz
        sh rm -rf ${TOP}
{%- endif %}

########################################################################
# EXPORT (lib & db)
#
{% if local.GEN_ETM == "true" %} 
    # set extract_model_num_capacitance_points 7
    # set extract_model_num_data_transition_points 7
    # set extract_model_num_clock_transition_points 7
    # set extract_model_use_conservative_current_slew true
    # If true, extract_model traverses all clock tree paths, computes the insertion delay
    # and creates clock latency arcs in the model
    # set extract_model_with_clock_latency_arcs true
    extract_mode -output $cur_flow_data_dir/${TOP}.${SESSION} -format {db lib} -library_cell
{%- endif %}

########################################################################
# EXPORT (SDF)
#
#{% if local.GEN_SDF == "true" %} 
#    write_sdf -version 3.0 -context verilog -compress gzip \
#	-include {SETUPHOLD RECREM} -exclude {no_condelse clock_tree_path_models} -no_internal_pins  \
#	$cur_flow_data_dir/${TOP}.${SESSION}.sdf.gz
#{%- endif %}

########################################################################
# EXPORT (ICE)
#
{% if local.GEN_ICE == "true" %} 
    # set output_dir_ice /proj/Pelican/WORK/ericl/hash_top/signoff/PTSI/ice_output
    # set scenario $SESSION
    # source /tools_lib3/apps/empyrean/icexplorer_2016.12.sp2_lnx26_x86_64/icexplorer_2016.12.sp2_lnx26_x86.64_20170730/library/pt_utils.tcl
    # report_scenario_data_for_icexplorer $scenario $output_dir_ice
    # report_pba_paths_for_icexplorer $scenario $output_dir_ice min_max 500000 50
{%- endif %}

########################################################################
# EXPORT (REDHAWK)
#
{% if local.GEN_RH == "true" %} {
}
{%- endif %}

########################################################################
# REPORT (WITHOUT IO)
#
set all_clock_inputs ""
foreach_in_collection clock [ all_clocks ] {
       foreach_in_collection source [ get_attribute $clock sources ] {
               set all_clock_inputs [ add_to_collection $all_clock_inputs $source ]
       }
}
set all_data_inputs [ remove_from_collection [ all_inputs ] $all_clock_inputs ]
set all_data_outputs [ remove_from_collection [ all_outputs ] $all_clock_inputs ]

set_false_path -from $all_data_inputs
set_false_path -to $all_data_outputs

eval $command > $cur_flow_rpt_dir/${TOP}.${SESSION}.wo_io.rpt
exec perl {{cur.config_plugins_dir}}/pt_scripts/scripts/check_violation_summary.pl \
     $cur_flow_rpt_dir/${TOP}.${SESSION}.wo_io.rpt \
   > $cur_flow_rpt_dir/${TOP}.${SESSION}.wo_io.rpt.summary
eval $new_command > $cur_flow_rpt_dir/${TOP}.${SESSION}.wo_io.rpt.more

{% if local.GEN_SDF == "true" %} 
exit
{%- endif %}
########################################################################
# REPORT DRC
#
report_constraint -nosplit -significant_digits 3 -all_violators -verbose -max_capacitance > $cur_flow_rpt_dir/report_constraint.max_capacitance.rpt
exec perl {{cur.config_plugins_dir}}/pt_scripts/scripts/check_max_capacitance.pl $cur_flow_rpt_dir/report_constraint.max_capacitance.rpt\
   > $cur_flow_rpt_dir/report_constraint.max_capacitance.rpt.summary
report_constraint -nosplit -significant_digits 3 -all_violators -verbose -max_fanout > $cur_flow_rpt_dir/report_constraint.max_fanout.rpt
exec perl {{cur.config_plugins_dir}}/pt_scripts/scripts/check_max_fanout.pl $cur_flow_rpt_dir/report_constraint.max_fanout.rpt\
   > $cur_flow_rpt_dir/report_constraint.max_fanout.rpt.summary
report_constraint -nosplit -significant_digits 3 -all_violators -verbose -max_transition > $cur_flow_rpt_dir/report_constraint.max_transition.rpt
exec perl {{cur.config_plugins_dir}}/pt_scripts/scripts/check_max_transition.pl $cur_flow_rpt_dir/report_constraint.max_transition.rpt\
   > $cur_flow_rpt_dir/report_constraint.max_transition.rpt.summary
report_constraint -nosplit -significant_digits 3 -all_violators -verbose -min_period > $cur_flow_rpt_dir/report_constraint.min_period.rpt
exec perl {{cur.config_plugins_dir}}/pt_scripts/scripts/get_min_pulse_summary.pl $cur_flow_rpt_dir/report_constraint.min_period.rpt \
   > $cur_flow_rpt_dir/report_constraint.min_period.rpt.summary
report_min_pulse_width -all_violators -significant_digits 3 -nosplit -path_type full_clock_expanded -input_pins > $cur_flow_rpt_dir/min_pulse_violation.rpt
exec perl {{cur.config_plugins_dir}}/pt_scripts/scripts/get_min_pulse_summary.pl $cur_flow_rpt_dir/min_pulse_violation.rpt \
   > $cur_flow_rpt_dir/min_pulse_violation.rpt.summary
report_si_double_switching -nosplit -rise -fall > $cur_flow_rpt_dir/report_si_double_switching.rpt

########################################################################
# REPORT NOISE
#
set_noise_parameters -enable_propagation -analysis_mode report_at_endpoint
check_noise > $cur_flow_rpt_dir/check_noise.report
update_noise
report_noise -nosplit -all_violators -above -low > $cur_flow_rpt_dir/report_noise_all_viol_abv_low.rpt
report_noise -all_violators -verbose > $cur_flow_rpt_dir/report_noise.rpt
exec perl {{cur.config_plugins_dir}}/pt_scripts/scripts/get_noise_report.pl $cur_flow_rpt_dir/report_noise.rpt \
   > $cur_flow_rpt_dir/report_noise.rpt.sum
report_noise_violation_sources -max_sources_per_endpoint 1000 -nworst_endpoints 1000 > $cur_flow_rpt_dir/report_noise_violation_sources.rpt


########################################################################
# REPORT CLOCKS
#
# ====== Clock Skew ========
report_clock_timing -nosplit -significant_digits 3 -type skew > $cur_flow_rpt_dir/clock_timing.${SESSION}.skew.rpt
report_clock_timing -nosplit -significant_digits 3 -type skew -verbose > $cur_flow_rpt_dir/clock_timing.${SESSION}.skew.detail.rpt

# ==== Clock Latency =======
file delete -force $cur_flow_rpt_dir/report_clock_timing.${SESSION}.latency.rpt
foreach_in_collection clock [ get_clocks * ] {
    set clock_name [ get_attribute $clock full_name ]
    foreach_in_collection source [ get_attribute $clock sources ] {
        set source_name [ get_attribute $source full_name ]
        echo [ format "# report_clock_timing -nosplit -significant_digits 3 -type latency -nworst 9999999 -clock %s -from %s" $clock_name $source_name ] \
        >> $cur_flow_rpt_dir/report_clock_timing.${SESSION}.latency.rpt
        report_clock_timing -nosplit -significant_digits 3 -type latency -nworst 9999999 -clock $clock_name -from $source_name \
        >> $cur_flow_rpt_dir/report_clock_timing.${SESSION}.latency.rpt
    }
}
exec perl {{cur.config_plugins_dir}}/pt_scripts/scripts/check_report_clock_timing_latency.pl \
     $cur_flow_rpt_dir/report_clock_timing.${SESSION}.latency.rpt \
   > $cur_flow_rpt_dir/report_clock_timing.${SESSION}.latency.rpt.summary

# ==== Clock Cell Type =======
source {{cur.config_plugins_dir}}/pt_scripts/scripts/check_clock_cell_type.tcl
check_clock_cell_type >  $cur_flow_rpt_dir/check_clock_cell_type.rpt
report_constraint -all_violators -nosplit >> $cur_flow_rpt_dir/report_constraints_all.rpt
check_timing -verbose >> $cur_flow_rpt_dir/check_timing.rpt
puts "INFO: PT finished."
########################################################################
