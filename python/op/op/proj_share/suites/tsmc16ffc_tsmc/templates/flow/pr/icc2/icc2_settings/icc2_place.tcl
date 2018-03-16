puts "this is icc2_place settings"
###############################################################################
## Varible control by varaible OPTIMIZATION_FLOW with value $OPTIMIZATION_FLOW
###############################################################################
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

####################################
## Isolate port
####################################
if {$ISOLATE_SIGNAL_PORT_LIBCELL != ""} {
set_isolate_ports -driver $ISOLATE_SIGNAL_PORT_LIBCELL -force [get_ports -filter "port_type == signal"]
}

if {$ISOLATE_CLOCK_PORT_LIBCELL != ""} {
set_isolate_ports -driver $ISOLATE_CLOCK_PORT_LIBCELL -force [get_ports -filter "port_type == clock"]
}

####################################
## Timing
####################################
## Enable clock-to-data analysis
set_app_options -name time.enable_clock_to_data_analysis -value true ;# default false

####################################
## PPA - Performance focused features (place_opt)
####################################
switch -regexp $PLACE_OPT_DO_PATH_OPT {
	"ttr|qor|arlp|hc|false" {set_app_option -name place_opt.flow.do_path_opt -value false ;# tool default}
	"hplp|true"             {set_app_option -name place_opt.flow.do_path_opt -value true}
}

switch -regexp $PLACE_OPT_FINAL_PLACE_EFFORT_HIGH {
	"ttr|qor|false"         {set_app_option -name place_opt.final_place.effort -value medium ;# tool default}
	"hplp|arlp|hc|true"     {set_app_option -name place_opt.final_place.effort -value high}
}

if {$PLACE_OPT_ICG_AUTO_BOUND} {
	# Note : optionally can be enabled along with PLACE_OPT_OPTIMIZE_ICGS
	set_app_options -name place.coarse.icg_auto_bound -value true ;# default false
}

if {$PLACE_OPT_ICG_AUTO_BOUND_FANOUT_LIMIT != ""} {
	set_app_options -name place.coarse.icg_auto_bound_fanout_limit -value $PLACE_OPT_ICG_AUTO_BOUND_FANOUT_LIMIT ;# default 100
} else {
	set_app_options -name place.coarse.icg_auto_bound_fanout_limit -value 40 ;# default 100
}

## Clock-aware placement
#  if PLACE_OPT_OPTIMIZE_ICGS is not enabled
if {$PLACE_OPT_CLOCK_AWARE_PLACEMENT && !$PLACE_OPT_OPTIMIZE_ICGS} {
	set_app_options -name place_opt.flow.clock_aware_placement -value true ;# default false
}

####################################
## place_opt/placement specific features
####################################
switch -regexp $PLACE_OPT_CONGESTION_EFFORT_HIGH {
	"ttr|qor|arlp|false"    {set_app_option -name place_opt.congestion.effort -value medium ;# tool default}
	"hplp|hc|true"     	{set_app_option -name place_opt.congestion.effort -value high}
}

if {$PLACE_OPT_REFINE_OPT_EFFORT_HIGH} {
	set_app_options -name refine_opt.place.effort -value high
}
 
## GR-opto : 
#  Run global route based buffering during HFS/DRC fixing. Global routes are deleted after buffering. 
set_app_option -name place_opt.initial_drc.global_route_based -value 1 ;# tool default 0

{%- if local.place_opt_spg_flow == "true" %} {
	set_app_options -name place_opt.flow.do_spg -value true
{%- endif %}
