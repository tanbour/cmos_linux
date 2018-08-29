
puts "RM-info: Running script [info script]\n"

set METAL_2 [get_attribute [get_layers -filter {mask_name==metal2}] name]
set METAL_3 [get_attribute [get_layers -filter {mask_name==metal3}] name]
set METAL_4 [get_attribute [get_layers -filter {mask_name==metal4}] name]

## Legalization settings
set_app_options -name place.legalize.use_eol_spacing_for_access_check -value true
set_app_options -name place.legalize.enable_prerouted_net_check -value true
set_app_options -name place.legalize.allow_touch_track_for_access_check -value true
set_app_options -name place.legalize.single_pass -value true
set_app_options -name place.legalize.num_tracks_for_access_check -value 2

## Pin/track alignment
set_app_options -name place.legalize.enable_pin_color_alignment_check -value true
set_app_options -name place.legalize.pin_color_alignment_layers -value [list $METAL_2 $METAL_3]
set filler_lib_cells [list \
	DCAP64XPXNBWP240H11P57PDLVT \
	DCAP64XPXNBWP240H11P57PDSVT \
	DCAP64XPXNBWP240H11P57PDULVT \
	DCAP64XPXNBWP240H8P57PDLVT \
	DCAP64XPXNBWP240H8P57PDSVT \
	DCAP64XPXNBWP240H8P57PDULVT \
	DCAP32XPXNBWP240H11P57PDLVT \
	DCAP32XPXNBWP240H11P57PDSVT \
	DCAP32XPXNBWP240H11P57PDULVT \
	DCAP32XPXNBWP240H8P57PDLVT \
	DCAP32XPXNBWP240H8P57PDSVT \
	DCAP32XPXNBWP240H8P57PDULVT \
	DCAP16XPXNBWP240H11P57PDLVT \
	DCAP16XPXNBWP240H11P57PDSVT \
	DCAP16XPXNBWP240H11P57PDULVT \
	DCAP16XPXNBWP240H8P57PDLVT \
	DCAP16XPXNBWP240H8P57PDSVT \
	DCAP16XPXNBWP240H8P57PDULVT \
	DCAP8XPXNBWP240H11P57PDLVT \
	DCAP8XPXNBWP240H11P57PDSVT \
	DCAP8XPXNBWP240H11P57PDULVT \
	DCAP8XPXNBWP240H8P57PDLVT \
	DCAP8XPXNBWP240H8P57PDSVT \
	DCAP8XPXNBWP240H8P57PDULVT \
	FILL64BWP240H11P57PDLVT \
	FILL64BWP240H11P57PDSVT \
	FILL64BWP240H11P57PDULVT \
	FILL64BWP240H8P57PDLVT \
	FILL64BWP240H8P57PDSVT \
	FILL64BWP240H8P57PDULVT \
	FILL32BWP240H11P57PDLVT \
	FILL32BWP240H11P57PDSVT \
	FILL32BWP240H11P57PDULVT \
	FILL32BWP240H8P57PDLVT \
	FILL32BWP240H8P57PDSVT \
	FILL32BWP240H8P57PDULVT \
	FILL16BWP240H11P57PDLVT \
	FILL16BWP240H11P57PDSVT \
	FILL16BWP240H11P57PDULVT \
	FILL16BWP240H8P57PDLVT \
	FILL16BWP240H8P57PDSVT \
	FILL16BWP240H8P57PDULVT \
	FILL12BWP240H11P57PDLVT \
	FILL12BWP240H11P57PDSVT \
	FILL12BWP240H11P57PDULVT \
	FILL12BWP240H8P57PDLVT \
	FILL12BWP240H8P57PDSVT \
	FILL12BWP240H8P57PDULVT \
	FILL8BWP240H11P57PDLVT \
	FILL8BWP240H11P57PDSVT \
	FILL8BWP240H11P57PDULVT \
	FILL8BWP240H8P57PDLVT \
	FILL8BWP240H8P57PDSVT \
	FILL8BWP240H8P57PDULVT \
	FILL4BWP240H11P57PDLVT \
	FILL4BWP240H11P57PDSVT \
	FILL4BWP240H11P57PDULVT \
	FILL4BWP240H8P57PDLVT \
	FILL4BWP240H8P57PDSVT \
	FILL4BWP240H8P57PDULVT \
	FILL3BWP240H11P57PDLVT \
	FILL3BWP240H11P57PDSVT \
	FILL3BWP240H11P57PDULVT \
	FILL3BWP240H8P57PDLVT \
	FILL3BWP240H8P57PDSVT \
	FILL3BWP240H8P57PDULVT \
	FILL2BWP240H11P57PDLVT \
	FILL2BWP240H11P57PDSVT \
	FILL2BWP240H11P57PDULVT \
	FILL2BWP240H8P57PDLVT \
	FILL2BWP240H8P57PDSVT \
	FILL2BWP240H8P57PDULVT \
	FILL1BWP240H11P57PDLVT \
	FILL1BWP240H11P57PDSVT \
	FILL1BWP240H11P57PDULVT \
	FILL1BWP240H8P57PDLVT \
	FILL1BWP240H8P57PDSVT \
	FILL1BWP240H8P57PDULVT \
]
set_app_options -name place.legalize.filler_lib_cells -value $filler_lib_cells

# advanced rule
set_app_options -name place.legalize.enable_advanced_rules -value true
#set_app_options -name place.coarse.run_full_global_route -value true
set_app_options -name opt.fix_multiple_port_nets -value true
#set_app_options -name opt.common.max_net_length -value 150
set_app_options -name opt.common.do_physical_checks -value legalize


## PNET-aware settings (optional for high utilization and congested designs)
#  pnet-aware coarse placement considers only $METAL_2
# 	set_app_options -name place.coarse.pnet_aware_layers -value $METAL_2
#  pnet-aware coarse placement is triggered if utilization is above 0.5
# 	set_app_options -name place.coarse.pnet_aware_density -value 0.5
#  pnet-aware coarse placement considers all pnets wider than 0
# 	set_app_options -name place.coarse.pnet_aware_min_width -value 0

## Make PG mask fixed for legalizer to work properly
set_app_options -name plan.pgroute.set_mask_fixed -value true

puts "RM-info: Completed script [info script]\n"
set_app_options -name route.detail.force_end_on_preferred_grid -value false
set_app_options -name route.detail.enable_end_off_preferred_grid_patching_on_fixed_shapes -value false


