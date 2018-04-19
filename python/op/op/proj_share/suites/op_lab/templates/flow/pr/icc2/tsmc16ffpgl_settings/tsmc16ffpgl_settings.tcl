puts "this is tsmc16ffpgl common settings"
### -------------------------
### Timer
set_app_options -as_user_default -name time.delay_calc_waveform_analysis_mode -value full_design
set_app_options -list {time.remove_clock_reconvergence_pessimism true}
set_app_options -list {time.enable_clock_to_data_analysis true}
set_app_options -list {time.edge_specific_source_latency true}
set_app_options -list {time.delay_calc_waveform_analysis_mode full_design}
set_app_options -list {time.enable_ccs_rcv_cap  true}
set_app_options -list {time.xtalk_use_small_xcap_filter 0.01}

### -------------------------
### Extraction
set_extraction_options -late_ccap_threshold 0.0005 -late_ccap_ratio 0.02
set_extraction_options -include_pin_resistance true
set_app_options -list {extract.via_node_cap true}

### -------------------------
### Pre route
set_app_options -list {opt.common.do_physical_checks legalize}

### -------------------------
### placer
{%- if cur.sub_stage == "02_place.tcl" %} 
# placement abut rule (Only needed in place stage)
create_abut_rules -number_of_references 4 -output {{cur.flow_scripts_dir}}/pr/lib_space_rule.tcl
source {{cur.flow_scripts_dir}}/pr/lib_space_rule.tcl
{%- endif %}
# general
set_app_options -list {place.rules.min_od_filler_size 2}
set_app_options -list {place.coarse.enable_enhanced_soft_blockages true}
set_app_options -list {place.coarse.tns_driven_placement true}
# congestion
set_app_options -list {place.coarse.pin_density_aware true}
set_app_options -list {place.coarse.max_pins_per_square_micron 10}
# icg
set_app_options -list {place.coarse.icg_auto_bound true}
set_app_options -list {place.coarse.icg_auto_bound_fanout_limit 40}
# opt
set_app_options -list {place_opt.initial_drc.global_route_based 1}
set_app_options -list {place_opt.flow.optimize_layers true}

### -------------------------
### refine_opt
set_app_options -list {refine_opt.flow.optimize_layers true}

### -------------------------
### CTS
set_app_options -list {cts.compile.enable_global_route true}
set_app_options -list {cts.optimize.enable_global_route true}

### -------------------------
# Router
# reporting
set_app_options -list {route.common.report_local_double_pattern_odd_cycles true}
set_app_options -list {route.common.verbose_level 1}
# general
set_app_options -list {route.common.extra_nonpreferred_direction_wire_cost_multiplier_by_layer_name { {M4 3.00} {M5 3.00} {M6 3.00} {M7 3.00} } }
set_app_options -list {route.common.global_min_layer_mode {hard}}
set_app_options -list {route.common.global_max_layer_mode {allow_pin_connection}}
set_app_options -list {route.common.net_min_layer_mode {allow_pin_connection}}
set_app_options -list {route.common.net_max_layer_mode {hard}}
set_app_options -list {route.common.via_array_mode rotate}
set_app_option  -list {route.global.double_pattern_utilization_by_layer_name { {M2 60} {M3 70} } }
# pin access
set_app_options -list {route.common.connect_within_pins_by_layer_name { {M1 via_wire_standard_cell_pins} {M2 off} } }
set_app_options -list {route.common.single_connection_to_pins standard_cell_pins}
set_app_options -list {route.global.pin_access_factor 5}
# timing-driven routing
set_app_options -list {route.common.high_resistance_flow true}
set_app_options -list {route.common.threshold_noise_ratio 0.15}
