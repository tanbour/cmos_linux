set_host_options -max_cores 32
########################################################################
# LIBRARY
#
source $LIBRARY_SETUP_FILE

########################################################################
# PT SETUP
#
source ${PT_SETTING_FILE}

########################################################################
# READ DESIGN
#
file delete -force $log_dir/read_verilog.log
redirect -append $log_dir/read_verilog.log {puts "read_verilog ${VNET}"}
redirect -append $log_dir/read_verilog.log {read_verilog ${VNET}}
foreach type [array names SUB_BLOCKS_CELL_MAP] {
    foreach blk $SUB_BLOCKS_CELL_MAP($type) {
        set SVNET $BLOCK_RELEASE_DIR/$blk/vnet/${blk}.v.gz
        redirect -append $log_dir/read_verilog.log {puts "read_verilog ${SVNET}"}
        redirect -append $log_dir/read_verilog.log {read_verilog ${SVNET}}
    }
}

current_design ${TOP}
link_design ${TOP}

foreach sdc $SDC_LIST {
   source -echo -verbose ${sdc}
}

update_timing
check_timing
########################################################3
source ./pts_procs.tcl

# check input floating
pts::check_open_input_pin

# check dont use cell based on the dont_use_list
pts::check_dont_use_cell -dont_use_file /proj/Beluga/Signoff_Check/PR/dont_use_list

# check the multiple drive
pts::check_multi_drive

# report the cell type of clock tree.
pts::report_clock_cell_type

exit
