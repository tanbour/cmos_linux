################################
## icc2_shell M-2016.12-SP2
## For 7nm Designs
## Minimum set, for better QoR may need adjust other app options

### -------------------------
### Timer
#set_app_options -list {time.delay_calc_waveform_analysis_mode full_design}
set_app_options -list {time.remove_clock_reconvergence_pessimism true}
set_app_options -list {time.enable_clock_to_data_analysis true}
set_app_options -list {time.edge_specific_source_latency true}
set_app_options -list {time.pocvm_enable_analysis true}
set_app_options -list {time.enable_ccs_rcv_cap false}
set_app_options -list {time.xtalk_use_small_xcap_filter 0.01}


# general
set_app_options -list {place.coarse.enable_enhanced_soft_blockages true}
# congestion
set_app_options -list {place.coarse.pin_density_aware true}

	### -------------------------
	#### Extraction
	set_extraction_options -late_ccap_threshold 0.001 -late_ccap_ratio 0.01
	set_app_options -list {extract.via_node_cap true}

	### -------------------------
	#### opt
	#set_app_options -list {opt.common.use_route_aware_estimation true}

	### -------------------------
	##### CTS
	set_app_options -list {cts.common.verbose 1}
        set_app_options -list {cts.compile.enable_global_route true}
        set_app_options -list {cts.optimize.enable_global_route true}
	set_app_options -list {clock_opt.flow.optimize_layers true}

	### -------------------------
	### Router
	set_app_options -list {route.common.verbose_level 1}
	# pin access
	#set_app_options -list {route.common.single_connection_to_pins standard_cell_pins}
	#set_app_options -list {route.global.pin_access_factor 5}
	# timing-driven routing
	set_app_options -list {route.common.threshold_noise_ratio 0.15}

