proc rfi {to} {
	report_transitive_fanin -to $to
	}
proc rfo {from} {
	report_transitive_fanout -from $from
	}
proc gc {cell} {
    get_cells -hier *$cell
    }
proc gp {pin} {
   get_pins -hier *$pin
   }
proc fpt {to} {
       report_timing -to $to -input_pins -nets -nosplit
       set setup_path [ get_timing_path -to $to -delay max ]

       echo -n "$to :  ( "
       foreach_in_collection path $setup_path  {
              set setup_margin [ get_attr $path slack ]
              echo -n " $setup_margin "
       }
       echo -n " ) \n"
       }

proc fpthr {thr} {
        report_timing -th $thr -input_pins -nets -nosplit
        }
proc fpthrh {thr} {
       report_timing -th $thr -input_pins -delay min
        }
proc fpthrce {thr} {
        report_timing -th $thr -input_pins -nets -nosplit -path full_clock_expanded
        }
proc fpthrhce {thr} {
        report_timing -th $thr -input_pins -nets -nosplit -path full_clock_expanded -delay min
        }
proc fptc {to} {
        report_timing -to $to -input_pins -nets -path full_clock -nosplit
        }
proc fptce {to} {
        report_timing -to $to -input_pins -nets -path full_clock_expanded -nosplit
        }
proc fpthce {to} {
        report_timing -to $to -input_pins -nets -path full_clock_expanded -nosplit -delay min
        }
proc fpf {from} {
       report_timing -from $from -input_pins -nets -nosplit
       set setup_path [ get_timing_path -from $from -delay max ]
       set hold_path [ get_timing_path -from $from -delay min ]

       echo -n "$from :  ( "
       foreach_in_collection path $setup_path  {
              set setup_margin [ get_attr $path slack ]
              echo -n "$setup_margin "
       }
      echo -n " ) ( "
      foreach_in_collection path $hold_path  {
              set hold_margin [ get_attr $path slack ]
              echo -n "$hold_margin "
       }
       echo  " )"
        }

proc fpfc {from} {
        report_timing -from $from -input_pins -nets -path full_clock -nosplit
        }

proc fpfce {from} {
        report_timing -from $from -input_pins -nets -path full_clock_expanded -nosplit
        }

proc sdin {from to no} {
         set_annotated_delay -cell  -from $from -to $to -increment $no 
         }
proc sd {from to no} {
         set_annotated_delay -cell  -from $from -to $to $no
         }
proc sdn {from to no} {
         set_annotated_delay -net --from $from -to $to $no
                  }
proc sdni {from to no} {
          set_annotated_delay -net  -from $from -to $to -increment $no
}
proc vc {to no} {
         set_annotated_delay -cell -load_delay cell -to $to -increment $no
                  }

proc vn {to no} {
         set_annotated_delay -net -load_delay net -to $to -increment $no
                  }

proc v0 { to } {
         set_annotated_delay 0 -cell -to $to
                  }
proc fpth {to} {
        report_timing -to $to -input_pins -nets -nosplit -delay min
        }
proc fpthc {to} {
        report_timing -to $to -input_pins -nets -path full_clock -nosplit -delay min
        }
proc fpfh {from} {
        report_timing -from $from -input_pins -nets -nosplit -delay min
        }
proc fpfhc {from} {
        report_timing -from $from -input_pins -nets -path full_clock -nosplit -delay min
        }
proc fpfhce {from} {
        report_timing -from $from -input_pins -nets -path full_clock_expanded -nosplit -delay min
        }
proc fptha {to} {
       report_timing -to $to -input_pins -delay min -start_end_pair 
       }
proc fpta {to} {
      report_timing -to $to -input_pins -start_end_pair
      }
proc rn {net} {
        report_net -conn $net
        }
proc rc {cell} {
        report_cell -conn $cell
        }
##
proc fpbsn {s n from to} {
report_timing -slack_lesser_than $s -nworst $n -from $from -to $to -nosplit
}
proc fpbn {n from to} {
report_timing -nworst $n -from $from -to $to -nosplit
}
proc fpbgln {g l n from to} {
report_timing -slack_greater_than $g -slack_lesser_than $l -nworst $n -from $from -to $to -nosplit
}
proc fptsn {s n to} {
report_timing -slack_lesser_than $s -nworst $n -to $to -nosplit
}
proc fpbsnn {s n from to} {
report_timing -slack_lesser_than $s -nworst $n -from $from -to $to -nosplit -input_pins -nets
}

