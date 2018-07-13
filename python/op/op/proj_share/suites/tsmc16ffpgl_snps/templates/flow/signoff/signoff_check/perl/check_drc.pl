#!/usr/bin/perl

$file = $ARGV[0] ;

$max_transition_relax  = 0.000 ;
$max_capacitance_relax = 0.000 ;

$max_transition_range_max_limit  = 0.500 ;
$max_transition_range_step       = 0.050 ;
$max_capacitance_range_max_limit = 0.100 ;
$max_capacitance_range_step      = 0.010 ;

@ignore_pin_list = qw(
AD0_IN[0]
AD0_IN[10]
AD0_IN[11]
AD0_IN[1]
AD0_IN[2]
AD0_IN[3]
AD0_IN[4]
AD0_IN[5]
AD0_IN[6]
AD0_IN[7]
AD0_IN[8]
AD0_IN[9]
AD1_IN[0]
AD1_IN[1]
AD1_IN[2]
AD1_IN[3]
AD1_IN[4]
AD1_IN[5]
AD1_IN[6]
AD2_IN[0]
AD2_IN[1]
AD2_IN[2]
AD2_IN[3]
DAC/dac1/COMP
DAC/dac1/IO
DAC/dac1/IOB
DA_COMP
DA_IO
DA_IOB
DA_IREF
DA_VREF
ISRX/U_cdnsmustangrx_r100_ss28lpp/rx_atb_out
ISRX/U_cdnsmustangrx_r100_ss28lpp/rx_rcalib
ISRX_RCALIB
PHY_USB/usb3_pipe_sspx1_hspx1/pads/DM0
PHY_USB/usb3_pipe_sspx1_hspx1/phy/DM0

PHY_USB/usb3_pipe_sspx1_hspx1/pads/REFALTCLKP
PHY_USB/usb3_pipe_sspx1_hspx1/phy/REFALTCLKP

PHY_USB/usb3_pipe_sspx1_hspx1/phy/ATBFP

PHY_USB/usb3_pipe_sspx1_hspx1/pads/DM0
PHY_USB/usb3_pipe_sspx1_hspx1/phy/DM0

PHY_USB/usb3_pipe_sspx1_hspx1/pads/DP0
PHY_USB/usb3_pipe_sspx1_hspx1/phy/DP0

USB_REXT
PHY_USB/usb3_pipe_sspx1_hspx1/phy/RKELVIN
PHY_USB/usb3_pipe_sspx1_hspx1/phy/TXRTUNE
PHY_USB/usb3_pipe_sspx1_hspx1/pads/RESREF
PHY_USB/usb3_pipe_sspx1_hspx1/phy/RESREFF
PHY_USB/usb3_pipe_sspx1_hspx1/phy/RKELVIN
PHY_USB/usb3_pipe_sspx1_hspx1/phy/TXRTUNE

PHY_USB/usb3_pipe_sspx1_hspx1/phy/RKELVIN
PHY_USB/usb3_pipe_sspx1_hspx1/phy/TXRTUNE

USB_VBUS
PHY_USB/usb3_pipe_sspx1_hspx1/pads/VBUS0
PHY_USB/usb3_pipe_sspx1_hspx1/phy/VBUS0

PN_DA_IO/AY
PN_MCKI/PADO
USB_DM
USB_DP
USB_REXT
USB_VBUS

PHY_USB/usb3_pipe_sspx1_hspx1/pads/ID0
PHY_USB/usb3_pipe_sspx1_hspx1/phy/ID0

PHY_USB/usb3_pipe_sspx1_hspx1/pads/REFPADCLKM
PHY_USB/usb3_pipe_sspx1_hspx1/pads/REFPADCLKINTM
PHY_USB/usb3_pipe_sspx1_hspx1/phy/REFPADCLKM

PHY_USB/usb3_pipe_sspx1_hspx1/pads/REFPADCLKP
PHY_USB/usb3_pipe_sspx1_hspx1/pads/REFPADCLKINTP
PHY_USB/usb3_pipe_sspx1_hspx1/phy/REFPADCLKP

PHY_USB/usb3_pipe_sspx1_hspx1/pads/XI
PHY_USB/usb3_pipe_sspx1_hspx1/phy/XI

PHY_USB/usb3_pipe_sspx1_hspx1/pads/XO
PHY_USB/usb3_pipe_sspx1_hspx1/phy/XO

PHY_USB/usb3_pipe_sspx1_hspx1/pads/HALFVPH
PHY_USB/usb3_pipe_sspx1_hspx1/phy/HALFVPH

PHY_USB/usb3_pipe_sspx1_hspx1/pads/REFALTCLKM
PHY_USB/usb3_pipe_sspx1_hspx1/phy/REFALTCLKM

USB_TX0P
PHY_USB/usb3_pipe_sspx1_hspx1/phy/TX0P
PHY_USB/usb3_pipe_sspx1_hspx1/pads/TX0P

USB_TX0M
PHY_USB/usb3_pipe_sspx1_hspx1/phy/TX0M
PHY_USB/usb3_pipe_sspx1_hspx1/pads/TX0M

PHY_USB/usb3_pipe_sspx1_hspx1/phy/HALFVPH
PHY_USB/usb3_pipe_sspx1_hspx1/pads/HALFVPH

PHY_USB/usb3_pipe_sspx1_hspx1/phy/EXTREFCLK
PHY_USB/usb3_pipe_sspx1_hspx1/phy/PHYRESET

USB_RX0P
PHY_USB/usb3_pipe_sspx1_hspx1/phy/RX0P

USB_RX0M
PHY_USB/usb3_pipe_sspx1_hspx1/phy/RX0M

HDMI_TX/hdmi20_tx_integ/u_hdmi_txphy_28nm_2nd_gen/sns
HDMI_TX/hdmi20_tx_integ/u_hdmi_txphy_28nm_2nd_gen/sns
HDMI_TX/hdmi20_tx_integ/u_hdmi_txphy_28nm_2nd_gen/rto
HDMI_TX/hdmi20_tx_integ/u_hdmi_txphy_28nm_2nd_gen/rto

HDMI_TX/hdmi20_tx_integ/u_hdmi_txphy_28nm_2nd_gen/ref_clkp
HDMI_TX/hdmi20_tx_integ/u_hdmi_txphy_28nm_2nd_gen/ref_clkp
HDMI_TX/hdmi20_tx_integ/u_hdmi_txphy_28nm_2nd_gen/ref_clkn
HDMI_TX/hdmi20_tx_integ/u_hdmi_txphy_28nm_2nd_gen/ref_clkn

PHY_USB/usb3_pipe_sspx1_hspx1/fix_signal_0619_net_35076__cell_prefix_1074_eco_net_412_YY_eco_ISO_PD_TOP_nz0628_54/Y

PN_MCKI/PADO

DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/tx_atb_out
DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/txclkn
DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/txclkp
DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/txdn0
DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/txdn1
DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/txdn2
DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/txdn3
DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/txdp0
DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/txdp1
DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/txdp2
DITX/dsi_mustang_is/i_cdnsmustangtx_r100_ss28lpp/txdp3

EFUSE_FSOURCE_BIRA_PART0
EFUSE_FSOURCE_BIRA_PART1
EFUSE_FSOURCE_ECID_K5Q_CUSTOMER
) ;

