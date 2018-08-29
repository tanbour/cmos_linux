###==================================================================##
## settings.step.clock_opt_cts.tcl                                   ##
##===================================================================##
# clock_opt CCD (RM default true), Enables concurrent clock and data optimization (CCD) during clock_opt
set clock_opt_ccd                    "{{local.clock_opt_ccd}}"
# Enable power or area recovery from clock cells and registers during clock_opt (optional),  By default, it is set to auto which means in CCD flow, power recovery is on for the wns phase of clock_opt;
# while in non-CCD flow, auto means none. 
# available value auto/none/power/area
set clock_opt_power_recovery         "{{local.clock_opt_power_recovery}}"

## PPA - Performance focused features--------------------------------------------
{% if local.clock_opt_ccd == "true" %}
puts "RM-info: Setting clock_opt.flow.enable_ccd to $clock_opt_ccd (tool default false)"
set_app_option -name clock_opt.flow.enable_ccd -value $clock_opt_ccd
{%- else %}
set_app_options -name cts.compile.enable_local_skew -value true
set_app_options -name cts.optimize.enable_local_skew -value true
#enables the clock SI prevention feature in CTS,in order to minimize the impact of SI from/on clock nets at postroute
set_app_options -name cts.optimize.enable_congestion_aware_ndr_promotion -value true
{%- endif %}

## PPA - Power focused features----------------------------------------------------
puts "RM-info: Setting clock_opt.flow.enable_clock_power_recovery to $clock_opt_power_recovery (tool default auto)"
set_app_option -name clock_opt.flow.enable_clock_power_recovery -value $clock_opt_power_recovery

# Congestion focused features-------------------------------------------
# GR-based CTS: congestion estimation and congestion-aware path finder for clock_opt build_clock phase, Enabled for better congestion estimation
puts "RM-info: Setting cts.compile.enable_global_route to true (tool default false)" 
set_app_option -name cts.compile.enable_global_route -value true

# Coarse placement effort for clock_opt final_opto phase, Enabled for better placement quality
puts "RM-info: Setting clock_opt.place.effort to high (tool default medium)"
set_app_option -name clock_opt.place.effort -value high

# Congestion effort for clock_opt final_opto phase, Enabled for better congestion alleviation
puts "RM-info: Setting clock_opt.congestion.effort to high (tool default medium)"
set_app_option -name clock_opt.congestion.effort -value high
