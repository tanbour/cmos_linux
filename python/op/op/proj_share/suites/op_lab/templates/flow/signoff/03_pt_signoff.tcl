##########################################################################################
# Tool: PrimeTime
# Script: 03_pt_signoff.tcl
# Alchip OP
##########################################################################################
puts "Alchip-info : Running signoff-check script--> pt.check [info script]\n"

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

set signoff_dir     "signoff" 
set signoff_scripts "signoff_check"
set signoff_stage   "pt" 

exec mkdir -p $cur_flow_data_dir/$signoff_stage
exec mkdir -p $cur_flow_rpt_dir/$signoff_stage
exec mkdir -p $cur_flow_log_dir/$signoff_stage
exec mkdir -p $cur_flow_sum_dir/$signoff_stage
exec mkdir -p $cur_flow_scripts_dir

set start_time [clock seconds]
set BLOCK_NAME  "{{env.BLK_NAME}}"
set signoff_cpu_number "{{local.signoff_cpu_number}}"
set_host_options -max_cores  ${signoff_cpu_number}

source {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/procs.tcl
source {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/useful_procs.tcl
source {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/get_drivers.tcl
source {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/global_utility.tcl

## Restore PT sesseion
set SESSION                     "{{local._multi_inst}}"

if {[file isdirectory $pre_flow_data_dir/${SESSION}]} {
	restore_session $pre_flow_data_dir/${SESSION}
} else {
	puts "Alchip-error : $pre_flow_data_dir/${SESSION} no exist!\n"
	exit
}

## proc
#foreach file [ glob {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/*.tcl ] {
#source -e -v $file
#}

source {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/procs.tcl
source {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/useful_procs.tcl
source {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/get_drivers.tcl
source {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/proc/global_utility.tcl

source {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/${signoff_scripts}/global_variable_setting.tcl
foreach file [ glob {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/${signoff_scripts}/pt/*.tcl ] {
        source -e -v $file
   }
	# check multi driver
	output_rpt_multi_driver ${output_rpt_multi_driver}  > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_multi_driver.log
	# check multi drive nets
	check_multi_drive_net ${output_rpt_multi_drive_net}  > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_multi_drive_net.log
        # check_multi_drive_cell_type
        check_multi_drive_cell_type ${output_rpt_multi_cell_type}  > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_multi_drive_cell_type.log
        # check_dont_use_cell
	check_dont_use_cell ${output_rpt_dont_use_cell}  > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_dont_use_cell.log
        # check_open_input_pin 
        check_open_input_pin ${output_rpt_open} > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_open_input_pin.log
        # check_tie_cell_fanout
        check_tie_cell_fanout > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_tie_cell_fanout.log
        # check_ip_duty
        check_ip_duty ${ip_clock_duty_spec_file} ${pt_cmd_file} ${output_rpt_ip_duty} > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_ip_duty.log
        # check_clock_net_xtalk_delta_delay
        check_clock_net_xtalk_delta_delay ${clock_threshold} ${output_rpt_clock_pt} > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_clock_net_xtalk_delta_delay.log
        # check_signal_net_xtalk_delta_delay
        check_signal_net_xtalk_delta_delay ${signal_threshold} ${output_rpt_signal_pt} > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_signal_net_xtalk_delta_delay.log
        # check_dont_touch_net   
        check_dont_touch_net ${output_rpt_dont_touch_net} > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_dont_touch_net.log
        # check_size_only_cell  
        check_size_only_cell > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.check_size_only_cell.log
        # report_clock_summary
        report_clock_summary  > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.report_clock_summary.log
        # report_clock_cell_type
        report_clock_cell_type ${high_vth_cell_ref_name} ${low_drive_cell_ref_name} > $cur_flow_log_dir/{{env.BLK_NAME}}.pt.report_clock_cell_type.log    

exit

puts "Alchip-info : Completed signoff-check script--> pt.check [info script]\n"
