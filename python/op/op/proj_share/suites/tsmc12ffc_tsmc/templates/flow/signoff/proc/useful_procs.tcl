
## -----------------------------------------------------------------------------------------------
## 
## -----------------------------------------------------------------------------------------------

#$#   proc proc_color_cpu { } {
#$#   
#$#     remove_color
#$#     # uck_cpu udec udsu udt_gclk uexu uifu ul2_cpu_slv ulsu ureg_rep uvfu
#$#     set_color -color 8 -depth all [get_cells ul2_cpu_slv]
#$#   
#$#     set_color -color 33 -depth all [get_cells uck_cpu]
#$#     #set_color -color 50 -depth all [get_cells udec]
#$#     #set_color -color 60 -depth all [get_cells uif]
#$#     #set_color -color 8 -depth all [get_cells udsu]
#$#   
#$#     set_color -color_name red -depth all [get_cells uexu]
#$#     set_color -color_name orange  -depth all [get_cells ulsu]
#$#     set_color -color_name light_red -depth all [get_cells uvfu]
#$#   
#$#     # set_color -color 5 -depth all [get_cells u_noram/u_core/u_dec]
#$#     set_color -color 50 -depth all [get_cells udec]
#$#     set_color -color_name purple   -depth all [get_cells udsu]
#$#     set_color -color_name green  -depth all [get_cells uifu]
#$#     ## #set_color -color 40 -depth all [get_cells u_noramu_clk_module*/*]
#$#     ## set_color -color_name purple -depth all [get_cells u_noram/u_core/u_data_engine/u_de_issue_queue_top]
#$#   
#$#     set_colors -cycle_color [get_cells [list \
#$#       udsu/uarm_rf  \
#$#       uvfu/uissq_top  \
#$#       ulsu/uissq  \
#$#       udsu/uaes_resqd  \
#$#       udsu/uext_rf  \
#$#       udsu/uaes_resqs  \
#$#       udec/urename \
#$#     ]]
#$#   
#$#   }

## -----------------------------------------------------------------------------------------------
## 
## -----------------------------------------------------------------------------------------------
## -----------------------------------------------------------------------------------------------
## proc_report_utilization
## -----------------------------------------------------------------------------------------------
proc proc_report_utilization { } {

  remove_utilization_configurations -all

  report_utilization
  create_utilization_configuration -exclude {soft_blockages hard_macros soft_macros io_cells} config2
  report_utilization -config config2

}

## -----------------------------------------------------------------------------------------------
## proc_report_threshold_voltage_groups
## -----------------------------------------------------------------------------------------------
proc proc_report_threshold_voltage_groups { } {
  define_user_attribute -type string -class lib_cell threshold_voltage_group
  set_attribute -quiet [get_lib_cells -quiet *cpd/*] threshold_voltage_group SVT
  set_attribute -quiet [get_lib_cells -quiet *p16*cpdlvt/*] threshold_voltage_group LVT_C16
  set_attribute -quiet [get_lib_cells -quiet *p18*cpdlvt/*] threshold_voltage_group LVT_C18
  set_attribute -quiet [get_lib_cells -quiet *p20*cpdlvt/*] threshold_voltage_group LVT_C20
  set_attribute -quiet [get_lib_cells -quiet *p16*cpdulvt/*] threshold_voltage_group ULVT_C16
  set_attribute -quiet [get_lib_cells -quiet *p18*cpdulvt/*] threshold_voltage_group ULVT_C18
  set_attribute -quiet [get_lib_cells -quiet *p20*cpdulvt/*] threshold_voltage_group ULVT_C20


  report_threshold_voltage_groups
}








## -----------------------------------------------------------------------------------------------
## 
## -----------------------------------------------------------------------------------------------






