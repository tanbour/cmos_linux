puts "Alchip-info: Running script [info script]\n"

set cur_stage          "$cur_stage"
#exec mkdir -p $blk_rpt_dir/$cur_stage

####################################
## Timing Constraints 
####################################
### Check Timing ###
redirect -file $blk_rpt_dir/${cur_stage}.check_timing.addJZ.rpt {check_timing -all}

## Additional Zero interconnect delay reporting at init_design stage
if {$fp_report_zero_interconnect_delay_timing == "true" } {
  if {$cur_stage == "01_fp"} {
    puts "Alchip-info: time.delay_calculation_style is set to zero_interconnect ...\n"
    set_app_options -name time.delay_calculation_style -value zero_interconnect
    puts "Alchip-info: reporting timing and QoR in zero_interconnect mode ...\n"
  }
}
##  Condition
puts "Alchip-info: reporting timing constraints ...\n"
if {$common_report_scenario == "true"} { 
  redirect -file $blk_rpt_dir/$cur_stage.scenarios.rpt {report_scenarios}
  redirect -file $blk_rpt_dir/${cur_stage}.report_corners.addJZ.rpt {report_corners}
  redirect -file $blk_rpt_dir/${cur_stage}.report_timing_derate.addJZ.rpt {report_timing_derate -nosplit}
  redirect -app -file $blk_rpt_dir/${cur_stage}.report_timing_derate.addJZ.rpt {report_timing_derate -nosplit -increment}
  redirect -file $blk_rpt_dir/${cur_stage}.report_parasitic_parameters.addJZ.rpt {report_parasitic_parameters}
  redirect -file $blk_rpt_dir/${cur_stage}.ocv.sum {
    set all_scenarios [get_scenario -q * -fi " active" ]
    if {[get_app_option_value -name time.aocvm_enable_analysis]} {
      puts "## AOCV type:"
      foreach_in_collection c $all_scenarios {
          report_ocvm -type aocvm -nosplit -scenario $c
          set list_annotated_f "$blk_rpt_dir/${cur_stage}.aocv.list_annotated.[get_object_name $c].rpt"
          puts "# Detail list_annotated : $list_annotated_f"
          redirect $list_annotated_f {report_ocvm -type aocvm -nosplit -list_annotated -lib_cell -scenario $c}
          set list_not_annotated_f "$blk_rpt_dir/${cur_stage}.aocv.list_not_annotated.[get_object_name $c].rpt"
          puts "# Detail list_not_annotated : $list_not_annotated_f"
          redirect $list_not_annotated_f {report_ocvm -type aocvm -nosplit -list_not_annotated -lib_cell -scenario $c}
      }
    }
    if {[get_app_option_value -name time.pocvm_enable_analysis]} {
      puts "## POCV type:"
      foreach_in_collection c $all_scenarios {
          report_ocvm -type aocvm -nosplit -scenario $c
          set list_annotated_f "$blk_rpt_dir/${cur_stage}.pocv.list_annotated.[get_object_name $c].rpt"
          puts "# Detail list_annotated : $list_annotated_f"
          redirect $list_annotated_f {report_ocvm -type pocvm -nosplit -list_annotated -lib_cell -scenario $c}
          set list_not_annotated_f "$blk_rpt_dir/${cur_stage}.pocv.list_not_annotated.[get_object_name $c].rpt"
          puts "# Detail list_not_annotated : $list_not_annotated_f"
          redirect $list_not_annotated_f {report_ocvm -type pocvm -nosplit -list_not_annotated -lib_cell -scenario $c}
      }
    }
  }
}
if {$common_report_pvt == "true" } {
  redirect -file $blk_rpt_dir/$cur_stage.pvt.rpt {report_pvt}
}
####################################
## Timing and QoR 
####################################
puts "Alchip-info: reporting timing and QoR ...\n"
## QoR
if {$common_report_qor == "true" } {
  redirect -file $blk_rpt_dir/$cur_stage.qor.rpt {report_qor -scenarios [all_scenarios]}
  redirect -tee -append -file $blk_rpt_dir/$cur_stage.qor.rpt {report_qor -summary}
}
## Timing (-variation enabled for POCV)
set setup_scenarios [get_scenario -q * -fi "setup && active"]
set hold_scenarios [get_scenario -q * -fi "hold && active"]

