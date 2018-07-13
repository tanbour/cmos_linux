##################################################################################
# PROGRAM:     check_ip_isolation.icc2.tcl
# CREATOR:     Michael Mo <michaelm@alchip.com>
# DATE:        Mon Mar 27 16:03:45 CST 2017
# DESCRIPTION: Check ip wire length in IC Compiler II
# USAGE:       check_ip_isolation wire_length_limitation
# FOR:         GE-04-07,GE-04-19
##################################################################################

#set FOOTPRINT_BUF "BUF"
#set FOOTPRINT_INV "INV"
#set ip_reference_names [ list sasslsck4l1p1024x32m4b2w1c0p0d0t0s10 ]
proc check_ip_isolation { { wire_length_limitation 50 } { output check_ip_isolation.rep } } {
	global ip_reference_names
	global FOOTPRINT_BUF
  global FOOTPRINT_INV
  if { [ info exists ip_reference_names ] == 0 } {
		puts "Error: The procedure 'check_ip_isolation' stop, Please set variables ip_reference_names."
		return
	}
  if { [ info exists FOOTPRINT_BUF ] == 0 || $FOOTPRINT_BUF == "" } {
		puts "Error: The procedure 'check_ip_isolation' stop, Please set variables FOOTPRINT_BUF correctly."
	  return
	}
	if { [ info exists FOOTPRINT_INV ] == 0 || $FOOTPRINT_INV == "" } {
		puts "Error: The procedure 'check_ip_isolation' stop, Please set variables FOOTPRINT_INV correctly."
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
	set ip_names ""
	set is_isolation 0
	set all_pins ""
	set pin_length_iso_list ""
	foreach ip_reference_name $ip_reference_names {
		set ip [ get_cells -hier -filter "ref_name =~ $ip_reference_name" -quiet ]
   	if { [ sizeof_collection $ip ] == 0 } {
	  	continue
   	}
		set ip_names [ get_attr [ get_cells $ip ] full_name ]
		foreach ip_name $ip_names {
			set ip_pins [ get_attr [ get_pins -of $ip_name ] full_name ]
			foreach pin $ip_pins {
				set ip_net [ get_nets -of [ get_pins $pin ] -quiet ]
				set connect_cell [ remove_from_collection [ get_cells -of [ get_pins -of [ get_nets $ip_net -quiet ] -leaf -quiet ] -quiet ] [ get_cells $ip_name ] ]
				if { [ sizeof_collection $ip_net ] == 0 } {
					puts $file "Information: No net connected to pin '$pin'."
					continue
				}
				if { [ sizeof_collection $connect_cell ] == 0 } {
					puts $file "Information: No cell connected to pin '$pin'."
					continue
				}
				set connect_ref_name [ get_attr [ get_cells $connect_cell ] ref_name]
		    set length [ NET_LENGTH $ip_net ]
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

	puts $file "Total IP Wire Length over ${wire_length_limitation}(um) = $limitnets_length"
	foreach pin $all_pins {
		lappend pin_length_iso_list "$pin $leng($pin) $iso($pin)"
	}
	set length_order [ lsort -real -index 1 -decreasing $pin_length_iso_list ]
	foreach order $length_order {
		set pin [ lindex $order 0 ]
		set net_length [ lindex $order 1 ]
		set isolation [ lindex $order 2 ]
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
	}
	close $file
}

proc NET_LENGTH { net } {
        set length 0
	if {[sizeof_collection [get_nets $net -quiet]] == 0} {
		puts "Error: No such net: $net"
		return 0
	}

	set net_name [get_attr [get_nets $net -quiet ] full_name]
	if { [dbget [ dbGetNetByName $net_name ].wires] != "0x0" } {
	        foreach wire_len [dbget [dbGetNetByName $net_name].wires.length] {
	                set length [expr $length + $wire_len]
	        }
		return $length
	} else {
	        #puts "Error: No routed net: $net_name"
	        return 0
	}
	return $length
}
