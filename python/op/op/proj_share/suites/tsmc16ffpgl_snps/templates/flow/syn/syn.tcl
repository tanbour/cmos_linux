#===================================================================
#=================== run flow ======================================
#===================================================================
{% include 'dc/00_des.tcl' %}
{% include 'dc/00_create_lib.tcl' %}
{% include 'dc/01_read_verilog.tcl' %}
{% include 'dc/02_compile.tcl' %}
{% include 'dc/03_opt_net.tcl' %}
check_design > {{cur.flow_rpt_dir}}/{{cur.stage}}/02_check_design.log

puts "Alchip_info: op stage finished."

exit
