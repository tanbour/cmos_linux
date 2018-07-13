#############################################################################################
# PROGRAM     : check_tie_connection.icc2.tcl 
# CREATOR     : Michael Mo <michaelm@alchip.com>
# DATE        : Mon Mar 27 16:03:45 CST 2017
# DESCRIPTION : Check tie fanout and wire length in IC Compiler II
# USAGE       : check_tie_connection ?<tie_wire_length_limitation> ?<output_rpt_tie>
# UPDATE      : updated by felix_yuan 2018-02-13
# ITEM        : GE-02-12
#############################################################################################

proc check_tie_connection { { tie_wire_length_limitation 100 } { output_rpt_tie check_tie_connection.rpt } } {
     puts "Alchip-info: Starting to signoff check tie fanout and wire length in ICC2\n"
	global footprint_tie
	if { [ info exists footprint_tie ] == 0 || $footprint_tie == "" } {
		puts "Error: The procedure 'check_tie_connection' stop, Please set variables footprint_tie correctly."
	  return
	}
	set tie_cell [ get_flat_cells -filter "ref_name =~ *${footprint_tie}*" -quiet ]
	if { [ sizeof_collection [ get_cells $tie_cell -quiet ] ] == 0 } {
		puts "Information: No tie cells in this database!"
	  return
	}
	set file [ open $output_rpt_tie w ]
	set length_20 0
	set length_40 0
	set length_60 0
	set length_80 0
	set length_100 0
	set over100 0
	set fanout_4 0
	set fanout_8 0
	set fanout_12 0
	set fanout_16 0
	set over16 0
	set load_list ""
	set load_list_length 0
	set total_nets 0
	set limitnets ""
	set limitnets_length 0
  set length_order ""
  set net_length_list ""
	set tie_names ""
	set tie_net_list ""
	set tie_net_fanout ""
  set fanout_order ""
	set total_tie_cells ""
	set tie_names [ get_attr [ get_cells $tie_cell ] full_name ]
	foreach tie_name $tie_names {
		set tie_net [ get_nets -of [ get_pins -of [ get_cells $tie_name ] -leaf -filter "pin_direction == out" ] -quiet ]
		if { [ sizeof_collection [ get_nets $tie_net -quiet ] ] == 0 } {
			continue
		}
	  set net [ get_attr [ get_nets $tie_net ] full_name ]
		set load_list [ get_pins -of_objects [ get_nets $net ] -leaf -filter "pin_direction =~ in*" -quiet ]
		set load_list_length [ sizeof_collection [ get_pins $load_list -quiet ] ]
    set length [ NET_LENGTH $net ]
		set leng($net) $length
		if { $length >= 0 && $length < 20 } {
			incr length_20
		}
		if { $length >= 20 && $length < 40 } {
			incr length_40
		}
		if { $length >= 40 && $length < 60 } {
			incr length_60
		}
		if { $length >= 60 && $length < 80 } {
			incr length_80
		}
		if { $length >= 80 && $length < 100 } {
			incr length_100
		}
		if { $length >= 100 } {
			incr over100
		}
	  if { $length > $tie_wire_length_limitation } {
			lappend limitnets $net
			incr limitnets_length
	  }

		if { $load_list_length >= 0 && $load_list_length <= 4 } {
			incr fanout_4
		}
		if { $load_list_length > 4 && $load_list_length <= 8 } {
			incr fanout_8
		}
		if { $load_list_length > 8 && $load_list_length <= 12 } {
			incr fanout_12
		}
		if { $load_list_length > 12 && $load_list_length <= 16 } {
			incr fanout_16
		}
		if { $load_list_length > 16 } {
			set fan($net) $load_list_length
			lappend tie_net_list $net
			incr over16
		}
	}

	set total_tie_cells [ expr $fanout_4 + $fanout_8 + $fanout_12 + $fanout_16 + $over16 ]
	puts $file "###########################" 
	puts $file "Tie Fanout Range   Count" 
	puts $file "-----------------  -------"
	puts $file "    0 < 4          $fanout_4"
	puts $file "    4 < 8          $fanout_8"
	puts $file "    8 < 12         $fanout_12"
	puts $file "   12 < 16         $fanout_16"
	puts $file "   16 <            $over16"
	puts $file "-----------------  -------"
	puts $file "Total              $total_tie_cells\n"

	puts $file "Total Tie Fanout over 16 = $over16"
	foreach net $tie_net_list {
		lappend tie_net_fanout "$net $fan($net)"
	}
	set fanout_order [ lsort -real -index 1 -decreasing $tie_net_fanout ]
	foreach order $fanout_order {
		set net [ lindex $order 0 ]
		set net_fanout [ lindex $order 1 ]
		puts $file "Error: $net ($net_fanout)"
	}

	set total_nets [ expr $length_20 + $length_40 + $length_60 + $length_80 + $length_100 + $over100 ]
	puts $file "\n###############################" 
	puts $file "Tie Wire Length Range   Count" 
	puts $file "---------------------   -------"
	puts $file "    0 < 20              $length_20"
	puts $file "   20 < 40              $length_40"
	puts $file "   40 < 60              $length_60"
	puts $file "   60 < 80              $length_80"
	puts $file "   80 < 100             $length_100"
	puts $file "  100 <                 $over100"
	puts $file "---------------------   -------"
	puts $file "Total                   $total_nets\n"

	puts $file "Total Tie Wire Length over ${tie_wire_length_limitation}(um) = $limitnets_length"
	foreach net $limitnets {
		lappend net_length_list "$net $leng($net)"
	}
	set length_order [ lsort -real -index 1 -decreasing $net_length_list ]
	foreach order $length_order {
		set net [ lindex $order 0 ]
		set net_length [ lindex $order 1 ]
		puts $file "Error: $net ($net_length)"
	}
	close $file
        puts "Alchip-info: Completed to signoff check tie fanout and wire length in ICC2\n"
}



proc NET_LENGTH { net } {
  if { [ sizeof_collection [ get_nets $net -quiet ] ] != 0 } {
    set route_length [ get_attr [ get_nets $net ] route_length ]
    if { $route_length == 0 } {
      return 0
    }
    set length 0
    foreach l $route_length {
      set length [ expr $length + [ lindex $l 1 ] ]
    }
    return $length
  } else {
    puts "Error: No such net: $net"
    return 0
  }
}