proc fc {cell} {
  set all_cells [find -hierarchy cell *$cell*]
  foreach_in_collection list $all_cells {
      set cell_name [get_attr $list full_name]
      echo $cell_name
  }
}

proc fn {net} {
  set all_nets [find -hierarchy net *$net*]
  foreach_in_collection list $all_nets {
      set net_name [get_attr $list full_name]
      puts $net_name
  }
}


proc fpo {ports} {
  set all_ports [get_ports *$ports*]
  foreach_in_collection list $all_ports {
  set portlist [get_attr $list full_name]
  echo $portlist
  }
}

proc fpi {pins} {
  set all_pins [get_pins *$pins*]
  foreach_in_collection list $all_pins {
  set pinlist [get_attr $list full_name]
  echo $pinlist
  }
}

proc fct {type} {
  set all_cells [get_cells * -hierarchical  -filter "ref_name =~ $type "]
  set SNN [ sizeof  [get_cells * -hierarchical  -filter "ref_name =~ $type "] ]
  foreach_in_collection list $all_cells {
  set allct [get_attr $list full_name]
  set allctR [get_attr $list ref_name]
  echo $allct $allctR 
  }
  echo $SNN
}

proc gn {pin} {
  get_attribute [get_nets [all_connected $pin] -top_net_of_hierarchical_group -segments] full_name
}

proc gd { arg } {
    if { [sizeof_collection [ get_net $arg -quiet ] ] == 1 } {
        set tmp_net $arg
    } else {
        if { [sizeof_collection [ get_pins $arg -filter "direction == out" -quiet ]] == 1 } {
            echo "Error: pin $arg is an output pin"
            return 0
        } else {
            set tmp_net [ get_attr [ all_connected [ get_pins $arg ]] full_name ]
        }
    }
    set net [get_attr [ get_net -quiet -top -seg $tmp_net ] full_name ]
 
    if { $net == "" } {
            echo "Warning: pin $arg has no driver!!"
            return 0
    }

    if {[sizeof_collection [ get_port $net -quiet ] ] == 1 } {
        return [ get_ports $net ]
    } else {
        set drive_pin [ filter_collection \
            [ all_connected [ get_net $net ] -leaf ] "direction != in" ]
        if { [ sizeof_collection $drive_pin ] != 0 } {
#           return [ remove_from_collection $drive_pin [ get_ports $net -quiet ] ]
            return  $drive_pin
        } else {
            echo "Warning: net $arg has no driver!!"
            return 0
        }
    }
}

proc gl { arg } {
    if { [sizeof_collection [ get_net $arg -quiet ] ] == 1 } {
        set tmp_net $arg
    } else {
        if { [sizeof_collection [ get_pins $arg -filter "direction == in" -quiet ]] == 1 } {
            echo "Error: pin $arg is an input pin"
            return 0
        } else {
            set alc [ all_connected [ get_pins $arg ] ]
            if { [sizeof_collection $alc ] == 0 } {
                return $alc
            }
            set tmp_net [ get_attr $alc full_name ]
        }
    }
    set net [get_attr [ get_net -top -seg $tmp_net ] full_name ]

#    if {[sizeof_collection [ get_port $net -quiet ] ] == 1 } {
#        return [ get_ports $net ]
#    } else {
        set load_pin [ filter_collection \
            [ all_connected [ get_net $net ] -leaf ] "(direction != out && object_class != port) || (direction == out && object_class == port)" ]
#       if { [ sizeof_collection $load_pin ] != 0 } {
#           return $load_pin
#       } else {
#           echo "Warning: net $arg has no loading!!"
#           return 0
#       }
#    }
}

