#===================================================================
#=================== create library ================================
#===================================================================
suppress_message {VER-281 VER-936 VER-173 VER-944 VER-176 VER-976 ELAB-311 VER-318 VER-314}

### add 1121
set sh_new_variable_message false
set mw_power_net   VDD
set mw_ground_net  VSS
set mw_power_port  VDD
set mw_ground_port VSS
set mw_logic1_net  VDD
set mw_logic0_net  VSS

{% if local.syn_mode == "dcg" %}

#source ./scr/dont_use.tcl
  extend_mw_layers
#source ./scr/dont_use.tcl
  create_mw_lib -tech $TECH_FILE -mw_reference $mw_ref_lib DCT
  open_mw_lib DCT

{% endif %}

