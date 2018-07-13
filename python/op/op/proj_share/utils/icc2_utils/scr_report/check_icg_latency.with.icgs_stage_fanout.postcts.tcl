if {![info exist stage_fanout_file]} {set stage_fanout_file "icgs.stage.fanout.info.tcl"}
if {![info exist output_file]} {set output_file "icgs.latency.fanout.stage.info.rpt"}
sh rm -rf $output_file
sh touch $output_file
set icgs [get_cells -q -hierarchical   -filter "is_integrated_clock_gating_cell"]
if {![sizeof $icgs]} {puts "INFO: no ICGs"; return}
set icg_q_filter "lib_pin_name == Q"
set icg_ck_filter "lib_pin_name == CK"
set fanout_range_list "1-31 32-1000 1001-2000 2001-3000 3001-inf"

set err_info ""
#set fanout_range_list "1-inf"

#get_clock_tree_pins -filter {is_clock_gating_clock} -metrics {latency_max} -assign_to_variable la
get_clock_tree_pins  -metrics {latency_max} -assign_to_variable Allla

#stage 0 = sink
#get_clock_tree_pins -filter {is_net_load && is_sink}  -sort_by latency_max -assign_to_variable sin -verbose
proc ClkAgvLatency {clock_name} {
   get_clock_tree_pins -filter {is_net_load && is_sink}  -sort_by latency_max -assign_to_variable sin -clocks $clock_name
   set sin_array_names [array name sin]
   set sin_num [llength $sin_array_names]
   set total_la 0
   foreach sin_array_name $sin_array_names {
      set total_la [expr $total_la + $sin($sin_array_name)]
   }
   set agv_la [format "%.3f" [expr $total_la/$sin_num]]
   puts "# $clock_name: $agv_la = $total_la / $sin_num"
   return $agv_la
}
   

if {[info exist puts_info]} {unset puts_info};
if {[info exist height_max_num]} {unset height_max_num};

if {![file exist $stage_fanout_file]} {
#   puts "Error: $stage_fanout_file not exist"
   redirect -append $output_file {
      puts "# Haven't find stage_fanout_file preCTS: $stage_fanout_file"
      puts "### Not use icg stage preCTS, stage & fanout are postCTS ###\n# [sizeof $icgs] ICGs."
   }
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
      if {![info exist la($icg_ck_name)]} {lappend puts_info($stage_num) "$stage_num\t\t\t[format "%10s" $fanout_max($icg_q_name)] [format "%10s" "MissLatency"][format "%10s" $end_fanout_cells_num]\t$icg_name (Warning)";continue}
      if {[info exist total_latency(${stage_num}_$fanout_range)]} {set total_latency(${stage_num}_$fanout_range) [expr $total_latency(${stage_num}_$fanout_range) +  $la($icg_ck_name)]; incr latency_num(${stage_num}_$fanout_range)} else {set total_latency(${stage_num}_$fanout_range) $la($icg_ck_name); set latency_num(${stage_num}_$fanout_range) 1}
      lappend puts_info($stage_num) "$stage_num\t\t\t[format "%10s" $fanout_max($icg_q_name)] [format "%10s" $la($icg_ck_name)][format "%10s" $end_fanout_cells_num]\t$icg_name"
   }
   foreach latency_rag  [lsort -dic -dec [array name total_latency]] {
      set agv_latency($latency_rag) [expr $total_latency($latency_rag) / $latency_num($latency_rag)]
   }

   redirect -append  $output_file {
      puts "################################## CLK: $icgs_clk_name ##################################"
      set clk_agv_latency [ClkAgvLatency $icgs_clk_name]
      puts "# ClkAgvLatency: $clk_agv_latency\n"
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
      puts "# -------------- Agv Latency -------------------------#\n#\tLatency range : [array name total_latency]"
      foreach latency_rag  [lsort -dic -dec [array name total_latency]] {
         puts "#\t$latency_rag : \t $agv_latency($latency_rag)  ($total_latency($latency_rag) / $latency_num($latency_rag))"
      }
      puts "### -------------- End ---------------- ###\n"
   if {[file exist $stage_fanout_file]} {
      puts "#stage #preCTS_fanout #latency #end_fanout #icg"
   } else {
      puts "#stage #postCTs_fanout #latency #end_fanout #icg"
   }
      foreach num [lsort -integer -dec  [array name puts_info]] {
         puts "# [join $puts_info($num) "\n# "]"
      }
   }
}
