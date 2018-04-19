##########################################################################################
# Tool: PrimeTime
# Script: 03_pt_signoff.tcl
# Alchip OP
##########################################################################################
puts "Alchip-info : Running signoff-check script--> pt.check [info script]\n"

#set pre_stage = sta
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

set signoff_dir          "{{local.signoff_dir}}" 
set SESSION              "{{local._multi_inst}}"

exec mkdir -p $cur_flow_data_dir/${SESSION}
exec mkdir -p $cur_flow_rpt_dir/${SESSION}
exec mkdir -p $cur_flow_log_dir/${SESSION}
exec mkdir -p $cur_flow_sum_dir/${SESSION}
#exec mkdir -p $cur_flow_scripts_dir/${SESSION}

set start_time [clock seconds]
set BLOCK_NAME  "{{env.BLK_NAME}}"
set signoff_pt_cpu_number "{{local.signoff_pt_cpu_number}}"
set_host_options -max_cores  ${signoff_pt_cpu_number}
set ANNOTATED_FILE_FORMAT  "{{local.ANNOTATED_FILE_FORMAT}}"

## Link data
exec ln -sf $pre_flow_data_dir/${SESSION}/${BLOCK_NAME}.${SESSION}.session $cur_flow_data_dir/${signoff_dir}/${SESSION}/

## Restore PT session

if {[file isdirectory $pre_flow_data_dir/${SESSION}/${BLOCK_NAME}.${SESSION}.session]} {
	restore_session $pre_flow_data_dir/${SESSION}/${BLOCK_NAME}.${SESSION}.session
} else {
	puts "Alchip-error : $pre_flow_data_dir/${SESSION}/${BLOCK_NAME}.${SESSION}.session no exist!\n"
	exit
}

# proc
#foreach file [ glob {{env.PROJ_UTILS}}/${signoff_dir}/proc/*.tcl ] {
#source -e -v $file
#}
source -e -v {{env.PROJ_UTILS}}/${signoff_dir}/proc/procs.tcl
source -e -v {{env.PROJ_UTILS}}/${signoff_dir}/proc/useful_procs.tcl
source -e -v {{env.PROJ_UTILS}}/${signoff_dir}/proc/get_drivers.tcl
source -e -v {{env.PROJ_UTILS}}/${signoff_dir}/proc/global_utility.tcl

# PT global setting
#source -e -v {{env.PROJ_UTILS}}/${signoff_dir}/global_variable_setting.tcl
set clock_threshold  "{{local.clock_threshold}}"
set ip_clock_duty_spec_file  "{{local.ip_clock_duty_spec_file}}"
#set ip_clock_duty_spec_file "{{cur.config_plugins_dir}}/signoff/pt/ip_clock_duty_spec.list" 

set pt_cmd_file  "{{local.pt_cmd_file}}"
set high_vth_cell_ref_name  "{{local.high_vth_cell_ref_name}}"
set low_drive_cell_ref_name  "{{local.low_drive_cell_ref_name}}"


foreach file [ glob {{env.PROJ_UTILS}}/${signoff_dir}/pt/*.tcl ] {
        source -e -v $file
   }
# add
source -e -v {{cur.config_plugins_dir}}/signoff/pt/check_size_only_cell.pt.tcl
source -e -v {{cur.config_plugins_dir}}/signoff/pt/check_dont_touch_net.pt.tcl
	# check multi driver
	check_multi_driver  > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_multi_driver.log
	# check multi drive nets
	check_multi_drive_net  > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_multi_drive_net.log
        # check_multi_drive_cell_type
        check_multi_drive_cell_type  > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_multi_drive_cell_type.log
        # check_dont_use_cell
	check_dont_use_cell  > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_dont_use_cell.log
        # check_open_input_pin 
        check_open_input_pin  > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_open_input_pin.log
        # check_tie_cell_fanout
        check_tie_cell_fanout > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_tie_cell_fanout.log
        # check_ip_duty
        check_ip_duty ${ip_clock_duty_spec_file} ${pt_cmd_file}  > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_ip_duty.log
        # check_clock_net_xtalk_delta_delay
        check_clock_net_xtalk_delta_delay ${clock_threshold}  > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_clock_net_xtalk_delta_delay.log
        # check_signal_net_xtalk_delta_delay
        #check_signal_net_xtalk_delta_delay ${signal_threshold}  > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_signal_net_xtalk_delta_delay.log
        # check_dont_touch_net   
#        check_dont_touch_net  > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_dont_touch_net.log
        # check_size_only_cell  
#        check_size_only_cell > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.check_size_only_cell.log
        # report_clock_summary
        report_clock_summary  > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.report_clock_summary.log
        # report_clock_cell_type
        report_clock_cell_type ${high_vth_cell_ref_name} ${low_drive_cell_ref_name} > $cur_flow_log_dir/${SESSION}/{{env.BLK_NAME}}.pt.report_clock_cell_type.log    

# Move reports to signoff dir
sh cp -rf ./* $cur_flow_rpt_dir/${SESSION}
puts "{{env.FIN_STR}}\n" 

exit

puts "Alchip-info : Completed signoff-check script--> pt.check [info script]\n"
