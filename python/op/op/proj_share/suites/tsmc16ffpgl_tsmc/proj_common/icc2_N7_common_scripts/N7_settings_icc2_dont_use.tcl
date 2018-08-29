

#set_lib_cell_purpose -exclude all [get_lib_cells *_ulvt_*/*]


set_lib_cell_purpose -exclude all  [get_lib_cells */*D24*]  ;  # big cell
set_lib_cell_purpose -exclude all  [get_lib_cells */*D28*]  ;  # big cell
set_lib_cell_purpose -exclude all  [get_lib_cells */*D32*]  ;  # big cell
set_lib_cell_purpose -exclude all  [get_lib_cells */*D36*]  ;  # big cell
set_lib_cell_purpose -exclude all  [get_lib_cells */*DEL*]  ;  # delay cell
set_lib_cell_purpose -exclude all  [get_lib_cells */*TIE*]  ;  # tie cell
set_lib_cell_purpose -exclude all  [get_lib_cells */BHD*]   ;  # bhd cell
set_lib_cell_purpose -exclude all  [get_lib_cells */BUFT*]  ;  # tri buffer
set_lib_cell_purpose -exclude all  [get_lib_cells */CKL*]  ;  # Latch
set_lib_cell_purpose -exclude all  [get_lib_cells */*ANT*]  ;  # antenna cell
set_lib_cell_purpose -exclude all  [get_lib_cells */*DCAP*] ;  # decap cell
set_lib_cell_purpose -exclude all  [get_lib_cells */G*]     ;  # ECO cell
set_lib_cell_purpose -exclude all  [get_lib_cells */DCC*]   ;  # balance cell
set_lib_cell_purpose -exclude all  [get_lib_cells */CMP*]   ;  # Comparator
set_lib_cell_purpose -exclude all  [get_lib_cells */DFN*]   ;  # negative / mux input reg 
set_lib_cell_purpose -exclude all  [get_lib_cells */EDF*]   ;  # negative / mux input reg 
set_lib_cell_purpose -exclude all  [get_lib_cells */SDFN*]   ;  # negative / mux input reg 
set_lib_cell_purpose -exclude all  [get_lib_cells */SEDF*]   ;  # negative / mux input reg 
set_lib_cell_purpose -exclude all  [get_lib_cells */CK*]    ;  # clock cell
set_lib_cell_purpose -exclude all  [get_lib_cells */*SK*]    ;  # SK cell
set_lib_cell_purpose -exclude all  [get_lib_cells */MAOI*]
set_lib_cell_purpose -exclude all  [get_lib_cells */MOAI*]
set_lib_cell_purpose -exclude all  [get_lib_cells */*AOI*D1*]
set_lib_cell_purpose -exclude all  [get_lib_cells */*OAI*D1*]
set_lib_cell_purpose -exclude all  [get_lib_cells */BUFFD1BWP*]
set_lib_cell_purpose -exclude all  [get_lib_cells */INVD1BWP*]
set_lib_cell_purpose -exclude all  [get_lib_cells */CKBD1BWP*]
set_lib_cell_purpose -exclude all  [get_lib_cells */CKND1BWP*]
set_lib_cell_purpose -exclude all  [get_lib_cells */*OPT*]
#set_lib_cell_purpose -exclude all  [get_lib_cells */MB4*]
#set_lib_cell_purpose -exclude all  [get_lib_cells */MB8*]
set_lib_cell_purpose -exclude all [get_lib_cells */IND4D*BWP240H11P57PDULVT ]
set_lib_cell_purpose -exclude all [get_lib_cells */INR4D*BWP240H11P57PDULVT ]
set_lib_cell_purpose -exclude all [get_lib_cells */IND4D*BWP240H11P57PDULVT ]
set_lib_cell_purpose -exclude all [get_lib_cells */INR4D*BWP240H11P57PDULVT ]
set_lib_cell_purpose -exclude all [get_lib_cells */MUX4D*BWP240H11P57PDULVT ]
set_lib_cell_purpose -exclude all [get_lib_cells */ND4D*BWP240H11P57PDULVT ]
set_lib_cell_purpose -exclude all [get_lib_cells */NR4D*BWP240H11P57PDULVT ]
set_lib_cell_purpose -exclude all [get_lib_cells */OR4D*BWP240H11P57PDULVT ]
set_lib_cell_purpose -exclude all [get_lib_cells */XNR4D*BWP240H11P57PDULVT ]
set_lib_cell_purpose -exclude all [get_lib_cells */XOR4D*BWP240H11P57PDULVT ]

set high_pin_cells [list AOI222 AOI33 MUX4 MUX4N OAI222 OAI33 ]
foreach c $high_pin_cells {
  set_lib_cell_purpose -exclude all  [get_lib_cells */${c}*]
}

## prevent via1 space on low-driver complex cells
set reserved_libcells [list \
  OAI211D1 \
  OAI21D1 \
  OAI221D1 \
  OAI222D1 \
  OAI22D1 \
  OAI31D1 \
  OAI32D1 \
  OAI33D1 \
]
foreach libcell $reserved_libcells {
  set_lib_cell_purpose -exclude all  [get_lib_cells */${libcell}*]
}


