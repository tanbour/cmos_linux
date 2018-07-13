##############################################################################################
# PROGRAM     : check_open_input_pin.icc2.tcl 
# EDITOR      : Felix <felix_yuan@alchip.com>                                
# DATE        : 2018-02-09                                                   
# DESCRIPTION : check open input pin             
# USAGE       : check_open_input_pin ?<output_rpt_open_pin> 
# ITEM        : GE-02-02                                                   
##############################################################################################

proc check_open_input_pin {{output_rpt_open_pin check_open_input_pin.rep}} {
     puts "Alchip-info: Starting to signoff check open input pin in ICC2\n"
     set file [ open $output_rpt_open_pin w ]
     echo [ format "Info: check_open_input_pin started on %s" [ sh date +'%Y/%m%d %H:%M:%S' ] ]
     puts $file [ format "Info: check_open_input_pin started on %s" [ sh date +'%Y/%m%d %H:%M:%S' ] ]
    
     set cells [ get_flat_cells *  ]
     set input_pins [ get_flat_pins -of_objects $cells -filter "direction == in || direction == inout" ]
   
     # Only Virage 
     # set input_pins [ filter_collection $input_pins "lib_pin_name != iq" ]
   
     set open_input_pin_count 0
  foreach_in_collection input_pin $input_pins {
    set net  [get_nets -physical_context  -of_objects $input_pin ]
    set is_open_input_pin 0
    if { [ sizeof_collection $net ] == 0 } {
      set is_open_input_pin 1
    } elseif { [ sizeof_collection [ get_drivers $net ] ] == 0 } {
 #  set is_open_input_pin 1
      set NET [ get_object_name $net ]
      if { ([regexp {Logic0} $NET ] == 1 ) || ([regexp {Logic1} $NET ] == 1 ) } {
      set pin_name [ get_attribute $input_pin full_name ]
      set ref_name [ get_attribute [ get_cells -of_objects $input_pin ] ref_name ]
      echo [ format "Warning: Open input pin connected to 1'b0/1'b1  %s (%s) found." $pin_name $ref_name ]
      puts $file [ format "Warning: Open input pin connected to 1'b0/1'b1  %s (%s) found." $pin_name $ref_name ] 
      } else {

      set is_open_input_pin 1
	}
    }
    if { $is_open_input_pin == 1 } {
      incr open_input_pin_count
      set pin_name [ get_attribute $input_pin full_name ]
      set ref_name [ get_attribute [ get_cells -of_objects $input_pin ] ref_name ]
      echo [ format "Error: Open input pin %s (%s) found." $pin_name $ref_name ]
      puts $file [ format "Error: Open input pin %s (%s) found." $pin_name $ref_name ]
    }
  }
  echo [ format "Info: Total open input pin count = %d" $open_input_pin_count ]
  puts $file [ format "Info: Total open input pin count = %d" $open_input_pin_count ]

  echo [ format "Info: check_open_input_pin finished on %s" [ sh date +'%Y/%m%d %H:%M:%S' ] ]
  puts $file [ format "Info: check_open_input_pin finished on %s" [ sh date +'%Y/%m%d %H:%M:%S' ] ]
  close $file
  puts "Alchip-info: Completed to signoff check open input pin in ICC2\n"
}

####################################################################################################
# Description : find driver objects
# Usage       : get_drivers pin/cell/net
####################################################################################################

proc get_drivers {args} {
 parse_proc_arguments -args $args results

 # if it's not a collection, convert into one
 redirect /dev/null {set size [sizeof_collection $results(object_spec)]}
 if {$size == ""} {
  set objects {}
  foreach name $results(object_spec) {
   if {[set stuff [get_ports -quiet $name]] == ""} {
    if {[set stuff [get_cells -quiet $name]] == ""} {
     if {[set stuff [get_pins -quiet $name]] == ""} {
      if {[set stuff [get_nets -quiet $name]] == ""} {
       continue
      }
      }
    }
   }
   set objects [add_to_collection $objects $stuff]
  }
 } else {
  set objects $results(object_spec)
 }

 if {$objects == ""} {
  echo "Error: no objects given"
  return 0
 }

 set driver_results {}

 # process all cells
 if {[set cells [get_cells -quiet $objects]] != ""} {
  # add driver pins of these cells
  set driver_results [add_to_collection -unique $driver_results \
   [get_pins -quiet -of $cells -filter "pin_direction == out || pin_direction == inout"]]
 }

 # get any nets
 set nets [get_nets -quiet $objects]

 # get any pin-connected nets
 if {[set pins [get_pins -quiet $objects]] != ""} {
  set nets [add_to_collection -unique $nets \
   [get_nets -quiet -of $pins]]
 }

 # get any port-connected nets
 if {[set ports [get_ports -quiet $objects]] != ""} {
  set nets [add_to_collection -unique $nets \
   [get_nets -quiet -of $ports]]
 }

 # process all nets
 if {$nets != ""} {
  # add driver pins of these nets
  set driver_results [add_to_collection -unique $driver_results \
   [get_pins -quiet -leaf -of $nets -filter "pin_direction == out || pin_direction == inout"]]
  set driver_results [add_to_collection -unique $driver_results \
   [get_ports -quiet -of $nets -filter "port_direction == in || port_direction == inout"]]
 }

 # return results
 return $driver_results
}

define_proc_attributes get_drivers \
 -info "Return driver ports/pins of object" \
 -define_args {\
  {object_spec "Object(s) to report" "object_spec" string required}
 }