## worst path --> default max path 1
if {$common_report_timing == "true" } {
  if {[sizeof $setup_scenarios]} {
    if {[get_app_option_value -name time.pocvm_enable_analysis]} {
      redirect -file $blk_rpt_dir/$cur_stage.timing.max.rpt {report_timing -nosplit -delay max -scenarios [all_scenarios] \
      -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -variation}
    } else {
      redirect -file $blk_rpt_dir/$cur_stage.timing.max.rpt {report_timing -nosplit -delay max -scenarios [all_scenarios] \
      -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group}
    }
  }
  if {[sizeof $hold_scenarios]} {
    if {[get_app_option_value -name time.pocvm_enable_analysis]} {
      redirect -file $blk_rpt_dir/$cur_stage.timing.min.rpt {report_timing -nosplit -delay min -scenarios [all_scenarios] \
      -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -variation}
    } else {
      redirect -file $blk_rpt_dir/$cur_stage.timing.min.rpt {report_timing -nosplit -delay min -scenarios [all_scenarios] \
      -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group}
    }
  }
}
# Each scenarios timing reports.
if {$common_report_detail_timing == "true" } {
  foreach_in sc $setup_scenarios {
    set sc_name [get_object_name $sc]
    if {[get_app_option_value -name time.pocvm_enable_analysis]} {
      redirect -file $blk_rpt_dir/$cur_stage.${sc_name}_timing.max.rpt {report_timing -nosplit -slack_lesser_than 0 -max_paths 99999 -nosplit -sort_by slack -nets -input_pins -significant_digits 3  -derate -crosstalk_delta -scenarios $sc -variation}
    } else {
      redirect -file $blk_rpt_dir/$cur_stage.${sc_name}_timing.max.rpt {report_timing -nosplit -slack_lesser_than 0 -max_paths 99999 -nosplit -sort_by slack -nets -input_pins -significant_digits 3  -derate -crosstalk_delta -scenarios $sc} 
    }
    exec ${blk_utils_dir}/icc2_utils/check_violation_summary.pl $blk_rpt_dir/$cur_stage.${sc_name}_timing.max.rpt > $blk_rpt_dir/$cur_stage.${sc_name}_timing.max.rpt.sum
    exec ${blk_utils_dir}/icc2_utils/sort_sta_violation_summary.pl  $blk_rpt_dir/$cur_stage.${sc_name}_timing.max.rpt.sum > $blk_rpt_dir/$cur_stage.${sc_name}_timing.max.rpt.sum.sort
    exec ${blk_utils_dir}/icc2_utils/scr_report/spilt_group_of_timing.update.pl $blk_rpt_dir/$cur_stage.${sc_name}_timing $blk_rpt_dir/$cur_stage.${sc_name}_timing.max.rpt 
    exec gzip -f $blk_rpt_dir/$cur_stage.${sc_name}_timing.max.rpt
    exec rm $blk_rpt_dir/$cur_stage.${sc_name}_timing.max.rpt.sum
  }
  foreach_in sc $hold_scenarios {
    set sc_name [get_object_name $sc]
    if {[get_app_option_value -name time.pocvm_enable_analysis]} {
      redirect -file $blk_rpt_dir/$cur_stage.${sc_name}_timing.min.rpt {report_timing -nosplit -slack_lesser_than 0 -max_paths 99999 -nosplit -sort_by slack -nets -input_pins -significant_digits 3  -derate -crosstalk_delta -scenarios $sc -variation -delay min}
    } else {
      redirect -file $blk_rpt_dir/$cur_stage.${sc_name}_timing.min.rpt {report_timing -nosplit -slack_lesser_than 0 -max_paths 99999 -nosplit -sort_by slack -nets -input_pins -significant_digits 3  -derate -crosstalk_delta -scenarios $sc -delay min}
    }
    exec ${blk_utils_dir}/icc2_utils/check_violation_summary.pl $blk_rpt_dir/$cur_stage.${sc_name}_timing.min.rpt > $blk_rpt_dir/$cur_stage.${sc_name}_timing.min.rpt.sum
    exec ${blk_utils_dir}/icc2_utils/sort_sta_violation_summary.pl  $blk_rpt_dir/$cur_stage.${sc_name}_timing.min.rpt.sum > $blk_rpt_dir/$cur_stage.${sc_name}_timing.min.rpt.sum.sort
    exec ${blk_utils_dir}/icc2_utils/scr_report/spilt_group_of_timing.update.pl $blk_rpt_dir/$cur_stage.${sc_name}_timing $blk_rpt_dir/$cur_stage.${sc_name}_timing.min.rpt
    exec gzip -f $blk_rpt_dir/$cur_stage.${sc_name}_timing.min.rpt
    exec rm $blk_rpt_dir/$cur_stage.${sc_name}_timing.min.rpt.sum
  }
}

