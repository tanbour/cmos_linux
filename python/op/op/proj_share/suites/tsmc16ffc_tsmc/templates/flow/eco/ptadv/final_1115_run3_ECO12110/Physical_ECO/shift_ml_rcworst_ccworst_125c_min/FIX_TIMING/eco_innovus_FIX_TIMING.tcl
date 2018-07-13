setEcoMode -batchMode true
Error: can not find the inst.
set eco_pins [get_pins -hier {ECO_20171208_11/D}]
set term_names [get_attribute $eco_pins full_name]
ecoAddRepeater -cell BUFFD8BWP16P90CPDLVT -term $term_names -newNetName ECO_NET_FIX_SETUP_20171212_143710_PTECO_SETUP_NET1  -name ECO_INST_FIX_SETUP_20171212_143710_PTECO_SETUP_BUF1 -loc {4323.250 515.680}
ecoChangeCell -inst u_pcie_top/u_dbPcie_ios_top/u_core/i_pcie_dma/i_crri_axi/g_arbursts_fifo_3__i_arbursts_fifo/place_opt_AINV_P_752471 -cell INVD2BWP20P90CPD
ecoChangeCell -inst u_pcie_top/u_dbPcie_ios_top/u_core/i_pcie_dma/i_crri_axi/g_arbursts_fifo_3__i_arbursts_fifo/place_opt_RLB__922751 -cell INVD3BWP16P90CPDULVT
ecoChangeCell -inst place_opt_AINV_P_458596 -cell INVD2BWP20P90CPDULVT
ecoChangeCell -inst u_pcie_top/u_dbPcie_ios_top/u_phy/U267 -cell ND2D0P75BWP20P90CPDULVT
ecoChangeCell -inst u_pcie_top/u_dbPcie_ios_top/u_phy/U6 -cell INVD2BWP20P90CPD
ecoChangeCell -inst u_pcie_top/u_dbPcie_ios_top/u_core/i_pcie_dma/i_udma\/i_ob_buff/place_opt_AINV_P_412992 -cell INVD2BWP20P90CPD
ecoChangeCell -inst place_opt_RLB__1002304 -cell INVD2BWP20P90CPDULVT
ecoChangeCell -inst u_pcie_top/u_dbPcie_ios_top/u_core/i_pcie_dma/i_udma\/gen_cdn_udma_chnl_3__i_cdn_udma_chnl\/i_cdn_udma_chnl_sys_ctrl\/i_cdn_udma_buffer_ctrl/place_opt_AINV_P_366110 -cell INVD6BWP20P90CPDULVT
ecoChangeCell -inst u_pcie_top/u_dbPcie_ios_top/u_core/i_axi_wrapper/place_opt_AINV_P_370686 -cell INVD3BWP16P90CPDULVT
ecoChangeCell -inst u_pcie_top/u_dbPcie_ios_top/u_core/i_axi_wrapper/clock_opt_RLB__1244828 -cell INVD10BWP20P90CPDULVT
ecoChangeCell -inst u_pcie_top/u_dbPcie_ios_top/u_core/i_axi_wrapper/clock_opt_RLB__1243653 -cell INVD16BWP16P90CPDULVT
ecoChangeCell -inst u_pcie_top/u_dbPcie_ios_top/u_core/i_axi_wrapper/place_opt_AINV_P_761919 -cell INVD16BWP20P90CPDULVT
