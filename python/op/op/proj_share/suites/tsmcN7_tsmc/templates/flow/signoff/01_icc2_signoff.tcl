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
set pre_flow_data_dir "{{pre.flow_data_dir}}/{{pre.stage}}"
set cur_flow_data_dir "{{cur.flow_data_dir}}/{{cur.stage}}"
set cur_flow_rpt_dir  "{{cur.flow_rpt_dir}}/{{cur.stage}}"
set cur_flow_log_dir  "{{cur.flow_log_dir}}/{{cur.stage}}"
set cur_flow_sum_dir  "{{cur.flow_sum_dir}}/{{cur.stage}}"
set cur_flow_scripts_dir "{{cur.flow_scripts_dir}}/{{cur.stage}}"

set signoff_dir       "signoff" 
set signoff_scripts   "signoff_check"
set signoff_stage     "icc2" 

exec mkdir -p $cur_flow_data_dir/$signoff_stage
exec mkdir -p $cur_flow_rpt_dir/$signoff_stage
exec mkdir -p $cur_flow_log_dir/$signoff_stage
exec mkdir -p $cur_flow_sum_dir/$signoff_stage
exec mkdir -p $cur_flow_scripts_dir

set start_time [clock seconds]
set BLOCK_NAME "{{env.BLK_NAME}}"
set signoff_cpu_number "{{local.signoff_cpu_number}}"
set_host_options -max_cores  ${signoff_cpu_number}

# Open design 
open_lib -read "$pre_flow_data_dir/${pre_stage}.{{env.BLK_NAME}}.nlib"
open_block -read {{env.BLK_NAME}}
link_block

# proc
#foreach file [ glob {{env.PROJ_SHARE_TMP}}/flow/signoff/proc/*.tcl ] {
#source -e -v $file
#}
source -e -v {{env.PROJ_SHARE_TMP}}/flow/signoff/proc/procs.tcl
source -e -v {{env.PROJ_SHARE_TMP}}/flow/signoff/proc/useful_procs.tcl
source -e -v {{env.PROJ_SHARE_TMP}}/flow/signoff/proc/get_drivers.tcl
source -e -v {{env.PROJ_SHARE_TMP}}/flow/signoff/proc/global_utility.tcl

# ICC2
source -e -v {{env.PROJ_SHARE_TMP}}/flow/signoff/${signoff_scripts}/global_variable_setting.tcl

foreach file [ glob {{env.PROJ_SHARE_TMP}}/flow/signoff/${signoff_scripts}/icc2/*.tcl ] {
        source -e -v $file
   }
	# check signal wire length
	check_signal_wire_length ${signal_wire_length_limitation} ${output_rpt_signal} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_signal_wire_length.log 
        # check_layout_misc 
	check_layout_misc > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_layout_misc.log
	# check_nondef_route ,check_nondef_route < none | -net (net_name|file_name) | -clock clock_name >
	check_nondef_route > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_nondef_route.log
	# check_tie_connection
	check_tie_connection ${tie_wire_length_limitation} ${output_rpt_tie} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_tie_connection.log
	# check_tie_net_length
        check_tie_net_length ${tie_cell_type} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_tie_net_length.log
	# check_power_rail_via ,check_power_rail_via < none | -power | -ground > 
        check_power_rail_via > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_power_rail_via.log
        # check_open_input_pin 
        check_open_input_pin ${output_rpt_open_pin} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_open_input_pin.log
	# check_delay_cell_chain
	check_delay_cell_chain ${delay_cell_type} ${output_rpt_delay_cell_chain}  >  $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_delay_cell_chain.log
	# check_filler_cells
        check_filler_area_number ${filler_cell_type} ${output_rpt_filler} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_filler_cells.log
        # check_dcap_cells
        check_dcap_area_number ${dcap_cell_type} ${output_rpt_dcap} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_dcap_cells.log
        # check_eco_cells
        check_eco_area_number ${eco_cell_type} ${output_rpt_eco} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_eco_cells.log
        # check_keep_cells
        write_check_size_only_cell ${size_only_cell}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.write_keep_cell_scripts.log
        # check_keep_nets
        write_check_dont_touch_net ${dont_touch_nets}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.write_keep_net_scripts.log
	# check_ip_isolation
        check_ip_isolation ${ip_wire_length_limitation} ${output_rpt_ip_isolation} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_ip_isolation.log
	# check_memory_orientation
	check_memory_orientation ${mem_orientation_file} ${output_rpt_mem_orientation} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_memory_orientation.log
	# check_port_isolation
	check_port_isolation ${port_wire_length_limitation} ${output_rpt_port_isolation} >  $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_port_isolation.log
	# check_clock_wire_length
        check_clock_wire_length ${clock_pin_list_file} ${clock_wire_length_limitation} ${output_rpt_clock} > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_clock_wire_length.log
	# check_clock_decap
	check_clock_decap -file $check_clock_decap_file > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_clock_decap.log
	# check multi driver
	check_multi_driver ${output_rpt_multi_driver}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_multi_driver.log
	# check multi drive nets
	check_multi_drive_net ${output_rpt_multi_drive_net}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_multi_drive_net.log
        # check_multi_drive_cell_type
        check_multi_drive_cell_type ${output_rpt_multi_cell_type}  > $cur_flow_log_dir/{{env.BLK_NAME}}.icc2.check_multi_drive_cell_type.log


# Move report to signoff dir
sh cp -rf ./* $cur_flow_rpt_dir/
sh cp -rf ./* $cur_flow_rpt_dir/$signoff_stage

exit

puts "Alchip-info : Completed signoff-check script--> icc2.check [info script]\n"