proc format_float {number {format_str "%.2f"}} {
  switch -exact -- $number {
    UNINIT { }
    INFINITY { }
    default {set number [format $format_str $number]}
  }
  return $number;
}
proc show_arcs {args} {
  set arcs [eval [concat get_timing_arcs $args]]
  echo [format "%15s    %-15s  %8s %8s  %s" "from_pin" "to_pin" \
            "rise" "fall" "is_cellarc"]
  echo [format "%15s    %-15s  %8s %8s  %s" "--------" "------" \
            "----" "----" "----------"]

  foreach_in_collection arc $arcs {
    set is_cellarc [get_attribute $arc is_cellarc]
    set fpin [get_attribute $arc from_pin]
    set tpin [get_attribute $arc to_pin]
    set rise [get_attribute $arc delay_max_rise]
    set fall [get_attribute $arc delay_max_fall]

    set from_pin_name [get_attribute $fpin full_name]

    set to_pin_name [get_attribute $tpin full_name]
   echo [format "%15s -> %-15s  %8s %8s  %s" \
        $from_pin_name $to_pin_name \
        [format_float $rise] [format_float $fall] \
        $is_cellarc]
  }
}

proc pc { col } {
    set nc 0
    foreach_in_collection c_n $col {
    echo [ get_attr $c_n full_name ]
    incr nc
    }
   echo $nc
}
proc pc_full_ref { col } {
    set nc 0
    foreach_in_collection c_n $col {
    echo "[ get_attr $c_n full_name ] [ get_attr $c_n ref_name ]"
    incr nc
    }
   echo $nc
}


proc con { col } {
    set nc 0
    foreach_in_collection c_n $col {
    echo $c_n
    incr nc
    }
   echo $nc
}

proc con_num { col } {
    set nc 0
    foreach_in_collection c_n $col {
    incr nc
    }
   echo $nc
}


proc pc_ref { col } {
    set nc 0
    foreach_in_collection c_n $col {
    echo [ get_attr $c_n ref_name ]
    incr nc
    }
   echo $nc
}



proc pcL { col } {
  foreach_in_collection c_n $col {
  echo [ get_attr $c_n full_name ]
  }
}

proc sel { arg } {
    change_selection [get_cells -all $arg]
    }

alias clk "report_clock_timing -crosstalk_delta -nosplit -significant_digits 3 -type latency -verbose -to"
alias se  "report_timing -crosstalk_delta -nets -input_pins -nosplit -significant_digits 3 -max_paths 99999 -slack_lesser_than 0 -nworst 1 -delay_type max"
alias sef "report_timing -crosstalk_delta -nets -input_pins -nosplit -significant_digits 3 -max_paths 99999 -slack_lesser_than 0 -nworst 9999 -delay_type max"
alias sep "report_timing -crosstalk_delta -nets -input_pins -nosplit -significant_digits 3 -slack_lesser_than 0 -delay_type max -start_end_pair"
alias ho "report_timing -crosstalk_delta -nets -input_pins -nosplit -significant_digits 3 -max_paths 99999 -slack_lesser_than 0 -nworst 1 -delay_type min"
alias hop "report_timing -nets -input_pins -nosplit -significant_digits 3 -slack_lesser_than 0 -delay_type min -start_end_pair"
alias sec "report_timing -nets -input_pins -nosplit -significant_digits 3 -max_paths 99999 -slack_lesser_than 0 -nworst 1 -delay_type max -path_type full_clock_expanded"
alias hoc "report_timing -nets -input_pins -nosplit -significant_digits 3 -max_paths 99999 -slack_lesser_than 0 -nworst 1 -delay_type min -path_type full_clock_expanded"
alias sumH "sh /usr/bin/perl ~i_juliaz/check_violation_summary_update.pl"
alias sumS "sh /usr/bin/perl ~i_juliaz/check_violation_summary_update.pl"

proc hcc { fromC toC slack} {
report_timing -nets -input_pins -nosplit -significant_digits 3 -max_paths 99999 -nworst 1 -slack_lesser_than $slack -delay_type min -from $fromC -to $toC > ${fromC}_${toC}.rpt
sum ${fromC}_${toC}.rpt > ${fromC}_${toC}.sum
}

proc GA { PINNAME } {get_attr [get_pins $PINNAME] case_value}
proc GN { NETNAME } {get_nets -segments -top_net_of_hierarchical_group $NETNAME}

