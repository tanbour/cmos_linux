#==================================== Part 0: history ===============================================
# 1. Reduce 10% for (cell, data, late) base Jack Lu's OCV table.
# 2. Hold use sansung's criteria to replace Jack Lu's
# 3. Delta V/T derating for tt0p4v use James Huang's criteria @5mV, @5C
#
# Default: POCV ONLY

#====================================== Part 1: OCV =================================================
# ENABLE_OCV
if {[info exists ENABLE_OCV] & $ENABLE_OCV == "true"} {
puts "INFO: OCV is enable"
puts "INFO: apply OCV setting. Start ..."
reset_timing_derate
foreach voltage $VOLTAGE {
    set flatocv_instances ""
    if {$MV_LIBRARY_INST_MAP($voltage) != ""} {
        foreach inst $MV_LIBRARY_INST_MAP($voltage) {
              set cells [get_cells $inst]
             if {[get_attribute [get_cells $inst] is_hierarchical]} {
                   set cells [get_cells * -hierarchical -filter "full_name =~ $inst/*"]
             }
             if {$flatocv_instances == ""} {
                   set flatocv_instances $cells
             } else {
                   set flatocv_instances [add_to_collection $flatocv_instances $cells]
             }
        }
        #set flatocv_instances [get_cells * -hierarchical -filter "full_name =~ $MV_LIBRARY_INST_MAP($voltage)/*"
    }
    set derate_value [list 1.000 1.000 1.000 1.000 1.000 1.000 1.000 1.000] ;# default value.
    switch $voltage {
        "tt0p4v" {
            if {[regexp {max|setup} $CHECK_TYPE]} {
                switch $LIB_CORNER {
                    "tt85"  {set derate_value [list 1.045 0.889 1.100 0.900 1.152 0.889 1.100 1.000]}
                }
            } elseif {[regexp {min|hold} $CHECK_TYPE]} {
		if {[regexp {cworst} $RC_CORNER]} {
                    switch $LIB_CORNER {
                        "wc"  {set derate_value [list 1.045 0.889 1.000 0.900 1.045 0.682 1.000 0.900]}
                        "wcz" {set derate_value [list 1.045 0.889 1.000 0.900 1.045 0.682 1.000 0.900]}
                        "ml"  {set derate_value [list 1.111 0.955 1.000 0.900 1.111 0.748 1.000 0.900]}
                        "ltz" {set derate_value [list 1.111 0.955 1.000 0.900 1.111 0.748 1.000 0.900]}
                    }
                } else {
                    switch $LIB_CORNER {
                        "ml"  {set derate_value [list 1.111 0.955 1.100 1.000 1.111 0.748 1.000 1.000]}
                        "ltz" {set derate_value [list 1.111 0.955 1.100 1.000 1.111 0.748 1.000 1.000]}
                    }
                }
            }
        }
        "tt0p75v" {
            if {[regexp {max|setup} $CHECK_TYPE]} {
                switch $LIB_CORNER {
                    "tt85"  {set derate_value [list 1.045 0.889 1.100 0.900 1.152 0.889 1.100 1.000]}
                }
            } elseif {[regexp {min|hold} $CHECK_TYPE]} {
		if {[regexp {cworst} $RC_CORNER]} {
                    switch $LIB_CORNER {
                        "wc"  {set derate_value [list 1.153 1.000 1.153 1.000 1.153 1.000 1.153 1.000]}
                        "wcz" {set derate_value [list 1.153 1.000 1.153 1.000 1.153 1.000 1.153 1.000]}
                        "ml"  {set derate_value [list 1.153 1.000 1.153 1.000 1.153 1.000 1.153 1.000]}
                        "ltz" {set derate_value [list 1.153 1.000 1.153 1.000 1.153 1.000 1.153 1.000]}
                    }
                } else {
                    switch $LIB_CORNER {
                        "ml"  {set derate_value [list 1.153 1.000 1.153 1.000 1.153 1.000 1.153 1.000]}
                        "ltz" {set derate_value [list 1.153 1.000 1.153 1.000 1.153 1.000 1.153 1.000]}
                    }
                }
            }
        }
    }
    set cmd "set_timing_derate -clock -late  -cell_delay [lindex $derate_value 0]  $flatocv_instances"; eval $cmd; 
    set cmd "set_timing_derate -clock -early -cell_delay [lindex $derate_value 1]  $flatocv_instances"; eval $cmd;
    set cmd "set_timing_derate -clock -late  -net_delay  [lindex $derate_value 2]  $flatocv_instances"; eval $cmd;
    set cmd "set_timing_derate -clock -early -net_delay  [lindex $derate_value 3]  $flatocv_instances"; eval $cmd;
    set cmd "set_timing_derate -data  -late  -cell_delay [lindex $derate_value 4]  $flatocv_instances"; eval $cmd;
    set cmd "set_timing_derate -data  -early -cell_delay [lindex $derate_value 5]  $flatocv_instances"; eval $cmd;
    set cmd "set_timing_derate -data  -late  -net_delay  [lindex $derate_value 6]  $flatocv_instances"; eval $cmd;
    set cmd "set_timing_derate -data  -early -net_delay  [lindex $derate_value 7]  $flatocv_instances"; eval $cmd;
    ## for debugging
    puts "==================================== $voltage =========================================================="
    puts "set_timing_derate -clock -late  -cell_delay [lindex $derate_value 0]  $MV_LIBRARY_INST_MAP($voltage)" 
    puts "set_timing_derate -clock -early -cell_delay [lindex $derate_value 1]  $MV_LIBRARY_INST_MAP($voltage)"
    puts "set_timing_derate -clock -late  -net_delay  [lindex $derate_value 2]  $MV_LIBRARY_INST_MAP($voltage)"
    puts "set_timing_derate -clock -early -net_delay  [lindex $derate_value 3]  $MV_LIBRARY_INST_MAP($voltage)"
    puts "set_timing_derate -data  -late  -cell_delay [lindex $derate_value 4]  $MV_LIBRARY_INST_MAP($voltage)"
    puts "set_timing_derate -data  -early -cell_delay [lindex $derate_value 5]  $MV_LIBRARY_INST_MAP($voltage)"
    puts "set_timing_derate -data  -late  -net_delay  [lindex $derate_value 6]  $MV_LIBRARY_INST_MAP($voltage)"
    puts "set_timing_derate -data  -early -net_delay  [lindex $derate_value 7]  $MV_LIBRARY_INST_MAP($voltage)"
    puts "======================================================================================================="
    puts "INFO: apply OCV setting for $voltage domain Done."
}
puts "INFO: apply OCV setting. Done."
report_timing_derate > {{cur.cur_flow_rpt_dir}}/timing_derate.rpt

}
#===================================== Part 2: AOCV or POCV =================================================
# && [lindex $VOLTAGE 0] == "tt0p75v"
# ENABLE POCV
if {[info exists ENABLE_POCV] && $ENABLE_POCV == "true" } {
    if {[file exists report_pocv_not_annotated.rpt]} {file delete {{cur.cur_flow_rpt_dir}}/report_pocv_not_annotated.rpt}
    puts "INFO: POCV is enable."
    puts "INFO: apply POCV setting, start ..."
    
    set timing_pocvm_enable_analysis  true
    set timing_pocvm_corner_sigma  3
    set timing_pocvm_report_sigma  3
    set timing_enable_slew_variation  true
    set read_parasitics_load_locations true
    set timing_enable_constraint_variation false
    set timing_enable_cumulative_incremental_derate true
    
    echo "Read pocvm $pocvWireFile" 	>> {{cur.cur_flow_rpt_dir}}/report_pocv_not_annotated.rpt
    echo "Read pocvm $pocvWireFile"
    read_aocvm $pocvWireFile 		>> {{cur.cur_flow_rpt_dir}}/report_pocv_not_annotated.rpt
    foreach voltage [array names MV_LIBRARY_INST_MAP] {
        if { [info exist pocvLibrary($voltage)] && $pocvLibrary($voltage) != "" } {
            foreach file $pocvLibrary($voltage) {
                echo "Read pocvm $file" >> {{cur.cur_flow_rpt_dir}}/report_pocv_not_annotated.rpt
                echo "Read pocvm $file"
                read_ocvm $file >> {{cur.cur_flow_rpt_dir}}/report_pocv_not_annotated.rpt
            }
        
        }
    }
    report_ocvm -type pocvm >> {{cur.cur_flow_rpt_dir}}/report_pocv_not_annotated.rpt
    #report_ocvm -type pocvm -coefficient -list_not_annotated -nosplit >> {{cur.cur_flow_rpt_dir}}/report_pocv_not_annotated.rpt
    report_ocvm -type pocvm -list_not_annotated -nosplit              >> {{cur.cur_flow_rpt_dir}}/report_pocv_not_annotated.rpt
    puts "INFO: apply POCV setting. Done."

} elseif {[info exists ENABLE_AOCV] && $ENABLE_AOCV == "true"} {
# ENABLE_AOCV
    puts "INFO: AOCV is enable."
    puts "INFO: apply AOCV setting, start ..."
    set timing_aocvm_enable_analysis true
    set timing_aocvm_analysis_mode combined_launch_capture_depth
    
    foreach voltage $VOLTAGE {
        if { [info exist aocvLibrary($voltage)] && $aocvLibrary($voltage) != "" } {
            foreach file $aocvLibrary($voltage) {
                echo "Read aocvm $file"    >> {{cur.cur_flow_log_dir}}/check_aocvm.log
                read_aocvm $file >> {{cur.cur_flow_log_dir}}/check_aocvm.log
            }
        }
    echo "Read aocvm $aocvWireFile" >> {{cur.cur_flow_log_dir}}/check_aocvm.log
    read_aocvm $aocvWireFile >> {{cur.cur_flow_log_dir}}/check_aocvm.log
    report_aocvm >> {{cur.cur_flow_log_dir}}/check_aocvm.log
    report_aocvm -list_not_annotated -nosplit > {{cur.cur_flow_rpt_dir}}/report_aocv_not_annotated.rpt

}
puts "INFO: apply AOCV setting. Done."
}

