puts "this is icc2 finish settings"

###==================================================================##
## signoff_create_metal_fill settings                                ##
##===================================================================##
{%- if local.chip_finish_create_metal_fill == "true" %}
if {[file exists $finish_create_metal_fill_runset]} {set_app_options -name signoff.create_metal_fill.runset -value $finish_create_metal_fill_runset}
if {[file exists $finish_drc_icv_runset]} {set_app_options -name signoff.check_drc.runset -value $finish_drc_icv_runset} 
set_app_options -name signoff.create_metal_fill.flat -value true ;# default false

## Timing driven metal fill related settings---------------------------------------
{%- if local.finish_create_metal_fill_timing_driven_threshold %}
# Extraction options
set_extraction_options -real_metalfill_extraction none
# Optional app options to block fill creation on critical nets. Below are examples.
# 	set_app_options -name signoff.create_metal_fill.space_to_nets -value { {M1 4x} {M2 4x} ... }
# 	set_app_options -name signoff.create_metal_fill.space_to_clock_nets -value { {M1 5x} {M2 5x} ... }
# 	set_app_options -name signoff.create_metal_fill.space_to_nets_on_adjacent_layer -value { {M1 3x} {M2 3x} ... }
# 	set_app_options -name signoff.create_metal_fill.fix_density_error -value true
# 	set_app_options -name signoff.create_metal_fill.apply_nondefault_rules -value true
{%- endif %}
{%- endif %}

## ECO route settings----------------------------------------------------------------------
## Disable soft-rule-based timing optimization during ECO routing.
#  This is to limit spreading which can touch multiple nets and impact convergence.
set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false


