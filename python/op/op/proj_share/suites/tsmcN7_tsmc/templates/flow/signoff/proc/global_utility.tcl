##------------------------------------------------
## Procedure to print messages
## there are three types messages which is ERROR, WARNING and INFO separately
##------------------------------------------------
proc tproc_msg { args } {

  parse_proc_arguments -args $args options

  if {[info exists options(-err)]} {
    echo "ERROR: $options(-msg)" 
  } elseif {[info exists options(-warn)]} {
    echo "WARNING: $options(-msg)" 
  } else {
    echo "INFO: $options(-msg)" 
  }
}

define_proc_attributes tproc_msg \
  -info "Print messages." \
  -define_args {
    {-info  "Print INFO type message" "" boolean optional} \
    {-err   "Print ERROR type message" "" boolean optional} \
    {-warn  "Print WARNING type message" "" boolean optional} \
    {-msg   "Messages to print" AString string required} \
  }


##------------------------------------------------
## Procedure to create techfile based ndm library
##------------------------------------------------
proc tproc_create_tf_nlib {} {

  global LVAR
  set bk_version bak_on_[exec date +%m%d%H%M]
  set techfile $LVAR(TECH_FILE)
  set nlib_reference_library $LVAR(REFERENCE_NDM_LIBRARY)
  set nlib_design_library $LVAR(CURR_DESIGN_LIBRARY)

  if { [file exists $nlib_design_library] } {
    tproc_msg -warn -msg  "The specified ICC2 ndm database is already existing. It will be renamed first."
    file rename -force $nlib_design_library ${nlib_design_library}_${bk_version}
  }

  create_lib \
    -tech $techfile \
    -ref_libs $nlib_reference_library \
    $nlib_design_library

 # open_lib $nlib_design_library

}

##------------------------------------------------
## Procedure to create techlib based ndm library
##------------------------------------------------
proc tproc_create_tl_nlib {} {

  global LVAR
  set bk_version bak_on_[exec date +%m%d%H%M]
  set techlib $LVAR(TECH_NDM)
  set nlib_reference_library $LVAR(REFERENCE_NDM_LIBRARY)
  set nlib_design_library $LVAR(CURR_DESIGN_LIBRARY)

  if { [file exists $nlib_design_library] } {
    tproc_msg -warn -msg  "The specified ICC2 ndm database is already existing. It will be renamed first."
    file rename -force $nlib_design_library ${nlib_design_library}_${bk_version}
  }

  create_lib \
    -use_technology_lib $techlib \
    -ref_libs $nlib_reference_library \
    $nlib_design_library

  open_lib $nlib_design_library

}


##------------------------------------------------
## Procedure to write floorplan def
##------------------------------------------------
proc tproc_write_fp {} {

  global LVAR
  set bk_version bak_on_[exec date +%m%d%H%M]
  set curr_def  $LVAR(CURR_DEF)

  if { [file exists $curr_def] } {
    tproc_msg -warn -msg  "The specified fp def file is already existing. It will be renamed first."
    file rename -force $curr_def ${curr_def}_${bk_version}
  }

write_def   $curr_def

}

## -----------------------------------------------------------------------------------------------
## proc_report_utilization
## -----------------------------------------------------------------------------------------------
proc proc_report_utilization { } {

  remove_utilization_configurations -all

  report_utilization
  create_utilization_configuration -exclude {soft_blockages hard_macros soft_macros io_cells} config2
  report_utilization -config config2

}


## -----------------------------------------------------------------------------------------------
## proc_write_fp_data
## -----------------------------------------------------------------------------------------------
proc write_fp_def { }  {
  global LVAR
  set bk_version bak_on_[exec date +%m%d%H%M]
  if { [file exists $LVAR(BLOCK_NAME).$LVAR(op4_fp_session_name).def.gz] } {
    tproc_msg -warn -msg  "The specified floorplan def is already existing. It will be renamed first."
    file rename -force $LVAR(BLOCK_NAME).$LVAR(op4_fp_session_name).def.gz $LVAR(BLOCK_NAME).$LVAR(op4_fp_session_name).def.gz.${bk_version}
  }
  set_placement_status locked [get_cells -hier -filter "is_hard_macro == true"]
  write_def -compress gzip -include {blockages bounds cells ports rows_tracks specialnets vias} -objects [get_cells -hier -filter "is_hard_macro || is_physical_only"] $LVAR(BLOCK_NAME).$LVAR(op4_fp_session_name).def
}
## -----------------------------------------------------------------------------------------------
## proc_report_threshold_voltage_groups
## -----------------------------------------------------------------------------------------------
#proc proc_report_threshold_voltage_groups { } {
#  define_user_attribute -type string -class lib_cell threshold_voltage_group
#  set_attribute -quiet [get_lib_cells -quiet *cpd/*] threshold_voltage_group SVT
#  set_attribute -quiet [get_lib_cells -quiet *p16*cpdlvt/*] threshold_voltage_group LVT_C16
#  set_attribute -quiet [get_lib_cells -quiet *p18*cpdlvt/*] threshold_voltage_group LVT_C18
#  set_attribute -quiet [get_lib_cells -quiet *p20*cpdlvt/*] threshold_voltage_group LVT_C20
#  set_attribute -quiet [get_lib_cells -quiet *p16*cpdulvt/*] threshold_voltage_group ULVT_C16
#  set_attribute -quiet [get_lib_cells -quiet *p18*cpdulvt/*] threshold_voltage_group ULVT_C18
#  set_attribute -quiet [get_lib_cells -quiet *p20*cpdulvt/*] threshold_voltage_group ULVT_C20
#
#
#  report_threshold_voltage_groups
#}
## -----------------------------------------------------------------------------------------------
## alcp_report_utilization
## -----------------------------------------------------------------------------------------------
proc alcp_report_utilization {} {
sh rm -fr ./soft_blk
write_floorplan -objects [get_placement_blockages -filter "blockage_type =~ soft"] -output soft_blk
sh sed -i 's/^remove_placement_blockage/#remove_placement_blockage/' ./soft_blk/floorplan.tcl

set soft_blockages  [get_placement_blockages -filter "blockage_type =~ soft"]
if { $soft_blockages != "" } {
           set_attr $soft_blockages blockage_type hard -quiet
        }

report_utilization

remove_placement_blockage [get_placement_blockages $soft_blockages]
source ./soft_blk/floorplan.tcl
}



