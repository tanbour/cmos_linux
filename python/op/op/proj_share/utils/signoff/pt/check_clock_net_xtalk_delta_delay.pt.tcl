#!/usr/bin/tclsh
########################################################################
# PROGRAM:     check_clock_net_xtalk_delta_delay.pt.tcl
# CREATOR:     Zachary Shi <zacharys@alchip.com>
# DATE:        Thu Mar 30 15:30:54 CST 2017
# DESCRIPTION: Check clock net xtalk delta delay in PrimeTime.
# USAGE:       check_clock_net_xtalk_delta_delay ?threshold? ?<report_name>?
# FOR:         GE-06-05
########################################################################
proc get_annotated_delay_delta { clock_net min_max } {

  set driver_pins  [ get_attribute [ get_pins -of_objects $clock_net -filter "direction == out || direction == inout" -leaf -quiet ] full_name ]
  set loading_pins [ get_attribute [ get_pins -of_objects $clock_net -filter "direction == in  || direction == inout" -leaf -quiet ] full_name ]
  set driver_pins  [ lsort -unique [ concat $driver_pins  [ get_attribute [ get_ports -of_objects $clock_net -filter "direction == in  || direction == inout" -quiet ] full_name ] ] ]
  set loading_pins [ lsort -unique [ concat $loading_pins [ get_attribute [ get_ports -of_objects $clock_net -filter "direction == out || direction == inout" -quiet ] full_name ] ] ]

  if { [ llength $driver_pins ] == 0 } {
    puts "Error: The net can't find the drive pin, please check it: $clock_net"
    return -1
  }

#  if { [ llength $driver_pins ] > 1 } {
#    puts "Information: The net is multi-drive net: $clock_net"
#  }

  if { [ llength $loading_pins ] == 0 } {
    puts "Error: The net can't find the loading pin, please check it: $clock_net"
    return -1
  }

  foreach driver_pin $driver_pins {
    foreach loading_pin $loading_pins {

      if { $driver_pin == $loading_pin } {
        continue
      }

      redirect -variable annotate_delay { report_delay_calculation -from $driver_pin -to $loading_pin -$min_max }
      set rise_delta_delay [ format "%0.9f" [ lindex $annotate_delay [ expr [ lindex [ lsearch -all $annotate_delay "delay:" ] 0 ] + 1 ] ] ]
      set fall_delta_delay [ format "%0.9f" [ lindex $annotate_delay [ expr [ lindex [ lsearch -all $annotate_delay "delay:" ] 2 ] + 1 ] ] ]

      if { $min_max == "max" } {
        if { [ llength [ info vars annotated_delay_delta ] ] == 0 } {

          if { $rise_delta_delay > $fall_delta_delay } {
            set annotated_delay_delta $rise_delta_delay
          } else {
            set annotated_delay_delta $fall_delta_delay
          }

        } else {

          if { $rise_delta_delay > $fall_delta_delay } {
            if { $annotated_delay_delta > $rise_delta_delay } {
              continue
            } else {
              set annotated_delay_delta $rise_delta_delay
            }
          } else {
            if { $annotated_delay_delta > $fall_delta_delay } {
              continue
            } else {
              set annotated_delay_delta $fall_delta_delay
            }
          }

        }

      } else {

        if { [ llength [ info vars annotated_delay_delta ] ] == 0 } {

          if { $rise_delta_delay > $fall_delta_delay } {
            set annotated_delay_delta $fall_delta_delay
          } else {
            set annotated_delay_delta $rise_delta_delay
          }

        } else {

          if { $rise_delta_delay > $fall_delta_delay } {
            if { $annotated_delay_delta > $fall_delta_delay } {
              set annotated_delay_delta $fall_delta_delay
            } else {
              continue
            }
          } else {
            if { $annotated_delay_delta > $rise_delta_delay } {
              set annotated_delay_delta $rise_delta_delay
            } else {
              continue
            }
          }

        }

      }
      
    }
  }

  if { [ llength [ info vars annotated_delay_delta ] ] == 0 } {
    puts "Error: Maybe the net's direction of driver/loading are the same, please check the xtalk delta delay used <report_delay_calculation> by manual: $clock_net"
  } else {
    return $annotated_delay_delta
  }
}


proc get_clock_nets {} {

  set clock_nets ""
  set clock_sources [ lsort -unique [ get_attribute [ get_attribute [ get_clocks * ] sources -quiet ] full_name ] ]

  foreach clock_source $clock_sources {
   #set clk_net    [ get_attribute [ get_nets -of_objects [ all_fanout -from $clock_source -flat -trace_arcs all ] -quiet ] full_name ]
    set clk_net    [ get_attribute [ get_nets -of_objects [ all_fanout -from $clock_source -flat ] -quiet ] full_name ]
    set clock_nets [ concat $clock_nets $clk_net ]
  }

  set clock_nets [ lsort -unique $clock_nets ]
  return $clock_nets
}


