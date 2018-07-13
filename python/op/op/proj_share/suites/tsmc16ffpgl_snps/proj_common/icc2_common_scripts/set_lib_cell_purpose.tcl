#set TempDontUseCells [get_cells -q ""]
#append_to_collection -u TempDontUseCells [get_lib_cells */*_0P*]
#append_to_collection -u TempDontUseCells [get_lib_cells */*_20]
#append_to_collection -u TempDontUseCells [get_lib_cells */*_24]
#append_to_collection -u TempDontUseCells [get_lib_cells */*_32]
#append_to_collection -u TempDontUseCells [get_lib_cells */*_DEL*]
##append_to_collection -u TempDontUseCells [get_lib_cells */*_TIE*]
#append_to_collection -u TempDontUseCells [get_lib_cells */*ECO*]
#append_to_collection -u TempDontUseCells [get_lib_cells */*MMCK*]
#append_to_collection -u TempDontUseCells [get_lib_cells */*_CK_*]
#append_to_collection -u TempDontUseCells [get_lib_cells */*_MM_*]
#append_to_collection -u TempDontUseCells [get_lib_cells */*_S_*]
#append_to_collection -u TempDontUseCells [remove_from_collection [get_lib_cells */*FS*QO_*] [get_lib_cells */HSBSVT16_FSDNRBSBQO_V2_*]]
#append_to_collection -u TempDontUseCells [get_lib_cells */*FS*QBO_*]
#append_to_collection -u TempDontUseCells [get_lib_cells */*2222*]
#append_to_collection -u TempDontUseCells [get_lib_cells */*AOI222*]
#append_to_collection -u TempDontUseCells [get_lib_cells */*OAI222*]
#
#append_to_collection -u TempDontUseCells [get_lib_cells */*ULT*]
#
#set TempDontUseCells_num [sizeof $TempDontUseCells]
#
#if {$TempDontUseCells_num} {
#  set_lib_cell_purpose -include none $TempDontUseCells
#}

#puts "Alchip-info: $TempDontUseCells_num Dont use cells in set_lib_cell_purpose.tcl"

