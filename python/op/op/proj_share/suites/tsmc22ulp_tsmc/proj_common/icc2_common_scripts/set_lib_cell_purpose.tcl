#####################################
## dont_use_cells                  ## 
#####################################
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */PTBUF*]  ;  # aon buf cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */PTINV*]  ;  # aon inv cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*D0*]  ;  # weak cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*D20*]  ;  # big cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*D24*]  ;  # big cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*D28*]  ;  # big cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*D32*]  ;  # big cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*D36*]  ;  # big cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*DEL*]  ;  # delay cell
# #set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*TIE*]  ;  # tie cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */BHD*]   ;  # bhd cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */BUFT*]  ;  # tri buffer
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*LHQ*]  ;  # Latch
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*ANT*]  ;  # antenna cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*DCAP*] ;  # decap cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */G*]     ;  # ECO cell
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */DCC*]   ;  # balance cell
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */CMP*]   ;  # Comparator
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */DFN*]   ;  # negative / mux input reg 
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */EDF*]   ;  # negative / mux input reg 
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */SDFN*]   ;  # negative / mux input reg 
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */SEDF*]   ;  # negative / mux input reg 
 set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */CK*]    ;  # clock cell
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*SK*]    ;  # SK cell
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*lvt]    ;  # LVT cell
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*uhvt]    ;  # UHVT cell
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */MAOI*]
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */MOAI*]
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*AOI*D1*]
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*OAI*D1*]
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */BUFFD1BWP*]
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */INVD1BWP*]
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */CKBD1BWP*]
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */CKND1BWP*]
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*OPT*]
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */MB6*]
# set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */MB8*]
# 
# #set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */*PDSVT]
# #set_lib_cell_purpose -exclude all [get_lib_cells -quiet  */*PDLVT]
# 
# set_lib_cell_purpose -exclude all [get_lib_cells -quiet  */*H11P*]
# set high_pin_cells [list AOI222 AOI33 MUX4 MUX4N OAI222 OAI33 ]
# foreach c $high_pin_cells {
#   set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */${c}*]
# }
# 
## prevent via1 space on low-driver complex cells
# set reserved_libcells [list \
#   OAI211D1 \
#   OAI21D1 \
#   OAI221D1 \
#   OAI222D1 \
#   OAI22D1 \
#   OAI31D1 \
#   OAI32D1 \
#   OAI33D1 \
# ]
# foreach libcell $reserved_libcells {
#   set_lib_cell_purpose -exclude all  [get_lib_cells -quiet  */${libcell}*]
# }

#####################################
## cts cells                       ## 
#####################################
# List of CTS lib cell patterns to be used by CTS 
set CTS_LIB_CELL_PATTERN_LIST [list \
   */DCCKND16BWP7T30P140 \
   */DCCKND12BWP7T30P140 \
   */DCCKND8BWP7T30P140 \
   */DCCKND4BWP7T30P140 \
   */CKLNQD12BWP7T30P140  \
   */CKLNQD16BWP7T30P140  \
   */CKLNQD4BWP7T30P140  \
   */CKLNQD6BWP7T30P140  \
   */CKLNQD8BWP7T30P140  \
   */CKMUX2D4BWP7T30P140  \
   */CKMUX2D2BWP7T30P140 \
   */ISO*BWP7T30P140 \
]

set_lib_cell_purpose -exclude cts [get_lib_cells -quiet  */*]
set_lib_cell_purpose -include cts [get_lib_cells -quiet  $CTS_LIB_CELL_PATTERN_LIST]

#####################################
## tie cells                       ## 
#####################################
#A list of TIE lib cell patterns to be included for optimization 
set TIE_LIB_CELL_PATTERN_LIST "*/TIE*"
set_dont_touch [get_lib_cells -quiet  $TIE_LIB_CELL_PATTERN_LIST] false
set_lib_cell_purpose -include optimization [get_lib_cells -quiet  $TIE_LIB_CELL_PATTERN_LIST]

#####################################
## hold fix cells                  ## 
#####################################
#A list of hold time fixing lib cell patterns to be included only for hold
#set HOLD_FIX_LIB_CELL_PATTERN_LIST = ""
#	set_dont_touch [get_lib_cells -quiet  $HOLD_FIX_LIB_CELL_PATTERN_LIST] false
#	set_lib_cell_purpose -exclude hold [get_lib_cells -quiet  */*]
#	set_lib_cell_purpose -include hold [get_lib_cells -quiet  $HOLD_FIX_LIB_CELL_PATTERN_LIST]


