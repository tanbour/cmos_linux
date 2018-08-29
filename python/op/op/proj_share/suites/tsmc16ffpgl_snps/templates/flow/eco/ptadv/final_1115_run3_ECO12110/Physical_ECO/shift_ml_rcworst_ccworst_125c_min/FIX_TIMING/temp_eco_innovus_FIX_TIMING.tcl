setEcoMode -batchMode true
Error: can not find the inst.
set eco_pins [get_pins -hier {ECO_20171208_11/D}]
set term_names [get_attribute $eco_pins full_name]
ecoAddRepeater -cell BUFFD8BWP16P90CPDLVT -term $term_names -newNetName ECO_NET_FIX_SETUP_20171212_143710_PTECO_SETUP_NET1  -name ECO_INST_FIX_SETUP_20171212_143710_PTECO_SETUP_BUF1 -loc {4323.250 515.680}
