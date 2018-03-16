############################################################################################
# PROGRAM     : check_tie_net_length.icc2.tcl 
# CREATOR     : Alchip                                
# DATE        : 2018-02-24                                                   
# DESCRIPTION : check tie net length over 20um in ICC2 
# UPDATER     : Felix Yuan <felix_yuan@alchip.com>  
# USAGE       : check_tie_net_length ?<tie_cell_type> 
# ITEM        : GE-02-12
##############################################################################################

#proc check_tie_net_length { {tie_cell_type "ref_name =~ TIE*"} {output_rpt_tie_length check_tie_net_length.rpt} } {
proc check_tie_net_length { {tie_cell_type "TIE*"}} {
     puts "Alchip-info: Starting to signoff check tie net length over 20um {TIEH* TIEL*} in ICC2\n"
  #  set file [ open $output_rpt_tie_length w ]
     echo "## Starting to check tie net length over 20um Info: $tie_cell_type"
   foreach_in_collection cell [ get_cells -hier -filter "ref_name =~ $tie_cell_type" ] {
        set pin [get_pins -of_objects $cell -leaf -filter "pin_direction == out"]
        set pin_full_name [get_attr [get_pin $pin] full_name]
        set net [get_nets -of_objects $pin]
        set netlength [get_attr [get_nets $net] route_length]
        set totallength [calculate_length $netlength]
      if {$totallength > 20} {
         echo "$pin_full_name tie net length equal to $totallength (um)"
      }
   }
#close $file
}

proc calculate_length { arg } {
   set num [llength $arg]
   set route_len 0
   for {set x 0 } {$x < $num} {incr x} {
      set leng [lindex $arg $x]
      set metal_len [lindex $leng 1]
      set route_len [expr $route_len + $metal_len]
   }
   return $route_len
}


foreach_in_collection lib [get_lib_cells */TIEH*] {
  set cell_type [get_attribute [get_lib_cells $lib] base_name]
  if { [sizeof_collection [get_cells * -hier -filter "ref_name == $cell_type" -quiet]] != 0 } {
    check_tie_net_length $cell_type >> check_tie_net_length.rpt
  }
}

foreach_in_collection lib [get_lib_cells */TIEL*] {
  set cell_type [get_attribute [get_lib_cells $lib] base_name]
  if { [sizeof_collection [get_cells * -hier -filter "ref_name == $cell_type" -quiet]] != 0 } {
    check_tie_net_length $cell_type >> check_tie_net_length.rpt
  }
  puts "Alchip-info: Completed to signoff check tie net length over 20um {TIEH* TIEL*} in ICC2\n"
}
