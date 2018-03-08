# options
{% include 'spyglass/spg_rtl_sdc_check.tcl' %}
# read design
{% include 'spyglass/1_soc_rtl_load_design.tcl' %}
# set waiver
{% include 'spyglass/2_soc_rtl_waive.tcl' %}
# run checks
{% include 'spyglass/3_soc_rtl_run_goal.tcl' %}
# generate report
{% include 'spyglass/4_spg_report.tcl' %}

puts "Alchip_info: op stage finished."

save_project
exit -force

