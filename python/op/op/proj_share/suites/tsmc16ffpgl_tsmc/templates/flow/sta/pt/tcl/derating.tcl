set timing_aocvm_enable_analysis true
set timing_aocvm_analysis_mode combined_launch_capture_depth

exec rm -f {{cur.cur_flow_rpt_dir}}/${SESSION}/set_timing_derate.log
exec touch {{cur.cur_flow_rpt_dir}}/${SESSION}/set_timing_derate.log

#--> 1a. AOCV on launch + data /capture clock
set cmd "set aocv_files \$AOCV_[string toupper $VOLT]_[string toupper $LIB_CORNER]_[string toupper $CHECK_TYPE]"
puts $cmd
eval $cmd
exec rm -f {{cur.cur_flow_rpt_dir}}/${SESSION}/read_aocvm.log; exec touch {{cur.cur_flow_rpt_dir}}/${SESSION}/read_aocvm.log
foreach aocv_file_t $aocv_files {
  set aocv_file [glob -nocomplain $aocv_file_t] 
  if {[llength $aocv_file]} {
    redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/read_aocvm.log {  echo "# Read aocvm $aocv_file" }
    redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/read_aocvm.log {  read_aocvm $aocv_file }
  } else {
    redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/read_aocvm.log {puts "# Alchip-error: aocv file not exist: $aocv_file_t"}
  }
}
redirect {{cur.cur_flow_rpt_dir}}/${SESSION}/report_aocvm.rpt {report_aocvm }
report_aocvm -list_not_annotated -nosplit > {{cur.cur_flow_rpt_dir}}/${SESSION}/report_aocvm.not_annotated.rpt

#--> 1c. wire OCV +/-7% on clock and data path
set cmds_info ""
lappend cmds_info "set_timing_derate -early 0.93 -net_delay"
lappend cmds_info "set_timing_derate -late 1.07 -net_delay"
set cmds [join $cmds_info "\n"]
redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/set_timing_derate.log {puts "# wire OCV +/-7% on clock and data path" }
redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/set_timing_derate.log {puts $cmds }
puts $cmds; eval $cmds

#--> 1d. As Virage cells variation models do not account for voltage variation, additional incremental derates are needed to account for IR drop
#       SSGNP: +/-2.5% on clock path
#       FFGNP: +/-5% on the clock path
#set Virage_cells [get_lib_cells -q */HSB*]
#set Virage_cells [get_cells -q -hi -fi "ref_name =~ HSB* || ref_name =~ *BWP*"]
set Virage_cells [get_cells -q -hi -fi "ref_name =~ H* || ref_name =~ *BWP*"]
set Virage_cells_num [sizeof $Virage_cells]
if {$Virage_cells_num} {
  switch $LIB_CORNER {
    "wc"  {set delta_incr_derate4IRdrop 0.025}
    "wcl" {set delta_incr_derate4IRdrop 0.025}
    "wcz" {set delta_incr_derate4IRdrop 0.025}
    "lt"  {set delta_incr_derate4IRdrop 0.05}
    "ml"  {set delta_incr_derate4IRdrop 0.05}
    "bc"  {set delta_incr_derate4IRdrop 0.05}
    default {set delta_incr_derate4IRdrop 0}
  }
  set cmds_info ""
  lappend cmds_info "set_timing_derate -increment -cell_delay -clock -late  [expr 0 + $delta_incr_derate4IRdrop] \$Virage_cells"
  lappend cmds_info "set_timing_derate -increment -cell_delay -clock -early [expr 0 - $delta_incr_derate4IRdrop] \$Virage_cells"
  set cmds [join $cmds_info "\n"]  
redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/set_timing_derate.log {  puts "# $Virage_cells_num cells set incremental derates account for IR drop, delta_incr_derate4IRdrop : $delta_incr_derate4IRdrop" }
redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/set_timing_derate.log {  puts $cmds }
  puts $cmds; eval $cmds
}
#--> 1e. For IP which do not have POCV/AOCV model, apply linear derate factors:
#       cell delay (Tcq) SSGNP C -5%
#       cell delay (Tcq) FFGNP C -8%
#       cell check (Tsetup/Thold): 5% for SSGNPA and FFGNP

#set need_add_derate_ips [get_cells -q -hi -fi "is_hierarchical == false && ref_name !~ HSB*"]
set need_add_derate_ips [remove_from_collection [get_cells -q -fi "is_memory_cell == false && is_hierarchical == false && ref_name !~ H* && ref_name !~ *BWP*"] $Virage_cells]
set need_add_derate_ips_num [sizeof $need_add_derate_ips]
if {$need_add_derate_ips_num} {
  set cmds_info ""
  switch $LIB_CORNER {
    "wc"  {set Tcq_derate_delta 0.05}
    "wcl" {set Tcq_derate_delta 0.05}
    "wcz" {set Tcq_derate_delta 0.05}
    "lt"  {set Tcq_derate_delta 0.08}
    "ml"  {set Tcq_derate_delta 0.08}
    "bc"  {set Tcq_derate_delta 0.08}
    default {set Tcq_derate_delta 0}
  }
  lappend cmds_info "set_timing_derate -cell_delay  -late  [expr 1 + $Tcq_derate_delta] \$need_add_derate_ips"
  lappend cmds_info "set_timing_derate -cell_delay  -early [expr 1 - $Tcq_derate_delta] \$need_add_derate_ips"
  lappend cmds_info "set_timing_derate -cell_check -late 1.05 \$need_add_derate_ips"
  lappend cmds_info "set_timing_derate -cell_check -early 0.95 \$need_add_derate_ips"
  set cmds [join $cmds_info "\n"]
redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/set_timing_derate.log {  puts "# $need_add_derate_ips_num need_add_derate_ips apply linear derate factors" }
redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/set_timing_derate.log {  puts $cmds }
  puts $cmds; eval $cmds
}

report_timing_derate > {{cur.cur_flow_rpt_dir}}/${SESSION}/timing_derate.rpt
report_timing_derate -increment > {{cur.cur_flow_rpt_dir}}/${SESSION}/timing_derate_incr.rpt



## Add Multi-buf derate 0.07
set Multi_buf_lib_cells  [get_lib_cells -q  {*/M*INV* */M*BUF*}]
set Multi_buf_lib_cells_num [sizeof $Multi_buf_lib_cells]
if {$Multi_buf_lib_cells_num} {
  set cmds_info ""
  lappend cmds_info "set_timing_derate -cell_delay  -late 1.07 \$Multi_buf_lib_cells"
  lappend cmds_info "set_timing_derate -cell_delay  -early 0.93 \$Multi_buf_lib_cells" 
  set cmds [join $cmds_info "\n"]
  redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/set_timing_derate.log {  puts "# $Multi_buf_lib_cells_num Multi_buf_lib_cells  apply linear derate factors" }
  redirect -append {{cur.cur_flow_rpt_dir}}/${SESSION}/set_timing_derate.log {  puts $cmds }
  puts $cmds; eval $cmds
}
