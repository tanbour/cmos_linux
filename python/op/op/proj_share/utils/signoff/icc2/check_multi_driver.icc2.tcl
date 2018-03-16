####################################################################################################################
# PROGRAM     : check_multi_driver.icc2.tcl 
# CREATOR     : Alchip                                
# DATE        : 2018-03-05                                                   
# DESCRIPTION : check  hign-fanout net / multi-drive net / undirven net /undriven pin  in ICC2 
# USAGE       : check_multi_driver ?<check_multi_driver.rpt>
# UPDATER     : Felix Yuan <felix_yuan@alchip.com>  
# ITEM        : GE-02-03                                                     
####################################################################################################################
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

    if {[sizeof_collection [ get_port $net -quiet ] ] == 1 } {
        return [ get_ports $net ]
    } else {
        set load_pin [ filter_collection [ all_connected [ get_net $net ] -leaf ] "direction != out" ]
#       if { [ sizeof_collection $load_pin ] != 0 } {
#           return $load_pin
#       } else {
#           echo "Warning: net $arg has no loading!!"
#           return 0
#       }
    }
}

proc check_multi_driver { {output_rpt_multi_driver check_multi_driver.rpt} } {
     puts "Alchip-info: Starting to signoff check multi-driver in ICC2\n"
	set multiple_driven_net 0
	set undriven_net 0
	set undriven_pin 0
	set no_sink_net 0
	set high_fanout_net 0
	set high_fanout_threshold 32

	set report [open $output_rpt_multi_driver w]
	set all_pins [get_pins * -hier]
	foreach_in_collection pin $all_pins {
		set pin_name [get_attr [get_pins $pin] lib_pin_name]
		set net [all_connected $pin]
		set dir [get_attribute [get_pins $pin] direction]
		if { [get_attribute [get_cells -of $pin] is_hierarchical] == "true" } {
			continue
		}
		if { [sizeof_collection $net] == 0 } {
			set ref [get_attribute [get_cells -of $pin] ref_name]
			if { [string equal $dir "internal"] == 1 } {
				continue
			} elseif { [string equal $pin_name "FP"] == 1 } {
				continue
			} elseif { [string equal $pin_name "VDD"] == 1 } {
				continue
			} elseif { [string equal $pin_name "VSS"] == 1 } {
				continue
			} elseif { [string equal $pin_name "VDD1"] == 1 } {
				continue
			} elseif { [string equal $pin_name "VSS1"] == 1 } {
				continue
			} elseif { [string equal $pin_name "VDD2"] == 1 } {
				continue
			} elseif { [string equal $pin_name "VSS2"] == 1 } {
				continue
			} elseif { [string equal $dir "in"] == 1 } {
				puts $report [format "INFO : floating input pin %s (%s)" [get_attribute $pin full_name] $ref]
			} elseif { [string equal $dir "out"] == 1 } {
				puts $report [format "INFO : floating output pin %s (%s)" [get_attribute $pin full_name] $ref]
			} else {
				puts $report [format "INFO : floating inout pin %s (%s)" [get_attribute $pin full_name] $ref]
			}
		} elseif { [sizeof_collection $net] > 1 } {
			puts $report [format "INFO : multiple driven pin %s %s" [get_attribute $pin full_name] [sizeof_collection $net]]
		}
	}
	set all_nets [get_nets * -hier -top_net_of_hierarchical_group]
	foreach_in_collection net $all_nets {
		set drive_pins [filter_collection [get_pins -quiet -of_objects $net -leaf] "object_class == pin && direction == out && lib_pin_name != *VDD* && lib_pin_name != *VSS* "]
	        set drive_ports [filter_collection [get_ports -quiet -of_objects $net] "object_class == port && direction == in"]	
		set drive_num [expr [sizeof_collection $drive_pins] + [sizeof_collection $drive_ports]]
		set load_pins [filter_collection [get_pins -quiet -of_objects $net -leaf] "object_class == pin && direction == in"]
	        set load_ports [filter_collection [get_ports -quiet -of_objects $net] "object_class == port && direction == out"]	
		set load_num [expr [sizeof_collection $load_pins] + [sizeof_collection $load_ports]]
		set inout_pins [filter_collection [get_pins -quiet -of_objects $net -leaf] "object_class == pin && direction == inout"]
		set inout_ports [filter_collection [get_ports -quiet -of_objects $net] "object_class == port && direction == inout"]
		set inout_num [expr [sizeof_collection $inout_pins] + [sizeof_collection $inout_ports]]

		set net_name [ get_attribute [get_nets $net] full_name ]
		if { $drive_num ==0 && $inout_num == 0 && $load_num == 0 && $inout_num == 0 } {
		} else {
			if { $drive_num == 0  && $inout_num == 0 } {
				puts $report "INFO : UNDRIVEN_NET $net_name"
				incr undriven_net
                ## to get open input pins
                set a [gl $net_name]
                foreach_in_collection b $a {
                    set c [get_attribute [get_pins $b] full_name]
                    puts $report "INFO : UNDRIVEN_PIN $c"
                }
                set undriven_pin [expr $undriven_pin + [sizeof [gl $net_name]]]

			} elseif { $drive_num > 1 } {
				puts $report "INFO : MULTIPLE_DRIVEN_NET $net_name"
				incr multiple_driven_net
			}
			if { $load_num > $high_fanout_threshold } {
				puts $report "INFO : HIGH_FANOUT_NET $net_name $load_num"
				incr high_fanout_net
			} elseif { $load_num == 0 && $inout_num == 0 } {
				puts $report "INFO : NO_SINK_NET $net_name"
				incr no_sink_net
			}
		}
	}

	puts $report ""
	puts $report "##### HIGH_FANOUT_NET ($high_fanout_threshold) : $high_fanout_net #####"
	puts $report "##### MULTIPLE_DRIVEN_NET : $multiple_driven_net #####"
	puts $report "##### UNDRIVEN_NET : $undriven_net #####"
	puts $report "##### UNDRIVEN_PIN : $undriven_pin #####"
	puts $report "##### NO_SINK_NET : $no_sink_net #####"
	puts "##### HIGH_FANOUT_NET : $high_fanout_net #####"
	puts "##### MULTIPLE_DRIVEN_NET : $multiple_driven_net #####"
	puts "##### UNDRIVEN_NET : $undriven_net #####"
	puts "##### UNDRIVEN_PIN : $undriven_pin #####"
	puts "##### NO_SINK_NET : $no_sink_net #####"
	close $report
        puts "Alchip-info: Completed to signoff check multi-driver in ICC2\n"
}
