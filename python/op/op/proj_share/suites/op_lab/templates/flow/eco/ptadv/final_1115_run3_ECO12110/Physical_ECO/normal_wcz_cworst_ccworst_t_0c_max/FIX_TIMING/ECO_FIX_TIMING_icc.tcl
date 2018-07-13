###############################################################################
# Change list, formatted for IC Compiler
#
# 
#
###############################################################################
current_instance
add_buffer_on_route [get_net -of {u_pcie_top/u_dbPcie_ios_top/u_core/i_axi_wrapper/place_opt_AINV_P_761919/ZN}] -user_specified_buffers { ECO_INST_FIX_SETUP_20171212_143710_PTECO_SETUP_BUF1 BUFFD8BWP16P90CPDLVT 4323.250 515.680 0} -no_legalize
set_cell_location -coordinates {4322.7100 515.7120} -orientation FS [get_cells ECO_INST_FIX_SETUP_20171212_143710_PTECO_SETUP_BUF1 -hier]
current_instance
current_instance {u_pcie_top/u_dbPcie_ios_top/u_core/i_pcie_dma/i_crri_axi/g_arbursts_fifo_3__i_arbursts_fifo}
size_cell {place_opt_AINV_P_752471} {INVD2BWP20P90CPD}
set_cell_location -coordinates {4066.0300 421.2480} -orientation FS [get_cells place_opt_AINV_P_752471]
size_cell {place_opt_RLB__922751} {INVD3BWP16P90CPDULVT}
set_cell_location -coordinates {4228.5700 220.8000} -orientation FS [get_cells place_opt_RLB__922751]
current_instance
size_cell {place_opt_AINV_P_458596} {INVD2BWP20P90CPDULVT}
set_cell_location -coordinates {4561.3000 236.9280} -orientation FS [get_cells place_opt_AINV_P_458596]
current_instance
current_instance {u_pcie_top/u_dbPcie_ios_top/u_phy}
size_cell {U267} {ND2D0P75BWP20P90CPDULVT}
set_cell_location -coordinates {3685.9600 595.7760} -orientation N [get_cells U267]
size_cell {U6} {INVD2BWP20P90CPD}
set_cell_location -coordinates {3681.4600 592.3200} -orientation N [get_cells U6]
current_instance
current_instance {u_pcie_top/u_dbPcie_ios_top/u_core/i_pcie_dma/i_udma\/i_ob_buff}
size_cell {place_opt_AINV_P_412992} {INVD2BWP20P90CPD}
set_cell_location -coordinates {3753.9100 374.0160} -orientation FS [get_cells place_opt_AINV_P_412992]
current_instance
size_cell {place_opt_RLB__1002304} {INVD2BWP20P90CPDULVT}
set_cell_location -coordinates {3834.8200 386.6880} -orientation FS [get_cells place_opt_RLB__1002304]
current_instance
current_instance {u_pcie_top/u_dbPcie_ios_top/u_core/i_pcie_dma/i_udma\/gen_cdn_udma_chnl_3__i_cdn_udma_chnl\/i_cdn_udma_chnl_sys_ctrl\/i_cdn_udma_buffer_ctrl}
size_cell {place_opt_AINV_P_366110} {INVD6BWP20P90CPDULVT}
set_cell_location -coordinates {3682.9900 278.4000} -orientation FS [get_cells place_opt_AINV_P_366110]
current_instance
current_instance {u_pcie_top/u_dbPcie_ios_top/u_core/i_axi_wrapper}
size_cell {place_opt_AINV_P_370686} {INVD3BWP16P90CPDULVT}
set_cell_location -coordinates {4791.4300 527.8080} -orientation N [get_cells place_opt_AINV_P_370686]
size_cell {clock_opt_RLB__1244828} {INVD10BWP20P90CPDULVT}
set_cell_location -coordinates {4664.0800 523.2000} -orientation N [get_cells clock_opt_RLB__1244828]
size_cell {clock_opt_RLB__1243653} {INVD16BWP16P90CPDULVT}
set_cell_location -coordinates {4347.1000 520.8960} -orientation N [get_cells clock_opt_RLB__1243653]
size_cell {place_opt_AINV_P_761919} {INVD16BWP20P90CPDULVT}
set_cell_location -coordinates {4031.6500 514.5600} -orientation FS [get_cells place_opt_AINV_P_761919]
current_instance
