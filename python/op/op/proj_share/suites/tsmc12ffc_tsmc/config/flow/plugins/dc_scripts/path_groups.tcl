#set_critical_range 0.3 [current_design]
#
##===================================================================
##=================== common path group =============================
##===================================================================
#set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
#group_path -name REGOUT -to [all_outputs]
#group_path -name REGIN -from [remove_from_collection [all_inputs] ${ports_clock_root}] 
#group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
#
#
##===================================================================
##=================== special path group ============================
##===================================================================
#
#group_path -weight 2 -name TO_MEM -to      [get_pins -of [all_macro_cells]]
#group_path -weight 2 -name FROM_MEM -from  [get_pins -of [all_macro_cells]]
#
#set all_regs [remove_from_collection [all_registers -edge_triggered] [all_macro_cells]]
#
### main clock
#group_path -weight 10 -name ck_gclkt
#
### uix
#group_path -weight 20 -name uexu -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uexu/*"]]
#
#group_path -weight 5 -name uexu_umx_mac -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uexu/umx_mac/*"]]
#
#group_path -weight 5 -name uexu_usx_issq_top -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uexu/usx_issq_top/*"]]
#
#group_path -weight 5 -name uexu_umx_div -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uexu/umx_div/*"]]
#
#group_path -weight 5 -name uexu_usx_dpk -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uexu/usx_dpk/*"]]
#
#group_path -weight 5 -name uexu_usx_dpj -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uexu/usx_dpj/*"]]
#
#group_path -weight 5 -name uexu_umx_issq -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uexu/umx_issq/*"]]
#
#
### uls
#group_path -weight 30 -name uls -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ ulsu/*"]]
#
#group_path -weight 30 -name uls_uagutlbld -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ ulsu/uagutlbld/*"]]
#
#group_path -weight 25 -name uls_uagutlbst -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ ulsu/uagutlbst/*"]]
#
#### ***
#group_path -weight 5 -name uls_uissq -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ ulsu/uissq/*"]]
#
#group_path -weight 5 -name uls_uld_ctl -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ ulsu/uld_ctl/*"]]
#
#group_path -weight 5 -name uds_to_uls_uissq -from [get_pins -leaf -filter "name == clocked_on" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/*"]] \
#						-to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ ulsu/uissq/*"]]
#
#group_path -weight 5 -name uls_usb -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ ulsu/usb/*"]]
#
### uid
#group_path -weight 30 -name uid -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udec/*"]]
#
#group_path -weight 40 -name uid_ugenq -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udec/ugenq/*"]]
#
#group_path -weight 40 -name uid_urenq -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udec/urenq/*"]]
#
#group_path -weight 10 -name uid_uresqfree -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udec/uresqfree/*"]]
#
#group_path -weight 5 -name uid_ur2q -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udec/ur2q/*"]]
#
#group_path -weight 50 -name urenq_2_ur2q -from [get_pins -leaf -filter "name == clocked_on" -of \
#        [get_cells -hier * -filter "is_sequential == true && full_name =~ udec/urenq/*"]] \
#                                                -to [get_pins -leaf -filter "name == next_state" -of \
#        [get_cells -hier * -filter "is_sequential == true && full_name =~ udec/ur2q/*"]]
#
#group_path -weight 50 -name uresqfree_2_urename -from [get_pins -leaf -filter "name == clocked_on" -of \
#        [get_cells -hier * -filter "is_sequential == true && full_name =~ udec/uresqfree/*"]] \
#                                                -to [get_pins -leaf -filter "name == next_state" -of \
#        [get_cells -hier * -filter "is_sequential == true && full_name =~ udec/urename/*"]]
#
#group_path -weight 50 -name uid_urename -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udec/urename/*"]]
#
#group_path -weight 5 -name uid_udec23 -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udec/udec23/*"]]
#
### uif
#group_path -weight 20 -name uif -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uifu/*"]]
#
#group_path -weight 5 -name uif_ufq -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uifu/ufq*"]]
#
#group_path -weight 5 -name uif_utlb_ctl -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uifu/utlb_ctl*"]]
#
### uds
#group_path -weight 5 -name uds -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/*"]]
#
#group_path -weight 5 -name uds_udispq -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/udispq/*"]]
#
##### ***
#group_path -weight 30 -name uds_resqd -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/*_resqd/*"]]
#
##### ***
#group_path -weight 5 -name uds_usp_issq -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/usp_issq/*"]]
#
#group_path -weight 30 -name uds_uimm -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/uimm/*"]]
#
#group_path -weight 5 -name uds_uarm_rf -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/uarm_rf/*"]]
#
##group_path -weight 10 -name uds_ucomm_ctl -to [get_pins -leaf -filter "name == next_state" -of \
##	[get_cells -hier * -filter "is_sequential == true && full_name =~ uds/ucomm_ctl/*"]]
#
#group_path -weight 5 -name uds_upc -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/upc/*"]]
#
#group_path -weight 5 -name uds_uaes_resqs -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/uaes_resqs/*"]]
#
#group_path -weight 10 -name uds_ustg -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/ustg/*"]]
#
#group_path -weight 5 -name uds_uext_rf -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/uext_rf/*"]]
#
#
### uvfu
#group_path -weight 50 -name uvfu -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uvfu/*"]]
#
#### ***
#group_path -weight 5 -name uvfu_uissq_top -to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uvfu/uissq_top/*"]]
#
#group_path -weight 20 -name uds_to_uvfu_uissq_top -from [get_pins -leaf -filter "name == clocked_on" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ udsu/*"]] \
#						-to [get_pins -leaf -filter "name == next_state" -of \
#	[get_cells -hier * -filter "is_sequential == true && full_name =~ uvfu/uissq_top/*"]]
#
### New path group for alchip
#group_path -weight 50 -name uvfu_to_uvfu_ufmulj \
#  -from [filter_collection $all_regs "full_name =~ uvfu/*" ] \
#  -to [filter_collection $all_regs "full_name =~ uvfu/ufmulj*"]
#
#group_path -weight 50 -name uvfu_to_uvfu_ufmulk \
#  -from [filter_collection $all_regs "full_name =~ uvfu/*" ] \
#  -to [filter_collection $all_regs "full_name =~ uvfu/ufmulk*"]
#
#group_path -weight 20 -name uvfu_ufmulj \
#  -from [filter_collection $all_regs "full_name =~ uvfu/ufmulj*" ] \
#  -to [filter_collection $all_regs "full_name =~ uvfu/ufmulj*"]
#
#group_path -weight 20 -name uvfu_ufmulk \
#  -from [filter_collection $all_regs "full_name =~ uvfu/ufmulk*" ] \
#  -to [filter_collection $all_regs "full_name =~ uvfu/ufmulk*"]
#
#group_path -weight 10 -name uexu_to_udsu \
#  -from [filter_collection $all_regs "full_name=~uexu/*" ] \
#  -to [filter_collection $all_regs "full_name=~udsu/*"]
#
#group_path -weight 5 -name udec_to_uds \
#  -from [filter_collection $all_regs "full_name=~udec/*" ] \
#  -to [filter_collection $all_regs "full_name=~udsu/*"]
#
#group_path -weight 10 -name udec_to_uds_resqd \
#  -from [filter_collection $all_regs "full_name=~udec/*" ] \
#  -to [filter_collection $all_regs "full_name=~udsu/uaes_resqd/*"]
#
#group_path -weight 30 -name udec_to_uds_udispq \
#  -from [filter_collection $all_regs "full_name=~udec/*" ] \
#  -to [filter_collection $all_regs "full_name=~udsu/udispq/*"]
#
#group_path -weight 35 -name udec_to_uds_uimm \
#  -from [filter_collection $all_regs "full_name=~udec/*" ] \
#  -to [filter_collection $all_regs "full_name=~udsu/uimm/*"]
#
#group_path -weight 30 -name uds_to_udec_urename \
#  -from [filter_collection $all_regs "full_name=~udsu/*"] \
#  -to [filter_collection $all_regs "full_name=~ udec/urename*" ]
#
#group_path -weight 35 -name uds_uaes_resqd_resqsrc \
#  -from [filter_collection $all_regs "full_name=~ udsu*"] \
#  -to [filter_collection $all_regs "full_name=~ udsu/uaes_resqd/resq_src?_rd_data_*reg*"]
#
#group_path -weight 5 -name uds_uaes_resqd_rfb1hi \
#  -from [filter_collection $all_regs "full_name=~ udsu*"] \
#  -to [filter_collection $all_regs "full_name=~ udsu/uaes_resqd/urfb1hi*"]
#
