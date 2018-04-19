## Pre-Set Vars
set 7nm_M1 [get_attribute [get_layers -filter {mask_name==metal2}] name]
set 7nm_M2 [get_attribute [get_layers -filter {mask_name==metal3}] name]
set 7nm_M3 [get_attribute [get_layers -filter {mask_name==metal4}] name]

# Core Row
set_app_options -list {plan.flow.segment_rule "horizontal_even vertical_even"}
check_boundary_cells -precheck_segment_parity

# Metal-cut
set_app_options -name chipfinishing.metal_cut_allowed_vertical_shrink_factor -value 0.5
set_app_options -name chipfinishing.metal_cut_allowed_horizontal_shrink_factor -value 0

# PG related
set_app_options -name plan.pgroute.set_mask_fixed -value true
set_app_options -name plan.pgroute.drc_check_fast_mode -value false
set_app_options -name plan.pgroute.honor_signal_route_drc -value true
set_app_options -name plan.pgroute.honor_std_cell_drc -value true
set_app_options -name plan.pgroute.verbose -value true
set_app_options -name plan.pgroute.ignore_area_based_fat_metal_extension_contact_rule -value true

# placer
set_app_options -name place.coarse.pin_density_aware -value true
set_app_options -name place.legalize.enable_prerouted_net_check -value true
set_app_options -name place.legalize.allow_touch_track_for_access_check -value true
set_app_options -name place.legalize.use_eol_spacing_for_access_check -value true
set_app_options -name place.legalize.enable_track_capacity_check -value true
set_app_options -name place.legalize.enable_pin_color_alignment_check -value true
set_app_options -name place.legalize.pin_color_alignment_layers -value [list $7nm_M1 $7nm_M2]
set_app_options -name place.legalize.num_tracks_for_access_check -value 2
set_app_options -name place.legalize.filler_lib_cells -value $filler_lib_cells

# router
set_ignored_layers -min_routing_layer $7nm_M1
set_app_options -name route.common.connect_within_pins_by_layer_name -value [list \
[list $7nm_M0 via_wire_all_pins] \
[list $7nm_M1 off] \
[list $7nm_M2 via_wire_standard_cell_pins] \
]
set_app_options -name route.common.via_array_mode -value rotate
set_app_options -name route.common.global_min_layer_mode -value hard
set_app_options -name route.common.color_based_dpt_flow -value true
set_app_options -name route.common.extra_via_cost_multiplier_by_layer_name -value $tmpStr1
set_app_options -name route.common.extra_nonpreferred_direction_wire_cost_multiplier_by_layer_name -value $tmpStr2
set_app_options -name route.detail.enable_end_off_preferred_grid_patching_on_fixed_shapes -value false
set_app_options -name route.detail.report_end_off_preferred_grid_boundary_violations -value false
set_app_options -name route.detail.check_pin_min_area_min_length -value true
set_app_options -name route.detail.detail_route_special_design_rule_fixing_stage -value early_routing ;# tool default late_routing
set_app_options -name route.detail.group_route_special_design_rule_fixing_stage -value early_routing  ;# tool default late_routing
set_app_options -name route.detail.post_process_special_design_rule_fixing_stage -value early_routing  ;# tool default late_routing
set_app_options -name route.detail.incremental_detail_route_special_design_rule_fixing_stage -value early_routing  ;# tool default late_routing
set_app_options -name route.detail.eco_route_special_design_rule_fixing_stage -value early_routing  ;# tool default late_routing

# Extractor
set_extraction_options -late_ccap_threshold 0.001 -late_ccap_ratio 0.01 -honor_mask_constraints true

# timer
set_app_options -list {time.delay_calc_waveform_analysis_mode full_design}
# POCV is recommended

# data output
#write_def -version 5.8
#write_gds -connect_below_cut_metal 
