####################################################################################################
# PROGRAM     : get_drivers
# DESCRIPTION : find driver objects
# USAGE       : get_drivers pin/cell/net
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

