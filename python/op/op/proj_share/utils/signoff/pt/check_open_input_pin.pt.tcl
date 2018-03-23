############################################################################################
# PROGRAM     : check_open_input_pin.tcl
# CREATOR     : Hideki Abe <abe@alchip.com>
# DATE        : Thu April 27 14:05:00 2017
# DESCRIPTION : Check open input pins in PrimeTime.
# USAGE       : check_open_input_pin ?<check_open_input_pin.rpt>
# UPDATE      : updated by Felix <felix_yuan@alchip.com>    2018-03-15
# ITEM        : GE-02-02
############################################################################################

proc check_open_input_pin { {output_rpt_open check_open_input_pin.rpt} } {
     puts "Alchip-info: Starting to signoff check open input pin in PrimeTime\n"
     set file [ open $output_rpt_open w ]
     set cells [ get_cells * -hierarchical -filter "is_hierarchical != true" ]
     set input_pins [ get_pins -of_objects $cells -filter "direction == in || direction == inout" ]
   
   # set input_pins [ filter_collection $input_pins "lib_pin_name != iq" ] ; # Virage only
   
     set open_input_pin_count 0
  foreach_in_collection input_pin $input_pins {
    if { [ string compare [ get_attribute [get_lib_pins -of_objects $input_pin ] is_pad ] false ] == 0 } {
    set net [ all_connected $input_pin ]
    set is_open_input_pin 0
    if { [ sizeof_collection $net ] == 0 } {
      set is_open_input_pin 1  ;# if there is no net connected to this input pin, this pin is a open_input_pin.
    } else {
      set connections [ all_connected -leaf $net ] ;# get all pins connected to this net
      set connections [ remove_from_collection $connections $input_pin ]
      set source_pins  [ filter_collection $connections "( object_class == pin  ) && ( ( direction == out ) || ( direction == inout ) )" ]
      set source_ports [ filter_collection $connections "( object_class == port ) && ( ( direction == in  ) || ( direction == inout ) )" ]
      if { ( [ sizeof_collection $source_pins ] == 0 ) && ( [ sizeof_collection $source_ports ] == 0 ) } {
        set is_open_input_pin 1 ;# if the pins connected to this net are all input pins, this $input_pin is also a open_input_pin
      }
    }
    if { $is_open_input_pin == 1 } {
      incr open_input_pin_count
      set pin_name [ get_attribute $input_pin full_name ]
      set ref_name [ get_attribute [ get_cells -of_objects $input_pin ] ref_name ]
      puts $file [ format "Error: Open input pin %s (%s) found." $pin_name $ref_name ]
    }
   }
  }
  puts $file [ format "Info: Total open input pin count = %d" $open_input_pin_count ]
  close $file
  puts "Alchip-info: Completed to signoff check open input pin in PrimeTime\n"
}

