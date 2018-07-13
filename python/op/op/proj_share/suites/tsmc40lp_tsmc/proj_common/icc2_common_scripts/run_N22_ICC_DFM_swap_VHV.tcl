set top_layer [lindex [regexp -all -inline {[0-9]+} [get_attribute [get_layers -filter "name =~ M*"] name]] end]
set direction {"h" "v"}

set VIAx_hlayer [list ]
set VIAx_vlayer [list ]
set VIAy_hlayer [list ]
set VIAy_vlayer [list ]

for {set i 2} {$i <= ${top_layer}} {incr i} {
	set lower_pitch [get_attribute [get_layers -filter "name == M[expr ${i} - 1]"] pitch]
	set upper_pitch [get_attribute [get_layers -filter "name == M${i}"] pitch]
	if {${upper_pitch} == 0.2} {
		set cmd "lappend VIAy_[lindex ${direction} [expr ${i} % 2]]layer VIA[expr ${i} - 1]${i}"
		puts ${cmd}
		eval ${cmd}
	} elseif {${upper_pitch} == 0.1} {
		set cmd "lappend VIAx_[lindex ${direction} [expr ${i} % 2]]layer VIA[expr ${i} - 1]${i}"
		puts ${cmd}
		eval ${cmd}
	}
}

set DFMVia_from_list    ""
set DFMVia_to_list      ""
set DFMVia_to_x_size    ""
set DFMVia_to_y_size    ""
set DFMVia_weight       ""

foreach VIAx ${VIAx_hlayer} {
    if { $VIAx=="VIA12"||$VIAx=="VIA23" } { set FAT FAT_V } else { set FAT FAT_C }
    set DFMVia_from_list "$DFMVia_from_list \
	${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut \
	${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V \
	${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS \
	${VIAx}_LONG_H  ${VIAx}_LONG_H  ${VIAx}_LONG_H  ${VIAx}_LONG_H  ${VIAx}_LONG_H \
	${VIAx}_LONG_V  ${VIAx}_LONG_V  ${VIAx}_LONG_V  ${VIAx}_LONG_V  ${VIAx}_LONG_V \
	${VIAx}_LONG_HH ${VIAx}_LONG_HH ${VIAx}_LONG_HH ${VIAx}_LONG_HH ${VIAx}_LONG_HH \
    "

    set DFMVia_to_list "$DFMVia_to_list \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE ${VIAx}_FBS25 ${VIAx}_PBSB ${VIAx}_PBSU ${VIAx}_1cut_$FAT \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE ${VIAx}_FBS25 ${VIAx}_PBSB ${VIAx}_PBSU ${VIAx}_1cut_$FAT \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE ${VIAx}_FBS25 ${VIAx}_PBSB ${VIAx}_PBSU ${VIAx}_1cut_$FAT \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE \
    "

    set DFMVia_to_x_size "$DFMVia_to_x_size \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 \
	1 1 1 1 1 \
	1 1 1 1 1 \
    "

    set DFMVia_to_y_size "$DFMVia_to_y_size \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 \
	1 1 1 1 1 \
	1 1 1 1 1 \
    "

    set DFMVia_weight "$DFMVia_weight \
	9 8 7 6 5 4 3 2 1 \
	9 8 7 6 5 4 3 2 1 \
	9 8 7 6 5 4 3 2 1 \
	9 8 7 6 5 \
	9 8 7 6 5 \
	9 8 7 6 5 \
    "
}

