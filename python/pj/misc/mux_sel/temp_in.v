//
//  auto generated by mux_sel.py
//

// wire declaration
module uop_temp_out
  (
   {%-for output_name in output_lst%}
   output {{output_name}},
   {%-endfor%}

   input wire [7:0] A0 , //src1 data
   input wire [7:0] A1 , //src1 data
   input wire [7:0] A2 , //src1 data
   input wire [7:0] A3 , //src1 data
   input wire [7:0] A4 , //src1 data
   input wire [7:0] A5 , //src1 data
   input wire [7:0] A6 , //src1 data
   input wire [7:0] A7 , //src1 data
   input wire [7:0] A8 , //src1 data
   input wire [7:0] A9 , //src1 data
   input wire [7:0] A10, //src1 data
   input wire [7:0] A11, //src1 data
   input wire [7:0] A12, //src1 data
   input wire [7:0] A13, //src1 data
   input wire [7:0] A14, //src1 data
   input wire [7:0] A15, //src1 data
   input wire [7:0] B0 , //src2 data
   input wire [7:0] B1 , //src2 data
   input wire [7:0] B2 , //src2 data
   input wire [7:0] B3 , //src2 data
   input wire [7:0] B4 , //src2 data
   input wire [7:0] B5 , //src2 data
   input wire [7:0] B6 , //src2 data
   input wire [7:0] B7 , //src2 data
   input wire [7:0] B8 , //src2 data
   input wire [7:0] B9 , //src2 data
   input wire [7:0] B10, //src2 data
   input wire [7:0] B11, //src2 data
   input wire [7:0] B12, //src2 data
   input wire [7:0] B13, //src2 data
   input wire [7:0] B14, //src2 data
   input wire [7:0] B15, //src2 data
   input wire [7:0] imm, //imm data
   input wire [127:0] B, //src2 data
   input wire [127:0] A, //src1 data

   {%-for input_name in input_lst%}
   {%-if loop.last%}
   input {{input_name}}
   {%-else%}
   input {{input_name}},
   {%-endif%}
   {%-endfor%}
   );

   {%-for wire_name in wire_lst%}
   wire {{wire_name}};
   {%-endfor%}

   // assignments
   {%-for assign_key, assign_value in assign_dic|dictsort%}
   assign {{assign_key}} = {{assign_value}};
   {%-endfor%}

endmodule
