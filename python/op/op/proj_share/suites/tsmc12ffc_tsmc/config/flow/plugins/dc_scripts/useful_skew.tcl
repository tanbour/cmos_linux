##===================================================================
##=================== usefull skew ==================================
##===================================================================
#set pre_cts_clock_latency_estimate 0.0
#
## ICG EN
#set all_icgs [get_flat_cells -filter "ref_name =~ CKLN*"]
#set tool_icg [get_flat_cells -quiet -filter "ref_name =~ CKLN* && full_name=~*clk_gate*"]
#set sram_icg [filter_collection $all_icgs "full_name =~ *sram*"]
#set arch_icg [remove_from_collection [remove_from_collection $all_icgs $tool_icg] $sram_icg]
#
#set first_arch_icg [get_cells [list \
#  uck_cpu/ucpu_main/uck_gclkcx/uIcg \
#  uck_cpu/ucpu_main/uck_gclkcr/uIcg \
#]]
#
#set second_arch_icg [remove_from_collection $arch_icg $first_arch_icg]
#
#set_clock_latency [expr $pre_cts_clock_latency_estimate - 0.02] [get_pins -of_object $sram_icg -filter "name == CP"]
#set_clock_latency $pre_cts_clock_latency_estimate [get_pins -of_object $sram_icg -filter "name == Q"]
#
#if {[sizeof $tool_icg] > 0} {
#  set_clock_latency [expr $pre_cts_clock_latency_estimate - 0.02] [get_pins -of_object $tool_icg -filter "name == CP"]
#  set_clock_latency $pre_cts_clock_latency_estimate [get_pins -of_object $tool_icg -filter "name == Q"]
#}
#
#set_clock_latency [expr $pre_cts_clock_latency_estimate - 0.10] [get_pins -of_object $second_arch_icg -filter "name == CP"]
#set_clock_latency $pre_cts_clock_latency_estimate [get_pins -of_object $second_arch_icg -filter "name == Q"]
#
#set_clock_latency [expr $pre_cts_clock_latency_estimate - 0.20] [get_pins -of_object $first_arch_icg -filter "name == CP"]
#set_clock_latency $pre_cts_clock_latency_estimate [get_pins -of_object $first_arch_icg -filter "name == Q"]
#
#
##===================================================================
##=================== dont use setting ==============================
##===================================================================
##$# --> ## ----------------------------------------------------------------------------------
##$# --> ## For first-level Arch ICG enable timing
##$# --> ## ----------------------------------------------------------------------------------
##$# --> set_clock_latency -0.25 [get_pins uck_cpu/ucpu_reset/ck_frc_cr_clk_en_q_reg/CP ]
##$# --> set_clock_latency -0.25 [get_pins uck_cpu/ucpu_reset/ck_reset_n_reg_7_/CP]
##$# --> set_clock_latency -0.25 [get_pins uck_cpu/ucpu_reset/ck_vfu_rst_clk_en_reg/CP]
##$# --> 
##$# --> ## ----------------------------------------------------------------------------------
##$# --> ## reduce TNS for udec/urename
##$# --> ## ----------------------------------------------------------------------------------
##$# --> set_clock_latency -0.04 [get_pins udec/urename/uext_ren/aes_restore_atag_b2_?t?_?u?_reg*/CP]
##$# --> set_clock_latency -0.04 [get_pins udec/udec23/vld_j0d3_reg/CP]
##$# --> set_clock_latency -0.03 [get_pins udsu/udispq/dispq_threshold_q_reg_*/CP]
##$# --> set_clock_latency -0.03 [get_pins udec/uresqfree/uflshfqdp/rensq*_q_reg*/CP]
##$# --> set_clock_latency -0.03 [get_pins udec/uresqfree/uaes_free/fl_entry00_reg_*/CP]
##$# --> set_clock_latency -0.02 [get_pins udsu/udispq/dispsq7_q_reg_*/CP]
##$# --> 
##$# --> ## ----------------------------------------------------------------------------------
##$# --> ## reduce TNS for uvfu/ufmul*
##$# --> ## ----------------------------------------------------------------------------------
##$# --> set_clock_latency -0.04 [get_pin uvfu/uissq_top/uissqj/uslot/srca_hi_sel_e1_reg*/CP]
##$# --> set_clock_latency -0.04 [get_pin uvfu/uissq_top/uissqk/uslot/srca_hi_sel_e1_reg*/CP]