if {$common_report_constraint == "true" } {
## Constraint violations
  redirect -file $blk_rpt_dir/$cur_stage.constraint.rpt {report_constraint -all_violators -max_transition -max_capacitance -scenarios [all_scenarios]}
}

## Debug ##
if {[info exists common_analyze_design_violations]} {
  if {$common_analyze_design_violations == "true"} {
    # analyze_design_violations for setup
    if {[regexp "place" $cur_stage] || [regexp "clock" $cur_stage]} {
       redirect -file $blk_rpt_dir/${cur_stage}.analyze_design_violations.setup.addJZ.rpt {analyze_design_violations -type setup -stage preroute -output ${blk_rpt_dir}/${cur_stage}.analyze_design_violations.setup}
    } elseif {[regexp "route" $cur_stage]} {
       redirect -file $blk_rpt_dir/${cur_stage}.analyze_design_violations.setup.addJZ.rpt {analyze_design_violations -type setup -stage postroute -output ${blk_rpt_dir}/${cur_stage}.analyze_design_violations.setup}
    }
    if {[sizeof [get_scenarios -filter "hold && active" -q]]} {
       # analyze_design_violations for hold
      if {[regexp "place" $cur_stage] || [regexp "clock" $cur_stage]} {
          redirect -file $blk_rpt_dir/${cur_stage}.analyze_design_violations.hold.addJZ.rpt {analyze_design_violations -type hold -stage preroute -output ${blk_rpt_dir}/${cur_stage}.analyze_design_violations.hold}
      } elseif {[regexp "route" $cur_stage]} {
          redirect -file $blk_rpt_dir/${cur_stage}.analyze_design_violations.hold.addJZ.rpt {analyze_design_violations -type hold -stage postroute -output ${blk_rpt_dir}/${cur_stage}.analyze_design_violations.hold}
       }
    }
  }
}
####################################
## UPF and power 
####################################
# redirect -file $blk_rpt_dir/$cur_stage.check_mv_design {check_mv_design} ;# included in the check_design commands
if {$common_report_threshold_voltage_group == "true" } {
	redirect -file $blk_rpt_dir/$cur_stage.threshold_voltage_group.rpt {report_threshold_voltage_group}
}
if {$common_report_power == "true" } {
  redirect -file $blk_rpt_dir/$cur_stage.power.rpt {report_power -verbose -scenarios [all_scenarios]}
}
if {$common_report_mv_path == "true" } {
  redirect -file $blk_rpt_dir/$cur_stage.mv_path.rpt {report_mv_path -all_not_associated}
}
####################################
## Clock trees 
####################################
if {$cts_report_clock_tree_info == "true"} {
  if {$cur_stage == "03_clock" || $cur_stage == "04_clock_opt" || $cur_stage == "05_route" || $cur_stage == "06_route_opt" } {
	  puts "Alchip-info: reporting clock tree information and QoR ...\n"
# report clock timing for each scenario from Alicez
    foreach_in_collection SCENARIO [get_scenario -fi "active"] {
      set SCENARIO_NAME [get_object_name $SCENARIO]
      current_scenario $SCENARIO_NAME 
      set output_dir $blk_rpt_dir/${cur_stage}_report/${SCENARIO_NAME}
      exec mkdir -p $output_dir
      exec rm -f $output_dir/report_clock_timing.latency.rpt; exec touch $output_dir/report_clock_timing.latency.rpt;
      set block_clocks [ get_clocks * -fi "is_virtual == false"]
      set block_clocks_num [sizeof $block_clocks]
      if {![info exist max_rpt_block_clocks_num]} {set max_rpt_block_clocks_num 50}
      set no_regs_clocks [get_clocks -q ""]
      if {$block_clocks_num < $max_rpt_block_clocks_num} {
        foreach_in_collection clock $block_clocks {
          set clock_regs [all_registers -clock $clock]
          if {[sizeof $clock_regs] == 0} {append_to_collection -u no_regs_clocks $clock;continue}
          set clock_name [ get_attribute $clock full_name ]
          set file_use_clock_name [regsub -all "/"  ${clock_name} "_"]
          set clock_name_latency_file "$output_dir/${file_use_clock_name}.report_clock_timing.latency.rpt"
          exec rm -f $clock_name_latency_file; exec touch  $clock_name_latency_file;
          set clock_name [ get_attribute $clock full_name ]
          foreach_in_collection source [ get_attribute $clock sources ] {
            # ---> puts clock info to same sum rpt: $output_dir/report_clock_timing.latency.rpt
          	set source_name [ get_attribute $source full_name ]
          	echo [ format "# report_clock_timing -nosplit -significant_digits 3 -type latency -nworst 9999999 -clock %s -from %s -scenarios $SCENARIO_NAME" $clock_name $source_name ] \
          	>> $output_dir/report_clock_timing.latency.rpt
          	set fail [catch {report_clock_timing -nosplit -significant_digits 3 -type latency -nworst 9999999 -clock $clock_name -from $source_name -scenarios $SCENARIO_NAME \
          	>> $output_dir/report_clock_timing.latency.rpt}]
            if {$fail} {redirect -app  $output_dir/report_clock_timing.latency.rpt {puts "# Alchip-warning: Fail to reports"}}
            # ---> each clock latency conditions.       
            if {$fail == 0} {
          	  echo [ format "# report_clock_timing -nosplit -significant_digits 3 -type latency -nworst 9999999 -clock %s -from %s -scenarios $SCENARIO_NAME" $clock_name $source_name ] \
          	>> $clock_name_latency_file
          	  report_clock_timing -nosplit -significant_digits 3 -type latency -nworst 9999999 -clock $clock_name -from $source_name -scenarios $SCENARIO_NAME \
          	>> $clock_name_latency_file
		
          	  exec ${blk_utils_dir}/icc2_utils/check_report_clock_timing_latency.pl  $clock_name_latency_file  > $output_dir/${file_use_clock_name}.report_clock_timing.latency.summary.rpt
            } else { if {[file exists $clock_name_latency_file]} {exec mv $clock_name_latency_file ${clock_name_latency_file}.error}}
          }
        }
        exec /usr/bin/perl ${blk_utils_dir}/icc2_utils/check_report_clock_timing_latency.pl $output_dir/report_clock_timing.latency.rpt > $output_dir/$cur_stage.report_clock_timing.latency.summary.rpt
      }
      set no_regs_clocks_num [sizeof $no_regs_clocks]
      if {$no_regs_clocks_num} {redirect $output_dir/no_regs_clocks.rpt {puts "# $no_regs_clocks_num clocks no regs\nset no_regs_clocks \[get_clocks { \\\n\t[join [get_object_name $no_regs_clocks] "\n\t"]\n}\]"}}
      report_clock_qor  -type summary -significant_digits 3  -scenarios $SCENARIO_NAME    > $output_dir/$cur_stage.report_clock_qor_clock_summary.rpt
      report_clock_qor  -type structure  -significant_digits 3  -scenarios $SCENARIO_NAME > $output_dir/report_clock_qor_clock_structure.rpt
      report_clock_qor  -histogram_type latency -histogram_bins 15 -significant_digits 3 -nosplit  -scenarios $SCENARIO_NAME > $output_dir/report_clock_qor_clock_latency.rpt
    }
# -----------> add
   redirect -file $blk_rpt_dir/${cur_stage}.report_clock_qor.area.addJZ.rpt {report_clock_qor -type area -nosplit}
   redirect -file $blk_rpt_dir/${cur_stage}.report_clock_balance_groups.addJZ.rpt {report_clock_balance_groups}
   redirect -file $blk_rpt_dir/${cur_stage}.report_clock_balance_points.addJZ.rpt {report_clock_balance_points -nosplit}
   redirect -file $blk_rpt_dir/${cur_stage}.report_clock_skew_groups.addJZ.rpt {report_clock_skew_groups}
   # local_skew
   if {[get_app_option_value -name cts.compile.enable_local_skew] || [get_app_option_value -name cts.optimize.enable_local_skew] || [get_app_option_value -name clock_opt.flow.enable_ccd]} {
      redirect -file $blk_rpt_dir/${cur_stage}.report_clock_qor.local_skew.addJZ.rpt {report_clock_qor -type local_skew -nosplit}
   }
   # all Violators
   redirect -file $blk_rpt_dir/${cur_stage}.report_clock_qor.drc_violators.addJZ.rpt {report_clock_qor -type drc_violators -all -nosplit}
  }
}
# ------> add
## placemenet stage, get ICG fanout & stage condition: icgs.stage.fanout.info.preCTS.tcl
## Post CTS stage, get ICG fanout & stage & latency condition: icgs.latency.fanout.stage.info.postCTS.addJZ.rpt
if {[regexp {place} $cur_stage]} {
   set output_file "$blk_rpt_dir/02_place.icgs.stage.fanout.info.preCTS.tcl"
   source ${blk_utils_dir}/icc2_utils/scr_report/get_icgs.stage.fanout.prects.tcl
} elseif {[regexp {clock} $cur_stage]} {
   set stage_fanout_file  "$blk_rpt_dir/02_place.icgs.stage.fanout.info.preCTS.tcl"
   if {![catch {glob $stage_fanout_file}]} {
      set stage_fanout_file [glob $stage_fanout_file]
   }
   set output_file "$blk_rpt_dir/${cur_stage}.icgs.latency.fanout.stage.info.postCTS.addJZ.rpt"
   source ${blk_utils_dir}/icc2_utils/scr_report/check_icg_latency.with.icgs_stage_fanout.postcts.tcl
}