proc skew  { CLOCK } {
file delete -force ./report_clock_timing_${CLOCK}_latency.rpt
foreach_in_collection clock [ get_clocks $CLOCK ] {
  set clock_name [ get_attribute $clock full_name ]
  foreach_in_collection source [ get_attribute $clock sources ] {
    set source_name [ get_attribute $source full_name ]
    echo [ format "# report_clock_timing -nosplit -significant_digits 3 -type latency -nworst 999999 -clock %s -from %s" $clock_name $source_name ] \
       >> ./report_clock_timing_${CLOCK}_latency.rpt
    report_clock_timing -nosplit -significant_digits 3 -type latency -nworst 999999 -clock $clock_name -from $source_name \
       >> ./report_clock_timing_${CLOCK}_latency.rpt
    sh perl ~i_juliaz/check_report_clock_timing_latency.pl \
       ./report_clock_timing_${CLOCK}_latency.rpt \
       > ./report_clock_timing_${CLOCK}_latency.rpt.summary
    }
  }
}

proc skewT  { CLOCK } {
file delete -force ./report_clock_timing_${CLOCK}_latency.rpt
foreach_in_collection clock [ get_clocks $CLOCK ] {
  set clock_name [ get_attribute $clock full_name ]
  foreach_in_collection source [ get_attribute $clock sources ] {
    set source_name [ get_attribute $source full_name ]
    echo [ format "# report_clock_timing -nosplit -significant_digits 3 -type latency -nworst 999999 -clock %s -from %s" $clock_name $source_name ] \
       >> ./report_clock_timing_${CLOCK}_latency.rpt
    report_clock_timing -nosplit -significant_digits 3 -type latency -nworst 999999 -clock $clock_name \
       >> ./report_clock_timing_${CLOCK}_latency.rpt
    sh perl ~i_juliaz/check_report_clock_timing_latency.pl \
       ./report_clock_timing_${CLOCK}_latency.rpt \
       > ./report_clock_timing_${CLOCK}_latency.rpt.summary
    }
  }
}

proc CheckMargin { pin_name } {
   if { [get_attr [get_pins $pin_name ] direction] == "in" && [get_attr [get_pins $pin_name ] is_hierarchical ] == "false"  } {
     set worst_slack 9999
     foreach_in_collection timing_path [ get_timing_paths -through [ get_pins $pin_name ] -delay max ] {
       set slack [ get_attribute $timing_path slack ]
       if { $slack < $worst_slack } {
       set worst_slack $slack
       }
     }
   } else {
   set worst_slack -9999
   }
echo "$pin_name $worst_slack"
}

proc CheckMargin_kevin { pin_name } {
   if {  ( [get_attr [get_pins $pin_name ] direction] == "in" ||  [ get_attr [get_pins $pin_name ] lib_pin_name ] == "Q" ) && [get_attr [get_pins $pin_name ] is_hierarchical ] == "false" && [get_attr [get_cells -of [get_pins $pin_name ]] number_of_pins] <= 7 } {
       set rise_slack [ get_attribute [get_pins $pin_name] max_rise_slack ]
       set fall_slack [ get_attribute [get_pins $pin_name] max_fall_slack ]
   if {$fall_slack == "INFINITY" && $rise_slack == "INFINITY"} {
        set worst_slack 9999
       } elseif  { $rise_slack < $fall_slack } {
       set worst_slack $rise_slack
       } else {
       set worst_slack $fall_slack
      }
   } else {
       set worst_slack -9999
   }
echo "$pin_name $worst_slack"
 }


proc TraceIN { INPIN } {
set ALLCP [gd $INPIN]
  foreach_in_collection DCP $ALLCP {
  set ALLCN  [get_object_name [get_cells -of $DCP] ]
  set ALLCR  [get_attr [get_cells $ALLCN] ref_name ]
  set PINN   [get_attr [get_cells $ALLCN] number_of_pins ]
    if { $PINN == 2 } {
    set PININ [get_pins -of $ALLCN -filter "direction == in"] 
    set LOADN [sizeof [gl $DCP]]
    echo "$ALLCN ( $ALLCR ) $LOADN"
    TraceIN $PININ
    } else {
    echo "$ALLCN ( $ALLCR )"
    echo "--------------------------- PATH END ---------------------------"
    }
  }
}
proc TraceOUT { OUTPIN } {
set ALLCP [gl $OUTPIN]
  foreach_in_collection DCP $ALLCP {
  set pinname [get_object_name [get_pins $DCP]]
  set ALLCN   [get_object_name [get_cells -of $DCP] ]
  set ALLCR   [get_attr [get_cells $ALLCN] ref_name ]
  set PINN    [get_attr [get_cells $ALLCN] number_of_pins ]
    if { $PINN == 2 } {
    set PININ [get_pins -of $ALLCN -filter "direction == out"]
    TraceOUT $PININ
    } else {
    echo "$pinname ( $ALLCR )"
    }
  }
}



