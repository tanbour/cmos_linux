source ${blk_utils_dir}/icc2_utils/scr_report/icc2.tcl
set stds [get_cells -hi -fi "is_hierarchical == false && is_hard_macro == false && is_physical_only == false"]
CollectionAttrCondition $stds ref_name RF 0
if {[info exists DriverCells]} {unset DriverCells}
set no_check_cells [get_cells -q ""]
foreach n [array name RF] {
  set c $RF($n);
  if {[regexp {.*_(\S+)} $n "" d]} {
    append_to_collection DriverCells($d) $c
  } else {
    append_to_collection no_check_cells $c
  }
}
puts "[sizeof $no_check_cells] cells no checks, total have [sizeof $stds] stds" 
set t_cells 0
foreach n [lsort -dic [array name DriverCells]] {
    puts "Driver [format "%-5s" $n] :\t[sizeof $DriverCells($n)]"
    set t_cells [expr $t_cells + [sizeof $DriverCells($n)]]
}
puts "## Total check $t_cells cells."
  

