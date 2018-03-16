puts "this is icc2 clock opt settings"

###############################################################################
## Varible control by varaible OPTIMIZATION_FLOW with value $OPTIMIZATION_FLOW
###############################################################################

set CTS_ENABLE_GLOBAL_ROUTE               "{{local.optimization_flow}}" ;# enable global router in CTS, 
                                                                        ;# ttr:false|qor:false|hplp:false|arlp:false|hc:true
set CLOCK_OPT_OPTO_PLACE_EFFORT_HIGH      "{{local.optimization_flow}}" ;#sets clock_opt.place.effort to high to enable high coarse placement effort during clock_opt's final_opto phase
                                                                        ;#value of $OPTIMIZATION_FLOW will be converted: ttr:false|qor:false|hplp:false|arlp:false|hc:true
set CLOCK_OPT_OPTO_CONGESTION_EFFORT_HIGH "{{local.optimization_flow}}" ;#sets clock_opt.congestion.effort to high to enable high congestion effort during clock_opt's final_opto phase
                                                                        ;#value of $OPTIMIZATION_FLOW will be converted: ttr:false|qor:false|hplp:false|arlp:false|hc:true

####################################
## PPA - Performance focused features
####################################
{%- if local.clock_opt_enable_ccd == "true" %} 
set_app_option -name clock_opt.flow.enable_ccd -value true
{%- else %}
set_app_option -name clock_opt.flow.enable_ccd -value false
{%- endif %}

####################################
## Congestion focused features
####################################
switch -regexp $CTS_ENABLE_GLOBAL_ROUTE {
	"ttr|qor|hplp|arlp|false" {set_app_option -name cts.compile.enable_global_route -value false ;# tool default}
	"hc|true" 	        {set_app_option -name cts.compile.enable_global_route -value true}
}
switch -regexp $CLOCK_OPT_OPTO_PLACE_EFFORT_HIGH {
	"ttr|qor|hplp|arlp|false" {set_app_option -name clock_opt.place.effort -value medium ;# tool default}
	"hc|true" 	        {set_app_option -name clock_opt.place.effort -value high}
}

switch -regexp $CLOCK_OPT_OPTO_CONGESTION_EFFORT_HIGH {
	"ttr|qor|hplp|arlp|false" {set_app_option -name clock_opt.congestion.effort -value medium ;# tool default}
	"hc|true" 	        {set_app_option -name clock_opt.congestion.effort -value high}
}

