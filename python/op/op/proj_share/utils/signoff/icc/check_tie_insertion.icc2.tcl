#########################################################################
# Date      :    2018-02-13                                            ## 
# Modifier  :    Felix <felix_yuan@alchip.com>                         ##
# Function  :    check 1'b0 / 1'b1 in flatten netlist in ICC2          ##
# Usage     :    check_tie_insertion                                   ##
# Item      :    GE-02-04                                              ## 
#########################################################################
proc check_tie_insertion {} {
# get flatten design
ungroup -all -flatten -force

# write -format verilog -output flatten_netlist.v
write_verilog flatten_netlist.v

# grep data
exec grep {1'b0} flatten_netlist.v >  ./1b1_1b0.rep
exec grep {1'b1} flatten_netlist.v >> ./1b1_1b0.rep

}
