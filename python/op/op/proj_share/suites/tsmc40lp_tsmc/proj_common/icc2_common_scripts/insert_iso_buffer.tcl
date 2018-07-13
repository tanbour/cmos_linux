
set in_clk_ports [filter_collection [get_attr  [get_clocks *] sources] "object_class == port"]
foreach_in_collection  port [filter_collection [get_ports] "port_type != ground && port_type != power"] {
	set name [get_attribute [get_port $port] full_name]
	set num [sizeof_collection [get_pins -of_objects [all_connected [get_port $port]]]]
	if {$num != 0} {
      if {[sizeof [remove_from_collection $port $in_clk_ports]]} {
   		insert_buffer -lib_cell */BUFFD6BWP240H8P57PDLVT -new_net_names ISO_BUF_${name} -new_cell_names ISO_BUF_${name} -no_of_cells 1 [get_ports $port]
      } else {
         insert_buffer -lib_cell */CKBD6BWP240H8P57PDLVT -new_net_names ISO_BUF_${name} -new_cell_names ISO_BUF_${name} -no_of_cells 1 [get_ports $port]
      }
	}
}

set ports [get_attribute [filter_collection [get_ports ] "port_type != ground && port_type != power"] full_name]
#set ports [get_attribute [filter_collection [get_ports ] "port_type != ground && port_type != power && layer_name == M5"] full_name]
#source -e -v "{{env.PROJ_SHARE_CMN}}/icc2_common_scripts/icc2_proc_sh2.tcl"
moveIObufferA $ports R {2.2 0}

set_app_options -name place.legalize.enable_pin_color_alignment_check -value true
set_app_options -name place.legalize.pin_color_alignment_layers -value [list M1 M2]
change_selection [get_cells ISO_BUF_*]
legalize_placement -cells [get_selection]
set_locked_objects [get_selection]


set portListA   [arrangPinInc $ports X]
set portS       [lindex $portListA 0]
set portE       [lindex $portListA end]

set xl [lindex [get_attribute [get_ports $portS ] bbox] 0 0]
set xr [lindex [get_attribute [get_ports $portE ] bbox] 0 0]
set area ""
lappend area    [calculateRefRowloc2 [concat [expr $xl - 1] 0] {0 0}]
lappend area    [calculateRefRowloc2 [concat [expr $xr + 3] 5] {0 0}]

create_placement_blockage -boundary $area -name port_Blk -type hard

