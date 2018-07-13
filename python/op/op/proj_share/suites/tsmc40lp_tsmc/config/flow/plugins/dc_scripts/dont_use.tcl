# if {[sizeof [get_lib_cells -q */RC*]] !=0} {set_dont_use [get_lib_cells */RC*]}  ; # TP cell
# if {[sizeof [get_lib_cells -q */TP*]] !=0} {set_dont_use [get_lib_cells */TP*]}  ; # TP cell
# #set_dont_use [get_lib_cells */*D0*]  ; # weak cell
# #set_dont_use [get_lib_cells */*D24*] ; # big cell
# #if {[sizeof [get_lib_cells -q */*D24*]] !=0} {set_dont_use [get_lib_cells */*D32*]} ; # big cell
# #if {[sizeof [get_lib_cells -q */*D32*]] !=0} {set_dont_use [get_lib_cells */*D32*]} ; # big cell
# set_dont_use [get_lib_cells */*DEL*] ; # delay cell
# #set_dont_use [get_lib_cells */*TIE*] ; # tie cell
# #set_dont_use [get_lib_cells */BHD*]  ; # bhd cell
# #set_dont_use [get_lib_cells */BUFT*] ; # tri buffer
# set_dont_use [get_lib_cells */LHQ*]  ; # Latch
# # set_dont_use [get_lib_cells */G*]    ; # ECO cell
# set_dont_use [get_lib_cells */CK*]   ; # balance cell
# #set_dont_use [get_lib_cells */DCC*]  ; # balance cell
# #set_dont_use [get_lib_cells */PT*]   ; # always on cell
# #set_dont_use [get_lib_cells */DFN*]  ; # negative / mux input reg
# #set_dont_use [get_lib_cells */DFX*]  ; # negative / mux input reg
# #set_dont_use [get_lib_cells */CMP*]  ; # Comparator
# #set_dont_use [get_lib_cells */*DCAP*] ; # decap cell
# #set_dont_use [get_lib_cells */SDFN*]  ; # negative / mux input reg 
# #set_dont_use [get_lib_cells */SDFX*]  ; # negative / mux input reg
# if {[sizeof [get_lib_cells -q */EDFK*]] !=0} {set_dont_use [get_lib_cells */EDFK*]}  ; # sync reset reg
# if {[sizeof [get_lib_cells -q */SEDFK*]] !=0} {set_dont_use [get_lib_cells */SEDFK*]} ; # sync reset reg
# #set_dont_use [get_lib_cells */ANT*]   ; # antenna cell
# #set_dont_use [get_lib_cells */F*]     ; # full adder
# #set_dont_use [get_lib_cells */H*]     ; # half adder
# #set_dont_use [get_lib_cells */*OPT*] ;# Large cells
# #set_dont_use [get_lib_cells */DFQD0BWP7D5T16P96CPD*]
# set_dont_use [get_lib_cells */*DF*]
# set_attribute [get_lib_cells */SDF*] dont_use false
# set_attribute [get_lib_cells */DFRPQD*] dont_use false
# set_attribute [get_lib_cells */DFQD*] dont_use false
# set_attribute [get_lib_cells */DFSNQD*] dont_use false
# set_attribute [get_lib_cells */EDFRPQD*] dont_use false
# set_attribute [get_lib_cells */MB4*] dont_use false
# # set_dont_use [get_lib_cells */DFQD1BWP7D5T16P96CPD*]
# #set_dont_use [get_lib_cells */*20P*]
# 
# set high_pin_cells [list AO222 AO33 AOI222 AOI222X AOI33 AOI33X MUX4 MUX4N OA222 OA33 OAI222 OAI222X OAI33 OAI33X]
# foreach c $high_pin_cells {
#         if {[sizeof [get_lib_cells -q */${c}*]] !=0} {
#                 set_dont_use [get_lib_cells */${c}*]
#         }
# }
#LIB_CELL_DONT_USE_LIST                            : "*/INVF2F_D1_* */AOI31* */NAND3* */NAND4* */OAI211* */DLYCLK8* */MXT* */MXIT* */MX2F*" ;# *list of lib cell prevent to be used in design
 