####################################
## Routing  
####################################
if {$common_report_congestion_map == "true" } {
#congestion map
  if {$cur_stage == "02_place" | $cur_stage == "03_clock"| $cur_stage == "04_clock_opt" | $cur_stage == "05_route" | $cur_stage == "06_route_opt"} {
    redirect -tee -file $blk_rpt_dir/$cur_stage.route_global.congestion_map_only.rpt {route_global -congestion_map_only true}
  }
}
## check_routes is performed for postroute
if {$route_check_route == "true" } {
  if {$cur_stage == "03_clock"| $cur_stage == "04_clock_opt" | $cur_stage == "05_route" | $cur_stage == "06_route_opt"} {
	  puts "Alchip-info: Verifying and checking routing ...\n"
	  redirect -file $blk_rpt_dir/$cur_stage.check_routes.rpt {check_routes}
    redirect -file $blk_rpt_dir/$cur_stage.report_routing_rules.rpt {report_routing_rules -verbose}
    redirect -file $blk_rpt_dir/$cur_stage.report_clock_routing_rules.rpt {report_clock_routing_rules}
  }
}
## DRC
set short_txt "$blk_rpt_dir/$cur_stage.short_drc.rpt"
set short_png "$blk_rpt_dir/$cur_stage.short_drc.png"
if {$cur_stage == "05_route" | $cur_stage == "06_route_opt"} {
  source -e -v ${blk_utils_dir}/icc2_utils/scr_report/GetShortDRC.info.tcl
}

