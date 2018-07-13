#!/usr/bin/tclsh
########################################################################################
# PROGRAM     : check_filler_cells.icc2.tcl
# CREATOR     : Zachary Shi <zacharys@alchip.com>
# DATE        : Fri Aug 11 12:23:04 2017
# DESCRIPTION : checking the clock cells if they were enclosed by decap cells.
# USAGE       : check_clock_decap < -file file_name >
#               check_clock_decap -help
# ITEM        : CK-01-15
########################################################################################

proc check_clock_decap { args } {
  puts "Alchip-info: Starting to signoff check clock cells enclosed by decap cells in ICC2\n"
  ####### decap info #######
  set decap_patterns "DCAP FILLCAP" ; # "DCAP" for TSMC, "FILLCAP" for Samsung.
  dputs "Info: this script could check two types decaping cells of TSMC and Samsung,"
  dputs " if you are using the other fab's library, please updated the decap pattern setting: set decap_patterns \"$decap_patterns\".\n"

  ####### step info #######
  set step "0.05" ; # In TSMC N7 technology, the minimum FILL cell width is 0.057um.
  dputs "Info: this script checking the decap cells which enclosed clock cell by step of ${step}um,"
  dputs "      the step value must less than the minimum FILL cell width,"
  dputs "      so if the minimum FILL cell width is less than ${step}um in your design, please modify this script setting: set step \"$step\".\n"

  ####### check the input file line by line #######
  set args_num [ llength $args ]
  if { $args_num != 2 } {
    check_clock_decap::script_help
    return

  } else {
    set flag      [ lindex $args 0 ]
    set flag_name [ lindex $args 1 ]

    if { $flag != "-file" } {
      check_clock_decap::script_help
      return

    } else {
      if { [ file exist $flag_name] == 0 } {
        puts "Error: can not found the input file: $flag_name"
        return

      } else {
        set input_file  [ open $flag_name r ]
        while { [ gets $input_file line ] >= 0 } {
          set cel_list [ list ]
          if { [ llength $line ] == 0 } {
            continue
          } else {
            set line [ lindex $line 0 ] ;# remove the empty space
          }
          set is_cel [ sizeof_collection [ get_cells $line -quiet ] ]
          set is_net [ sizeof_collection [ get_nets  $line -quiet ] ]
      
          if { $is_cel == 1 && $is_net == 1 } {
            puts "Warning: find a cell and net with the same name: $line, please carefully check if encounter an error later." 
      
            set cel_tmp [ get_cells -of_objects [ get_pins -of_objects $line -leaf -quiet ] -quiet ]
            if { $cel_tmp == "" } {
              puts "Error: can not find the cells connected to net: $line, please check it."
            } else {
              set cel_list [ concat "$line" [ get_attribute [ get_cells $cel_tmp ] full_name ] ]
            }
      
          } elseif { $is_cel } {
            set cel_list $line
      
          } elseif { $is_net } {
            set cel_tmp [ get_cells -of_objects [ get_pins -of_objects $line -leaf -quiet ] -quiet ]
            if { $cel_tmp == "" } {
              puts "Error: can not find the cell connected to net: $line, please check it."
            } else {
              set cel_list [ get_attribute [ get_cells $cel_tmp ] full_name ]
            }
      
          } else {
            puts "Error: can't find the cell or net, please check it: $line."
            continue
          }
      
          ####### check the cells of each line #######
          foreach cel_name $cel_list {
            dputs "Info: begin of checking the decap cell for clock cell: $cel_name"
            set is_enclose 1
            set cel_box [ get_attribute [ get_cells $cel_name ] boundary_bbox ]
            set cel_lx  [ lindex $cel_box 0 0 ]
            set cel_ly  [ lindex $cel_box 0 1 ]
            set cel_ux  [ lindex $cel_box 1 0 ]
            set cel_uy  [ lindex $cel_box 1 1 ]
      
            #### cell left side ####
            set left_side_cels_ptr [ get_cells -at [ list $cel_lx [ expr $cel_ly + $step ] ] -quiet ]
            if { [ sizeof_collection $left_side_cels_ptr ] == 1 } {
              set is_enclose 0
              dputs "Error: the cell left side is empty, no cell next to it, please check, clock cell: $cel_name."
            } else {
              set left_side_cels [ get_attribute [ get_cells $left_side_cels_ptr ] full_name ]
              set flag [ lsearch $left_side_cels $cel_name ]
              set left_side_cel  [ lreplace $left_side_cels $flag $flag ]
      
              set left_side_cel_ref_name [ get_attribute [ get_cells $left_side_cel ] ref_name ]
              ########
              set is_decap 0
              foreach decap_pattern $decap_patterns {
                if { [ regexp "$decap_pattern" $left_side_cel_ref_name ] } {
                  set is_decap 1
                }
              }
              if { $is_decap == 0 } {
                set is_enclose 0
                dputs "Error: the cell left side cell is not decap cell, please check it, clock cell: $cel_name, left side cell ref_name: $left_side_cel_ref_name."
              }
            }
      
            #### cell right side ####
            set right_side_cels_ptr [ get_cells -at [ list $cel_ux [ expr $cel_uy - $step ] ] -quiet ]
            if { [ sizeof_collection $right_side_cels_ptr ] == 1 } {
              set is_enclose 0
              dputs "Error: the cell right side is empty, no cell next to it, please check, clock cell: $cel_name."
            } else {
              set right_side_cels [ get_attribute [ get_cells $right_side_cels_ptr ] full_name ]
              set flag [ lsearch $right_side_cels $cel_name ]
              set right_side_cel  [ lreplace $right_side_cels $flag $flag ]
      
              set right_side_cel_ref_name [ get_attribute [ get_cells $right_side_cel ] ref_name ]
              ########
              set is_decap 0
              foreach decap_pattern $decap_patterns {
                if { [ regexp "$decap_pattern" $right_side_cel_ref_name ] } {
                  set is_decap 1
                }
              }
              if { $is_decap == 0 } {
                set is_enclose 0
                dputs "Error: the cell right side cell is not decap cell, please check it, clock cell: $cel_name, right side cell ref_name: $right_side_cel_ref_name."
              }
            }
      
            #### cell top side ####
            set top_side_cels [ list ]
            set top_uy [ expr $cel_uy + $step ] ; # potential issue, the $step is larger than cell height.
      
            # top left side
            set top_left_side_cels_ptr [ get_cells -at [ list $cel_lx $top_uy ] -quiet ]
            if { [ sizeof_collection $top_left_side_cels_ptr ] == 0 } {
              set is_enclose 0
              dputs "Error: the cell top left corner can not find decap cell, please check it: $cel_name."
      
            } else {
              set top_left_side_cels [ get_attribute [ get_cells $top_left_side_cels_ptr ] full_name ]
              set top_side_cels [ concat $top_side_cels $top_left_side_cels ]
      
              if { [ sizeof_collection $top_left_side_cels_ptr ] == 1 } {
                set top_left_side_cel_box [ get_attribute [ get_cells $top_left_side_cels_ptr ] boundary_bbox ]
                if { $cel_lx == [ lindex $top_left_side_cel_box 0 0 ] } {
                  set is_enclose 0
                  dputs "Error: the cell top left side can not find decap cell, please check it: $cel_name."
                }
              }
            }
      
            # top right side
            set top_right_side_cels_ptr [ get_cells -at [ list $cel_ux $top_uy ] -quiet ]
            if { [ sizeof_collection $top_right_side_cels_ptr ] == 0 } {
              set is_enclose 0
              dputs "Error: the cell top righ corner can not find decap cell, please check it: $cel_name."
      
            } else {
              set top_right_side_cels [ get_attribute [ get_cells $top_right_side_cels_ptr ] full_name ]
              set top_side_cels [ concat $top_side_cels $top_right_side_cels ]
      
              if { [ sizeof_collection $top_right_side_cels_ptr ] == 1 } {
                set top_right_side_cel_box [ get_attribute [ get_cells $top_right_side_cels_ptr ] boundary_bbox ]
                if { $cel_ux == [ lindex $top_right_side_cel_box 1 0 ] } {
                  set is_enclose 0
                  dputs "Error: the cell top right side can not find decap cell, please check it: $cel_name."
                }
              }
            }
       
            # top middle side
            set top_check_point_x [ expr $cel_lx + $step ]
            while { $top_check_point_x < $cel_ux } {
              set top_mid_side_cels_ptr [ get_cells -at [ list $top_check_point_x $top_uy ] -quiet ]
              if { [ sizeof_collection $top_mid_side_cels_ptr ] == 0 } {
                set is_enclose 0
                dputs "Error: the cell top side have a empty area at \"$top_check_point_x $top_uy\", please check, clock cell: $cel_name."
              } else {
                set top_mid_side_cels [ get_attribute [ get_cells $top_mid_side_cels_ptr ] full_name ]
                set top_side_cels [ concat $top_side_cels $top_mid_side_cels ]
              }
              set top_check_point_x [ expr $top_check_point_x + $step ]
            }
      
            # checking decap cell on top side
            if { [ llength $top_side_cels ] == 0 } {
              set is_enclose 0
              dputs "Error: the top side can not find any cells, please check it: $cel_name."
            } else {
              set top_side_cels [ lsort -unique $top_side_cels ]
              foreach top_side_cel $top_side_cels {
                set top_side_cel_ref_name [ get_attribute [ get_cells $top_side_cel ] ref_name ]
                ########
                set is_decap 0
                foreach decap_pattern $decap_patterns {
                  if { [ regexp "$decap_pattern" $top_side_cel_ref_name ] } {
                    set is_decap 1
                  }
                }
                if { $is_decap == 0 } {
                  set is_enclose 0
                  dputs "Error: found a cell on the top side is not decap cell, please check it, clock cell: $cel_name, top side cell ref_name: $top_side_cel_ref_name."
                }
              }
            }
      
            #### cell bottom side ####
            set bottom_side_cels [ list ]
            set bottom_ly [ expr $cel_ly - $step ] ; # potential issue, the $step is larger than cell height.
      
            # bottom left side
            set bottom_left_side_cels_ptr [ get_cells -at [ list $cel_lx $bottom_ly ] -quiet ]
            if { [ sizeof_collection $bottom_left_side_cels_ptr ] == 0 } {
              set is_enclose 0
              dputs "Error: the cell bottom left corner can not find decap cell, please check it: $cel_name."
      
            } else {
              set bottom_left_side_cels [ get_attribute [ get_cells $bottom_left_side_cels_ptr ] full_name ]
              set bottom_side_cels [ concat $bottom_side_cels $bottom_left_side_cels ]
      
              if { [ sizeof_collection $bottom_left_side_cels_ptr ] == 1 } {
                set bottom_left_side_cel_box [ get_attribute [ get_cells $bottom_left_side_cels_ptr ] boundary_bbox ]
                if { $cel_lx == [ lindex $bottom_left_side_cel_box 0 0 ] } {
                  set is_enclose 0
                  dputs "Error: the cell bottom left side can not find decap cell, please check it: $cel_name."
                }
              }
            }
      
            # bottom right side
            set bottom_right_side_cels_ptr [ get_cells -at [ list $cel_ux $bottom_ly ] -quiet ]
            if { [ sizeof_collection $bottom_right_side_cels_ptr ] == 0 } {
              set is_enclose 0
              dputs "Error: the cell bottom right corner can not find decap cell, please check it: $cel_name."
      
            } else {
              set bottom_right_side_cels [ get_attribute [ get_cells $bottom_right_side_cels_ptr ] full_name ]
              set bottom_side_cels [ concat $bottom_side_cels $bottom_right_side_cels ]
      
              if { [ sizeof_collection $bottom_right_side_cels_ptr ] == 1 } {
                set bottom_right_side_cel_box [ get_attribute [ get_cells $bottom_right_side_cels_ptr ] boundary_bbox ]
                if { $cel_ux == [ lindex $bottom_right_side_cel_box 1 0 ] } {
                  set is_enclose 0
                  dputs "Error: the cell bottom right side can not find decap cell, please check it: $cel_name."
                }
              }
            }
      
            # bottom middle side
            set bottom_check_point_x [ expr $cel_lx + $step ]
            while { $bottom_check_point_x < $cel_ux } {
              set bottom_mid_side_cels_ptr [ get_cells -at [ list $bottom_check_point_x $bottom_ly ] -quiet ]
              if { [ sizeof_collection $bottom_mid_side_cels_ptr ]  == 0 } {
                set is_enclose 0
                dputs "Error: the cell bottom side have a empty area at \"$bottom_check_point_x $bottom_ly\", please check, clock cell: $cel_name."
              } else {
                set bottom_mid_side_cels [ get_attribute [ get_cells $bottom_mid_side_cels_ptr ] full_name ]
                set bottom_side_cels [ concat $bottom_side_cels $bottom_mid_side_cels ]
              }
              set bottom_check_point_x [ expr $bottom_check_point_x + $step ]
            }
      
            # checking decap cell on bottom side
            if { [ llength $bottom_side_cels ] == 0 } {
              set is_enclose 0
              dputs "Error: the bottom side can not find any cells, please check it: $cel_name."
            } else {
              set bottom_side_cels [ lsort -unique $bottom_side_cels ]
              foreach bottom_side_cel $bottom_side_cels {
                set bottom_side_cel_ref_name [ get_attribute [ get_cells $bottom_side_cel ] ref_name ]
                ########
                set is_decap 0
                foreach decap_pattern $decap_patterns {
                  if { [ regexp "$decap_pattern" $bottom_side_cel_ref_name ] } {
                    set is_decap 1
                  }
                }
                if { $is_decap == 0 } {
                  set is_enclose 0
                  dputs "Error: found a cell on the bottom side is not decap cell, please check it, clock cell: $cel_name, bottom side cell ref_name: $bottom_side_cel_ref_name."
                }
              }
            }
            if { $is_enclose == 0 } {
              puts "Error: the cell \"$cel_name\" is not enclosed by decap cells."
            } else {
              puts "Info: end of checking for clock cell: $cel_name, this cell is enclosed by decap cell."
            }
          }
      
        }
        close $input_file
      }
    }
  }
}

#### sub proceduce ####
namespace eval check_clock_decap {

  proc script_help {} {
    puts "Warning: the input variable is not right."
    puts "Usage:   check_clock_decap < -file file_name >"
    puts "         <-file file_name>    checking if the decap cells were enclosed by the clock cells, a file inlcude the cells or nets need to be specified."
  }
  puts "Alchip-info: Completed to signoff check clock cells enclosed by decap cells in ICC2\n"

}

proc dputs { input } {

  set is_debug "false" ; # "true" is used for debug script, "false" is used for regular using script.

  if { $is_debug } {
    puts $input
  }
}

