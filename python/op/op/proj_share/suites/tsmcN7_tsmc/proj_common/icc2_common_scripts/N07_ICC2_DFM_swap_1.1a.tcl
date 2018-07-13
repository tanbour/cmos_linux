set vias [lsort [get_attribute [get_via_defs -tech [get_techs] -filter "name !~ *_DFM_* && is_default == true"] name]]
set dfm_vias [lsort [get_attribute [get_via_defs -tech [get_techs] -filter "name =~ *_DFM_P*_VIA*"] name]]
foreach dfm_via $dfm_vias {
	set dfm_via_name_prefix [lindex [split $dfm_via _] 0]
	set dfm_via_weight [expr 12 - [regexp -all -inline {[0-9]+} [regexp -all -inline {DFM_P[0-9]+_} $dfm_via]]]
	foreach via $vias {
		set via_name_prefix [lindex [split $via _] 0]
		if { [string match $dfm_via_name_prefix $via_name_prefix] } {
			puts "add_via_mapping -from {$via 1x1} -to {$dfm_via 1x1} -weight $dfm_via_weight"
			set mapping_command "add_via_mapping -from {$via 1x1} -to {$dfm_via 1x1} -weight $dfm_via_weight"
			eval $mapping_command
		}
	}
}
puts "add_redundant_vias"
report_via_mapping > via_mapping.rpt
#add_redundant_vias