####################################
## report_design  
####################################
## utilization & VT & paths group & bounds & report design & dont use
redirect -file $blk_rpt_dir/${cur_stage}.report_size_only.rpt {report_size_only -all}
if {$common_report_utilization == "true" } {
  redirect -tee -file $blk_rpt_dir/$cur_stage.utilization.rpt {report_utilization}
}
redirect -file $blk_rpt_dir/${cur_stage}.report_vt.addJZ.rpt {source ${blk_utils_dir}/icc2_utils/scr_report/report_vt_all.tcl}
redirect -file $blk_rpt_dir/${cur_stage}.get_cells_drivers.addJZ.rpt {source ${blk_utils_dir}/icc2_utils/scr_report/get_cells_drivers.tcl}
redirect -file $blk_rpt_dir/${cur_stage}.report_path_groups.addJZ.rpt {report_path_groups -nosplit -modes [all_modes]}
if {[sizeof [get_bounds * -q]]} {
  redirect -file $blk_rpt_dir/${cur_stage}.report_bounds.addJZ.rpt {report_bounds}
}
if {[regexp {route} $cur_stage]} {
   redirect -file $blk_rpt_dir/${cur_stage}.report_design.addJZ.rpt {report_design -library -netlist -floorplan -routing -nosplit}
} else {
   redirect -file $blk_rpt_dir/${cur_stage}.report_design.addJZ.rpt {report_design -library -netlist -floorplan -nosplit}
}
  
####################################
## MISC  
####################################
if {$common_report_units == "true" } {
  puts "Alchip-info: reporting units ...\n"
	redirect -file $blk_rpt_dir/$cur_stage.units.rpt {report_units}
}

## Reset Zero interconnect delay reporting at init_design stage
if {$fp_report_zero_interconnect_delay_timing == "true" } { 
  if {$cur_stage == "01_fp"} {
	  puts "Alchip-info: time.delay_calculation_style is reset...\n"
	  reset_app_options time.delay_calculation_style
  }
}

## # report_app_option & printvar & print_message_info
redirect -file $blk_rpt_dir/${cur_stage}.printvar.app.addJZ.rpt {printvar -application}
redirect -file $blk_rpt_dir/${cur_stage}.printvar.user.addJZ.rpt {printvar -user_defined}

## Error & Warining ##
redirect -file $blk_rpt_dir/${cur_stage}.print_message_info.sum  {print_message_info -ids * -summary}

puts "Alchip-info: Completed script [info script]\n"