proc PD {PIN} {
set D [get_attr [get_pins $PIN] direction]
if { $D eq "out" } {
set PINN [get_object_name [get_pins $PIN]]
set T [get_attr [get_cells -of [get_pins $PINN]] ref_name]
} else {
set PINN [get_object_name [gd $PIN]]
set T [get_attr [get_cells -of [get_pins $PINN]] ref_name]
}
echo "$PINN $T"
}


proc get_setup_margin { pin_name } {
  global timing_save_pin_arrival_and_slack
  if {[sizeof_coll [get_pins $pin_name -quiet]] > 0} {
    if {$timing_save_pin_arrival_and_slack == "true"} {
        if {  [get_attr [get_pins $pin_name ] direction] == "in" && [get_attr [get_pins $pin_name ] is_hierarchical ] == "false" && [regexp {SV*} [get_attr [get_cells -of [get_pins $pin_name ]] ref_name]] } {
            set rise_slack [ get_attribute [get_pins $pin_name] max_rise_slack ]
            set fall_slack [ get_attribute [get_pins $pin_name] max_fall_slack ]
        if {$fall_slack == "INFINITY" && $rise_slack == "INFINITY"} {
             set worst_slack 9999
            } elseif  { $rise_slack < $fall_slack } {
            set worst_slack $rise_slack
            } else {
            set worst_slack $fall_slack
           }
        } else {
            set worst_slack -9999
        }
     echo "$pin_name $worst_slack"
    } else {
        if { [get_attr [get_pins $pin_name ] direction] == "in" && [get_attr [get_pins $pin_name ] is_hierarchical ] == "false"  } {
          set worst_slack 9999
          foreach_in_collection timing_path [ get_timing_paths -through [ get_pins $pin_name ] -delay max ] {
            set slack [ get_attribute $timing_path slack ]
            if { $slack < $worst_slack } {
            set worst_slack $slack
            }
          }
        } else {
        set worst_slack -9999
        }
     echo "$pin_name $worst_slack"
    }
  } else {echo "$pin_name 9999"}
}




#$# proc get_setup_margin_Pearl { pin_name } {
#$#   global timing_save_pin_arrival_and_slack
#$#   if {[sizeof_coll [get_pins $pin_name -quiet]] > 0} {
#$#     if {$timing_save_pin_arrival_and_slack == "true"} {
#$#         if {  [get_attr [get_pins $pin_name ] direction] == "in" && [get_attr [get_pins $pin_name ] is_hierarchical ] == "false" && ( [string match "SV*" [get_attr [get_cells -of [get_pins $pin_name ]] ref_name]] || [string match "SE*" [get_attr [get_cells -of [get_pins $pin_name ]] ref_name]] )  } {
#$#             set rise_slack [ get_attribute [get_pins $pin_name] max_rise_slack ]
#$#             set fall_slack [ get_attribute [get_pins $pin_name] max_fall_slack ]
#$#         if {$fall_slack == "INFINITY" && $rise_slack == "INFINITY"} {
#$#              set worst_slack 9999
#$#             } elseif  { $rise_slack < $fall_slack } {
#$#             set worst_slack $rise_slack
#$#             } else {
#$#             set worst_slack $fall_slack
#$#            }
#$#         } else {
#$#             set worst_slack -9999
#$#         }
#$#      echo "$pin_name $worst_slack"
#$#     } else {
#$#         if {  [get_attr [get_pins $pin_name ] direction] == "in" && [get_attr [get_pins $pin_name ] is_hierarchical ] == "false" && ( [string match "SV*" [get_attr [get_cells -of [get_pins $pin_name ]] ref_name]] || [string match "SE*" [get_attr [get_cells -of [get_pins $pin_name ]] ref_name]] )  } {
#$#           set worst_slack 9999
#$#           foreach_in_collection timing_path [ get_timing_paths -through [ get_pins $pin_name ] -delay max ] {
#$#             set slack [ get_attribute $timing_path slack ]
#$#             if { $slack < $worst_slack } {
#$#             set worst_slack $slack
#$#             }
#$#           }
#$#         } else {
#$#         set worst_slack -9999
#$#         }
#$#      echo "$pin_name $worst_slack"
#$#     }
#$#   } else {echo "$pin_name -9999"}
#$# }