proc check_clock_net_xtalk_delta_delay { {clock_threshold 0.02} {output_rpt_clock_pt check_clock_net_xtalk_delta_delay.rep} } {

  puts "Information: Checking started: [date]\n"
  set viol_list ""
  set threshold $clock_threshold

  # for old version( <= J-2014.06-SP3) PrimeTime, it's not support attribute "is_clock_network"
  # "annotated_delay_delta_max" and "annotated_delay_delta_min" also not support in the old version PrimeTime
  redirect -variable attribute_var { list_attributes -application -class net }
  if { [ lsearch $attribute_var is_clock_network ] == -1 } {
    set pt_version 0 ; # "0" for old version( <= J-2014.06-SP3), "1" for high version( >= 2015.06-SP3-2)
    puts "Information: The Primetime version is old, maybe caused long run time."

  } else {
    set pt_version 1
  }

  if { $pt_version } {
    set clock_nets [get_attribute [get_nets * -hierarchical -filter "is_clock_network == true" -quiet] full_name ]
  } else {
    set clock_nets [ get_clock_nets ]
  }

  if {[llength $clock_nets] == 0} {
    puts "Warning: Can't find any clock nets, please check design."
    puts "Information: Checking completed: [date]\n"
    return
  }

  if {[file exist $output_rpt_clock_pt]} {
    puts "Warning: Checking clock net xtalk report is exist: $output_rpt_clock_pt"
    puts "Information: Checking completed: [date]\n"
    return
  }

  foreach clock_net $clock_nets {

    ## if the net pins are used for data, ignored this net.
    set input_pin  [get_pins -of_objects $clock_net -leaf -filter "direction == inout || direction == in" -quiet]
    set output_pin [get_pins -of_objects $clock_net -leaf -filter "direction == out || direction == inout" -quiet]

    set is_clock_pin           [ get_attribute [ get_pins $output_pin -quiet ] is_clock_pin -quiet ]
    set is_clock_used_as_data  [ get_attribute [ get_pins $output_pin -quiet ] is_clock_used_as_data -quiet ]
    set is_clock_used_as_clock [ get_attribute [ get_pins $output_pin -quiet ] is_clock_used_as_clock -quiet ]

    if { [lindex $is_clock_pin 0] == false } {
      if { [lindex $is_clock_used_as_data 0] } {
        continue
      } else {
        if { [lindex $is_clock_used_as_clock 0] == false } {
          continue
        }
      }
    }

    ## get delta delay
    if { $pt_version } {
      set max_delta_delay [get_attribute [get_nets $clock_net] annotated_delay_delta_max]
      set min_delta_delay [get_attribute [get_nets $clock_net] annotated_delay_delta_min]
    } else {
      set max_delta_delay [get_annotated_delay_delta $clock_net max]
      set min_delta_delay [get_annotated_delay_delta $clock_net min]
    }

    ## if the delta delay abnormal, jump out of current loop
    if { $max_delta_delay == -1 || $min_delta_delay == -1 } {
      continue
    }

    ## get clock net related clocks
    set pin_clock_periods ""
    if {[sizeof_collection $output_pin] == 0} {

      if {[sizeof_collection $input_pin] == 0} {
        puts "Warning: No pin for clock net, please check it: $clock_net"
        set pin_clock_period "NONE"

      } else {
        set pin_clocks [get_attribute [get_pins $input_pin -quiet] clocks -quiet]
      }

    } else {
      set pin_clocks [get_attribute [get_pins $output_pin -quiet] clocks -quiet]
    }

    ## selected the fastest clock
    if {[sizeof_collection $pin_clocks] == 1} {
      set pin_clock_period [get_attribute $pin_clocks period]

     } elseif {[sizeof_collection $pin_clocks] > 1} {
       foreach_in_collection ptrpc $pin_clocks {
         set pin_clock_period [get_attribute $ptrpc period]
         lappend pin_clock_periods $pin_clock_period
       }
       set pin_clock_period [lindex [lsort -real $pin_clock_periods] 0]

     } else {
       puts "Warning: Can't not find related clock of net, ignore it: $clock_net"
       set pin_clock_period "NONE"
     }

    ## get delta delay
    if {[expr $threshold - $max_delta_delay] > 0} {
      if {[expr $threshold + $min_delta_delay] > 0} {
        continue

      } else {
        set abs_delta_delay [expr abs($min_delta_delay)]
        set v_list "$abs_delta_delay $clock_net ($min_delta_delay:) ($pin_clock_period)"
        lappend viol_list $v_list
      }

    } else {
      if {[expr $threshold + $min_delta_delay] > 0} {
        set abs_delta_delay [expr abs($max_delta_delay)]
        set v_list "$abs_delta_delay $clock_net (:$max_delta_delay) ($pin_clock_period)"
        lappend viol_list $v_list

      } else { 
        if {[expr $max_delta_delay + $min_delta_delay] > 0} {
          set abs_delta_delay [expr abs($max_delta_delay)]
        } else {
          set abs_delta_delay [expr abs($min_delta_delay)]
        }

        set v_list "$abs_delta_delay $clock_net ($min_delta_delay:$max_delta_delay) ($pin_clock_period)"
        lappend viol_list $v_list
      }
    }
  }

  ## sort and output
  set viol_num    [llength $viol_list]
  set viol_list   [lsort -decreasing -index 0 $viol_list]
  set output_file [open $output_rpt_clock_pt w]

  puts $output_file "No.     Net Name(min:max)                                                     (Related clock period)"
  puts $output_file "------- --------------------------------------------------------------------- ---------------------------"

  set num 0
  foreach v_list $viol_list {
    set v_list [lreplace $v_list 0 0]
    incr num
    puts $output_file "$num\t $v_list"
  }

  puts $output_file "------- -------------------------------------------------------------------------------------------------"
  puts $output_file "Information: Checking completed, Total $viol_num violation nets."
  puts "Information: Checking completed: [date]\n"
  close $output_file
}

