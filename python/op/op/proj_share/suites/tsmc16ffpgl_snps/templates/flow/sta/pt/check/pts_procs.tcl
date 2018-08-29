namespace eval pts:: {
  proc check_tie_cells {args} {
      set fanoutLimit 1
      parse_proc_arguments -args $args results
      if {[info exists results(-fanout)]} {
          set fanoutLimit $results(-fanout)
      }
      puts  "Info: TIE_HL fanout checking start..."
      set tie_cells [get_cells * -hier -filter { ( is_hierarchical == false ) && ( ref_name =~ "*TIEH*" || ref_name =~ "*TIEL*") } ]
      foreach_in_collection tie_cell $tie_cells {
          set tie_cell_name [get_attribute [get_cells $tie_cell] full_name]
          set tie_fanout_number [sizeof_collection [filter_collection [all_connected [get_nets [all_connected [get_pins ${tie_cell_name}/Z*]]] -leaf ] "( object_class == pin && direction == in )"]]
          if { ${tie_fanout_number} > $fanoutLimit } {
              echo "${tie_cell_name}/Z* fanout is " ${tie_fanout_number}
          }
      }
      set tlp 0
      foreach_in_collection NETS [get_nets -quiet -hierarchical *Logic0*] {
          set load  [gl [get_nets $NETS]]
          if { [sizeof $load ] > 0 } {
              foreach_in_collection loadcellpin $load {
                  set loadcellpinname [get_attr [get_pins $loadcellpin] full_name ]
                  echo "$loadcellpinname"
                  incr tlp
             }
          }
      }
      echo "# NEED TIE LOW PIN = $tlp"
      set thp 0
      foreach_in_collection NETS [get_nets -quiet -hierarchical *Logic1*] {
      set load  [gl [get_nets $NETS]]
          if { [sizeof $load ] > 0 } {
              foreach_in_collection loadcellpin $load {
                  set loadcellpinname [get_attr [get_pins $loadcellpin] full_name ]
                  echo "$loadcellpinname"
                  incr thp
              }
          }
      }
      echo "# NEED TIE HIGH PIN = $thp"
  }
  define_proc_attributes check_tie_cells \
    -info "Check the fanout of tie cells in design." \
    -define_args {
      {-fanout "Specify the max fanout limit of tie cells in design" "" int optional }
    }


  proc check_open_input_pin {args} {
      parse_proc_arguments -args $args results
      set cells [ get_cells * -hierarchical -filter "is_hierarchical != true" ]
      set input_pins [ get_pins -of_objects $cells -filter "direction == in || direction == inout" ]
      set open_input_pin_count 0
      foreach_in_collection input_pin $input_pins {
          if { [ string compare [ get_attribute [get_lib_pins -of_objects $input_pin ] is_pad ] false ] == 0 } {
              set net [ all_connected $input_pin ]
              set is_open_input_pin 0
              if { [ sizeof_collection $net ] == 0 } {
                  set is_open_input_pin 1  ;# if there is no net connected to this input pin, this pin is a open_input_pin.
              } else {
                  set connections [ all_connected -leaf $net ] ;# get all pins connected to this net
                  set connections [ remove_from_collection $connections $input_pin ]
                  set source_pins  [ filter_collection $connections "( object_class == pin  ) && ( ( direction == out ) || ( direction == inout ) )" ]
                  set source_ports [ filter_collection $connections "( object_class == port ) && ( ( direction == in  ) || ( direction == inout ) )" ]
                  if { ( [ sizeof_collection $source_pins ] == 0 ) && ( [ sizeof_collection $source_ports ] == 0 ) } {
                      set is_open_input_pin 1 ;# if the pins connected to this net are all input pins, this $input_pin is also a open_input_pin
                  }
              }
              if { $is_open_input_pin == 1 } {
                  incr open_input_pin_count
                  set pin_name [ get_attribute $input_pin full_name ]
                  set ref_name [ get_attribute [ get_cells -of_objects $input_pin ] ref_name ]
                  echo [ format "Error: Open input pin %s (%s) found." $pin_name $ref_name ]
              }
          }
      }
      echo [ format "Info: Total open input pin count = %d" $open_input_pin_count ]
  }
  define_proc_attributes check_open_input_pin \
    -info "Check the input floating of the cells in design."

  proc check_multi_driver {args} {
      set fishbone_patterns ""
      parse_proc_arguments -args $args results
      if {[info exists results(-ignore)]} {
          set fishbone_patterns $results(-ignore)
      }
      if { [ get_designs -quiet ] != "" } {
          set top_design [ get_object_name [ get_designs ] ]
          puts "Information: check multi_driver_net for design \"$top_design\" starting...\n"
      } else {
          puts "Error: Please open a design first!"
          return
      }
  
      set num_fishbone_net     0
      set num_multi_driver_net 0
      set all_nets [ get_nets -hierarchical * -top_net_of_hierarchical_group -segments -quiet ]
      set f [open $top_design.multi_dirver.rpt w]
      if { [ sizeof_collection $all_nets ] == 0 } {
          puts "Error: Can not find any nets, please check the design."
          return
  
      } else {
          foreach_in_collection ptrn $all_nets {
              set net_name   [ get_attribute $ptrn full_name ]
              set pins_name  [ get_pins  -of_objects $net_name -filter "direction == out || direction == inout" -quiet -leaf]
              set ports_name [ get_ports -of_objects $net_name -filter "direction == in  || direction == inout" -quiet ]
              set num_pins   [ sizeof_collection $pins_name ]
              set num_ports  [ sizeof_collection $ports_name ]
  
              if { [ expr $num_pins + $num_ports ] >= 2 } {
                  set net_type "none"
                  if { [ llength $fishbone_patterns ] != 0 } {
                      foreach fishbone_pattern $fishbone_patterns {
                          if { [ string match $fishbone_pattern $net_name ] } {
                              set  net_type "fishbone"
                              incr num_fishbone_net
                              puts $f "Information: Fishbone net found: $net_name"
                              #puts "Information: Fishbone net found: $net_name"
                              break
                          }
                      }
                  }
  
                  if { $net_type == "none" } {
                      puts $f "Error: multi_drive net found, net: ${net_name}"
                      puts "Error: multi_drive net found, net: ${net_name}"
                      incr num_multi_driver_net
                  }
  
              }
          }
      }
  
      puts $f "\n---------------------------------------------------------------------------------"
      puts "\n---------------------------------------------------------------------------------"
      puts $f "Information: There total found \"$num_fishbone_net\" fishbone nets, \"$num_multi_driver_net\" multi-driver nets."
      puts "Information: There total found \"$num_fishbone_net\" fishbone nets, \"$num_multi_driver_net\" multi-driver nets."
      puts $f "Information: Check multi_driver_net for design \"$top_design\" end."
      puts "Information: Check multi_driver_net for design \"$top_design\" end."
      close $f
  
  }
  define_proc_attributes check_multi_driver \
    -info "Check the multi-driver cells in design." \
    -define_args {
      {-ignore "Specify the net pattern should be ignored. Such as fishbone, PAD, and so on." "" string optional }
    }
  
  proc report_clock_cell_type {args} {
      parse_proc_arguments -args $args results

      set clocks [ get_clocks -quiet * ]
      #set clocks [ add_to_collection $clocks [ get_clocks -quiet * ] ]
      set clockTreeCellList [list]
      foreach_in_collection clk $clocks {
          set clkname [get_attribute $clk full_name]
          foreach_in_collection src [ get_attribute -quiet $clk sources ] {
              puts [ format "------------------------------------------------------------------------" ]
              if { [ get_attribute $src object_class ] == "port" } {
                  puts [ format "Information: Checking clock network from source %s (%s) in clock %s" \
                    [ get_attribute $src full_name ] [ get_attribute $src direction ] [ get_attribute $clk full_name ] ]
              } else {
                  puts [ format "Information: Checking clock network from source %s (%s) in clock %s" \
                    [ get_attribute $src full_name ] [ get_attribute [ get_cells -of_objects $src ] ref_name ] [ get_attribute $clk full_name ] ]
              }
  
              # all cells from clock source
              set clock_cells [ all_fanout -flat -from $src -only_cells ]
              # exclude leaf flipflops
              set clock_cells [ remove_from_collection $clock_cells [ all_fanout -flat -from $src -only_cells -endpoints_only ] ]
              # generated clock source
              if { [get_attribute $src object_class ] == "pin" } {
                  set clock_cell [ get_cells -of_objects $src ]
                  if { [ sizeof_collection $clock_cells ] == [ sizeof_collection [ remove_from_collection $clock_cells $clock_cell ] ] } {
                      set clock_cells [ add_to_collection $clock_cells $clock_cell ]
                  }
              } 
              foreach cell [lsort -u [get_attribute $clock_cells ref_name]] {
                  lappend clockTreeCellList $cell
              }
          }
      }
      puts "Summary:"
      foreach cell [lsort -u $clockTreeCellList] {
          puts "  - $cell"
      }
  }
  define_proc_attributes report_clock_cell_type \
    -info "Check the type of clock cells in design."
 
  proc check_dont_use_cell {args} {
      parse_proc_arguments -args $args results
      if {[info exists results(-dont_use_file)]} {
          set dont_use_cell_list_file $results(-dont_use_file)
      }
      if {![file isfile $dont_use_cell_list_file]} {
          puts "ERROR: Can not find dont_use file: $dont_use_cell_list_file."
          return
      }
      set dontCellList [list]
      set f [open $dont_use_cell_list_file r]
      while {![eof $f]} {
          gets $f line
          if {![regexp {^ *$} $line]} {
              regsub -all { *} $line "" line
              lappend dontCellList $line
          }
      }
      close $f
      set design_name [ get_object_name [get_designs]]
      set n [open $design_name.dont_use.rpt w]
      puts $n "# Check Results:"
      puts "# Check Results:"
      foreach dc $dontCellList {
          set cellNum [sizeof_collection [get_cells * -hierarchical -quiet -filter "ref_name =~$dc"]]
          puts $n [format " - %-30s %50s" \'$dc\' $cellNum]
          puts [format " - %-30s %50s" \'$dc\' $cellNum]
      }
      puts $n "# Done"
      puts "# Done"
      puts "# Create reports $design_name.dont_use.rpt"
      close $n
  }
  define_proc_attributes check_dont_use_cell \
      -info "Check the status of dont use cells in design." \
      -define_args {
         {-dont_use_file "Specify the dont use cell list file." "" "string" required} \
      }

 
  proc check_icg_fanout {args} {
      set minFanout 0
      set maxFanout inf
      parse_proc_arguments -args $args results
      if {[info exists results(-min)]} {
          set minFanout $results(-min)
      }
      if {[info exists results(-max)]} {
          set maxFanout $results(-max)
      }
 
    set icgs [get_cells -q -hierarchical   -filter "is_integrated_clock_gating_cell"]





    if {![sizeof $icgs]} {puts "INFO: no ICGs"; return}
    set icg_q_filter "lib_pin_name == Q"
    set icg_ck_filter "lib_pin_name == CP"
    set fanout_range_list "1-16 16-inf"
    
    set err_info ""
    #set fanout_range_list "1-inf"
    
    #get_clock_tree_pins -filter {is_clock_gating_clock} -metrics {latency_max} -assign_to_variable la
    get_clock_tree_pins  -metrics {latency_max} -assign_to_variable Allla
    
    #stage 0 = sink
    #get_clock_tree_pins -filter {is_net_load && is_sink}  -sort_by latency_max -assign_to_variable sin -verbose
       
    
    if {[info exist puts_info]} {unset puts_info};
    if {[info exist height_max_num]} {unset height_max_num};
    
    if {![file exist $stage_fanout_file]} {
    #   puts "Error: $stage_fanout_file not exist"
    #   redirect -append $output_file {
    #      puts "# Haven't find stage_fanout_file preCTS: #stage_fanout_file"
    #      puts "### Not use icg stage preCTS, stage & fanout are postCTS ###\n# [sizeof $icgs] ICGs."
    #   }
    
       get_clock_tree_pins -assign_to_variable height_max -sort_by height_max -filter {is_on_icg}
       get_clock_tree_pins -assign_to_variable fanout_max -sort_by fanout_max -filter {is_on_icg}
    } else {
       redirect -append $output_file {puts "# Script can use for DCG:"}
       source $stage_fanout_file
    }
    redirect -append $output_file { puts "#####  CLKs INFO  #####"}
    set icgs_cks [get_pins -of $icgs  -filter $icg_ck_filter]
    set icgs_clk_names [lsort -u [get_attr $icgs_cks clocks.name]]
    set undefined_clks_icgs [filter_collection $icgs_cks "undefined(clocks)"]
    if {[sizeof $undefined_clks_icgs]} {redirect -append $output_file {puts "# Undefine CLK ICGs num: [sizeof $undefined_clks_icgs] \$undefined_clks_icgs"}}
    redirect -append $output_file {puts "# Clock nums: [llength $icgs_clk_names] ( $icgs_clk_names )\n"}
    
    ## Each clock condition #
    foreach icgs_clk_name $icgs_clk_names {
       set clk_icgs [get_cells -of [filter_collection $icgs_cks "clocks.name =~ $icgs_clk_name"]]
    
       if {[info exist fanout_range_cnd]} {unset fanout_range_cnd};
       if {[info exist miss_fanout_range_info]} {unset miss_fanout_range_info};
       if {[info exist total_latency]} {unset total_latency}; if {[info exist latency_num]} {unset latency_num}
       if {[info exist FO]} {unset FO}; if {[info exist agv_latency]} {unset agv_latency};
       get_clock_tree_pins -clocks $icgs_clk_name -metrics {latency_max} -assign_to_variable la
    
       foreach_in_collection icg $clk_icgs {
          set icg_name [get_object_name $icg]
          set icg_q [get_pins -of $icg  -filter $icg_q_filter]
          set icg_q_name [get_object_name $icg_q]
          set icg_ck [get_pins -of $icg  -filter $icg_ck_filter]
          set icg_ck_name [get_object_name $icg_ck]
          if {![info exists height_max($icg_ck_name)]} {lappend err_info "# $icg_ck_name miss \"height_max(stage_num)\""; continue}
          set stage_num $height_max($icg_ck_name)
          if {[regexp {\.} $stage_num]} {lappend err_info "# $icg_ck_name  \"height_max(stage_num)\" not integer : $stage_num"; continue}
          set end_fanout_cells [all_fanout -from $icg_q -flat  -only_cells -endpoints_only]
          set end_fanout_cells_num [sizeof $end_fanout_cells]
          if {![info exist puts_info($stage_num)]} {set puts_info($stage_num) ""}
          if {[info exist height_max_num($stage_num)]} {incr height_max_num($stage_num)} else {set height_max_num($stage_num) 1}
          foreach fanout_range $fanout_range_list {
             regexp {(\S+)-(\S+)} $fanout_range "" begin end
             if {$end == "inf"} {
                if {$fanout_max($icg_q_name) >= $begin} {
                   if {[info exist fanout_range_cnd($fanout_range)]} {incr fanout_range_cnd($fanout_range)} else {set fanout_range_cnd($fanout_range) 1}
                   set have_fanout_range 1
                   break
                }
             } elseif {$fanout_max($icg_q_name) >= $begin} {
                if {$fanout_max($icg_q_name) <= $end} {
                   if {[info exist fanout_range_cnd($fanout_range)]} {incr fanout_range_cnd($fanout_range)} else {set fanout_range_cnd($fanout_range) 1}
                   set have_fanout_range 1
                   break
                }
             }
          }
          if {!$have_fanout_range} {
             set fanout_range miss_fanout_range
             if {[info exist  fanout_range_cnd(miss_fanout_range)]} {incr fanout_range_cnd(miss_fanout_range);lappend miss_fanout_range_info "[format "%10s" $fanout_max($icg_q_name)] $icg_name"} else {set fanout_range_cnd(miss_fanout_range) 1; set miss_fanout_range_info ""; lappend miss_fanout_range_info "[format "%10s" $fanout_max($icg_q_name)] $icg_name";}
          set have_fanout_range 0 
          }           
          if {![info exist la($icg_ck_name)]} {
    lappend puts_info($stage_num) "$stage_num\t\t\t[format "%10s" $end_fanout_cells_num]\t$icg_name (Warning)";continue
    #lappend puts_info($stage_num) "$stage_num\t\t\t[format "%10s" $fanout_max($icg_q_name)] [format "%10s" "MissLatency"][format "%10s" $end_fanout_cells_num]\t$icg_name (Warning)";continue
    }
          if {[info exist total_latency(${stage_num}_$fanout_range)]} {set total_latency(${stage_num}_$fanout_range) [expr $total_latency(${stage_num}_$fanout_range) +  $la($icg_ck_name)]; incr latency_num(${stage_num}_$fanout_range)} else {set total_latency(${stage_num}_$fanout_range) $la($icg_ck_name); set latency_num(${stage_num}_$fanout_range) 1}
    #      lappend puts_info($stage_num) "$stage_num\t\t\t[format "%10s" $fanout_ [format "%10s" $la($icg_ck_name)][format "%10s" $end_fanout_cells_num]\t$icg_name"
    lappend puts_info($stage_num) "$stage_num\t\t\t[format "%10s" $end_fanout_cells_num]\t$icg_name"
       }
       foreach latency_rag  [lsort -dic -dec [array name total_latency]] {
          set agv_latency($latency_rag) [expr $total_latency($latency_rag) / $latency_num($latency_rag)]
       }
    
       redirect -append  $output_file {
          puts "################################## CLK: $icgs_clk_name ##################################"
          set clk_agv_latency [ClkAgvLatency $icgs_clk_name]
    #      puts "# ClkAgvLatency: $clk_agv_latency\n"
          if {$err_info != ""} {puts "#Error info:\n\t[join $err_info "\n\t"]\n"}
          if {[file exist $stage_fanout_file]} {
              puts "set_clock_latency  $clk_agv_latency  \[get_clocks $icgs_clk_name\]"
              foreach FO_st [lsort -integer -dec  [array name height_max_num]] {
                 set cmd "set_clock_gate_latency -clock \[get_clocks $icgs_clk_names\] -stage $FO_st -fanout_latency \{"
                 set bk_cmd $cmd
                 if {[info exist last_latency]} {unset last_latency }
                 foreach fo $fanout_range_list {
                    set latency_rag ${FO_st}_$fo
                    if {[info exist agv_latency($latency_rag)]} {
                       set last_latency $agv_latency($latency_rag)
                       set bk_cmd "$bk_cmd $fo [format "%.3f" $agv_latency($latency_rag)],"
                       set cmd "$cmd $fo [format "%.3f" $agv_latency($latency_rag)],"
                    } elseif {[info exist last_latency]} {
                       set cmd "$cmd $fo [format "%.3f" $last_latency],"
                    } 
                 }
                 regexp {(.*),} $cmd "" t_cmd                                         
                 set cmd "${t_cmd}\}"
                 if {![regexp {\{\s*1-} $cmd]} {
                    regexp {(.*\{)\s*\d+(.*)} $cmd "" cmdb cmde
                    set cmd "${cmdb}1${cmde}"
                 }
                 if {![regexp {\-inf} $cmd]} {
                    regexp {(.*-)\d+(.*)} $cmd "" cmdb cmde
                    set cmd "${cmdb}inf${cmde}"
                 }
       
                 regexp {(.*),} $bk_cmd "" t_bk_cmd
                 set bk_cmd "${t_bk_cmd}\}"
      
                 puts "#$bk_cmd\n$cmd"
             }
          }
          puts "### [sizeof $icgs] ICGs. stage & fanout info as follow ###"
          puts "# -------------- Stage ----------------------------#"   
          foreach num [lsort -integer -dec  [array name height_max_num]] {
             puts "#\tStage $num : $height_max_num($num)"
          }
          puts "# -------------- Fanout ---------------------------#\n#\tfanout_range_list : $fanout_range_list"
          foreach fanout_range [concat $fanout_range_list miss_fanout_range] {
             if {![info exist fanout_range_cnd($fanout_range)]} {set fanout_range_cnd($fanout_range) 0}
             puts "#\t$fanout_range :\t$fanout_range_cnd($fanout_range)"
          }
          if {[info exist miss_fanout_range_info]} {
             puts "# ---- detail miss fanout range info: $fanout_range_cnd(miss_fanout_range)\n\t[join $miss_fanout_range_info "\n\t"]"
          }
         # puts "# -------------- Agv Latency -------------------------#\n#\tLatency range : [array name total_latency]"
         # foreach latency_rag  [lsort -dic -dec [array name total_latency]] {
         #    puts "#\t$latency_rag : \t $agv_latency($latency_rag)  ($total_latency($latency_rag) / $latency_num($latency_rag))"
          #}
          puts "### -------------- End ---------------- ###\n"
       if {[file exist $stage_fanout_file]} {
          puts "#stage #fanout #icg_pints"
       } else {
          puts "#stage #postCTs_fanout #latency #end_fanout #icg"
       }
          foreach num [lsort -integer -dec  [array name puts_info]] {
             puts "# [join $puts_info($num) "\n# "]"
          }
       }
    }
  }

  proc gen_hold_free_sdf {args} {
      set outputFile ""
      parse_proc_arguments -args $args results
      if {[info exists results(-file)]} {
          set annotFile $results(-file)
      }
      if {[info exists results(-output)]} {
          set outputFile $results(-output)
      }

      if {[file isfile $annotFile]} {source -verbose $annotFile}
      set f [open $annotFile a+]
      suppress_message UITE-416
      set new_args "-delay_type min -start_end_pair"
      set paths [eval [concat "get_timing_paths " $new_args]]
      set num [sizeof_collection $paths]
      puts "Total Hold Violated Path: $num"
      set PreTNS 0
      foreach_in_collection path $paths {
          set slack [get_attribute $path slack]
          if {[regexp {\d+} $slack]} {
              set PreTNS [expr $PreTNS + $slack]
          }
      }
      puts "Pre Fix Hold TNS: ${PreTNS}ns"
      foreach_in_collection path $paths {
          set slack [get_attribute $path slack]
          set endpt [get_attribute $path endpoint]
          if {[regexp {\d+} $slack]} {
              set slack [expr $slack - 0.005]
              set_annotated_delay [expr 0 - $slack] -increment -net -to [get_attribute $endpt full_name]
              puts $f "set_annotated_delay [expr 0 - $slack] -increment -net -to [get_attribute $endpt full_name]"
          }
      }
      update_timing -full
      set PostTNS 0
      set paths [eval [concat "get_timing_paths " $new_args]]
      foreach_in_collection path $paths {
          set slack [get_attribute $path slack]
          if {[regexp {\d+} $slack]} {
              set PostTNS [expr $PostTNS + $slack]
          }
      }
      puts "Post Fix Hold TNS: ${PostTNS}ns"
      if {$outputFile != ""} {
          set design [get_attribute [current_design] full_name]
          write_sdf -version 3.0 -context verilog -compress gzip \
              -include {SETUPHOLD RECREM} -exclude {no_condelse clock_tree_path_models} -no_internal_pins  \
              $outputFile
      }
      close $f
  
  }
  define_proc_attributes gen_hold_free_sdf \
    -info "Generate the hold free sdf file." \
    -define_args {
      {-file "Specify the annotated delay file" "" string optional } \
    }
}
