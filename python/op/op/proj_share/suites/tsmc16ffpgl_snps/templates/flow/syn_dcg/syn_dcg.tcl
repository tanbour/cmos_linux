#===================================================================
#=================== run flow ======================================
#===================================================================
{% include 'dcg/00_des.tcl' %}
{% include 'dcg/00_create_lib.tcl' %}
{% include 'dcg/01_read_verilog.tcl' %}
{% include 'dcg/02_compile.tcl' %}
{% include 'dcg/03_opt_net.tcl' %}
check_design > {{cur.flow_rpt_dir}}/{{cur.stage}}/02_check_design.log

puts "Alchip_info: op stage finished."

exit
