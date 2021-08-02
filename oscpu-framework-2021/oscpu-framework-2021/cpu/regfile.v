
`include "defines.v"

module regfile(
    input  wire clk,
	input  wire rst,

	//from id_stage
	input  wire  [4  : 0] r_addr1_i,
	input  wire 		  r_ena1_i,
	
	input  wire  [4  : 0] r_addr2_i,	
	input  wire 		  r_ena2_i,

	//from wb_stage
	input  wire  [4  : 0] w_addr_i,
	input  wire  [`REG_BUS] w_data_i,
	input  wire 		  w_ena_i,
 
	//trans to id_stage
	output reg   [`REG_BUS] r_data1_o,
	output reg   [`REG_BUS] r_data2_o
    );

    // 32 registers
	reg [`REG_BUS] 	regs[0 : 31];
	
	always @(posedge clk) 
	begin
		if ( rst == `RST_ENABLE ) 
		begin
			regs[ 0] <= `ZERO_WORD;
			regs[ 1] <= `ZERO_WORD;
			regs[ 2] <= `ZERO_WORD;
			regs[ 3] <= `ZERO_WORD;
			regs[ 4] <= `ZERO_WORD;
			regs[ 5] <= `ZERO_WORD;
			regs[ 6] <= `ZERO_WORD;
			regs[ 7] <= `ZERO_WORD;
			regs[ 8] <= `ZERO_WORD;
			regs[ 9] <= `ZERO_WORD;
			regs[10] <= `ZERO_WORD;
			regs[11] <= `ZERO_WORD;
			regs[12] <= `ZERO_WORD;
			regs[13] <= `ZERO_WORD;
			regs[14] <= `ZERO_WORD;
			regs[15] <= `ZERO_WORD;
			regs[16] <= `ZERO_WORD;
			regs[17] <= `ZERO_WORD;
			regs[18] <= `ZERO_WORD;
			regs[19] <= `ZERO_WORD;
			regs[20] <= `ZERO_WORD;
			regs[21] <= `ZERO_WORD;
			regs[22] <= `ZERO_WORD;
			regs[23] <= `ZERO_WORD;
			regs[24] <= `ZERO_WORD;
			regs[25] <= `ZERO_WORD;
			regs[26] <= `ZERO_WORD;
			regs[27] <= `ZERO_WORD;
			regs[28] <= `ZERO_WORD;
			regs[29] <= `ZERO_WORD;
			regs[30] <= `ZERO_WORD;
			regs[31] <= `ZERO_WORD;
		end
		else 
		// this is write back implementation 
		begin
			if ((w_ena_i == 1'b1) && (w_addr_i != 5'h00))	
				regs[w_addr_i] <= w_data_i;
		end
	end
	
	always @(*) begin
		if (rst == `RST_ENABLE)
			r_data1_o = `ZERO_WORD;
		else if (r_ena1_i == 1'b1)
			r_data1_o = regs[r_addr1_i];
		else
			r_data1_o = `ZERO_WORD;
	end
	
	always @(*) begin
		if (rst == `RST_ENABLE)
			r_data2_o = `ZERO_WORD;
		else if (r_ena2_i == 1'b1)
			r_data2_o = regs[r_addr2_i];
		else
			r_data2_o = `ZERO_WORD;
	end

endmodule