foreach VIAx ${VIAx_vlayer} {
    if { $VIAx=="VIA12"||$VIAx=="VIA23" } { set FAT FAT_V } else { set FAT FAT_C }
    set DFMVia_from_list "$DFMVia_from_list \
	${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut    ${VIAx}_1cut \
	${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V  ${VIAx}_1cut_V \
	${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS ${VIAx}_1cut_AS \
	${VIAx}_LONG_H  ${VIAx}_LONG_H  ${VIAx}_LONG_H  ${VIAx}_LONG_H  ${VIAx}_LONG_H \
	${VIAx}_LONG_V  ${VIAx}_LONG_V  ${VIAx}_LONG_V  ${VIAx}_LONG_V  ${VIAx}_LONG_V \
	${VIAx}_LONG_HH ${VIAx}_LONG_HH ${VIAx}_LONG_HH ${VIAx}_LONG_HH ${VIAx}_LONG_HH \
    "

    set DFMVia_to_list "$DFMVia_to_list \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE ${VIAx}_FBS25 ${VIAx}_PBSB ${VIAx}_PBSU ${VIAx}_1cut_$FAT \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE ${VIAx}_FBS25 ${VIAx}_PBSB ${VIAx}_PBSU ${VIAx}_1cut_$FAT \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE ${VIAx}_FBS25 ${VIAx}_PBSB ${VIAx}_PBSU ${VIAx}_1cut_$FAT \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE \
	${VIAx}_FBD20 ${VIAx}_FBD30 ${VIAx}_PBDB ${VIAx}_PBDU ${VIAx}_PBDE \
    "

    set DFMVia_to_x_size "$DFMVia_to_x_size \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 \
	1 1 1 1 1 \
	1 1 1 1 1 \
    "

    set DFMVia_to_y_size "$DFMVia_to_y_size \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 1 1 1 1 \
	1 1 1 1 1 \
	1 1 1 1 1 \
	1 1 1 1 1 \
    "

    set DFMVia_weight "$DFMVia_weight \
	9 8 7 6 5 4 3 2 1 \
	9 8 7 6 5 4 3 2 1 \
	9 8 7 6 5 4 3 2 1 \
	9 8 7 6 5 \
	9 8 7 6 5 \
	9 8 7 6 5 \
    "
}

if { $VIAy_vlayer ne "" } {
 foreach VIAy ${VIAy_vlayer} {
    set DFMVia_from_list "$DFMVia_from_list \
       ${VIAy}_1cut ${VIAy}_1cut ${VIAy}_1cut ${VIAy}_1cut ${VIAy}_1cut \
    "

    set DFMVia_to_list "$DFMVia_to_list \
       ${VIAy}_FBS ${VIAy}_FBS ${VIAy}_1cut ${VIAy}_1cut ${VIAy}_1cut_FAT_C \
    "

    set DFMVia_to_x_size "$DFMVia_to_x_size \
       2 1 1 2 1 \
    "

    set DFMVia_to_y_size "$DFMVia_to_y_size \
       1 1 2 1 1 \
    "

    set DFMVia_weight "$DFMVia_weight \
       9 8 7 6 5 \
    "
 }
}

if { $VIAy_hlayer ne "" } {
 foreach VIAy ${VIAy_hlayer} {
    set DFMVia_from_list "$DFMVia_from_list \
       ${VIAy}_1cut ${VIAy}_1cut ${VIAy}_1cut ${VIAy}_1cut ${VIAy}_1cut \
    "

    set DFMVia_to_list "$DFMVia_to_list \
       ${VIAy}_FBS ${VIAy}_FBS ${VIAy}_1cut ${VIAy}_1cut ${VIAy}_1cut_FAT_C \
    "

    set DFMVia_to_x_size "$DFMVia_to_x_size \
       2 1 2 1 1 \
    "

    set DFMVia_to_y_size "$DFMVia_to_y_size \
       1 1 1 2 1 \
    "

    set DFMVia_weight "$DFMVia_weight \
       9 8 7 6 5 \
    "
 }
}


define_zrt_redundant_vias -from_via $DFMVia_from_list -to_via $DFMVia_to_list -to_via_x_size $DFMVia_to_x_size -to_via_y_size $DFMVia_to_y_size -to_via_weights $DFMVia_weight
insert_zrt_redundant_vias

#route_zrt_detail -incremental true -max_number_iterations 100
#verify_zrt_route
#report_design -physical

