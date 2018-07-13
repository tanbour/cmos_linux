###############################################################################################################
# PROGRAM     : check_filler_cells.icc2.tcl
# CREATOR     : Felix <felix_yuan@alchip.com>                                
# DATE        : 2018-02-08                                                   
# DESCRIPTION : check and statistic filler cell's area and number            
# USAGE       : check_filler_area_number ?<filler_cell_type> ?<output_rpt_filler>
# ITEM        : GE-04-20                                                     
###############################################################################################################

proc check_filler_area_number {{filler_cell_type "ref_name =~ FILL*"} {output_rpt_filler "check_filler_area_number.rpt"} } {
   puts "Alchip-info: Starting to signoff check filler cell's area and number in ICC2\n"
   global cell_ref_name;
   set fillers [get_cells -q -filter $filler_cell_type]
   set total_area 0
   set outputs ""
   if {[sizeof $fillers] == 0 } {puts "# Error: haven't filler cells ($filler_cell_type).";redirect -append $output_rpt_filler {puts "# Error:haven't filler cells ($filler_cell_type)."} } else {
      redirect -append $output_rpt_filler {puts "# Info: [sizeof $fillers] cells ($filler_cell_type)";attr_colloction $fillers ref_name cell_ref_name}
      foreach ref [array name cell_ref_name] {
         set area [get_attr [get_lib_cells */$ref] area]
         set num [sizeof $cell_ref_name($ref)]
         set ref_areas [expr $area * $num]
         set total_area [expr $ref_areas + $total_area]
         lappend outputs "# $ref :\t$ref_areas\t($area * $num)"
      }
   }
   redirect -append $output_rpt_filler {puts "# Total Areas: $total_area;\tTotal Number: [sizeof $fillers]\n\t[join $outputs "\n\t"]"}
   if {![regexp {^/} $output_rpt_filler]} {set output_rpt_filler [pwd]/$output_rpt_filler}
   puts "# Info: $output_rpt_filler"
   puts "Alchip-info: Completed to signoff check filler cell's area and number in ICC2\n"
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
     exec rm -rf $output_rpt_filler; exec touch $output_rpt_filler
     redirect $output_rpt_filler {get_block_info}
##Usgae:check_filler_area_number $filler_cell_type  $output_rpt_filler 
puts "Alchip-info: Completed to signoff check filler cell's area and number in ICC2\n"