#==================================== Part 3: Delta V&T OCV ===============================================

foreach voltage $VOLTAGE {
    #set flatocv_instances ""
    #if {$MV_LIBRARY_INST_MAP($voltage) != ""} {
    #    set flatocv_instances [get_cells * -hierarchical -filter "full_name =~ $MV_LIBRARY_INST_MAP($voltage)/*"
    #}
    set vt_derate_value [list 1.000 1.000 1.000] ;# default value.
    switch $voltage {
        "tt0p4v" {
            #if {$ENABLE_POCV == "true"} {
            ##puts "INFO: OCV  = P + V + T @10mV, @10C, Jack Lu confirmed at 2018 Jan 25."
            puts "INFO: OCV = V + T @5mV, @5C, James Huang comfirmed at 2018 Jan 27."
            puts "INFO: No Delta V and Delta T derating for TT0P4V."
            #if {[regexp {max|setup} $CHECK_TYPE]} {
            #        set_timing_derate -increment -cell_delay -clock -early [expr 0 - 0.0409 - 0.0300] [get_lib_cells */*BWP*PDULVT]
            #} elseif {[regexp {min|hold} $CHECK_TYPE]} {
            #    switch $LIB_CORNER {
            #        "wcz" { set_timing_derate -increment -cell_delay        -early [expr 0 - 0.0409 - 0.0300] [get_lib_cells */*BWP*PDULVT]}
            #        "wc"  { set_timing_derate -increment -cell_delay        -early [expr 0 - 0.0409 - 0.0300] [get_lib_cells */*BWP*PDULVT]}
            #        "ltz" { set_timing_derate -increment -cell_delay -clock -late  [expr 0 + 0.0409 + 0.0300] [get_lib_cells */*BWP*PDULVT]}
            #        "ml"  { set_timing_derate -increment -cell_delay -clock -late  [expr 0 + 0.0409 + 0.0300] [get_lib_cells */*BWP*PDULVT]}
            #    }
            #}
            #}
        }
        "tt0p75v" {
            if {[regexp {max|setup} $CHECK_TYPE]} {
                   set_timing_derate -increment -cell_delay -clock -early [expr 0 - 0.033 - 0.016] [get_lib_cells *0p75*/*BWP*PDULVT]
            } elseif {[regexp {min|hold} $CHECK_TYPE]} {
                switch $LIB_CORNER {
                    "wcz" { set_timing_derate -increment -cell_delay        -early [expr 0 - 0.037 - 0.000] [get_lib_cells *0p675*/*BWP*PDULVT]}
                    "wc"  { set_timing_derate -increment -cell_delay        -early [expr 0 - 0.028 - 0.002] [get_lib_cells *0p675*/*BWP*PDULVT]}
                    "ltz" { set_timing_derate -increment -cell_delay -clock -late  [expr 0 + 0.024 + 0.005] [get_lib_cells *0p825*/*BWP*PDULVT]}
                    "ml"  { set_timing_derate -increment -cell_delay -clock -late  [expr 0 + 0.019 + 0.008] [get_lib_cells *0p825*/*BWP*PDULVT]}
                }
            }
        }
    }
}

report_timing_derate -increment > {{cur.cur_flow_rpt_dir}}/timing_derate_incr.rpt

#==================================== Part 4: MaxTrans ==============================================
if {[file exists maxTransConstraint.rpt]} {file delete maxTransConstraint.rpt}
puts "INFO: Applay Max Transition Setting as following,"
puts "==============================================================================="
puts "MaxTrans (clock) = min(clk_ocv_slew, clock_unc_slew, minPeriod/3, maxLibSlew)"
puts "MaxTrans (data)  = min(clk_ocv_slew, clock_unc_slew, minPeriod/6, maxLibSlew)"
puts "==============================================================================="
array unset pinList *
set pinList($defaultVoltage) [get_pins -quiet -hier * -filter "is_hierarchical==false && pin_direction==in"]
puts "INFO: Total Pins: [sizeof_collection $pinList($defaultVoltage)]"
foreach voltage [lrange $VOLTAGE 1 end] {
    set instances ""
    if {$MV_LIBRARY_INST_MAP($voltage) != ""} {
        foreach inst $MV_LIBRARY_INST_MAP($voltage) {
              set cells [get_cells $inst]
             if {[get_attribute [get_cells $inst] is_hierarchical]} {
                   set cells [get_cells * -hierarchical -filter "full_name =~ $inst/*"]
             }
             if {$instances == ""} {
                   set instances $cells
             } else {
                   set instances [add_to_collection $instances $cells]
             }
        }
        set pinList($voltage) [get_pins -of_object $instances -quiet -filter "is_hierarchical==false && pin_direction==in"]
        set pinList($defaultVoltage) [remove_from_collection $pinList($defaultVoltage) $pinList($voltage)]
    }
}

foreach voltage [array names pinList] {
    puts "INFO: MaxTrans for $voltage -- Pin Number:[sizeof_collection $pinList($voltage)]"
    set pins $pinList($voltage)
    set  clk_ocv_slew 0.100	;# from TSMC
    set data_ocv_slew 0.200	;# from TSMC
    set  clk_unc_slew  $clk_ocv_slew
    set data_unc_slew $data_ocv_slew
    switch $voltage {
        "tt0p4v" {
            set  clk_ocv_slew 0.100	;# estimation
            ## changed @Feb07, Feiwei required.
            if {[regexp {wc$} $LIB_CORNER]} {set clk_ocv_slew 0.200}
            if {[regexp {wcz} $LIB_CORNER]} {set clk_ocv_slew 0.200}
            if {[regexp {tt}  $LIB_CORNER]} {set clk_ocv_slew 0.120}
            set data_ocv_slew 0.350	;# estimation
            ## changed @Feb07, Feiwei required.
            if {[regexp {wc$} $LIB_CORNER]} {set data_ocv_slew 0.700}
            if {[regexp {wcz} $LIB_CORNER]} {set data_ocv_slew 0.800}
            set  clk_unc_slew  $clk_ocv_slew
            set data_unc_slew $data_ocv_slew
        }
        "tt0p75v" {
            set  clk_ocv_slew 0.100	;# from TSMC
            set data_ocv_slew 0.200	;# from TSMC
            set  clk_unc_slew  $clk_ocv_slew
            set data_unc_slew $data_ocv_slew
        }
    }
    set_max_transition $data_ocv_slew [current_design]
    set_max_transition $clk_ocv_slew [all_clocks] -clock_path

    ## apply max_clock_transition = min(1/6T, max_lib_slew)
    set clist [list]
    set design [current_design]
    set all_clock_pins [get_pins -quiet $pins -filter "defined(clocks)"]
    set clock_pins [get_pins -quiet $all_clock_pins -filter "is_clock_used_as_data==false"]
    set all_clock_pinsCount [sizeof_collection $clock_pins]
    puts "INFO: Clock Pin Counts: $all_clock_pinsCount"
    foreach_in_collection clock_pin $clock_pins {
        set clock_pin_name [get_object_name $clock_pin]
        set clocks [get_attribute $clock_pin clocks]
        set clocks [get_clocks $clocks -filter defined(period)]
        set min_period 10000000000
        foreach_in_collection clock $clocks {
            set period [get_attribute [get_clocks $clock] period]
            if {$period < $min_period} {set min_period $period}
        }
        set max_p_trans [format "%.3f" [expr $min_period/6.0]]
        set max_lib_trans [get_attribute [get_lib_pins -of $clock_pin] max_transition]
        set cell [get_cells -of [get_pins $clock_pin]]
        set is_memcell [get_attribute $cell is_memory_cell]
        set is_seqcell [get_attribute $cell is_sequential]
        set margin 0.000
        #if {$voltage == "tt0p4v"} {set margin 0.050}
        if {$is_seqcell == "true" && [regexp {BWP} [get_attribute $cell ref_name]]} {
            set max_c_trans [lindex [lsort -real [list $max_p_trans [expr $clk_unc_slew - $margin] $max_lib_trans]] 0]
        } else {
            set max_c_trans [lindex [lsort -real [list $max_p_trans $clk_ocv_slew $max_lib_trans]] 0]
        }
        #lappend clist [list $clock_pin_name $max_c_trans]
        set_max_transition -force $max_c_trans $clock_pin_name
    }
    
    
    ## apply max_data_uncertainty = min(1/3T, max_lib_slew)
    set dlist [list]
    set all_data_pins [get_pins $pins -filter "!defined(clocks)||is_clock_used_as_data==true"]
    set all_data_pinsCount [sizeof_collection $all_data_pins]
    puts "INFO: Data Pin Counts: $all_data_pinsCount"
    foreach_in_collection data_pin $all_data_pins {
        set pin_name [get_object_name $data_pin]
        set clocks ""
        set pin_arrivals [get_attribute -quiet $data_pin arrival_window]
        foreach pin_arrival $pin_arrivals {
            foreach tmp $pin_arrival {
                lappend clocks [lindex $tmp 0]
            }
        }
        set clock_count [llength $clocks]
        if {$clock_count == 0} {
            set max_p_trans 99999999999
        } else {
            set min_period 10000000000
            foreach clock $clocks {
                set period [get_attribute [get_clocks $clock] period]
                if {$period <$min_period} {set min_period $period}
            }
            set max_p_trans [format "%.3f" [expr $min_period/3.0]]
        }
        set cell [get_cells -of [get_pins $data_pin]]
        set is_memcell [get_attribute $cell is_memory_cell]
        set is_seqcell [get_attribute $cell is_sequential]
        set refName_cell [get_attribute $cell ref_name]
        set max_lib_trans [get_attribute [get_lib_pins -of $data_pin] max_transition]
        set margin 0.000
        if {$voltage == "tt0p4v"} {set margin 0.050}
        if {![regexp {BWP} $refName_cell]} {
             set max_d_trans [lindex [lsort -real [list $max_p_trans $data_ocv_slew $max_lib_trans]] 0]
        } elseif {$is_seqcell} {
             set max_d_trans [lindex [lsort -real [list $max_p_trans [expr $data_unc_slew - $margin] $max_lib_trans]] 0]
        } else {
             set max_d_trans [lindex [lsort -real [list $max_p_trans $max_lib_trans]] 0]
             if {$voltage == "tt0p4v"} {
             set max_d_trans [lindex [lsort -real [list $max_p_trans $data_unc_slew $max_lib_trans]] 0]
             }
        }
        #lappend dlist [list $pin_name $max_d_trans]
        set_max_transition -force $max_d_trans $pin_name
    }
    
    for {set i 0} {$i<[llength $clist]} {incr i} {
        set pin_name [lindex [lindex $clist $i] 0]
        set max_tran [lindex [lindex $clist $i] 1]
        #remove_max_trans $pin_name
        #set_max_transition -force $max_tran $pin_name
        #echo "set_max_transition -force $max_tran $pin_name" >> {{cur.cur_flow_rpt_dir}}/maxTransConstraint.rpt
    }
    
    
    for {set i 0} {$i<[llength $dlist]} {incr i} {
        set pin_name [lindex [lindex $dlist $i] 0]
        set max_tran [lindex [lindex $dlist $i] 1]
        #remove_max_trans $pin_name
        #set_max_transition -force $max_tran $pin_name
        #echo "set_max_transition -force $max_tran $pin_name" >> {{cur.cur_flow_rpt_dir}}/maxTransConstraint.rpt
    }
}
unset pins
unset all_clock_pins
unset all_data_pins
unset clock_pins
puts "INFO: Applay Max Transition -- Done."

#================================== Part 5: Noise Margin ============================================
puts "INFO: Apply Noise Margin Setting as following,"
puts "==============================================================================="
puts "INFO: Apply noise margin setting for non-ccs lib."
puts "==============================================================================="
array unset MacroPins *
set MacroPins($defaultVoltage) [get_pins -of_objects [get_cells -hierarchical  -filter "ref_name !~ *BWP*"] -filter "direction == in && is_hierarchical==false"]
foreach voltage [lrange $VOLTAGE 1 end] {
    set instances ""
    if {$MV_LIBRARY_INST_MAP($voltage) != ""} {
        foreach inst $MV_LIBRARY_INST_MAP($voltage) {
              set cells [get_cells $inst]
             if {[get_attribute [get_cells $inst] is_hierarchical]} {
                   set cells [get_cells * -hierarchical -filter "full_name =~ $inst/*"]
             }
             if {$instances == ""} {
                   set instances $cells
             } else {
                   set instances [add_to_collection $instances $cells]
             }
        }
        set MacroPins($voltage) [get_pins -of_object [get_cells $instances -quiet -filter "ref_name !~ *BWP*"] -quiet -filter "is_hierarchical==false && pin_direction==in"]
        set MacroPins($defaultVoltage) [remove_from_collection $MacroPins($defaultVoltage) $MacroPins($voltage)]
    }
}

foreach voltage [array names MacroPins] {
    puts "Noise for $voltage, Pin Number: [sizeof_collection $MacroPins($voltage)]"
    set macro_pins $MacroPins($voltage)
    switch $voltage {
        "tt0p4v" {
            switch $LIB_CORNER {
                "wc"    {set noise_margin [list [expr 0.36 * 0.9 * 0.4] [expr 0.36 * 0.9 * 0.3]]}
                "wcz"   {set noise_margin [list [expr 0.36 * 0.9 * 0.4] [expr 0.36 * 0.9 * 0.3]]}
                "tt85"  {set noise_margin [list [expr 0.40 * 1.0 * 0.4] [expr 0.40 * 1.0 * 0.3]]}
                "ml"    {set noise_margin [list [expr 0.44 * 1.1 * 0.4] [expr 0.44 * 1.1 * 0.3]]}
                "ltz"   {set noise_margin [list [expr 0.44 * 1.1 * 0.4] [expr 0.44 * 1.1 * 0.3]]}
            }
        }
        "tt0p75v" {
            switch $LIB_CORNER {
                "wc"    {set noise_margin [list [expr 0.675 * 0.9 * 0.4] [expr 0.675 * 0.9 * 0.3]]}
                "wcz"   {set noise_margin [list [expr 0.675 * 0.9 * 0.4] [expr 0.675 * 0.9 * 0.3]]}
                "tt85"  {set noise_margin [list [expr 0.750 * 1.0 * 0.4] [expr 0.750 * 1.0 * 0.3]]}
                "ml"    {set noise_margin [list [expr 0.825 * 1.1 * 0.4] [expr 0.825 * 1.1 * 0.3]]}
                "ltz"   {set noise_margin [list [expr 0.825 * 1.1 * 0.4] [expr 0.825 * 1.1 * 0.3]]}
            }
        }
    }
    if {[sizeof_collection $macro_pins] == 0} {
        puts "INFO: no macro cells for $voltage"
    } else {
        echo "set [lindex $noise_margin 1] on all macro cell input!"
        set_noise_margin [lindex $noise_margin 1] [get_pins $macro_pins]
        echo "Add noise margin [lindex $noise_margin 1] to [sizeof_collection $macro_pins] pins."
    }
}
#============================ Part 6: Hold Uncertainty Margin =======================================
# set_clock_uncertainty 0.200 [all_clocks]

foreach voltage [lrange $VOLTAGE 0 0] {
    switch $voltage {
        "tt0p4v" {
            #samsung# "tt85" {set_clock_uncertainty -hold 0.150 [all_clocks]}
            #samsung# "wc"   {set_clock_uncertainty -hold 0.150 [all_clocks]}
            #samsung# "wcz"  {set_clock_uncertainty -hold 0.150 [all_clocks]}
            #samsung# "ml"   {set_clock_uncertainty -hold 0.100 [all_clocks]}
            #samsung# "ltz"  {set_clock_uncertainty -hold 0.200 [all_clocks]}
            #if {$ENABLE_POCV == "true"} {
            #    set_clock_uncertainty -hold [expr 0.000 + 0.010] [all_clocks]
            # } else {
            #}
            # relax 5ps for TT0P4V at Feb 07, Jack Lu confirm for pelican.
            switch $LIB_CORNER {
                "tt85" {set_clock_uncertainty -hold [expr 0.120 - 0.005] [all_clocks]}
                "wc"   {set_clock_uncertainty -hold [expr 0.120 - 0.005] [all_clocks]}
                "wcz"  {set_clock_uncertainty -hold [expr 0.120 - 0.005] [all_clocks]}
                "ml"   {set_clock_uncertainty -hold [expr 0.120 - 0.005] [all_clocks]}
                "ltz"  {set_clock_uncertainty -hold [expr 0.120 - 0.005] [all_clocks]}
            }
            #set_clock_uncertainty -setup 0.180 [all_clocks]	;# with -10% derating, case 1, the results of meeting
            #set_clock_uncertainty -setup 0.120 [all_clocks]	;# with Jack's results, no change derate. mail at Jan30
        }
        "tt0p75v" {
            # LVF = 0, MB-inhouse = 0.050 ???
            switch $LIB_CORNER {
                "tt85" {set_clock_uncertainty -hold [expr 0.000 + 0.010] [all_clocks]}
                "wc"   {set_clock_uncertainty -hold [expr 0.000 + 0.010] [all_clocks]}
                "wcz"  {set_clock_uncertainty -hold [expr 0.000 + 0.010] [all_clocks]}
                "ml"   {set_clock_uncertainty -hold [expr 0.000 + 0.010] [all_clocks]}
                "ltz"  {set_clock_uncertainty -hold [expr 0.000 + 0.010] [all_clocks]}
            }
            # for MB-inhouse without POCV
            #set_clock_uncertainty -hold 0.050 [get_pins -of_objects [get_cells [all_registers] -filter "ref_name =~ MB*"] -filter "defined(clocks)"]
        }
    }
}
#============================== Part 7: MV interface Margin =========================================
# N/A

#source /proj/Pelican/WORK/carsonl/scripts/alcp_set_multi_drv_stop_propagate_nocheck.tcl
#alcp_set_multi_drv_stop_propagate_nocheck
