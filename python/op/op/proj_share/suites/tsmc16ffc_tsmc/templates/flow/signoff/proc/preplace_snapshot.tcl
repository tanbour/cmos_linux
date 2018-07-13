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

##stop gui###
stop_gui
puts "Alchip-info: Completed script [info script]\n"

