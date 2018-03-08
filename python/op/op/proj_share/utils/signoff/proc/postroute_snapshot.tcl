puts "Alchip-info: Running script [info script]\n"

global LVAR
global vars

start_gui

##pin density
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {pinDensityMap} -show {true}
gui_load_pin_density_mm
gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).pin_density.png

##cell density
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {cellDensityMap} -show {true}
gui_load_cell_density_mm
gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).cell_density.png

##congestion map
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
gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPin -value false
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

gui_show_map -window [gui_get_current_window -types Layout -mru] -map {globalCongestionMap} -show {true}
#route_global -congestion_map_only true
gui_write_window_image -window [gui_get_current_window ]  -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).congestion.png

gui_set_window_preset -window_type Layout -default


##check_route


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

gui_write_window_image -window [gui_get_current_window ]  -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).check_drc.png
gui_set_window_preset -window_type Layout -default


gui_error_browser -hide
stop_gui
puts "Alchip-info: Completed script [info script]\n"

