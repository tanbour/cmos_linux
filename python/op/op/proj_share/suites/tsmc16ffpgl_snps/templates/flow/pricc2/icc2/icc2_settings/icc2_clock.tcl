puts "this is icc2 clock settings"

###==============================================================================##
## Varible control by varaible OPTIMIZATION_FLOW with value $OPTIMIZATION_FLOW   ##
##===============================================================================##
set CTS_ENABLE_GLOBAL_ROUTE "{{local.optimization_flow}}" ;# enable global router in CTS, 

## PPA - Performance focused features-----------------------------------------------
{%- if local.clock_enable_ccd == "true" %} 
set_app_option -name clock_opt.flow.enable_ccd -value true
{%- else %}
set_app_option -name clock_opt.flow.enable_ccd -value false
{%- endif %}

## Congestion focused features ------------------------------------------------------
{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name cts.compile.enable_global_route -value false
{%- elif local.optimization_flow == "hc" %}
set_app_option -name cts.compile.enable_global_route -value true
{%- endif %}

