source ${blk_utils_dir}/icc2_utils/scr_report/SelectDrcError.proc.tcl
source ${blk_utils_dir}/icc2_utils/scr_report/onlyshowFP_JZ.proc.tcl
source ${blk_utils_dir}/icc2_utils/scr_report/icc2.tcl
if {![info exist short_png]} {set short_png "short_drc.png"}
if {![info exist short_txt]} {set short_txt "short_drc.rpt"}
if {[sizeof [get_drc_error_data zroute.err -q -all ]] == 0} {redirect $short_txt {puts "Warinig: cannot get_drc_error_data zroute.err"; return}}
gui_start
set data [open_drc_error_data -name zroute.err]
open_drc_error_data -name zroute.err
set drc_errors [get_drc_errors -quiet -error_data zroute.err]
set short_drcs [filter_collection $drc_errors "type_name==Short"]
redirect $short_txt {
  puts "INFO: [sizeof $drc_errors] DRC errors";CollectionAttrCondition $drc_errors type_name TN
  puts "------------------------- Shorts Condition -------------------------"
}
if {[sizeof $short_drcs]} {
  set short_nets [add_to_collection -u "" [get_attr $short_drcs objects]]
  redirect -append $short_txt {
  puts "INFO: [sizeof $short_drcs] shorts, contain [sizeof $short_nets] nets."
  CollectionAttrCondition $short_nets net_type NT
  puts "------------------------- Short layers Condition -------------------------"
  CollectionAttrCondition $short_drcs layers.name LN 0
  foreach n [lsort -dic [array name LN]] {puts "Layer: $n [sizeof $LN($n)]"; CollectionAttrCondition [get_attr $LN($n) objects] net_type NT 1 "\t";puts "";}
  if {[regexp "^/" $short_png]} {puts "---> png:\neog $short_png"} else {puts "---> png:\neog [pwd]/$short_png"}
  }
  SelectDrcError $short_drcs
  onlyshowFP_JZ
  change_selection
  gui_set_active_window -window [gui_get_current_window -types Layout -mru]
  gui_hide_toolbar -all
#  gui_zoom -window [gui_get_current_window -types Layout -mru] -fit -clct [current_design]
  gui_zoom -window [gui_get_current_window -types Layout -mru] -factor 1.07
  gui_write_window_image -file $short_png
} else {
  redirect -append $short_txt {puts "INFO: No shorts."}
}
if {[regexp "^/" $short_txt]} {puts "File: $short_txt"} else { puts "File: [pwd]/$short_txt"}
gui_stop 
