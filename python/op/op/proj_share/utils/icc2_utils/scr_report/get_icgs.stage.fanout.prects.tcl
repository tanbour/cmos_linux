if {![info exist output_file]} {set output_file "icgs.stage.fanout.info.tcl"}
set icgs [get_cells -q -hierarchical   -filter "is_integrated_clock_gating_cell"]
if {![sizeof $icgs]} {puts "INFO: no ICGs"; return}
set icg_q_filter "lib_pin_name == Q"
set icg_ck_filter "lib_pin_name == CK"
set fanout_range_list "1-32 32-1000 1001-2000 2001-3000 3001-inf"

set err_info ""
##** height_max = Stage/Level of Clock gate
##***The stage of Clock gate cannot be determined after the clock tree is built. ICC II treats CT buffers/inverters as levels.Hence the stage and fanout information has to be dumped out from pre-CTS database.
get_clock_tree_pins -assign_to_variable height_max -sort_by height_max -filter {is_on_icg}
get_clock_tree_pins -assign_to_variable fanout_max -sort_by fanout_max -filter {is_on_icg}
if {[info exist puts_info]} {unset puts_info};
if {[info exist height_max_num]} {unset height_max_num};
if {[info exist fanout_range_cnd]} {unset fanout_range_cnd};
if {[info exist miss_fanout_range_info]} {unset miss_fanout_range_info};
foreach_in_collection icg $icgs {
   set icg_name [get_object_name $icg]
   set icg_q [get_pins -of $icg  -filter $icg_q_filter]
   set icg_q_name [get_object_name $icg_q]
   set icg_ck [get_pins -of $icg  -filter $icg_ck_filter]
   set icg_ck_name [get_object_name $icg_ck]
   if {[info exist height_max($icg_ck_name)]} {set stage_num $height_max($icg_ck_name)} else { lappend err_info "# $icg_ck_name  \"miss height_max(stage_num)\""; continue}
#   if {[expr int($stage_num)] != $stage_num} {lappend err_info "# $icg_ck_name  \"height_max(stage_num)\" not integer : $stage_num"; continue} 
   if {[regexp {\.} $stage_num]} {lappend err_info "# $icg_ck_name  \"height_max(stage_num)\" not integer : $stage_num"; continue}
   if {![info exist puts_info($stage_num)]} {set puts_info($stage_num) ""}
   lappend puts_info($stage_num) "set height_max($icg_ck_name) $stage_num"
   lappend puts_info($stage_num) "set fanout_max($icg_q_name) $fanout_max($icg_q_name)"
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
      if {[info exist  fanout_range_cnd(miss_fanout_range)]} {incr fanout_range_cnd(miss_fanout_range);lappend miss_fanout_range_info "[format "%10s" $fanout_max($icg_q_name)] $icg_name"} else {set fanout_range_cnd(miss_fanout_range) 1; set miss_fanout_range_info ""; lappend miss_fanout_range_info "[format "%10s" $fanout_max($icg_q_name)] $icg_name";}
   set have_fanout_range 0 
   }           
}
redirect  $output_file {
   if {$err_info != ""} {puts "#Error info:\n\t[join $err_info "\n\t"]\n"}
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
   puts "### -------------- End ---------------- ###\n"
   puts "if {\[info exist height_max\]} {unset height_max}\nif {\[info exist fanout_max\]} {unset fanout_max}"
   foreach num [lsort -integer -dec  [array name puts_info]] {
      puts [join $puts_info($num) "\n"]
   }
}
