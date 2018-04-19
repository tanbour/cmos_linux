## Track and boundary cells need to be generated inside database
## Informations are saved in NDM database

#source /proj/7nm_evl/WORK/grace/templates/FP/icc2_procs.tcl
source ./rm_user_scripts/gen_track.tcl
#gen_tracks

# Clean-up old cells
#set_placement_status placed boundarycell*
#remove_cells [get_cells -filter "ref_name =~BOUNDARY*"]
#set_placement_status placed  tapfiller*
#remove_cells [get_cells -filter "ref_name =~TAPCELLB*"]

#$#gen_boundary_cells
#$#gen_tap_cells

set_message_info -id ZRT-030 -limit 10
set_message_info -id ATTR-12 -limit 10
set_message_info -id ZRT-105 -limit 10
