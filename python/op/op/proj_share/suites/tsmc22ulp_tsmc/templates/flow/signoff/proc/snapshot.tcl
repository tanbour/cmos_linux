puts "Alchip-info: Running script [info script]\n"
global LVAR
global vars

#define stage 
set INIT_DESIGN_BLOCK_NAME      icc2_init
set FP_BLOCK_NAME               icc2_fp
set PLACE_OPT_BLOCK_NAME        icc2_place
set CLOCK_OPT_CTS_BLOCK_NAME    icc2_clock
set CLOCK_OPT_OPTO_BLOCK_NAME   icc2_clock_opt
set ROUTE_AUTO_BLOCK_NAME       icc2_route
set ROUTE_OPT_BLOCK_NAME        icc2_route_opt
set SIGNOFF_BLOCK_NAME          icc2_finish


if  {[regexp $REPORT_PREFIX "$FP_BLOCK_NAME"]} {
start_gui

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

gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).placement_overview.png

#hierarchy overview
set_colors  -hierarchy_types all -cycle_color -depth 1
gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).hier_placement_overview.png
remove_colors [get_flat_cells]
gui_set_window_preset -window_type Layout -default

stop_gui
}

if {[regexp $REPORT_PREFIX "$PLACE_OPT_BLOCK_NAME|$CLOCK_OPT_CTS_BLOCK_NAME|$CLOCK_OPT_OPTO_BLOCK_NAME"]} {
start_gui

##pin density
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {pinDensityMap} -show {true}
gui_load_pin_density_mm
gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).pin_density.png
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {pinDensityMap} -show {false}

##cell density
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {cellDensityMap} -show {true}
gui_load_cell_density_mm
gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).cell_density.png
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

gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).placement_overview.png

#hierarchy overview
set_colors  -hierarchy_types all -cycle_color -depth 1
gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).hier_placement_overview.png
remove_colors [get_flat_cells]

#congestion map
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {globalCongestionMap} -show {true}
#route_global -congestion_map_only true
gui_write_window_image -window [gui_get_current_window ]  -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).congestion.png

gui_set_window_preset -window_type Layout -default

##stop gui###
stop_gui

}

if {[regexp $REPORT_PREFIX "$ROUTE_AUTO_BLOCK_NAME|$ROUTE_OPT_BLOCK_NAME|$SIGNOFF_BLOCK_NAME"]} {
start_gui

##pin density
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {pinDensityMap} -show {true}
gui_load_pin_density_mm
gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).pin_density.png
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {pinDensityMap} -show {false}
##cell density
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {cellDensityMap} -show {true}
gui_load_cell_density_mm
gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).cell_density.png
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

gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).placement_overview.png

#hierarchy overview
set_colors  -hierarchy_types all -cycle_color -depth 1
gui_write_window_image -window [gui_get_current_window ] -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).hier_placement_overview.png
remove_colors [get_flat_cells]

#congestion map
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {globalCongestionMap} -show {true}
#route_global -congestion_map_only true
gui_write_window_image -window [gui_get_current_window ]  -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).congestion.png
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

gui_write_window_image -window [gui_get_current_window ]  -file $RPT_DIR/$BLOCK_NAME.$vars(dst).$LVAR(CURR_VIEW).check_drc.png
gui_set_window_preset -window_type Layout -default

gui_error_browser -hide
gui_set_error_browser_option -view_mode zoom

##stop gui###
stop_gui


}


