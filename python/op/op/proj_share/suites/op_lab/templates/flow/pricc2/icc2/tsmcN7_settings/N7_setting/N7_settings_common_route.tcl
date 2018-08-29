puts "RM-info: Running script [info script]\n"

set METAL_1 [get_attribute [get_layers -filter {mask_name==metal1}] name]
set METAL_2 [get_attribute [get_layers -filter {mask_name==metal2}] name]
set METAL_3 [get_attribute [get_layers -filter {mask_name==metal3}] name]

set_ignored_layers -min_routing_layer $METAL_2

set_app_options -name route.common.connect_within_pins_by_layer_name -value [list [list $METAL_1 via_wire_all_pins] [list $METAL_2 off] [list $METAL_3 via_wire_standard_cell_pins]]

set_app_options -list {route.common.global_min_layer_mode hard}
set_app_options -list {route.common.global_max_layer_mode hard}
set_app_options -list {route.common.net_min_layer_mode soft}
set_app_options -list {route.common.net_max_layer_mode hard}

set_app_options -list {route.common.rc_driven_setup_effort_level high}
set_app_options -list {route.common.assert_mode ignore}
set_app_options -list {route.common.track_auto_fill false}
set_app_options -list {route.common.high_resistance_flow true}

set_app_options -list {route.detail.use_wide_wire_to_port  true}
set_app_options -list {route.detail.drc_convergence_effort_level high}
set_app_options -list {route.detail.optimize_wire_via_effort_level high}

# Routing: DPT metal layer coloring
set_app_options -list {route.common.color_based_dpt_flow  true}
set_app_options -list {route.common.write_instance_via_color  true}
set_app_options -list {route.detail.recolor_via_colors_mode  1}


set_app_option  -list {route.global.double_pattern_utilization_by_layer_name {{M1 70} {M2 80} {M3 90}} }

## Set the cost multiplier for routing on 76nm pitch metal layers in nonpreferred direction to 3
redirect -var x {get_layers -filter "mask_name=~metal* && min_width==0.038"}
if !{[regexp "Error" $x]} {
	set p76_layer_np_costs ""
	foreach p76_layer [get_attribute [get_layers -filter "mask_name=~metal* && min_width==0.038"] name] {
	        puts "RM-info: $p76_layer is an 76nm pitch layer"
	        lappend p76_layer_np_costs [list $p76_layer 3]
	}
	set_app_options -name route.common.extra_nonpreferred_direction_wire_cost_multiplier_by_layer_name -value $p76_layer_np_costs
}
set_app_option  -list {route.common.extra_preferred_direction_wire_cost_multiplier_by_layer_name {{M2 0.2} {M3 0.2}}}

## Short-pin library setup
set_app_options -list {route.common.check_temporary_patch_connectivity true}
set_app_options -list {route.detail.enable_end_off_preferred_grid_patching_on_fixed_shapes true}
set_app_options -list {route.detail.report_end_off_preferred_grid_boundary_violations true}

## Enable checking for min area and min length rules on pins}
set_app_options -list {route.detail.check_pin_min_area_min_length true}
set_app_options -list {route.detail.check_port_min_area_min_length true}

## Specify the cost multiplier for vias (optional)
set_app_options -name route.common.extra_via_cost_multiplier_by_layer_name -value {{VIA2 3} {VIA3 2}}

set_app_options -list {route.common.via_array_mode rotate}

## If you encounter routing issues on NDR nets with the option set to true, you can set it to false to disable it 
set_app_options -list {route.common.enable_single_connection_for_var_width false}

## Extraction : mask aware etch
#  Tool considers mask  constraints during extraction. Colors of both victim and aggressor nets  
#  are considered. The design should have geometries with mask (color) attributes annotated.
#  The TLUPlus file should be defined with mask-dependent (color-dependent) etch-versus-width-spacing (EVWS) 
#  information.
set_extraction_options -honor_mask_constraints true

puts "RM-info: Completed script [info script]\n"