$block_by_instance{"ADU"} = "ADU" ;
$block_by_instance{"APU01"} = "APU01" ;
$block_by_instance{"CDU_A0"} = "CDU_A" ;
$block_by_instance{"CDU_A1"} = "CDU_A" ;
$block_by_instance{"CDU_MEM0"} = "CDU_MEM" ;
$block_by_instance{"CDU_MEM1"} = "CDU_MEM" ;
$block_by_instance{"CDU_S0"} = "CDU_S" ;
$block_by_instance{"CDU_S1"} = "CDU_S" ;
$block_by_instance{"DCIO_0/c34a_wrap"} = "dcio_lpddr34_ca_wrapper_h" ;
$block_by_instance{"DCIO_0/p34/phy"} = "dft_top_wrapper" ;
$block_by_instance{"DCIO_1/c4a_wrap"} = "dcio_lpddr4_ca_wrapper_h" ;
$block_by_instance{"DCIO_1/p4/phy"}  = "dft_top_wrapper_lp4" ;
$block_by_instance{"DCIO_2/c34a_wrap"} = "dcio_lpddr34_ca_wrapper_v" ;
$block_by_instance{"DCIO_2/p34/phy"} = "dft_top_wrapper" ;
$block_by_instance{"DCIO_3/c4a_wrap"} = "dcio_lpddr4_ca_wrapper_v" ;
$block_by_instance{"DCIO_3/p4/phy"}  = "dft_top_wrapper_lp4" ;
$block_by_instance{"DITX"} = "DITX" ;
$block_by_instance{"FRU_PD14"} = "FRU_PD14" ;
$block_by_instance{"FRU_PD15"} = "FRU_PD15" ;
$block_by_instance{"FRU_PD16"} = "FRU_PD16" ;
$block_by_instance{"FRU_PD17"} = "FRU_PD17" ;
$block_by_instance{"FRU_PD18"} = "FRU_PD18" ;
$block_by_instance{"FRU_PD19"} = "FRU_PD19" ;
$block_by_instance{"GAIA"} = "GAIA" ;
$block_by_instance{"GEVG"} = "GEVG" ;
$block_by_instance{"HDMI_TX"} = "HDMI_TX" ;
$block_by_instance{"IPU"} = "IPU" ;
$block_by_instance{"ISRX/U_LINK_TOP"} = "LINK_TOP" ;
$block_by_instance{"JPU"} = "JPU" ;
$block_by_instance{"LCU"} = "LCU" ;
$block_by_instance{"MCU/NoC_Top/i_Mem_Int_Arc_St/m_PD01"} = "Mem_Int_Arc_St_m_PD01" ;
$block_by_instance{"MCU/NoC_Top/i_Mem_Int_Arc_St/m_PD06"} = "Mem_Int_Arc_St_m_PD06" ;
$block_by_instance{"MCU/NoC_Top/i_Mem_Int_Arc_St/m_PD30"} = "Mem_Int_Arc_St_m_PD30" ;
$block_by_instance{"MCU/NoC_Top/i_Mem_Int_Arc_St/m_PD_DEF01_600/NIUs_To_Scheduler"} = "Mem_Int_Arc_St_m_PD_DEF01_600_NIUs_To_Scheduler" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_A10"} = "S_MainNoC_Arc_St_m_PD_A10" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_A35"} = "S_MainNoC_Arc_St_m_PD_A35" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_A36"} = "S_MainNoC_Arc_St_m_PD_A36" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_A39"} = "S_MainNoC_Arc_St_m_PD_A39" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_B12"} = "S_MainNoC_Arc_St_m_PD_B12" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_B13"} = "S_MainNoC_Arc_St_m_PD_B13" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_C17"} = "S_MainNoC_Arc_St_m_PD_C17" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_C18"} = "S_MainNoC_Arc_St_m_PD_C18" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_C19"} = "S_MainNoC_Arc_St_m_PD_C19" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_D14"} = "S_MainNoC_Arc_St_m_PD_D14" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_D15"} = "S_MainNoC_Arc_St_m_PD_D15" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_D16"} = "S_MainNoC_Arc_St_m_PD_D16" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF00/NIUs_ODU0"} = "S_MainNoC_Arc_St_m_PD_DEF00_NIUs_ODU0" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF00/NIUs_PCIe_reg"} = "S_MainNoC_Arc_St_m_PD_DEF00_NIUs_PCIe_reg" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF01/NIUs_To_ReorderBuffer/NIU_to_DRAM_0"} = "S_MainNoC_Arc_St_m_PD_DEF01_NIUs_To_ReorderBuffer_NIU_to_DRAM_0" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF01/NIUs_To_ReorderBuffer/NIU_to_DRAM_1"} = "S_MainNoC_Arc_St_m_PD_DEF01_NIUs_To_ReorderBuffer_NIU_to_DRAM_1" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF01/NIUs_To_ReorderBuffer/NIU_to_DRAM_4"} = "S_MainNoC_Arc_St_m_PD_DEF01_NIUs_To_ReorderBuffer_NIU_to_DRAM_4" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF01/NIUs_To_ReorderBuffer/NIU_to_DRAM_5"} = "S_MainNoC_Arc_St_m_PD_DEF01_NIUs_To_ReorderBuffer_NIU_to_DRAM_5" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF01/NIUs_To_ReorderBuffer/NIU_to_DRAM_6"} = "S_MainNoC_Arc_St_m_PD_DEF01_NIUs_To_ReorderBuffer_NIU_to_DRAM_6" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF02/NIUs_GEVG"} = "S_MainNoC_Arc_St_m_PD_DEF02_NIUs_GEVG" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF06/NIUs_ADU"} = "S_MainNoC_Arc_St_m_PD_DEF06_NIUs_ADU" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF06/NIUs_JPU"} = "S_MainNoC_Arc_St_m_PD_DEF06_NIUs_JPU" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF06/NIUs_STU_ETH"} = "S_MainNoC_Arc_St_m_PD_DEF06_NIUs_STU_ETH" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF06/NIUs_STU_SD2"} = "S_MainNoC_Arc_St_m_PD_DEF06_NIUs_STU_SD2" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF07/NIUs_STU_SD0"} = "S_MainNoC_Arc_St_m_PD_DEF07_NIUs_STU_SD0" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF07/NIUs_STU_SD1"} = "S_MainNoC_Arc_St_m_PD_DEF07_NIUs_STU_SD1" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF07/NIUs_STU_other_mas"} = "S_MainNoC_Arc_St_m_PD_DEF07_NIUs_STU_other_mas" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF07/NIUs_STU_other_slv"} = "S_MainNoC_Arc_St_m_PD_DEF07_NIUs_STU_other_slv" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF08/NIUs_MIU_mas"} = "S_MainNoC_Arc_St_m_PD_DEF08_NIUs_MIU_mas" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF08/NIUs_MIU_slv"} = "S_MainNoC_Arc_St_m_PD_DEF08_NIUs_MIU_slv" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF08/NIUs_VOU_monm_pro"} = "S_MainNoC_Arc_St_m_PD_DEF08_NIUs_VOU_monm_pro" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF08/NIUs_VOU_mont"} = "S_MainNoC_Arc_St_m_PD_DEF08_NIUs_VOU_mont" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF08/NIUs_VOU_other_mas"} = "S_MainNoC_Arc_St_m_PD_DEF08_NIUs_VOU_other_mas" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF08/NIUs_VOU_other_slv"} = "S_MainNoC_Arc_St_m_PD_DEF08_NIUs_VOU_other_slv" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF08/NIUs_VOU_sub_mont"} = "S_MainNoC_Arc_St_m_PD_DEF08_NIUs_VOU_sub_mont" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_DEF09/NIUs_TCC"} = "S_MainNoC_Arc_St_m_PD_DEF09_NIUs_TCC" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_F21"} = "S_MainNoC_Arc_St_m_PD_F21" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_F22"} = "S_MainNoC_Arc_St_m_PD_F22" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_F23_0"} = "S_MainNoC_Arc_St_m_PD_F23_0" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_F23_1"} = "S_MainNoC_Arc_St_m_PD_F23_1" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_F24_f32"} = "S_MainNoC_Arc_St_m_PD_F24_f32" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_F24_f4"} = "S_MainNoC_Arc_St_m_PD_F24_f4" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_F24_uec"} = "S_MainNoC_Arc_St_m_PD_F24_uec" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_F24_ume"} = "S_MainNoC_Arc_St_m_PD_F24_ume" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_F24_usc"} = "S_MainNoC_Arc_St_m_PD_F24_usc" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_H20"} = "S_MainNoC_Arc_St_m_PD_H20" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_J07"} = "S_MainNoC_Arc_St_m_PD_J07" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_L33"} = "S_MainNoC_Arc_St_m_PD_L33" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_L34"} = "S_MainNoC_Arc_St_m_PD_L34" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_U08_0"} = "S_MainNoC_Arc_St_m_PD_U08_0" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_V28"} = "S_MainNoC_Arc_St_m_PD_V28" ;
$block_by_instance{"MCU/NoC_Top/i_S_MainNoC_Arc_St/m_PD_V29"} = "S_MainNoC_Arc_St_m_PD_V29" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_B12"} = "S_PeriNoC_Arc_St_m_PD_B12" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_B13"} = "S_PeriNoC_Arc_St_m_PD_B13" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_C14"} = "S_PeriNoC_Arc_St_m_PD_C14" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_C15"} = "S_PeriNoC_Arc_St_m_PD_C15" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_C16"} = "S_PeriNoC_Arc_St_m_PD_C16" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_C17"} = "S_PeriNoC_Arc_St_m_PD_C17" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_C19"} = "S_PeriNoC_Arc_St_m_PD_C19" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF00/NIU_ISRX"} = "S_PeriNoC_Arc_St_m_PD_DEF00_NIU_ISRX" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF00/NIUs_ODU0"} = "S_PeriNoC_Arc_St_m_PD_DEF00_NIUs_ODU0" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF00/NIUs_PCIe_reg"} = "S_PeriNoC_Arc_St_m_PD_DEF00_NIUs_PCIe_reg" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF01/NIUs_DCIO_0"} = "S_PeriNoC_Arc_St_m_PD_DEF01_NIUs_DCIO_0" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF02/NIUs_GEVG"} = "S_PeriNoC_Arc_St_m_PD_DEF02_NIUs_GEVG" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF03/NIUs_MCU"} = "S_PeriNoC_Arc_St_m_PD_DEF03_NIUs_MCU" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF05/NIUs_PCIe_reg"} = "S_PeriNoC_Arc_St_m_PD_DEF05_NIUs_PCIe_reg" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF06/NIUs_ADU"} = "S_PeriNoC_Arc_St_m_PD_DEF06_NIUs_ADU" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF06/NIUs_DITX"} = "S_PeriNoC_Arc_St_m_PD_DEF06_NIUs_DITX" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF06/NIUs_JPU"} = "S_PeriNoC_Arc_St_m_PD_DEF06_NIUs_JPU" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF06/NIUs_LCU"} = "S_PeriNoC_Arc_St_m_PD_DEF06_NIUs_LCU" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF06/NIUs_STU_ETH"} = "S_PeriNoC_Arc_St_m_PD_DEF06_NIUs_STU_ETH" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF06/NIUs_STU_SD2"} = "S_PeriNoC_Arc_St_m_PD_DEF06_NIUs_STU_SD2" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF07/NIUs_HDMI"} = "S_PeriNoC_Arc_St_m_PD_DEF07_NIUs_HDMI" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF07/NIUs_STU_SD0"} = "S_PeriNoC_Arc_St_m_PD_DEF07_NIUs_STU_SD0" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF07/NIUs_STU_SD1"} = "S_PeriNoC_Arc_St_m_PD_DEF07_NIUs_STU_SD1" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF07/NIUs_STU_other_slv"} = "S_PeriNoC_Arc_St_m_PD_DEF07_NIUs_STU_other_slv" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF08/NIUs_MIU_slv"} = "S_PeriNoC_Arc_St_m_PD_DEF08_NIUs_MIU_slv" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF08/NIUs_MIU_slv_APB_I4"} = "S_PeriNoC_Arc_St_m_PD_DEF08_NIUs_MIU_slv_APB_I4" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF08/NIUs_MIU_slv_APB_I9"} = "S_PeriNoC_Arc_St_m_PD_DEF08_NIUs_MIU_slv_APB_I9" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF08/NIUs_PMU"} = "S_PeriNoC_Arc_St_m_PD_DEF08_NIUs_PMU" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF08/NIUs_SSG"} = "S_PeriNoC_Arc_St_m_PD_DEF08_NIUs_SSG" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF09/NIUs_TCC"} = "S_PeriNoC_Arc_St_m_PD_DEF09_NIUs_TCC" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_DEF11/NIUs_CKG"} = "S_PeriNoC_Arc_St_m_PD_DEF11_NIUs_CKG" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_H20"} = "S_PeriNoC_Arc_St_m_PD_H20" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_J07"} = "S_PeriNoC_Arc_St_m_PD_J07" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_L33"} = "S_PeriNoC_Arc_St_m_PD_L33" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_L34"} = "S_PeriNoC_Arc_St_m_PD_L34" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_T01"} = "S_PeriNoC_Arc_St_m_PD_T01" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_T06"} = "S_PeriNoC_Arc_St_m_PD_T06" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_T30"} = "S_PeriNoC_Arc_St_m_PD_T30" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_U08_0"} = "S_PeriNoC_Arc_St_m_PD_U08_0" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_V28"} = "S_PeriNoC_Arc_St_m_PD_V28" ;
$block_by_instance{"MCU/NoC_Top/i_S_PeriNoC_Arc_St/m_PD_V29"} = "S_PeriNoC_Arc_St_m_PD_V29" ;
$block_by_instance{"MIU"} = "MIU" ;
$block_by_instance{"MIU/HCPU/HARM/CA7"} = "k5q" ;
$block_by_instance{"ODU0"} = "ODU" ;
$block_by_instance{"ODU1"} = "ODU" ;
$block_by_instance{"PCIE0"} = "PCIE0" ;
$block_by_instance{"PCIE1"} = "PCIE1" ;
$block_by_instance{"PMU"} = "PMU" ;
$block_by_instance{"PPU"} = "PPU_WRAP" ;
$block_by_instance{"SIU"} = "SIU" ;
$block_by_instance{"STU/ETH"} = "ETH" ;
$block_by_instance{"STU/MEMIO"} = "MEMIO" ;
$block_by_instance{"STU/SD0TOP"} = "SD0TOP" ;
$block_by_instance{"STU/SD1TOP"} = "SD1TOP" ;
$block_by_instance{"STU/SD2TOP"} = "SD2TOP" ;
$block_by_instance{"STU/USB"} = "USB" ;
$block_by_instance{"TCC"} = "TCC" ;
$block_by_instance{"VOU"} = "VOU_WRAP" ;
$block_by_instance{"YCU_AM"} = "YCU_AM" ;
$block_by_instance{"YCU_BS"} = "YCU_BS" ;

