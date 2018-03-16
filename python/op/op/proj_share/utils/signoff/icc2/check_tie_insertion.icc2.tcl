#########################################################################
# PROGRAM     : check_delay_cell_chain.icc2.tcl 
# CREATOR     : Alchip                                
# DATE        : 2018-02-13                                             
# DESCRIPTION : check 1'b0 / 1'b1 in flatten netlist in ICC2          
# UPDATER     : Felix Yuan <felix_yuan@alchip.com>  
# USAGE       : check_tie_insertion                                   
# ITEM        : GE-02-04                                               
#########################################################################

proc check_tie_insertion {output_rpt_tie_insertion check_tie_insertion.rpt} {
     puts "Alchip-info: Starting to signoff check 1'b0 / 1'b1 in flatten netlist in ICC2\n"
   # get flatten design
     ungroup_cells -flatten -all
     
   # write -format verilog -output flatten_netlist.v
     write_verilog flatten_netlist.v
     
   # grep data
#     exec grep {1'b0} flatten_netlist.v >  ./check_tie_insertion.rpt
#     exec grep {1'b1} flatten_netlist.v >> ./check_tie_insertion.rpt
     exec grep {1'b0} flatten_netlist.v >  ./$output_rpt_tie_insertion
     exec grep {1'b1} flatten_netlist.v >> ./$output_rpt_tie_insertion
     puts "Alchip-info: Completed to signoff check 1'b0 / 1'b1 in flatten netlist in ICC2\n"

}
