###############################################################################################################
# PROGRAM     : check_filler_cells.icc2.tcl
# CREATOR     : Felix <felix_yuan@alchip.com>                                
# DATE        : 2018-02-08                                                   
# DESCRIPTION : check and statistic dcap cell's area and number            
# USAGE       : check_dcap_area_number ?<dcap_cell_type> ?<output_rpt_dcap> 
# ITEM        : GE-04-02                                                   
###############################################################################################################

proc check_dcap_area_number {{dcap_cell_type "ref_name =~ DCAP*"} {output_rpt_dcap "check_dcap_area_number.rpt"}} {
   puts "Alchip-info: Starting to signoff check dcap cell's area and number in ICC2\n"
   global cell_ref_name;
   set dcaps [get_cells -q -filter $dcap_cell_type]
   set total_area 0
   set outputs ""
   if {[sizeof $dcaps] == 0 } {puts "# Error: haven't dcap cells ($dcap_cell_type).";redirect -append $output_rpt_dcap {puts "# Error:haven't dcap cells ($dcap_cell_type)."} } else {
      redirect -append $output_rpt_dcap {puts "# Info: [sizeof $dcaps] cells ($dcap_cell_type)";attr_colloction $dcaps ref_name cell_ref_name}
      foreach ref [array name cell_ref_name] {
         set area [get_attr [get_lib_cells */$ref] area]
         set num [sizeof $cell_ref_name($ref)]
         set ref_areas [expr $area * $num]
         set total_area [expr $ref_areas + $total_area]
         lappend outputs "# $ref :\t$ref_areas\t($area * $num)"
      }
   }
   redirect -append $output_rpt_dcap {puts "# Total Areas: $total_area;\tTotal Number: [sizeof $dcaps]\n\t[join $outputs "\n\t"]"}
   if {![regexp {^/} $output_rpt_dcap]} {set output_rpt_dcap [pwd]/$output_rpt_dcap}
   puts "# Info: $output_rpt_dcap"
   puts "Alchip-info: Completed to signoff check dcap cell's area and number in ICC2\n"
}

proc attr_colloction {collection attr group {control_tag 1} {add_tab ""}} {
   global $group
   set outputs ""
   set count 0
   if {[info exist $group]} {unset $group}
   set refs [lsort -u -dic -incr  [get_attr $collection $attr]]
   if {![llength $refs]} {puts "# Error: There is no attr $attr defined in current collection";return}
   lappend outputs "# [sizeof $collection] have [llength $refs]  $attr as follow:"
   if {[llength $refs] == 1} {
      set ref $refs
      set ref [regsub -all " " $ref "\*"];
      set cof $collection;
      set ${group}($ref) $cof
      lappend outputs "#\t\$${group}($ref) : [sizeof $cof]"
      set count [expr $count + [sizeof $cof]]
   } else {
      foreach ref $refs {
         set ref [regsub -all " " $ref "\*"]
         if {[regexp {\*} $ref]} {set cof [filter_collection $collection "$attr =~ $ref"]} else {set cof [filter_collection $collection "$attr == $ref"]}
         set cof_refs [lsort -u [get_attr $cof $attr]]
         if {[llength $cof_refs] > 1} {
            if {[info exists remove_refs]} {unset remove_refs}
            foreach cof_ref $cof_refs {
               set cof_ref [regsub -all " " $cof_ref "\*"]
               if {$cof_ref != $ref} {
                  if {[info exists remove_refs]} {set remove_refs "$remove_refs && $attr !~ $cof_ref"} else { set remove_refs  "$attr !~ $cof_ref"}
               }
            }
            set cof [filter_collection $cof $remove_refs]
         } 
         set ${group}($ref) $cof
         lappend outputs "#\t\$${group}($ref) : [sizeof $cof]"
         set count [expr $count + [sizeof $cof]]
      }
   }
   if {$control_tag} {
      if {$add_tab != ""} {puts "$add_tab[join $outputs "\n$add_tab"]"; puts "${add_tab}# Total Number: $count"} else {
         puts [join $outputs "\n"]
         puts "# Total Number: $count"
      }
   }
}

proc get_block_info {} {
     set lib_source [get_attr [current_lib] source_file_name]
     set lib_info [exec ls -l -d $lib_source]
     set lib_location [lindex $lib_info end]
     set block_name [lindex [split [get_object_name [current_block ]] ":"] end]
     set hostname [exec hostname]
     puts "# Lib: $lib_location  (%Hostname: $hostname)\n# Block: $block_name\n"
}
     set output_rpt_dcap "check_dcap_area_number.rpt"
     exec rm -rf $output_rpt_dcap; exec touch $output_rpt_dcap
     redirect $output_rpt_dcap {get_block_info}
##Usgae:check_dcap_area_number $dcap_cell_type $output_rpt_dcap 
puts "Alchip-info: Completed to signoff check dcap cell's area and number in ICC2\n"