if( $file =~ /max_transition/ ) {
  $is_max_transition = 1 ;
  $is_max_capacitance = 0 ;
}
if( $file =~ /max_capacitance/ ) {
  $is_max_transition = 0 ;
  $is_max_capacitance = 1 ;
}
while( <> ) {
  if( /^   max_transition/ ) {
    $is_max_transition = 1 ;
    $is_max_capacitance = 0 ;
    print ;
  }

  if( $is_max_transition == 1 ) {
    if( /^\s*(\S+)\s+(-\d+\.*\d*)\s*$/ ) {
       s/^\s*(\S+)\s+(-\d+\.*\d*)\s*$/ \1 0.000 0.000 \2 \(VIOLATED\)\n/ ;
    }
    if( /^\s+(\S+)\s+(\d+\.*\d*)\s+(\d+\.*\d*)\s+(-*\d+\.*\d*)\s+\(VIOLATED.*\)/ ) {
      ( $pin, $required, $actual, $slack ) =
        /^\s+(\S+)\s+(\d+\.*\d*)\s+(\d+\.*\d*)\s+(-*\d+\.*\d*)\s+\(VIOLATED.*\)/ ;
      $flag = 1 ;
      $flag = 0 if( $pin =~ /^[^\/]+$/ ) ;
      $flag = 0 if( $pin =~ /\/PAD$/ ) ;
      $flag = 0 if( $pin =~ /\/PADP$/ ) ;
      $flag = 0 if( $pin =~ /\/PADN$/ ) ;
      $flag = 0 if( $pin =~ /\/CK$/ ) ;
      $flag = 0 if( $pin =~ /^GPIO\d+$/ ) ;
      $flag = 0 if( $pin =~ /^MIU\/HCPU\/HARM\/CA7\// ) ;
      $flag = 0 if( $pin =~ /ISO_PD_\w+\/EN$/ ) ;
      $flag = 0 if( $pin =~ /^DCIO_0\/p34\/phy\// ) ;
      $flag = 0 if( $pin =~ /^DCIO_1\/p4\/phy\// ) ;
      $flag = 0 if( $pin =~ /^DCIO_2\/p34\/phy\// ) ;
      $flag = 0 if( $pin =~ /^DCIO_3\/p4\/phy\// ) ;
      foreach $ignore_pin ( @ignore_pin_list ) {
        $flag = 0 if( $pin eq $ignore_pin ) ;
      }
      $flag = 0 if( $is_checked{"$pin"} == 1 ) ;
      $flag = 0 if( $slack + $max_transition_relax >= 0.000 ) ;
      if( $flag == 1 ) {
        $is_checked{"$pin"} = 1 ;
        $negative_slack = $slack * -1.000 ;
        for( $range_min = 0.000 ; $range_min + $max_transition_range_step <= $max_transition_range_max_limit ; $range_min = $range_min + $max_transition_range_step ) {
          $range_max = $range_min + $max_transition_range_step ;
          if( ( $negative_slack > $range_min ) && ( $negative_slack <= $range_max ) ) {
            $max_transition_violation_count_by_range{"$range_min:$range_max"}++ ;
          }
        }
        $range_min = $max_transition_range_max_limit ;
        $range_max = "" ;
        if( $negative_slack > $range_min ) {
          $max_transition_violation_count_by_range{"$range_min:$range_max"}++ ;
        }
        $max_transition_violation_count++ ;
        $max_transition_worst_slack = $slack if( $max_transition_worst_slack eq "" ) ;
        $max_transition_worst_slack = $slack if( $max_transition_worst_slack > $slack ) ;
        $max_transition_total_negative_slack = $max_transition_total_negative_slack + $slack * -1 ;
        print ;

        $is_top = 1 ;
        foreach $instance ( sort( keys( %block_by_instance ) ) ) {
         #next if( ( $instance eq "MIU" ) && ( $pin =~ /^MIU\/HCPU\/HARM\/CA7\// ) ) ;
          $instance_pattern = $instance ;
          $instance_pattern =~ s/\//\\\//g ;
          if( $pin =~ /^$instance_pattern\// ) {
            $block = $block_by_instance{"$instance"} ;
                 $max_transition_violation_count_by_block{"$block"}++ ;
                     $max_transition_worst_slack_by_block{"$block"} = $slack if( $max_transition_worst_slack_by_block{"$block"} eq "" ) ;
                     $max_transition_worst_slack_by_block{"$block"} = $slack if( $max_transition_worst_slack_by_block{"$block"} > $slack ) ;
            $max_transition_total_negative_slack_by_block{"$block"} = $max_transition_total_negative_slack_by_block{"$block"} - $slack ;
            $is_top = 0 ;
          }
        }
        if( $is_top == 1 ) {
               $max_transition_violation_count_by_block{"PS02"}++ if( $is_top == 1 ) ;
                   $max_transition_worst_slack_by_block{"PS02"} = $slack if( $max_transition_worst_slack_by_block{"PS02"} eq "" ) ;
                   $max_transition_worst_slack_by_block{"PS02"} = $slack if( $max_transition_worst_slack_by_block{"PS02"} > $slack ) ;
          $max_transition_total_negative_slack_by_block{"PS02"} = $max_transition_total_negative_slack_by_block{"PS02"} - $slack ;
        }
      }
    }
  }

  if( /^   max_capacitance/ ) {
    $is_max_transition = 0 ;
    $is_max_capacitance = 1 ;
    print ;
  }

  if( $is_max_capacitance == 1 ) {
    if( /^\s*(\S+)\s+(-\d+\.*\d*)\s*$/ ) {
       s/^\s*(\S+)\s+(-\d+\.*\d*)\s*$/ \1 0.000 0.000 \2 \(VIOLATED\)\n/ ;
    }
    if( /^\s+(\S+)\s+(\d+\.*\d*)\s+(\d+\.*\d*)\s+(-*\d+\.*\d*)\s+\(VIOLATED.*\)/ ) {
      ( $pin, $required, $actual, $slack ) =
        /^\s+(\S+)\s+(\d+\.*\d*)\s+(\d+\.*\d*)\s+(-*\d+\.*\d*)\s+\(VIOLATED.*\)/ ;
      $flag = 1 ;
      $flag = 0 if( $pin =~ /\/PAD$/ ) ;
      $flag = 0 if( $pin =~ /\/PADP$/ ) ;
      $flag = 0 if( $pin =~ /\/PADN$/ ) ;
      $flag = 0 if( $pin =~ /\/AY$/ ) ;
      $flag = 0 if( $pin =~ /\/AY50$/ ) ;
      $flag = 0 if( $pin =~ /\/AY200$/ ) ;
      $flag = 0 if( $pin =~ /\/CK$/ ) ;
      $flag = 0 if( $pin =~ /\/RETEN_N_HV$/ ) ;
      $flag = 0 if( $pin =~ /\/RETEN_N_UB$/ ) ;
      $flag = 0 if( $pin =~ /\/TRIM_NPD_HV\[\d+\]$/ ) ;
      $flag = 0 if( $pin =~ /\/TRIM_NPU_HV\[\d+\]$/ ) ;
      $flag = 0 if( $pin =~ /\/TRIM_PPU_HV\[\d+\]$/ ) ;
      $flag = 0 if( $pin =~ /\/PADN$/ ) ;
      $flag = 0 if( $pin =~ /\/PADP$/ ) ;
      $flag = 0 if( $pin =~ /^DRAM[0-3]_DQSM\[[0-9]+\]$/ ) ;
      $flag = 0 if( $pin =~ /^DRAM[0-3]_DQSP\[[0-9]+\]$/ ) ;
      $flag = 0 if( $pin =~ /^DRAM[0-3]_DM\[[0-9]+\]$/ ) ;
      $flag = 0 if( $pin =~ /^DRAM[0-3]_DQ\[[0-9]+\]$/ ) ;
     #$flag = 0 if( $pin =~ /\/SLEEPOUT$/ ) ;
      foreach $ignore_pin ( @ignore_pin_list ) {
        $flag = 0 if( $pin eq $ignore_pin ) ;
      }
      $flag = 0 if( $slack + $max_capacitance_relax >= 0.000 ) ;
      if( $flag == 1 ) {
        $negative_slack = $slack * -1.000 ;
        for( $range_min = 0.000 ; $range_min + $max_capacitance_range_step <= $max_capacitance_range_max_limit ; $range_min = $range_min + $max_capacitance_range_step ) {
          $range_max = $range_min + $max_capacitance_range_step ;
          if( ( $negative_slack > $range_min ) && ( $negative_slack <= $range_max ) ) {
            $max_capacitance_violation_count_by_range{"$range_min:$range_max"}++ ;
          }
        }
        $range_min = $max_capacitance_range_max_limit ;
        $range_max = "" ;
        if( $negative_slack > $range_min ) {
          $max_capacitance_violation_count_by_range{"$range_min:$range_max"}++ ;
        }
        $max_capacitance_violation_count++ ;
        $max_capacitance_worst_slack = $slack if( $max_capacitance_worst_slack eq "" ) ;
        $max_capacitance_worst_slack = $slack if( $max_capacitance_worst_slack > $slack ) ;
        $max_capacitance_total_negative_slack = $max_capacitance_total_negative_slack + $slack * -1 ;
        print ;

        $is_top = 1 ;
        foreach $instance ( sort( keys( %block_by_instance ) ) ) {
          $instance_pattern = $instance ;
          $instance_pattern =~ s/\//\\\//g ;
          if( $pin =~ /^$instance_pattern\// ) {
            $block = $block_by_instance{"$instance"} ; 
                 $max_capacitance_violation_count_by_block{"$block"}++ ;
                     $max_capacitance_worst_slack_by_block{"$block"} = $slack if( $max_capacitance_worst_slack_by_block{"$block"} eq "" ) ;
                     $max_capacitance_worst_slack_by_block{"$block"} = $slack if( $max_capacitance_worst_slack_by_block{"$block"} > $slack ) ;
            $max_capacitance_total_negative_slack_by_block{"$block"} = $max_capacitance_total_negative_slack_by_block{"$block"} - $slack ;
            $is_top = 0 ;
          }
        }
        if( $is_top == 1 ) {
               $max_capacitance_violation_count_by_block{"PS02"}++ if( $is_top == 1 ) ;
                   $max_capacitance_worst_slack_by_block{"PS02"} = $slack if( $max_capacitance_worst_slack_by_block{"PS02"} eq "" ) ;
                   $max_capacitance_worst_slack_by_block{"PS02"} = $slack if( $max_capacitance_worst_slack_by_block{"PS02"} > $slack ) ;
          $max_capacitance_total_negative_slack_by_block{"PS02"} = $max_capacitance_total_negative_slack_by_block{"PS02"} - $slack ;
        }

      }
    }
  }
}
printf( "\n" ) ;

printf( "\n" ) ;

printf( "%s\n", $file ) ;
printf( "\n" ) ;

printf( "* max_transition slack distribution\n" ) ;
printf( "\n" ) ;
if( $max_transition_violation_count > 0 ) {
for( $range_min = 0.000 ; $range_min + $max_transition_range_step <= $max_transition_range_max_limit ; $range_min = $range_min + $max_transition_range_step ) {
  $range_max = $range_min + $max_transition_range_step ;
  printf( "%6.3f - %6.3f : %6d (%6.2f%%)\n", $range_min, $range_max, $max_transition_violation_count_by_range{"$range_min:$range_max"}, $max_transition_violation_count_by_range{"$range_min:$range_max"} / $max_transition_violation_count * 100 ) ;
}
$range_min = $max_transition_range_max_limit ; 
$range_max = "" ;
printf( "%6.3f - %6s : %6d (%6.2f%%)\n", $range_min, $range_max, $max_transition_violation_count_by_range{"$range_min:$range_max"}, $max_transition_violation_count_by_range{"$range_min:$range_max"} / $max_transition_violation_count * 100 ) ;
printf( "%6s   %6s : %6d (%6.2f%%)\n", "Total", "", $max_transition_violation_count, 100 ) ;
printf( "\n" ) ;
}
#printf( " Number of max transition violating pins : %d\n", $max_transition_violation_count ) ;
#printf( " Worst slack : %.3f\n", $max_transition_worst_slack ) ;
#printf( " Total negative slack : %.3f\n", $max_transition_total_negative_slack ) ;
printf( " Number of max_transition violating pins : %d, Worst slack : %.3f, Total negative slack : %.3f\n", $max_transition_violation_count, $max_transition_worst_slack, $max_transition_total_negative_slack ) ;
printf( "\n" ) ;

foreach $block ( sort( { $max_transition_total_negative_slack_by_block{"$b"} <=> $max_transition_total_negative_slack_by_block{"$a"} } keys( %max_transition_total_negative_slack_by_block ) ) ) { 
  if( $max_transition_total_negative_slack_by_block{"$block"} > 0 ) {
    printf( " %-70s : %5d, %6.3f, %6.3f\n", $block, $max_transition_total_negative_slack_by_block{"$block"}, $max_transition_worst_slack_by_block{"$block"}, $max_transition_total_negative_slack_by_block{"$block"} ) ;
  }
}
printf( "\n" ) ;

printf( "* max_capacitance on case analyzed pins slack distribution\n" ) ;
printf( "\n" ) ;
if( $max_capacitance_violation_count > 0 ) {
for( $range_min = 0.000 ; $range_min + $max_capacitance_range_step <= $max_capacitance_range_max_limit ; $range_min = $range_min + $max_capacitance_range_step ) {
  $range_max = $range_min + $max_capacitance_range_step ;
  printf( "%6.3f - %6.3f : %6d (%6.2f%%)\n", $range_min, $range_max, $max_capacitance_violation_count_by_range{"$range_min:$range_max"}, $max_capacitance_violation_count_by_range{"$range_min:$range_max"} / $max_capacitance_violation_count * 100 ) ;
}
$range_min = $max_capacitance_range_max_limit ;
$range_max = "" ;
printf( "%6.3f - %6s : %6d (%6.2f%%)\n", $range_min, $range_max, $max_capacitance_violation_count_by_range{"$range_min:$range_max"}, $max_capacitance_violation_count_by_range{"$range_min:$range_max"} / $max_capacitance_violation_count * 100 ) ;
printf( "%6s   %6s : %6d (%6.2f%%)\n", "Total", "", $max_capacitance_violation_count, 100 ) ;
printf( "\n" ) ;
}
#printf( " Number of max capacitance violating pins : %d\n", $max_capacitance_violation_count ) ;
#printf( " Worst slack : %.3f\n", $max_capacitance_worst_slack ) ;
#printf( " Total negative slack : %.3f\n", $max_capacitance_total_negative_slack ) ;
printf( " Number of max_capacitance violating pins : %d, Worst slack : %.3f, Total negative slack : %.3f\n", $max_capacitance_violation_count, $max_capacitance_worst_slack, $max_capacitance_total_negative_slack ) ;
printf( "\n" ) ;

foreach $block ( sort( { $max_capacitance_total_negative_slack_by_block{"$b"} <=> $max_capacitance_violation_count_by_block{"$a"} } keys( %max_capacitance_violation_count_by_block ) ) ) { 
  if( $max_capacitance_total_negative_slack_by_block{"$block"} > 0 ) {
    printf( " %-70s : %5d, %6.3f, %6.3f\n", $block, $max_capacitance_total_negative_slack_by_block{"$block"}, $max_capacitance_worst_slack_by_block{"$block"}, $max_capacitance_total_negative_slack_by_block{"$block"} ) ;
  }
}
printf( "\n" ) ;

