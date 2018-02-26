set target_library ""
{% if local.syn_mode == "dcg" %}
set mw_ref_lib  ""  
{% endif %}

{% if local.lib_corner == "tt0p55v_wc" %}
set target_library       "{{liblist.DB_STD_TT0P55V_WC}} {{liblist.DB_MEM_TT0P55V_WC}}  {{liblist.DB_IP_TT0P55V_WC}} {{liblist.DB_IO_TT0P55V_WC}}"
{% elif local.lib_corner == "tt0p55v_wcl" %}
set target_library  "{{liblist.DB_STD_TT0P55V_WCL}} {{liblist.DB_MEM_TT0P55V_WCL}} {{liblist.DB_IP_TT0P55V_WCL}} {{liblist.DB_IO_TT0P55V_WCL}}"
{% elif local.lib_corner == "tt0p55v_lt" %}
set target_library  "{{liblist.DB_STD_TT0P55V_LT}} {{liblist.DB_MEM_TT0P55V_LT}} {{liblist.DB_IP_TT0P55V_LT}} {{liblist.DB_IO_TT0P55V_LT}}"
{% elif local.lib_corner == "tt0p55v_ltz" %}
set target_library  "{{liblist.DB_STD_TT0P55V_LTZ}} {{liblist.DB_MEM_TT0P55V_LTZ}} {{liblist.DB_IP_TT0P55V_LTZ}} {{liblist.DB_IO_TT0P55V_LTZ}}"
{% elif local.lib_corner == "tt0p55v_tt25" %}
set target_library  "{{liblist.DB_STD_TT0P55V_TT25}} {{liblist.DB_MEM_TT0P55V_TT25}} {{liblist.DB_IP_TT0P55V_TT25}} {{liblist.DB_IO_TT0P55V_TT25}} "
{% elif local.lib_corner == "tt0p55v_tt85" %}
set target_library  "{{liblist.DB_STD_TT0P55V_TT85}} {{liblist.DB_MEM_TT0P55V_TT85}} {{liblist.DB_IP_TT0P55V_TT85}} {{liblist.DB_IO_TT0P55V_TT85}}"
{% endif %}

{% if local.lib_corner == "tt0p75v_wc" %}
set target_library       "{{liblist.DB_STD_TT0P75V_WC}} {{liblist.DB_MEM_TT0P75V_WC}} {{liblist.DB_IP_TT0P75V_WC}} {{liblist.DB_IO_TT0P75V_WC}}"
{% elif local.lib_corner == "tt0p75v_wcl" %}
set target_library  "{{liblist.DB_STD_TT0P75V_WCL}} {{liblist.DB_MEM_TT0P75V_WCL}} {{liblist.DB_IP_TT0P75V_WCL}} {{liblist.DB_IO_TT0P75V_WCL}}"
{% elif local.lib_corner == "tt0p75v_lt" %}
set target_library  "{{liblist.DB_STD_TT0P75V_LT}} {{liblist.DB_MEM_TT0P75V_LT}} {{liblist.DB_IP_TT0P75V_LT}} {{liblist.DB_IO_TT0P75V_LT}}"
{% elif local.lib_corner == "tt0p75v_ltz" %}
set target_library  "{{liblist.DB_STD_TT0P75V_LTZ}} {{liblist.DB_MEM_TT0P75V_LTZ}} {{liblist.DB_IP_TT0P75V_LTZ}} {{liblist.DB_IO_TT0P75V_LTZ}}"
{% elif local.lib_corner == "tt0p75v_tt25" %}
set target_library  "{{liblist.DB_STD_TT0P75V_TT25}} {{liblist.DB_MEM_TT0P75V_TT25}} {{liblist.DB_IP_TT0P75V_TT25}} {{liblist.DB_IO_TT0P75V_TT25}}"
{% elif local.lib_corner == "tt0p75v_tt85" %}
set target_library  "{{liblist.DB_STD_TT0P75V_TT85}} {{liblist.DB_MEM_TT0P75V_TT85}} {{liblist.DB_IP_TT0P75V_TT85}} {{liblist.DB_IO_TT0P75V_TT85}}"
{% endif %}

{% if local.lib_corner == "tt0p8v_wc" %}
set target_library       "{{liblist.DB_STD_TT0P8V_WC}} {{liblist.DB_MEM_TT0P8V_WC}} {{liblist.DB_IP_TT0P8V_WC}} {{liblist.DB_IO_TT0P8V_WC}}"
{% elif local.lib_corner == "tt0p8v_wcl" %}
set target_library  "{{liblist.DB_STD_TT0P8V_WCL}} {{liblist.DB_MEM_TT0P8V_WCL}} {{liblist.DB_IP_TT0P8V_WCL}} {{liblist.DB_IO_TT0P8V_WCL}}"
{% elif local.lib_corner == "tt0p8v_lt" %}
set target_library  "{{liblist.DB_STD_TT0P8V_LT}} {{liblist.DB_MEM_TT0P8V_LT}} {{liblist.DB_IP_TT0P8V_LT}} {{liblist.DB_IO_TT0P8V_LT}}"
{% elif local.lib_corner == "tt0p8v_ltz" %}
set target_library  "{{liblist.DB_STD_TT0P8V_LTZ}} {{liblist.DB_MEM_TT0P8V_LTZ}} {{liblist.DB_IP_TT0P8V_LTZ}} {{liblist.DB_IO_TT0P8V_LTZ}}"
{% elif local.lib_corner == "tt0p8v_tt25" %}
set target_library  "{{liblist.DB_STD_TT0P8V_TT25}} {{liblist.DB_MEM_TT0P8V_TT25}} {{liblist.DB_IP_TT0P8V_TT25}} {{liblist.DB_IO_TT0P8V_TT25}}"
{% elif local.lib_corner == "tt0p8v_tt85" %}
set target_library  "{{liblist.DB_STD_TT0P8V_TT85}} {{liblist.DB_MEM_TT0P8V_TT85}} {{liblist.DB_IP_TT0P8V_TT85}} {{liblist.DB_IO_TT0P8V_TT85}}"
{% endif %}

