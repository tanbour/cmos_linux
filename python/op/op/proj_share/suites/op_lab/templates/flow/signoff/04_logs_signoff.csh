#!/bin/csh -f 
##########################################################################################
# Script: 04_logs_signoff.csh
# Alchip  OP
##########################################################################################
echo  "Alchip-info : Running signoff-check script--> logs.check [info script]\n"

#set pre_stage = sta
#set cur_stage = signoff
set pre_stage = "{{pre.sub_stage}}"
set cur_stage = "{{cur.sub_stage}}"

set pre_stage = `echo $pre_stage | cut -d . -f 1`
set cur_stage = `echo $cur_stage | cut -d . -f 1`

##mkdir tool output dirctory
set pre_flow_data_dir    =   "{{pre.flow_data_dir}}/{{pre.stage}}"
set pre_flow_log_dir     =   "{{pre.flow_log_dir}}/{{pre.stage}}"
set cur_flow_data_dir    =   "{{cur.flow_data_dir}}"
set cur_flow_rpt_dir     =   "{{cur.flow_rpt_dir}}"
set cur_flow_log_dir     =   "{{cur.flow_log_dir}}"
set cur_flow_sum_dir     =   "{{cur.flow_sum_dir}}"
set cur_flow_scripts_dir =   "{{cur.flow_scripts_dir}}"

set signoff_dir =  "{{local.signoff_dir}}" 

mkdir -p $cur_flow_data_dir
mkdir -p $cur_flow_rpt_dir
mkdir -p $cur_flow_log_dir
mkdir -p $cur_flow_sum_dir
mkdir -p $cur_flow_scripts_dir


##link previous stage data
ln -sf $pre_flow_log_dir/*  $cur_flow_data_dir

set BLOCK_NAME = "{{env.BLK_NAME}}"

set netlist_1 = "{{cur.config_plugins_dir}}/signoff/perl/Netlist_1.v"
set netlist_2 = "{{cur.config_plugins_dir}}/signoff/perl/Netlist_2.v"
set netlist_3 = "{{cur.config_plugins_dir}}/signoff/perl/Netlist_3.v"

#set top_dir   "local.top_dir"
#set sc_dir    "local.sc_dir"
#set mem_dir   "local.mem_dir"
#set io_dir    "local.io_dir"
#set ip_dir    "local.ip_dir"

set path_cdl    = "{{cur.config_plugins_dir}}/signoff/perl/IP.cdl"

##################################
# check perl log 
##################################
## Item: check netlist and statistic chip size / cell type & number & area and so on.
# check low-drive / high-drive cell / no-bs
perl {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/perl/check_netlist.pl ${netlist_1}  > $cur_flow_log_dir/{{env.BLK_NAME}}.perl.check_netlist.log

# check max_size cell / min_size cell error / min_area cell
perl {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/perl/check_cellsize.pl ${netlist_2} > $cur_flow_log_dir/{{env.BLK_NAME}}.perl.check_cellsize.log

# check chip size / logic gate size (Mgate) / SC area-ratio of each VTH cells
perl {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/perl/check_netlist_statistic.pl ${netlist_3}  > $cur_flow_log_dir/{{env.BLK_NAME}}.perl.check_netlist_statistic.log

## Item: check IP cdl bus order
perl {{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/perl/check_ip_cdl_bus_order.pl ${path_cdl} > $cur_flow_log_dir/{{env.BLK_NAME}}.perl.check_ip_cdl_bus_order.log

##################################
# check starrc log 
##################################
# Usage: check_starrc_log.csh <starrc_log_dir> <block_name>
{{env.PROJ_SHARE_TMP}}/flow/${signoff_dir}/csh/check_starrc_log.csh $pre_flow_log_dir {{env.BLK_NAME}}  > $cur_flow_log_dir/{{env.BLK_NAME}}.starrc_log_check.log

echo  "Alchip-info : Completed signoff-check script--> logs.check [info script]\n"
