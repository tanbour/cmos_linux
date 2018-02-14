#===================================================================
#read_ddc $DDC_FILE 
#
#set hdlin_prohibit_nontri_multiple_drivers false
set_svf "{{ver.misc}}/{{BLK_NAME}}.svf"

set rtl_filelist [glob {{ver.rtl}}/*.v]

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
link > {{cur.flow_log_dir}}/00_link_design.log
#
#set uniquify_naming_style ${TOP}_%s_%d
uniquify
#check_design > {{cur.flow_log_dir}}/01_check_design.log
