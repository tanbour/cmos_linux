###################################################################
# PROGRAM:     check_signal_wire_length.icc2.tcl
# CREATOR:     Michael Mo <michaelm@alchip.com>
# DATE:        Mon Mar 27 16:03:45 CST 2017
# DESCRIPTION: Check all wire length in IC Compiler II
# USAGE:       check_signal_wire_length wire_length_limitation
# FOR:         GE-05-05
###################################################################

proc check_signal_wire_length { { wire_length_limitation 1000 } { output check_signal_wire_length.rep } } {
	set file [ open $output w ]
	set length_200 0
	set length_400 0
	set length_600 0
	set length_800 0
	set length_1000 0
	set over1000 0
	set total_nets 0
	set limitnets ""
	set limitnets_length 0
  set length_order ""
  set net_length_list ""
	set nets [ get_nets -hier]
  foreach_in_collection net $nets {
    set net_name [ get_attr [ get_nets $net ] full_name ]
    set length [ NET_LENGTH $net_name ]
		set leng($net_name) $length
		if { $length >= 0 && $length < 200 } {
			incr length_200
		}
		if { $length >= 200 && $length < 400 } {
			incr length_400
		}
		if { $length >= 400 && $length < 600 } {
			incr length_600
		}
		if { $length >= 600 && $length < 800 } {
			incr length_800
		}
		if { $length >= 800 && $length < 1000 } {
			incr length_1000
		}
		if { $length >= 1000 } {
			incr over1000
		}
    if { $length > $wire_length_limitation } {
			lappend limitnets $net_name
			incr limitnets_length
    }
  }

	set total_nets [ expr $length_200 + $length_400 + $length_600 + $length_800 + $length_1000 + $over1000 ]
	puts $file "Wire Length Range   Count" 
	puts $file "-----------------   -------"
	puts $file "     0 < 200        $length_200"
	puts $file "   200 < 400        $length_400"
	puts $file "   400 < 600        $length_600"
	puts $file "   600 < 800        $length_800"
	puts $file "   800 < 1000       $length_1000"
	puts $file "  1000 <            $over1000"
	puts $file "-----------------   -------"
	puts $file "Total               $total_nets\n"

	puts $file "Total Wire Length over ${wire_length_limitation}(um) = $limitnets_length"
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
