##########################################################################################
# Script:04_perl_signoff.tcl
# Alchip OP
##########################################################################################
puts "Alchip-info : Running signoff-check script--> perl.check [info script]\n"

set src_stage icc2_route 
set dst_stage signoff 
set op4_dst_eco signoff_check

set start_time [clock seconds]
set_host_options -max_cores 16
set BLOCK_NAME   "{{env.BLK_NAME}}"

exec mkdir -p {{env.RUN_DATA}}
exec mkdir -p {{env.RUN_RPT}}
exec mkdir -p {{env.RUN_LOG}}

## Item: check netlist and statistic chip size / cell type & number & area and so on.

# check low-drive / high-drive cell / no-bs
perl {{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/perl/check_netlist.pl ${netlist_1}  > {{env.RUN_RPT}}/$op4_dst_eco/{{env.BLK_NAME}}.perl.check_netlist.log

# check max_size cell / min_size cell error / min_area cell
perl {{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/perl/check_cellsize.pl ${netlist_2} > {{env.RUN_RPT}}/$op4_dst_eco/{{env.BLK_NAME}}.perl.check_cellsize.log

# check chip size / logic gate size (Mgate) / SC area-ratio of each VTH cells
perl {{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/perl/check_netlist_statistic.pl ${netlist_3}  >> {{env.RUN_RPT}}/$op4_dst_eco/{{env.BLK_NAME}}.perl.check_netlist_statistic.log

## Item: check GDS layer 
# Compare all of them with chip[top]
perl {{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/perl/check_GDS_layer_usage.pl -top ${top_dir} -sc ${sc_dir} -mem ${mem_dir} -ip ${ip_dir} -io ${io_dir} > {{env.RUN_RPT}}/$op4_dst_eco/{{env.BLK_NAME}}.perl.check_GDS_layer.log

# Compare some of them with chip[top]
perl {{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/perl/check_GDS_layer_usage.pl -top ${top_dir} -sc ${sc_dir}  > {{env.RUN_RPT}}/$op4_dst_eco/{{env.BLK_NAME}}.perl.check_GDS_layer.log
perl {{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/perl/check_GDS_layer_usage.pl -top ${top_dir} -sc ${sc_dir} -mem ${mem_dir}  > {{env.RUN_RPT}}/$op4_dst_eco/{{env.BLK_NAME}}.perl.check_GDS_layer.log
perl {{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/perl/check_GDS_layer_usage.pl -top ${top_dir} -sc ${sc_dir} -mem ${mem_dir} -ip ${ip_dir}  > {{env.RUN_RPT}}/$op4_dst_eco/{{env.BLK_NAME}}.perl.check_GDS_layer.log

## Item: check IP cdl bus order
perl {{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/perl/check_ip_cdl_bus_order.pl ${path_cdl} > {{env.RUN_RPT}}/$op4_dst_eco/{{env.BLK_NAME}}.perl.check_ip_cdl_bus_order.log


puts "Alchip-info : Completed signoff-check script--> perl.check [info script]\n"
