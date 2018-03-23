puts "this is icc2_place settings"

###=================================================================================##
## Varible control by varaible OPTIMIZATION_FLOW with value $OPTIMIZATION_FLOW      ##
##==================================================================================##
set PLACE_OPT_DO_PATH_OPT                 "{{local.optimization_flow}}" ;# set_app_option -name place_opt.flow.do_path_opt -value false
                                                             ;# ttr:false|qor:false|hplp:true|arlp:flase|hc:false"
set PLACE_OPT_FINAL_PLACE_EFFORT_HIGH     "{{local.optimization_flow}}" ;# set_app_option -name place_opt.final_place.effort -value medium 
                                                             ;# ttr:false|qor:false|hplp:true|arlp:true|hc:true
set PLACE_OPT_CONGESTION_EFFORT_HIGH      "{{local.optimization_flow}}" ;#set_app_option -name place_opt.congestion.effort -value medium
                                                             ;#ttr:false|qor:false|hplp:true|arlp:false|hc:true
set ISOLATE_SIGNAL_PORT_LIBCELL           "{{local.isolate_signal_port_libcell}}"
set ISOLATE_CLOCK_PORT_LIBCELL            "{{local.isolate_clock_port_libcell}}"
set PLACE_OPT_ICG_AUTO_BOUND              "{{local.place_opt_icg_auto_bound}}"
set PLACE_OPT_ICG_AUTO_BOUND_FANOUT_LIMIT "{{local.place_opt_icg_auto_bound_fanout_limit}}"
set PLACE_OPT_OPTIMIZE_ICGS               "{{local.place_opt_optimize_icgs}}"
set PLACE_OPT_CLOCK_AWARE_PLACEMENT       "{{local.place_opt_clock_aware_placement}}"
set PLACE_OPT_REFINE_OPT_EFFORT_HIGH      "{{local.place_opt_refine_opt_effort_high}}" 

# Isolate port settings----------------------------------------------------------------------
{%- if local.isolate_signal_port_libcell %}
set_isolate_ports -driver $ISOLATE_SIGNAL_PORT_LIBCELL -force [get_ports -filter "port_type == signal"]
{%- endif %}

{%- if local.isolate_clock_port_libcell %}
set_isolate_ports -driver $ISOLATE_CLOCK_PORT_LIBCELL -force [get_ports -filter "port_type == clock"]
{%- endif %}

## Timing settings----------------------------------------------------------------------
set_app_options -name time.enable_clock_to_data_analysis -value true ;# default false

# PPA - Performance focused features (place_opt)---------------------------------------------------
{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or local.optimization_flow == "hc" or local.optimization_flow == "arlp" %}
set_app_option -name place_opt.flow.do_path_opt -value false 
{%- elif local.optimization_flow == "hplp" %}
set_app_option -name place_opt.flow.do_path_opt -value true
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor"  %}
set_app_option -name place_opt.final_place.effort -value medium
{%- elif local.optimization_flow == "hc" or local.optimization_flow == "arlp" or local.optimization_flow == "hplp" %}
set_app_option -name place_opt.final_place.effort -value high
{%- endif %}

{%- if local.place_opt_icg_auto_bound == "true" %}
	set_app_options -name place.coarse.icg_auto_bound -value true ;# default false
{%- endif %}

{%- if local.place_opt_icg_auto_bound_fanout_limit %}
	set_app_options -name place.coarse.icg_auto_bound_fanout_limit -value $PLACE_OPT_ICG_AUTO_BOUND_FANOUT_LIMIT ;# default 100
{%- else %}
	set_app_options -name place.coarse.icg_auto_bound_fanout_limit -value 40 ;# default 100
{%- endif %}

## Clock-aware placement settings----------------------------------------------------------------------
{%- if local.place_opt_clock_aware_placement == "true" %}
	set_app_options -name place_opt.flow.clock_aware_placement -value true ;# default false
{%- endif %}

##  place_opt/placement specific features ----------------------------------------------------------------------
{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or local.optimization_flow == "arlp" %}
set_app_option -name place_opt.congestion.effort -value medium
{%- elif local.optimization_flow == "hc" or local.optimization_flow == "hplp" %}
set_app_option -name place_opt.congestion.effort -value high
{%- endif %}

{%- if local.place_opt_refine_opt_effort_high %}
	set_app_options -name refine_opt.place.effort -value high
{%- endif %}
 
## GR-opto : 
#  Run global route based buffering during HFS/DRC fixing. Global routes are deleted after buffering. 
set_app_option -name place_opt.initial_drc.global_route_based -value 1 ;# tool default 0

{%- if local.place_opt_spg_flow == "true" %} {
	set_app_options -name place_opt.flow.do_spg -value true
{%- endif %}
