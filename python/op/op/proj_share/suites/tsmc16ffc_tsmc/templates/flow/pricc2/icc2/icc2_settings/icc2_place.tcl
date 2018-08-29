###==================================================================##
## settings.step.place_opt.tcl                                       ##
##===================================================================##
## Path opt (RM default is true), Performs register location optimization for better timing
set place_opt_do_path_opt                            "{{local.place_opt_do_path_opt}}"
## Final coarse placement effort level (RM default is high)
set place_opt_final_place_effort                     "{{local.place_opt_final_place_effort}}"
## Effort level for congestion alleviation in place_opt (RM default is high), Expect run time increase at high effort.
set place_opt_congestion_effort                      "{{local.place_opt_congestion_effort}}"
## GR-based HFS DRC (RM default is enabled), Run global route based buffering during HFS/DRC fixing. Global routes are deleted after buffering. 
set place_opt_gr_based_hfsdrc                        "{{local.place_opt_gr_based_hfsdrc}}"
## Enable high CPU effort level for coarse placements invoked in refine_opt (optional)
set place_opt_refine_opt_effort                      "{{local.place_opt_refine_opt_effort}}"
## place_opt CCD (optional), Enables concurrent clock and data optimization (CCD) during place_opt final_opto phase.
#  If PLACE_OPT_OPTIMIZE_ICGS or PLACE_OPT_TRIAL_CTS is also enabled, place_opt CCD will be based on propagated early clocks.
set place_opt_ccd                                    "{{local.place_opt_ccd}}"
## Auto bound for ICG placement (optional), Can be enabled along with place_opt_optimize_icgs
set place_opt_icg_auto_bound                         "{{local.place_opt_icg_auto_bound}}"
## Clock-aware placement (optional), Enabled only if place_opt_optimize_icgs is not enabled 
set place_opt_clock_aware_placement                  "{{local.place_opt_clock_aware_placement}}"

## clock-to-data analysis (RM default is true) ------------------------
puts "RM-info: Setting time.enable_clock_to_data_analysis to true (tool default false)"
set_app_options -name time.enable_clock_to_data_analysis -value true

##PPA - Performance focused features (place_opt) -----------------------
puts "RM-info: Setting place_opt.flow.do_path_opt to $place_opt_do_path_opt (tool default false)"
set_app_option -name place_opt.flow.do_path_opt -value $place_opt_do_path_opt

puts "RM-info: Setting place_opt.final_place.effort to $place_opt_final_place_effort (tool default medium)"
set_app_option -name place_opt.final_place.effort -value $place_opt_final_place_effort

puts "RM-info: Setting place_opt.congestion.effort to $place_opt_congestion_effort (tool default medium)"
set_app_option -name place_opt.congestion.effort -value $place_opt_congestion_effort
 
{%- if local.place_opt_gr_based_hfsdrc == "true" %}
puts "RM-info: Setting place_opt.initial_drc.global_route_based to 1 (tool default 0)" 
set_app_option -name place_opt.initial_drc.global_route_based -value 1
{%- else %}
puts "RM-info: Setting place_opt.initial_drc.global_route_based to 0 (tool default 0)"
set_app_option -name place_opt.initial_drc.global_route_based -value 0
{%- endif %}

{%- if local.use_spg_flow == "true" %}
set_app_options -name place_opt.flow.do_spg -value true
{%- else %}
#  making initial_drc phase skipped during "place_opt -from initial_drc", place_opt.flow.do_spg is reset to false.
puts "RM-info: Resetting place_opt.flow.do_spg"
reset_app_options place_opt.flow.do_spg
{% endif %}
puts "RM-info: Setting refine_opt.place.effort to $place_opt_refine_opt_effort (tool default medium)"
set_app_options -name refine_opt.place.effort -value $place_opt_refine_opt_effort

puts "RM-info: Setting place_opt.flow.enable_ccd to $place_opt_ccd (tool default false)"
set_app_option -name place_opt.flow.enable_ccd -value $place_opt_ccd

puts "RM-info: Setting place.coarse.icg_auto_bound to $place_opt_icg_auto_bound (tool default false)"
set_app_option -name place.coarse.icg_auto_bound -value $place_opt_icg_auto_bound

{%- if local.place_opt_clock_aware_placement == "true" and local.place_opt_optimize_icgs != "true" %}
puts "RM-info: Setting place_opt.flow.clock_aware_placement to true (tool default false)"
set_app_options -name place_opt.flow.clock_aware_placement -value true
{%- elif local.place_opt_clock_aware_placement != "true" %}
puts "RM-info: Setting place_opt.flow.clock_aware_placement to false (tool default false)"
set_app_options -name place_opt.flow.clock_aware_placement -value false
{% endif %} 

{# 
   # To create a buffer-only blockage, follow the example below.
   #  The area covered by a buffer-only blockage can only be used by buffers and inverters, which is honored by placement.
   #  -blocked_percentage 0 means that 100% of the area can be used by buffers and inverters.
   #  -blocked_percentage 100 means that 0% of the area can be used by buffers and inverters. 
   #   (as a result, no standard cells can be placed under a buffer only blockage with -blocked_percentage 100).
   #
   #  Example for creating a buffer only blockage with 100% of the area open to repeaters : 
   #	create_placement_blockage -name placement_blockage_1 -type allow_buffer_only -blocked_percentage 0 \
   #       -boundary { {x1 y1} {x2 y2} } 
#} 
