#===================================================================
#=================== DCG common setting =============================
#===================================================================
set sh_enable_page_mode false
set dc_cpu_number   "[lindex "{{local._job_cpu_number}}" end]"
set_host_options -max_cores $dc_cpu_number
#
# constant
# set compile_seqmap_propagate_constants true
# set compile_seqmap_propagate_high_effort true
# set compile_seqmap_propagate_constants_size_only true

set_app_var hdlin_infer_multibit default_all 
# register_merging
#set compile_enable_register_merging false
set compile_enable_register_merging  true

#
set bind_unused_hierarchical_pins false
set case_analysis_with_logic_constants true
set compile_instance_name_prefix "alchip"
set compile_instance_name_suffix "_dcg"
set disable_auto_time_borrow false
set enable_recovery_removal_arcs true
set timing_enable_multiple_clocks_per_reg true
set timing_enable_non_sequential_checks true
set verilogout_no_tri true
set verilogout_show_unconnected_pins true

#-- Place --
set physopt_enable_via_res_support true
set placer_disable_auto_bound_for_gated_clock false
set placer_enable_enhanced_soft_blockages true
set timing_waveform_analysis_mode full_design
#set_separate_process_options -placement false

#$# --> # -----------------------------------
#$# --> #-- from_synopsys 1030--
#$# --> # -----------------------------------
#$# --> suppress_message  {VER-314 VER-318 VER-936 TEST-337 ELAB-311}
#$# --> suppress_message  {PWR-806 PWR-477 OPT-1206 OPT-1207}

# set compile_register_replication_across_hierarchy true
set compile_seqmap_identify_shift_registers false
set enable_recovery_removal_arcs true
set timing_enable_multiple_clocks_per_reg true
set case_analysis_with_logic_constants true
set hdlin_ff_always_sync_set_reset true
set report_default_significant_digits 3

set verilogout_higher_designs_first true
set verilogout_no_tri true

set alib_library_analysis_path .
set upf_create_implicit_supply_sets false
set dct_placement_ignore_scan true

# HPC
set timing_separate_clock_gating_group true
set timing_scgc_override_library_setup_hold false
set timing_use_enhanced_capacitance_modeling true

set compile_enable_async_mux_mapping  false
set compile_delete_unloaded_sequential_cells true
set compile_mapped_redundancy_removal 1
set compile_xor_high_effort true
set compile_gshr_consider_logic_levels true
set compile_timing_high_effort true

set placer_disable_auto_bound_for_gated_clock false
set placer_gated_register_area_multiplier 8
set placer_enable_redefined_blockage_behavior  true
set placer_enable_enhanced_soft_blockages true
set placer_channel_detect_mode true
set psynopt_tns_high_effort true

set physopt_enable_via_res_support true
set spg_enable_via_resistance_support true

define_design_lib work -path "./work"
#------------------------------------
#     Clock Gate Style
#------------------------------------
#set power_cg_auto_identify true
set power_cg_iscgs_enable true
## enable physical-aware ICG restructuring
set power_cg_physically_aware_cg true
set pwr_cg_improved_cell_sorting true
## chose ULVT cells for clock network, alignd with CTS
#set_clock_gating_style \
   -max_fanout 32 \
   -minimum_bitwidth 3 \
   -sequential_cell latch \
   -positive_edge_logic "integrated:PREICGF2F_D12_N_S8P75TSL_C68L22" \
   -control_point before \
   -control_signal scan_enable