#if {  [get_attr [get_pins $pin_name ] direction] == "in" && [get_attr [get_pins $pin_name ] is_hierarchical ] == "false" && ( [string match "SV*" [get_attr [get_cells -of [get_pins $pin_name ]] ref_name]] || [string match "SE*" [get_attr [get_cells -of [get_pins $pin_name ]] ref_name]] || [string match "true" [get_attribute [get_cells -of [get_pins $pin_name ]] is_memory_cell]] ) && [sizeof_collection [get_ports -quiet [all_fanin -to $pin_name -flat -startpoint]]] == 0 } {
proc get_setup_margin_Pearl { pin_name } {
  global timing_save_pin_arrival_and_slack
  if {[sizeof_coll [get_pins $pin_name -quiet]] > 0} {
    if {$timing_save_pin_arrival_and_slack == "true"} {
        if {  [get_attr [get_pins $pin_name ] direction] == "in" && [get_attr [get_pins $pin_name ] is_hierarchical ] == "false" && [string match "SCD*" [get_attr [get_cells -of [get_pins $pin_name ]] ref_name]] } {
            set rise_slack [ get_attribute [get_pins $pin_name] max_rise_slack ]
            set fall_slack [ get_attribute [get_pins $pin_name] max_fall_slack ]
        if {$fall_slack == "INFINITY" && $rise_slack == "INFINITY"} {
             set worst_slack 9999
            } elseif  { $rise_slack < $fall_slack } {
            set worst_slack $rise_slack
            } else {
            set worst_slack $fall_slack
           }
        } else {
            set worst_slack -9999
        }
     echo "$pin_name $worst_slack"
    } else {
        if {  [get_attr [get_pins $pin_name ] direction] == "in" && [get_attr [get_pins $pin_name ] is_hierarchical ] == "false" &&  [string match "SCD*" [get_attr [get_cells -of [get_pins $pin_name ]] ref_name]] } {
          set worst_slack 9999
          foreach_in_collection timing_path [ get_timing_paths -through [ get_pins $pin_name ] -delay max ] {
            set slack [ get_attribute $timing_path slack ]
            if { $slack < $worst_slack } {
            set worst_slack $slack
            }
          }
        } else {
        set worst_slack -9999
        }
     echo "$pin_name $worst_slack"
    }
  } else {echo "$pin_name -9999"}
}




###my alias
#alias la "list_attributes -application -nosplit -class "
#alias rpt_sfpba "report_timing -tran -net -nosplit -capacitance -input_pins -crosstalk_delta -derate -pba_mode path -from "
#alias rpt_stpba "report_timing -tran -net -nosplit -capacitance -input_pins -crosstalk_delta -derate -pba_mode path -to"

#proc rpt_fcpba {start end} {
#report_timing -tran -net -nosplit -capacitance -input_pins -crosstalk_delta -derate -pba_mode path -from $start -to $end -path_type full_clock_ex
#}

proc reverse_list {lst} {
   set return_l ""
   set lst_l [llength $lst]
   while {$lst_l >0} {
      set lst_l [expr $lst_l -1]
      set return_l "$return_l [lindex $lst $lst_l]"
   }
   return $return_l
}

proc remove_from_list {all_list remove_list} {
  set result_list ""
  foreach s_list $all_list {
    set need_remove 0
    foreach o_list $remove_list {
      if {"$o_list"=="$s_list"} {
        set need_remove 1
      }
    }
    if {$need_remove==0} {
      lappend result_list $s_list
    }
  }
  return $result_list
}

proc common_collection {c1 c2} {
  set tc [add_to_collection -unique $c1 $c2]
  set c1fc2 [remove_from_collection $c2 $c1]
  set c2fc1 [remove_from_collection $c1 $c2]
  set common [remove_from_collection $tc $c1fc2]
  set common [remove_from_collection $common $c2fc1]
  return $common
}

