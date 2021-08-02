
/* verilator lint_off UNUSED */
//

`include "defines.v"

module if_stage(
  input wire clk,
  input wire rst,
  

  output wire [63 : 0] pc_o,
  //output wire [63 : 0] inst_addr_o,
  output wire          inst_ena_o
  
);

reg [`REG_BUS]pc;

// fetch an instruction
always@( posedge clk )  
  begin
    // 
    if( rst == `RST_ENABLE )
    begin
      pc <= `ZERO_WORD ;
      
    end
    /*
    else begin
      
      pc <= pc + 4;
      
    end
    */
end

assign pc_o=pc;
//assign inst_addr_o= pc;  
assign inst_ena_o= ( rst == `RST_ENABLE ) ? 0 : 1;    


endmodule
