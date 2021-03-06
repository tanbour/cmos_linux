##################################################################################
# PROGRAM:     check_port_isolation.icc.tcl
# CREATOR:     Michael Mo <michaelm@alchport.com>
# DATE:        Fri Mar 17 11:38:31 CST 2017
# DESCRIPTION: Check port and sub block pin wire length in IC Compiler
# USAGE:       check_port_isolation wire_length_limitation
# FOR:         GE-04-19
##################################################################################

proc check_port_isolation { { wire_length_limitation 50 } { output check_port_isolation.rep } } {
	global physical_partition_reference_names
	global FOOTPRINT_BUF
	global FOOTPRINT_INV
  if { [ info exists physical_partition_reference_names ] == 0 } {
		puts "Error: The procedure 'check_ip_isolation' stop, Please set variables physical_partition_reference_names."
	  return
	}
  if { [ info exists FOOTPRINT_BUF ] == 0 || $FOOTPRINT_BUF == "" } {
		puts "Error: The procedure 'check_port_isolation' stop, Please set variables FOOTPRINT_BUF correctly"
    return
  }
	if { [ info exists FOOTPRINT_INV ] == 0 || $FOOTPRINT_INV == "" } {
		puts "Error: The procedure 'check_port_isolation' stop, Please set variables FOOTPRINT_INV correctly"
		return
	}
	set file [ open $output w ]
	set length_10 0
	set length_20 0
	set length_30 0
	set length_40 0
	set length_50 0
	set over50 0
	set total_nets 0
	set limitnets ""
	set limitnets_length 0
  set length_order ""
	set ports ""
	set block_names ""
	set sub_blocks ""
  set is_isolation 0
  set all_pins ""
  set pin_length_iso_list ""
	set ports [ get_ports ]
	foreach_in_collection port $ports {
		set port_name [ get_attr [ get_ports $port ] full_name ]
		set net [ get_flat_nets -of [ get_ports $port ] -quiet ]
		set connect_cell [ get_flat_cells -of [ get_pins -of [ get_nets $net -quiet ] -leaf -quiet ] -quiet ]
		if { [ sizeof_collection $net ] == 0 } {
			puts $file "Information: No net connected to port '$port_name'."
			continue
		}
		if { [ sizeof_collection $connect_cell ] == 0 } {
			puts $file "Information: No cell connected to port '$port_name'."
			continue
		}
		set connect_ref_name [ get_attr [ get_cells $connect_cell ] ref_name ]
    set length [ NET_LENGTH $net ]
		if { $length >= 0 && $length < 10 } {
			incr length_10
		}
		if { $length >= 10 && $length < 20 } {
			incr length_20
		}
		if { $length >= 20 && $length < 30 } {
			incr length_30
		}
		if { $length >= 30 && $length < 40 } {
			incr length_40
		}
		if { $length >= 40 && $length < 50 } {
			incr length_50
		}
		if { $length >= 50 } {
			incr over50
		}
    if { $length > $wire_length_limitation } {
			incr limitnets_length
    }
		if { [ sizeof_collection $connect_cell ] == 1 && [ regexp $FOOTPRINT_BUF|$FOOTPRINT_INV $connect_ref_name ] == 1 } {
			set is_isolation 1
		} else {
			set is_isolation 0
		}
		lappend all_pins $port_name
		set leng($port_name) $length
		set iso($port_name) $is_isolation
	}
	foreach physical_reference_name $physical_partition_reference_names {
		set block [ get_flat_cells -filter "ref_name =~ $physical_reference_name" -quiet ]
		if { [ sizeof_collection [ get_cells $block -quiet ] ] == 0 } {
			continue
		}
		set block_names [ get_attr [ get_cells $block ] full_name ]
		foreach block_name $block_names {
			set block_pins [ get_attr [ get_flat_pins -of $block_name ] full_name ]
			foreach pin $block_pins {
				set block_net [ get_flat_net -of [ get_pins $pin ] -quiet ]
				set connect_cell [ remove_from_collection [ get_flat_cells -of [ get_flat_pins -of [ get_flat_nets $block_net -quiet ]  -quiet ] -quiet ] [ get_cells $block_name ] ]
				if { [ sizeof_collection $block_net ] == 0 } {
					puts $file "Information: No net connected to pin '$pin'."
					continue
				}
				if { [ sizeof_collection $connect_cell ] == 0 } {
					puts $file "Information: No cell connected to pin '$pin'."
					continue
				}
				set connect_ref_name [ get_attr [ get_cells $connect_cell ] ref_name]
		    set length [ NET_LENGTH $block_net ]
				if { $length >= 0 && $length < 10 } {
					incr length_10
				}
				if { $length >= 10 && $length < 20 } {
					incr length_20
				}
				if { $length >= 20 && $length < 30 } {
					incr length_30
				}
				if { $length >= 30 && $length < 40 } {
					incr length_40
				}
				if { $length >= 40 && $length < 50 } {
					incr length_50
				}
				if { $length >= 50 } {
					incr over50
				}
		    if { $length > $wire_length_limitation } {
					incr limitnets_length
		    }
				if { [ sizeof_collection $connect_cell ] == 1 && [ regexp $FOOTPRINT_BUF|$FOOTPRINT_INV $connect_ref_name ] == 1 } {
					set is_isolation 1
				} else {
					set is_isolation 0
				}
				lappend all_pins $pin
				set leng($pin) $length
				set iso($pin) $is_isolation
			}
		}
	}

	set total_nets [ expr $length_10 + $length_20 + $length_30 + $length_40 + $length_50 + $over50 ]
	puts $file "\nWire Length Range   Count" 
	puts $file "-----------------   -------"
	puts $file "    0 < 10          $length_10"
	puts $file "   10 < 20          $length_20"
	puts $file "   20 < 30          $length_30"
	puts $file "   30 < 40          $length_40"
	puts $file "   40 < 50          $length_50"
	puts $file "   50 <             $over50"
	puts $file "-----------------   -------"
	puts $file "Total               $total_nets\n"

	puts $file "Total Wire Length over ${wire_length_limitation}(um) = $limitnets_length"
	foreach pin $all_pins {
		lappend pin_length_iso_list "$pin $leng($pin) $iso($pin)"
	}
	set length_order [ lsort -real -index 1 -decreasing $pin_length_iso_list ]
	foreach order $length_order {
		set pin [ lindex $order 0 ]
		set net_length [ lindex $order 1 ]
		set isolation [ lindex $order 2 ]
		if { [ sizeof_collection [ get_ports $pin -quiet ] ] == 0 } {
			if { $net_length > $wire_length_limitation } {
				puts $file "Error:       Net length of net connected to pin '$pin' is ${net_length}um, longer than ${wire_length_limitation}um."
				puts $file "Warning:     No isolation buffer inserted on pin '$pin'.\n"
			}
			if { $net_length <= $wire_length_limitation && $isolation == 0 } {
				puts $file "Information: Net length of net connected to pin '$pin' is ${net_length}um, not longer than ${wire_length_limitation}um."
				puts $file "Warning:     No isolation buffer inserted on pin '$pin'.\n"
			} 
			if { $net_length <= $wire_length_limitation && $isolation == 1 } {
				puts $file "Information: Net length of net connected to pin '$pin' is ${net_length}um, not longer than ${wire_length_limitation}um."
				puts $file "Information: Isolation buffer inserted on pin '$pin'.\n"
			} 
		} else {
			if { $net_length > $wire_length_limitation } {
				puts $file "Error:       Net length of net connected to port '$pin' is ${net_length}um, longer than ${wire_length_limitation}um."
				puts $file "Warning:     No isolation buffer inserted on port '$pin'.\n"
			}
			if { $net_length <= $wire_length_limitation && $isolation == 0 } {
				puts $file "Information: Net length of net connected to port '$pin' is ${net_length}um, not longer than ${wire_length_limitation}um."
				puts $file "Warning:     No isolation buffer inserted on port '$pin'.\n"
			} 
			if { $net_length <= $wire_length_limitation && $isolation == 1 } {
				puts $file "Information: Net length of net connected to port '$pin' is ${net_length}um, not longer than ${wire_length_limitation}um."
				puts $file "Information: Isolation buffer inserted on port '$pin'.\n"
			} 
		}
	}
	close $file
}


proc NET_LENGTH { net } {
  if { [ sizeof_collection [ get_nets $net -quiet ] ] != 0 } {
    set route_length [ lindex [ get_attr [ get_nets $net ] route_length ] 0 ]
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
