##########################################################################################
# Tool  : IC Compiler II
# Script: 01_icc2_signoff.tcl
# Alchip OP
##########################################################################################
puts "Alchip-info : Running signoff-check script--> icc2.check [info script]\n"

#set pre_stage = icc2_route_opt
#set cur_stage = signoff
set pre_stage "{{pre.sub_stage}}"
set cur_stage "{{cur.sub_stage}}"

set pre_stage [lindex [split $pre_stage .] 0]
set cur_stage [lindex [split $cur_stage .] 0]

##mkdir tool output dirctory
set pre_flow_data_dir    "{{pre.flow_data_dir}}/{{pre.stage}}"
set cur_flow_data_dir    "{{cur.flow_data_dir}}"
set cur_flow_rpt_dir     "{{cur.flow_rpt_dir}}"
set cur_flow_log_dir     "{{cur.flow_log_dir}}"
set cur_flow_sum_dir     "{{cur.flow_sum_dir}}"
set cur_flow_scripts_dir "{{cur.flow_scripts_dir}}"

set signoff_dir   "{{local.signoff_dir}}" 

exec mkdir -p $cur_flow_data_dir
exec mkdir -p $cur_flow_rpt_dir
exec mkdir -p $cur_flow_log_dir
exec mkdir -p $cur_flow_sum_dir
exec mkdir -p $cur_flow_scripts_dir

set start_time [clock seconds]
set BLOCK_NAME  "{{env.BLK_NAME}}"
set signoff_icc2_cpu_number "{{local.signoff_icc2_cpu_number}}"
set_host_options -max_cores  ${signoff_icc2_cpu_number}

# Open design 
open_lib -read "$pre_flow_data_dir/${pre_stage}.{{env.BLK_NAME}}.nlib"
open_block -read {{env.BLK_NAME}}
link_block

# proc
#foreach file [ glob {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/*.tcl ] {
#source -e -v $file
#}
source -e -v {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/procs.tcl
source -e -v {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/useful_procs.tcl
source -e -v {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/get_drivers.tcl
source -e -v {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/global_utility.tcl

# ICC2 global setting
#source -e -v {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/global_variable_setting.tcl
set footprint_buf  "{{local.footprint_buf}}"
set footprint_inv  "{{local.footprint_inv}}"
set footprint_tie  "{{local.footprint_tie}}"
set wire_length_limitation  "{{local.wire_length_limitation}}"
set signal_wire_length_limitation  "{{local.signal_wire_length_limitation}}"
set clock_wire_length_limitation  "{{local.clock_wire_length_limitation}}"
set clock_pin_list_file "{{cur.config_plugins_dir}}/signoff_icc2/clk_pin.list"

set tie_wire_length_limitation  "{{local.tie_wire_length_limitation}}"

set tie_cell_type "{{local.tie_cell_type}}"
set mem_ref_names  "{{local.mem_ref_names}}"
set mem_orientation_file "{{cur.config_plugins_dir}}/signoff_icc2/allowed_orientation.list"
set net_file_name "{{cur.config_plugins_dir}}/signoff_icc2/clock_net.list"
set clock_file_name "{{cur.config_plugins_dir}}/signoff_icc2/clock_cell.list"

set physical_partition_reference_names  "{{local.physical_partition_reference_names}}"
set ip_reference_names  "{{local.ip_reference_names}}"
set ip_wire_length_limitation  "{{local.ip_wire_length_limitation}}"
set port_wire_length_limitation  "{{local.port_wire_length_limitation}}"
set check_clock_decap_file "{{cur.config_plugins_dir}}/signoff_icc2/clock_cell_nets.list"
set size_only_cell "{{cur.config_plugins_dir}}/signoff_icc2/size_only_cell.list"
set dont_touch_nets "{{cur.config_plugins_dir}}/signoff_icc2/dont_touch_nets.list"

set delay_cell_type  "{{local.delay_cell_type}}"
set filler_cell_type  "{{local.filler_cell_type}}"
set dcap_cell_type  "{{local.dcap_cell_type}}"
set eco_cell_type  "{{local.eco_cell_type}}"

foreach file [ glob {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/icc2/*.tcl ] {
        source -e -v $file
   }
	# check signal wire length
	check_signal_wire_length ${signal_wire_length_limitation} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_signal_wire_length.log 
	# check_clock_wire_length
        check_clock_wire_length ${clock_pin_list_file} ${clock_wire_length_limitation} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_clock_wire_length.log
        # check_layout_misc 
	check_layout_misc > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_layout_misc.log
	# check_nondef_route ,check_nondef_route < none | -net (net_name|file_name) | -clock clock_name >
	check_nondef_route > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_nondef_route.log
	# check_tie_connection
	check_tie_connection ${tie_wire_length_limitation}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_tie_connection.log
	# check_tie_net_length
        check_tie_net_length ${tie_cell_type} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_tie_net_length.log
	# check_power_rail_via ,check_power_rail_via < none | -power | -ground > 
        check_power_rail_via > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_power_rail_via.log
        # check_open_input_pin 
        check_open_input_pin > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_open_input_pin.log
	# check_delay_cell_chain
	check_delay_cell_chain ${delay_cell_type}  >  $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_delay_cell_chain.log
	# check_filler_cells
        check_filler_area_number ${filler_cell_type}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_filler_cells.log
        # check_dcap_cells
        check_dcap_area_number ${dcap_cell_type}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_dcap_cells.log
        # check_eco_cells
        check_eco_area_number ${eco_cell_type}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_eco_cells.log
        # check_keep_cells
        write_check_size_only_cell ${size_only_cell}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.write_size_only_cell_pt_scripts.log
        # check_keep_nets
        write_check_dont_touch_net ${dont_touch_nets}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.write_dont_touch_net_pt_scripts.log
	# check_ip_isolation
        check_ip_isolation ${ip_wire_length_limitation}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_ip_isolation.log
	# check_memory_orientation
	check_memory_orientation ${mem_orientation_file} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_memory_orientation.log
	# check_port_isolation
	check_port_isolation ${port_wire_length_limitation}  >  $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_port_isolation.log
	# check_clock_decap
	check_clock_decap -file $check_clock_decap_file > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_clock_decap.log
	# check multi driver
	check_multi_driver   > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_multi_driver.log
	# check multi drive nets
	check_multi_drive_net   > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_multi_drive_net.log
        # check_multi_drive_cell_type
        check_multi_drive_cell_type  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_multi_drive_cell_type.log


# Move report to signoff dir
sh mv check_size_only_cell.pt.tcl check_dont_touch_net.pt.tcl "{{cur.config_plugins_dir}}/signoff_pt/" 
sh cp -rf ./* $cur_flow_rpt_dir/

exit

puts "Alchip-info : Completed signoff-check script--> icc2.check [info script]\n"
