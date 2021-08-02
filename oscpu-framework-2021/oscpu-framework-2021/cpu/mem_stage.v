


`include "defines.v"

module mem_stage(
  input wire rst,
  //input wire clk,

 // input wire [4 : 0]inst_type_i,
  input reg  [`REG_BUS]rd_w_data_i,
  input wire rd_w_ena_i,
  input wire [4 : 0]rd_w_addr_i, 



  output wire rd_w_ena_o,
  output wire [4 : 0]rd_w_addr_o, 
  output reg  [`REG_BUS]rd_w_data_o

 // output wire [4 : 0]inst_type_o,//? why trans this?
  
);



always@(* )
begin
  if( rst == 1'b1 )
  begin
    rd_w_addr_o = 5'b00000; //could change to define
    rd_w_ena_o = `REG_W_DISABLE;
    rd_w_data_o = `ZERO_WORD;
    
  end
  else
  begin
    rd_w_addr_o = rd_w_addr_i; 
    rd_w_ena_o = rd_w_ena_i;
    rd_w_data_o = rd_w_data_i;
   // inst_type_o = inst_type_i;
  end
end



endmodule