{% if local.lib_corner == "tt0p85v_wc" %}
set target_library       "{{liblist.DB_STD_TT0P85V_WC}} {{liblist.DB_MEM_TT0P85V_WC}} {{liblist.DB_IP_TT0P85V_WC}} {{liblist.DB_IO_TT0P85V_WC}}"
{% elif local.lib_corner == "tt0p85v_wcl" %}
set target_library  "{{liblist.DB_STD_TT0P85V_WCL}} {{liblist.DB_MEM_TT0P85V_WCL}} {{liblist.DB_IP_TT0P85V_WCL}} {{liblist.DB_IO_TT0P85V_WCL}}"
{% elif local.lib_corner == "tt0p85v_lt" %}
set target_library  "{{liblist.DB_STD_TT0P85V_LT}} {{liblist.DB_MEM_TT0P85V_LT}} {{liblist.DB_IP_TT0P85V_LT}} {{liblist.DB_IO_TT0P85V_LT}}"
{% elif local.lib_corner == "tt0p85v_ltz" %}
set target_library  "{{liblist.DB_STD_TT0P85V_LTZ}} {{liblist.DB_MEM_TT0P85V_LTZ}} {{liblist.DB_IP_TT0P85V_LTZ}} {{liblist.DB_IO_TT0P85V_LTZ}}"
{% elif local.lib_corner == "tt0p85v_tt25" %}
set target_library  "{{liblist.DB_STD_TT0P85V_TT25}} {{liblist.DB_MEM_TT0P85V_TT25}} {{liblist.DB_IP_TT0P85V_TT25}} {{liblist.DB_IO_TT0P85V_TT25}}"
{% elif local.lib_corner == "tt0p85v_tt85" %}
set target_library  "{{liblist.DB_STD_TT0P85V_TT85}} {{liblist.DB_MEM_TT0P85V_TT85}} {{liblist.DB_IP_TT0P85V_TT85}} {{liblist.DB_IO_TT0P85V_TT85}}"
{% endif %}

{% if local.lib_corner == "tt1p0v_wc" %}
set target_library       "{{liblist.DB_STD_TT1P0V_WC}} {{liblist.DB_MEM_TT1P0V_WC}} {{liblist.DB_IP_TT1P0V_WC}} {{liblist.DB_IO_TT1P0V_WC}}"
{% elif local.lib_corner == "tt1p0v_wcl" %}
set target_library  "{{liblist.DB_STD_TT1P0V_WCL}} {{liblist.DB_MEM_TT1P0V_WCL}} {{liblist.DB_IP_TT1P0V_WCL}} {{liblist.DB_IO_TT1P0V_WCL}}"
{% elif local.lib_corner == "tt1p0v_lt" %}
set target_library  "{{liblist.DB_STD_TT1P0V_LT}} {{liblist.DB_MEM_TT1P0V_LT}} {{liblist.DB_IP_TT1P0V_LT}} {{liblist.DB_IO_TT1P0V_LT}}"
{% elif local.lib_corner == "tt1p0v_ltz" %}
set target_library  "{{liblist.DB_STD_TT1P0V_LTZ}} {{liblist.DB_MEM_TT1P0V_LTZ}} {{liblist.DB_IP_TT1P0V_LTZ}} {{liblist.DB_IO_TT1P0V_LTZ}}"
{% elif local.lib_corner == "tt1p0v_tt25" %}
set target_library  "{{liblist.DB_STD_TT1P0V_TT25}} {{liblist.DB_MEM_TT1P0V_TT25}} {{liblist.DB_IP_TT1P0V_TT25}} {{liblist.DB_IO_TT1P0V_TT25}}"
{% elif local.lib_corner == "tt1p0v_tt85" %}
set target_library  "{{liblist.DB_STD_TT1P0V_TT85}} {{liblist.DB_MEM_TT1P0V_TT85}} {{liblist.DB_IP_TT1P0V_TT85}} {{liblist.DB_IO_TT1P0V_TT85}}"
{% endif %}

{% if local.syn_mode == "dcg" %}
set mw_ref_lib  "{{liblist.MW_STD}} {{liblist.MW_MEM}} {{liblist.MW_IP}} {{liblist.MW_IO}}"  
{% endif %}

set link_library "* $target_library"
