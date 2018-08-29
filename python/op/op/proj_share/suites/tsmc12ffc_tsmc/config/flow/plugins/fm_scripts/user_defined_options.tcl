######################################################################################################################
# case/dont_verify and other setting
######################################################################################################################
# set_constant i:/WORK/${TOP_i}/pmu_wk_iso_en 0
# set_constant i:/WORK/${TOP_i}/LV_TM 0
# set_constant i:/WORK/${TOP_i}/mbist_mode 0
# set_constant i:/WORK/${TOP_i}/ALCP_BYPASS_MODE 0
# set_constant i:/WORK/${TOP_i}/scan_mode 0
# set_constant i:/WORK/${TOP_i}/scanen 0
# set_constant i:/WORK/${TOP_i}/TPI_MODE 0

# set_constant i:/WORK/${TOP_r}/pmu_wk_iso_en 0
# set_constant i:/WORK/${TOP_r}/LV_TM 0
# set_constant i:/WORK/${TOP_r}/mbist_mode 0
# set_constant i:/WORK/${TOP_r}/ALCP_BYPASS_MODE 0
# set_constant i:/WORK/${TOP_r}/scan_mode 0
# set_constant i:/WORK/${TOP_r}/scanen 0
# set_constant i:/WORK/${TOP_r}/TPI_MODE 0

# set_dont_verify i:/WORK/${TOP_i}/wk_pmu_pwr_stable
# set_dont_verify i:/WORK/${TOP_i}/x_eth_wrap/x_xpcs_pma/x_e12mp_phy/pma/gd 
# set_dont_verify i:/WORK/${TOP_i}/x_eth_wrap/x_xpcs_pma/x_e12mp_phy/pma_pads/gd 
# set_dont_verify i:/WORK/${TOP_i}/x_eth_wrap/x_xpcs_pma/x_e12mp_phy/pma/vp 
# set_dont_verify i:/WORK/${TOP_i}/x_eth_wrap/x_xpcs_pma/x_e12mp_phy/pma_pads/vp 

# set_dont_verify r:/WORK/${TOP_r}/wk_pmu_pwr_stable
# set_dont_verify r:/WORK/${TOP_r}/x_eth_wrap/x_xpcs_pma/x_e12mp_phy/pma/gd 
# set_dont_verify r:/WORK/${TOP_r}/x_eth_wrap/x_xpcs_pma/x_e12mp_phy/pma_pads/gd 
# set_dont_verify r:/WORK/${TOP_r}/x_eth_wrap/x_xpcs_pma/x_e12mp_phy/pma/vp 
# set_dont_verify r:/WORK/${TOP_r}/x_eth_wrap/x_xpcs_pma/x_e12mp_phy/pma_pads/vp 

######################################################################################################################
#clock gating setting
######################################################################################################################

# set verification_clock_gate_hold_mode             low	
# set verification_assume_reg_init                  liberal1                                                                                                
# set verification_merge_duplicated_registers       true

