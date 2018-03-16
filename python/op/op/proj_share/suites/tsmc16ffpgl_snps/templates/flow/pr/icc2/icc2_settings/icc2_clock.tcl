puts "this is icc2 clock settings"

###############################################################################
## Varible control by varaible OPTIMIZATION_FLOW with value $OPTIMIZATION_FLOW
###############################################################################

set CTS_ENABLE_GLOBAL_ROUTE "{{local.optimization_flow}}" ;# enable global router in CTS, 
                                                          ;# ttr:false|qor:false|hplp:false|arlp:false|hc:true

####################################
## PPA - Performance focused features
####################################
{%- if local.clock_enable_ccd == "true" %} 
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

