#$##set variable $left_ports, $right_ports, $top_ports, $bottom_ports. 
#$#source /proj/Mars2/WORK/juliaz/temp/ports/left.list
#$#source /proj/Mars2/WORK/juliaz/temp/ports/right.list
#$#source /proj/Mars2/WORK/juliaz/temp/ports/top.list
#$#source /proj/Mars2/WORK/juliaz/temp/ports/bottom.list
#$#
#$#set all_ports_list [concat $left_ports $right_ports $top_ports $bottom_ports]
#$##$#set all_ports_list [get_attribute [get_ports *] full_name]
#$##$#puts "[sizeof $all_ports_list]"
#$#set all_ports [get_ports $all_ports_list]
set all_ports [get_ports *]
#$# --> set clk_ports [get_ports {cru_dxe_clk dxe3_dxe_clkin dxe4_dxe_clkin}]
set clk_ports [get_ports -filter "is_clock_pin == true" ]
set neet_to_catch_ports [remove_from_collection $all_ports $clk_ports]
set input_ports [filter_collection $neet_to_catch_ports "pin_direction == in"]
set output_ports [filter_collection $neet_to_catch_ports "pin_direction == out"]

set in_regs [filter_collection [all_fanout -from $input_ports -flat -only_cells -endpoints_only ] "ref_name =~ *SDF*"]
set out_regs [filter_collection  [all_fanin -to $output_ports -startpoints_only -only_cells -flat ] "ref_name =~ *SDF*"]
#set in_regs [filter_collection [all_fanout -from $input_ports -flat -only_cells -endpoints_only ] "is_sequential == true"]
#set out_regs [filter_collection  [all_fanin -to $output_ports -startpoints_only -only_cells -flat ] "is_sequential == true"]

set exclude_merger_regs [add_to_collection $in_regs $out_regs] 
#set_size_only $in_regs
#set_size_only $out_regs
