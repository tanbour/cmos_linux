puts "this is icc2 clock opt settings"

###=============================================================================##
## Varible control by varaible OPTIMIZATION_FLOW with value $OPTIMIZATION_FLOW  ##
##==============================================================================##
set cts_enable_global_route               "{{local.optimization_flow}}" ;# enable global router in CTS, 
                                                                        ;# ttr:false|qor:false|hplp:false|arlp:false|hc:true
set clock_opt_opto_place_effort_high      "{{local.optimization_flow}}" ;#sets clock_opt.place.effort to high to enable high coarse placement effort during clock_opt's final_opto phase
                                                                        ;#value of $OPTIMIZATION_FLOW will be converted: ttr:false|qor:false|hplp:false|arlp:false|hc:true
set clock_opt_opto_congestion_effort_high "{{local.optimization_flow}}" ;#sets clock_opt.congestion.effort to high to enable high congestion effort during clock_opt's final_opto phase
                                                                        ;#value of $OPTIMIZATION_FLOW will be converted: ttr:false|qor:false|hplp:false|arlp:false|hc:true
## PPA - Performance focused features------------------------------------------------
{%- if local.clock_opt_enable_ccd == "true" %} 
set_app_option -name clock_opt.flow.enable_ccd -value true
{%- else %}
set_app_option -name clock_opt.flow.enable_ccd -value false
{%- endif %}

## Congestion focused features--------------------------------------------------------
{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name cts.compile.enable_global_route -value false
{%- elif local.optimization_flow == "hc" %}
set_app_option -name cts.compile.enable_global_route -value true
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name clock_opt.place.effort -value medium
{%- elif local.optimization_flow == "hc" %}
set_app_option -name clock_opt.place.effort -value high
{%- endif %}

{%- if local.optimization_flow == "ttr" or local.optimization_flow == "qor" or local.optimization_flow == "hplp" or local.optimization_flow == "arlp" %}
set_app_option -name clock_opt.congestion.effort -value medium
{%- elif local.optimization_flow == "hc" %}
set_app_option -name clock_opt.congestion.effort -value high
{%- endif %}


