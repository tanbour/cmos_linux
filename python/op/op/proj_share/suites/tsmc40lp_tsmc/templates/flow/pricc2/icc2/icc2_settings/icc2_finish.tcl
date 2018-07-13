##==================================================================##
## settings.step.finish.tcl                                         ##
##==================================================================##
## ECO route----------------------------------------------------------------------
# Disable soft-rule-based timing optimization during ECO routing. This is to limit spreading which can touch multiple nets and impact convergence.
set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false

## Timing----------------------------------------------------------------------
## Enable crosstalk analysis and the extraction of the routed nets along with their coupling caps
set_app_options -name time.si_enable_analysis -value true ;# default false

## PPA - Performance focused features---------------------------------------------
{#
    # Uncomment below to enable route_opt CCD, if you enable route_opt in chip_finish
    #	set_app_option -name route_opt.flow.enable_ccd -value true ;puts "RM-info: Setting route_opt.flow.enable_ccd to true"
    #	set_app_option -name ccd.post_route_buffer_removal -value true ;puts "RM-info: Setting ccd.post_route_buffer_removal to true" ;# tool default false
#}
## PPA - Power focused features----------------------------------------------------------------------
{#
    # Uncomment to enable leakage optimization during route_opt
    #	set_app_options -name route_opt.flow.enable_power -value true ;# default false; global-scoped and needs to be re-applied in a new session
#}
## CTO----------------------------------------------------------------------
{#
    # Uncomment to enable route_opt CTO
    #  Note : this feature is only for non-CCD flow.
    #	set_app_options -name route_opt.flow.enable_cto -value true ;# default false; global-scoped and needs to be re-applied in a new session
#}
