##########################################################################################
# Tool  : Innovus
# Script: 02_invs_signoff.tcl
# Alchip Onepiece4
##########################################################################################
puts "Alchip-info : Running signoff-check script--> innovus.check [info script]\n"


set src_stage icc2_route 
set dst_stage signoff 
set op4_dst_eco signoff_check

setMultiCpuUsage -localCpu 16
set start_time [clock seconds]
set BLOCK_NAME   "{{env.BLK_NAME}}"

source  -e -v    "{{env.RUN_SCRIPT}}/${dst_stage}/proc/procs.tcl"

#restoreDesign $DATA_DIR/$OP4_src_subdir/$BLOCK_NAME.$OP4_src.$OP4_src_branch.$OP4_src_eco.enc.dat $BLOCK_NAME
restoreDesign "{{env.RUN_DATA}}/{{env.BLK_NAME}}.${src_stage}.enc.dat {{env.BLK_NAME}}"

{%- if  local._exec_tool == "innovus" %}
source {{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/global_variable_setting.tcl
        foreach file [ glob {{env.PROJ_SHARE_TMP}}/${dst_stage}/${op4_dst_eco}/innovus/*.tcl ] {
        source -e -v $file
        }
	# check signal wire length
	check_signal_wire_length ${wire_length_limitation} {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_signal_wire_length.rpt 
        # check_layout_misc 
	check_layout_misc > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_layout_misc.rpt
	# check_nondef_route	
	check_nondef_route > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_nondef_route.rpt
	# check_tie_connection
	check_tie_connection ${wire_length_limitation} > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_tie_connection.rpt
	# check_tie_net_length
        check_tie_net_length ${tie_cell_ref_name} > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_tie_net_length.rpt
	# check_power_rail_via
        check_power_rail_via > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_power_rail_via.rpt
        # check_open_input_pin
        check_open_input_pin > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_open_input_pin.rpt
	# check_delay_cell_chain
	check_delay_cell_chain >  {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_delay_cell_chain.rpt
	# check_filler_cells
        check_filler_area_number ${filler_rpt} ${filler_cell_type} > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_filler_cells.rpt
        # check_dcap_cells
        check_dcap_area_number ${dcap_rpt} ${dcap_cell_type} > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_dcap_cells.rpt
        # check_eco_cells
        check_eco_area_number ${eco_rpt} ${eco_cell_type} > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_eco_cells.rpt
        # check_keep_cells
        write_check_size_only_cell ${size_only_cell}  > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.write_keep_cell_scripts.rpt
        # check_keep_nets
        write_check_dont_touch_net ${dont_touch_nets}  > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.write_keep_net_scripts.rpt
	# check_ip_isolation
        check_ip_isolation ${wire_length_limitation} > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_ip_isolation.rpt
	# check_memory_orientation
	check_memory_orientation  > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_memory_orientation.rpt
	# check_port_isolation
	check_port_isolation ${wire_length_limitation} >  {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_port_isolation.rpt
	# check_clock_wire_length
        check_clock_wire_length ${clock_pin_list_file} ${wire_length_limitation} > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_clock_wire_length.rpt
	# check_clock_decap
	check_clock_decap -file $check_clock_decap_file > {{env.RUN_RPT}}/${op4_dst_eco}/{{env.BLK_NAME}}.icc2.check_clock_decap.rpt

{%- endif %}

    exit

puts "Alchip-info : Completed signoff-check script--> innovus.check [info script]\n"
