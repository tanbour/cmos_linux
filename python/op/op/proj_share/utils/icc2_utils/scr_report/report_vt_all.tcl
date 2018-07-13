#set pre_final_total_ins  1096189
#set pre_final_total_area 4474439.2872

set total_ins 0
set total_area 0
if {![info exists sc_ords]} {
  if {[sizeof [get_lib_cells -q "*/*ULT*"]]} {
    set sc_ords {RVT:*SVT* LVT:*LVT* ULVT:*ULT*}
  } elseif {[sizeof [get_lib_cells -q "*/*CPD"]]} {
    set sc_ords {RVT:*CPD LVT:*CPDLVT ULVT:*CPDULVT}
  }  else {
    set sc_ords {RVT:*SVT* LVT:*LVT*}
  }
}
set sc_ords_list ""
catch {unset SC_TYPE_AREAS; unset SC_TYPE_NUMS; unset SC_TYPE_RF}
set sc_ords_warning ""
foreach sc_ord $sc_ords {
	#$# --> set t_cells [get_cells -hierarchical * -filter "ref_name =~ *BWP*${sc_type} && is_physical_only == false"]
	set sc_cnd [split $sc_ord ":"]
  set sc_type_name [lindex $sc_cnd 0]
  set sc_type [lindex $sc_cnd 1]
  if {[sizeof [get_lib_cells -q "*/$sc_type"]] == 0} { lappend sc_ords_warning "# Alchip-warning: ($sc_type_name) can not get lib cells : */$sc_type" }
	if {$synopsys_program_name == "icc2_shell"} {
	  set t_cells [get_cells -quiet -hierarchical * -filter "ref_name =~ ${sc_type} && is_hard_macro == false && is_physical_only == false && is_hierarchical == false"]
  } else {
    set t_cells [get_cells -quiet -hierarchical * -filter "ref_name =~ ${sc_type}"]
  }
	set sc_num [sizeof_collection $t_cells]
	set total_a 0
	foreach_in_collection cel $t_cells {
		set cel_area [get_attribute $cel area]
		set total_a [expr $total_a + $cel_area]
	}
	set total_ins [expr $total_ins + $sc_num]
	set total_area [expr $total_area + $total_a]
  
	set SC_TYPE_AREAS(${sc_type_name}) $total_a
  set SC_TYPE_NUMS(${sc_type_name}) $sc_num
  set SC_TYPE_RF(${sc_type_name}) $sc_type
  lappend sc_ords_list $sc_type_name
}
puts "##################################################"
puts "## Date: [date]"
puts "## Design: [get_object_name [current_design]]"
puts "## Caculate VT Ratios"
puts "##################################################\n"
puts "# INFO: \$sc_ords = \"$sc_ords\""
if {[llength $sc_ords_warning]} {puts "\t[join $sc_ords_warning "\n\t"]\n"} else {puts ""}
if {$total_area} {
  puts "+[string repeat - 131]+"
  puts "[format "| %-20s| %-20s| %-20s| %-20s| %-20s| %-20s|" "VT TYPE" "ref_name"  "Nums" "Nums Ratios" "Areas" "Areas Ratios"]"
  set total_nums_ratios 0
  set total_areas_ratios 0
  foreach n $sc_ords_list {
    set num_ratio [format "%.2f" [expr $SC_TYPE_NUMS($n) * 100.0 / $total_ins]]
    set area_ratio [format "%.2f" [expr $SC_TYPE_AREAS($n) * 100.0 / $total_area]]
    set total_nums_ratios [expr $total_nums_ratios + $num_ratio] 
    set total_areas_ratios [expr $total_areas_ratios + $area_ratio]
    puts "[string repeat - 133]"
    puts "[format "| %-20s| %-20s| %-20s| %-20s| %-20s| %-20s|" $n $SC_TYPE_RF($n) $SC_TYPE_NUMS($n) "$num_ratio%" $SC_TYPE_AREAS($n) "$area_ratio%"]"
  }
  puts "+[string repeat - 131]+"
  puts "[format "| %-20s| %-20s| %-20s| %-20s| %-20s| %-20s|" "Total" " \$sc_ords "  "$total_ins" "$total_nums_ratios%" "$total_area" "$total_areas_ratios%"]"
  puts "+[string repeat - 131]+"
} else {
  puts "# Alchip-warinig: please double check your \$sc_ords, cannot catch any cells areas. (total_area: $total_area)"
}
