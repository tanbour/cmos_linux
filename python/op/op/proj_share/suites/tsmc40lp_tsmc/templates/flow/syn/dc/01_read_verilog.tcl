#===================================================================
#read_ddc $DDC_FILE 
#
#set hdlin_prohibit_nontri_multiple_drivers false
if {[file exist {{env.BLK_MISC}}/{{ver.misc}}/{{env.BLK_NAME}}.svf]} {
set_svf "{{env.BLK_MISC}}/{{ver.misc}}/{{env.BLK_NAME}}.svf"
}
{%- if local.use_rtl_filelist_tcl == "true" %}
source {{cur.config_plugins_dir}}/dc_scripts/rtl_filelist.tcl
{%- else %}
set rtl_filelist [glob {{env.BLK_RTL}}/{{ver.rtl}}/*.v]
{%- endif %}
puts "rtl file list: \n 
$rtl_filelist "

foreach rtl_file $rtl_filelist {
puts "Alchip-info: start analyzing rtl $rtl_file "
analyze -format verilog $rtl_file
}

#===================================================================
#=================== link design ===================================
#===================================================================
#$# --> elaborate $TOP
elaborate {{env.BLK_NAME}}
current_design {{env.BLK_NAME}}
set_multibit_options -mode non_timing_driven 
link > {{cur.cur_flow_log_dir}}/00_link_design.log
#
#set uniquify_naming_style ${TOP}_%s_%d
uniquify
check_design > {{cur.cur_flow_rpt_dir}}/01_check_design.rpt
