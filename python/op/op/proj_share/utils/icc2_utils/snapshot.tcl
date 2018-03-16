puts "Alchip-info: Running script [info script]\n"

set cur_stage          "$cur_stage"
####################################
## snapshot
####################################

if  {$cur_stage == "01_fp" } {
start_gui
gui_hide_toolbar -all
gui_hide_palette -all

#floorplan overview
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPASiteArray -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPACore -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showVoltageArea -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showWiringGrid -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPGroup -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPKeepout -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouteCorridorShape -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContactRegion -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showTextObject -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRailAnalysisTap -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCoreArea -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPortShape -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCell -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showFillInst -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPASiteArray -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPACore -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showMovebound -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showVoltageArea -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoute -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouted -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContact -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showTopology -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showWiringGrid -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showBlockage -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPowerplanRegion -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPGroup -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPKeepout -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showGuide -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouteCorridorShape -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContactRegion -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showEditGroup -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showTextObject -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showText -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRailAnalysisTap -value false

gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCell -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinBlackBox -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinSoftMacro -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinOthers -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinCore -value false

gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.placement_overview.png -size {800 600}

#hierarchy overview
set_colors  -hierarchy_types all -cycle_color -depth 3
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting renderQuality -value 1
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting renderAntiAlias -value true
gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.hier_placement_overview.png -size {800 600}
remove_colors [get_flat_cells]
#show powerplan
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouted -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoutedClock -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoutedNoNet -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoutedNWell -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoutedPWell -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoutedReset -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoutedScan -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoutedSignal -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoutedTieHigh -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoutedTieLow -value false

gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.powerplan.png -size {800 600}

gui_set_window_preset -window_type Layout -default

stop_gui
}

if {$cur_stage == "02_place" | $cur_stage == "03_clock" | $cur_stage == "04_clock_opt"} {
start_gui
gui_hide_toolbar -all
gui_hide_palette -all

##pin density
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {pinDensityMap} -show {true}
gui_load_pin_density_mm
gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.pin_density.png -size {800 600}
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {pinDensityMap} -show {false}

##cell density
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {cellDensityMap} -show {true}
gui_load_cell_density_mm
gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.cell_density.png -size {800 600}
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {cellDensityMap} -show {false}

#floorplan overview
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPASiteArray -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPACore -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showVoltageArea -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showWiringGrid -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPGroup -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPKeepout -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouteCorridorShape -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContactRegion -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showTextObject -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRailAnalysisTap -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCoreArea -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPortShape -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCell -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showFillInst -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPASiteArray -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPACore -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showMovebound -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showVoltageArea -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoute -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouted -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContact -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showTopology -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showWiringGrid -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showBlockage -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPowerplanRegion -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPGroup -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPKeepout -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showGuide -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouteCorridorShape -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContactRegion -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showEditGroup -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showTextObject -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showText -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRailAnalysisTap -value false

gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCell -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinBlackBox -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinSoftMacro -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinOthers -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinCore -value false

gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.placement_overview.png -size {800 600}

#hierarchy overview
set_colors  -hierarchy_types all -cycle_color -depth 3
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting renderQuality -value 1
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting renderAntiAlias -value true
gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.hier_placement_overview.png -size {800 600}
remove_colors [get_flat_cells]
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting renderAntiAlias -value false

#congestion map
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {globalCongestionMap} -show {true}
#route_global -congestion_map_only true
gui_write_window_image -window [gui_get_current_window ]  -file $blk_rpt_dir/$cur_stage.congestion.png -size {800 600}

gui_set_window_preset -window_type Layout -default

##stop gui###
stop_gui

}

if {$cur_stage == "05_route" | $cur_stage == "06_route_opt" | $cur_stage == "07_route_eco" | $cur_stage == "08_finish"} {
start_gui
gui_hide_toolbar -all
gui_hide_palette -all

##pin density
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {pinDensityMap} -show {true}
gui_load_pin_density_mm
gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.pin_density.png -size {800 600}
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {pinDensityMap} -show {false}
##cell density
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {cellDensityMap} -show {true}
gui_load_cell_density_mm
gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.cell_density.png -size {800 600}
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {cellDensityMap} -show {false}
#floorplan overview
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPASiteArray -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPACore -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showVoltageArea -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showWiringGrid -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPGroup -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPKeepout -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouteCorridorShape -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContactRegion -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showTextObject -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRailAnalysisTap -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCoreArea -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPortShape -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCell -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showFillInst -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPASiteArray -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPACore -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showMovebound -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showVoltageArea -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoute -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouted -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContact -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showTopology -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showWiringGrid -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showBlockage -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPowerplanRegion -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPGroup -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPKeepout -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showGuide -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouteCorridorShape -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContactRegion -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showEditGroup -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showTextObject -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showText -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRailAnalysisTap -value false

gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCell -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinBlackBox -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinSoftMacro -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinOthers -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPinCore -value false

gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.placement_overview.png -size {800 600}

#hierarchy overview
set_colors  -hierarchy_types all -cycle_color -depth 3
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting renderQuality -value 1
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting renderAntiAlias -value true
gui_write_window_image -window [gui_get_current_window ] -file $blk_rpt_dir/$cur_stage.hier_placement_overview.png -size {800 600}
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting renderAntiAlias -value false
remove_colors [get_flat_cells]

#congestion map
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {globalCongestionMap} -show {true} 
#route_global -congestion_map_only true
gui_write_window_image -window [gui_get_current_window ]  -file $blk_rpt_dir/$cur_stage.congestion.png -size {800 600}
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {globalCongestionMap} -show {false}

gui_set_window_preset -window_type Layout -default

#check route
gui_set_error_browser_option -view_mode off
gui_open_error_data -name {zroute.err}

gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCoreArea -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPortShape -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCell -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellCore -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellHardMacro -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellSoftMacro -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellBlackBox -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellIO -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellFlipChip -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellNormalHier -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellPhysOnly -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellCover -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showMargin -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showFillInst -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPASiteArray -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPACore -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showMovebound -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showVoltageArea -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoute -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouted -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContact -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showWiringGrid -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showBlockage -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPowerplanRegion -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPGroup -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRPKeepout -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showGuide -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRouteCorridorShape -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showContactRegion -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showEditGroup -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showTextObject -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showText -value false
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCell -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCell -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellHardMacro -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellIO -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCellCore -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showCoreArea -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value true
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value true

gui_zoom -window [gui_get_current_window -view] -full

gui_write_window_image -window [gui_get_current_window ]  -file $blk_rpt_dir/$cur_stage.check_drc.png -size {800 600}
gui_set_window_preset -window_type Layout -default

gui_error_browser -hide
gui_set_error_browser_option -view_mode zoom

##stop gui###
stop_gui


}


