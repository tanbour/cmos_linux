# # set dont_touch
# # all pin/cell/module/need dont touch by set_dont_touch
# # skip violations on these pins.
# #
# set_dont_touch [get_pins pin_list] true  
# # Skip violation on the pins of these paths.
# set_dout_touch [get_paths -start_points pin1 -end_points pin2 -delay_type Min] true 
# # Skip violation on the pins of these paths.
# set_dont_touch [get_paths -group V_*] true 
# # dont touch this cell including sizing. 
# set_dont_touch [get_cells -hierarchical *u_iso] true 
# # dont touch this cell including sizing. 
# set_dont_touch [get_pins -hierarchical *u_iso/*] true 
# # dont touch this net including insert buffer at any pin connect to this net 
# set_dont_touch [get_nets net_list] true  
# # dont touch hier path, should supply instance path
# set_hier_path_dont_touch {hier_path1 hier_path2} true 
# # dont touch module/partition should supply module name or partition name
# set_module_dont_touch {cortexa7core_0_3_3_1_1} true 
# # dont touch all cells, pins , net from/to input/output to/from registers
# set_dont_touch [get_io_path_pins] true 
# set_dont_touch [get_nets -of_objects [get_pins pcie_iip_device_inst/u_subsystem/u_phy/phy*/pma/*]] true
# 
# # if you want to fix timing at module1 and module2 , please setting by the two commands
# set_module_dont_touch top_module true 
# set_module_dont_touch {module1 module2} false 
# 
# # if you want to fix timing at hierarchical hier_path1 and hier_path2, please setting by the two commands:
# set_hier_path_dont_touch / true 
# set_hier_path_dont_touch {hier_path1 hier_path2} false 
# 

