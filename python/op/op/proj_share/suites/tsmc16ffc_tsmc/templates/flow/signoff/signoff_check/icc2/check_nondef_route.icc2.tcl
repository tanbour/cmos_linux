#!/usr/bin/tclsh
########################################################################
# PROGRAM     : check_nondef_route.icc2.tcl
# CREATOR     : Zachary Shi <zacharys@alchip.com>
# DATE        : Fri Aug 11 12:23:04 2017
# DESCRIPTION : checking the clock net's routing rule
# USAGE       : check_nondef_route < none | -net (net_name|file_name) | -clock clock_name >
#               check_nondef_route -help
# ITEM       :  CK-01-07
########################################################################

proc check_nondef_route { args } {
  puts "Alchip-info: Starting to signoff check clock net's routing rule in ICC2\n"

  set args_num   [ llength $args ]
  dputs "Info: the input args number is $args_num"
  set clock_nets [ list ]

  if { $args_num == 0 } {
    # get clock nets excludes the net connected to leaf pins
    set clock_nets [ check_nondef_route::get_clock_nets [ get_clocks * -quiet ] ]
    if { [ llength $clock_nets ] == 0 } {
      return
    }

  } elseif { $args_num == 2 } {

    set flag      [ lindex $args 0 ]
    set flag_name [ lindex $args 1 ]

    if { $flag == "-clock" } {
      set clock_name [ lindex $args 1 ]
      set clock_nets [ check_nondef_route::get_clock_nets $clock_name ]
      if { [ llength $clock_nets ] == 0 } {
        return
      }

    } elseif { $flag == "-net" } {

      if { [ file exist $flag_name ] } {
        set net_num 0
        set input_file [ open $flag_name r ]
        while { [ gets $input_file line ] >= 0 } {
          if { [ llength $line ] != 0 } {
            set line [ lindex $line 0 ] ;# remove the empty space
            if { [ sizeof_collection [ get_nets $line -quiet ] ] == 1 } {
              lappend clock_nets $line
              incr net_num
            } else {
              puts "Error: can't find the net, please check it: $line"
            }
          }
        }
        close $input_file

        if { $net_num == 0 } {
          puts "Error: can't find any net, please check the input file"
          return
        } else {
          puts "Info: total $net_num nets were found in the input file"
        }

      } else {
        if { [ sizeof_collection [ get_nets $flag_name -quiet ] ] == 1 } {
          set clock_nets $flag_name
        } else {
          puts "Error: can't find the net, please check it: $flag_name"
          return
        }
      }

      foreach clock_net $clock_nets {
        if { [ get_attribute [ get_nets $clock_net -quiet ] net_type -quiet ] != "clock" } {
          dputs "Error: the input net type is not clock net, please check it: $clock_net"
        } else {
          dputs "Info: the input net type is clock net: $clock_net"
        }
      }

    } else {
      check_nondef_route::script_help
      return
    }

  } else {
    check_nondef_route::script_help
    return
  }

  #### checking clock net routing rule ####
  set route_rules [ get_attribute [ get_routing_rules -quiet ] full_name ]
  if { [ llength $route_rules ] != 0 } {

    puts "Info: total [ llength $route_rules ] routing rules were found: \"$route_rules\"\n"
    foreach route_rule $route_rules {
      set rule($route_rule) 0
      dputs "Info: inital variable \$rule($route_rule)"
    }
  } else {
    puts "Error: can not get any routing rules, please check your design."
    return
  }

  if { [ llength $clock_nets ] == 1 } {
    set routing_rule [ get_attribute [ get_nets $clock_net ] routing_rule ]
    puts "Info: the net \"$clock_nets\" routing rule is: $routing_rule"

  } else {

    #set clock_net_routing_rule "check_nondef_route.[clock milliseconds].tcl"
    #redirect -file $clock_net_routing_rule {puts "## clock_net_name\t\t\tcloc_net_routing_rule_name"}
    foreach clock_net $clock_nets {
      set routing_rule [ get_attribute [ get_nets $clock_net ] routing_rule ]
      incr rule($routing_rule)
      #redirect -file $clock_net_routing_rule -append {puts "$clock_net\t\t$routing_rule"}
    }

    foreach route_rule $route_rules {
      if { $rule($route_rule) != 0 } {
        puts "Info: the net number of routing rule \"$route_rule\" is: $rule($route_rule)"
      } else {
        dputs "Info: the net number of routing rule \"$route_rule\" is: $rule($route_rule)"
      }
    }

  }
  puts "Alchip-info: Completed to signoff check clock net's routing rule in ICC2\n"
}

#### sub proceduce ####
namespace eval check_nondef_route {

  proc get_clock_nets { args } {

    set clock_nets [ list ]
    set clock_sources [ get_attribute [ get_clocks $args -quiet ] sources -quiet ]
    if { [sizeof_collection $clock_sources ] == 0 } {
      puts "Error: No clock source found in this design, please check it: $args"
      return
    }

    foreach_in_collection clock_source $clock_sources {
      set clock_nets_tmp [ get_attribute [ remove_from_collection [get_nets -of_objects [all_fanout -from $clock_source -flat]] [get_nets -of_objects [all_fanout -from $clock_source -flat -endpoints_only ] ] ] full_name ]
      set clock_nets [ concat $clock_nets $clock_nets_tmp ]
    }

    puts "Info: total [ llength $clock_nets ] clock nets were found, which not included the net of leaf pins."
    return $clock_nets 
  }

  proc script_help {} {
    puts "Warning: the input variable is not right."
    puts "Usage:   check_nondef_route < none | -net (net_name|file_name) | -clock clock_name >"
    puts "         <none>              checking NDR rule for all clock nets in the design, nothing need to be specified."
    puts "         <-net net_name>     checking NDR rule for a specified net, a clock net name need to be specified."
    puts "         <-net file_name>    checking NDR rule for a group nets, a file name which included these nets need to be specified."
    puts "         <-clock clock_name> checking NDR rule for the specified clock, a clock name need to be specified."
  }
  puts "Alchip-info: Completed to signoff check clock net's routing rule in ICC2\n"
}

proc dputs { input } {

  set is_debug "false" ; # "true" for debug script, "false" for using script.

  if { $is_debug } {
    puts $input
  }
}
