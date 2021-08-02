
/* verilator lint_off UNUSED */
// 顶层模块，对各个阶段进进行例化、连接

`timescale 1ns / 1ps

`include "defines.v"


module rvcpu(
  input wire            clk,
  input wire            rst,

  input wire  [31 : 0]  inst,   
  
  output wire [63 : 0]  inst_addr, 
  output wire           inst_ena 
);

//if_stage -> id_stage
wire [63 : 0] pc_IF_ID;

// id_stage -> regfile
wire [4 : 0]inst_type_o; //hang in
wire rs1_r_ena_ID_REG;
wire [4 : 0]rs1_r_addr_ID_REG;
wire rs2_r_ena_ID_REG;
wire [4 : 0]rs2_r_addr_ID_REG;



// id_stage -> exe_stage
wire [63 : 0] pc_ID_EX;

wire [6 : 0]inst_num_ID_EX;
wire [6 : 0]inst_opcode_ID_EX;

wire [`REG_BUS]op1_ID_EX;
wire [`REG_BUS]op2_ID_EX;
wire [`REG_BUS]offset_ID_EX;
wire rd_w_ena_ID_EX;
wire [4 : 0]rd_w_addr_ID_EX;

// regfile -> id_stage
wire [`REG_BUS] r_data1_REG_ID;
wire [`REG_BUS] r_data2_REG_ID;


// ex_stage -> mem_stage
wire rd_w_ena_EX_MEM;
wire [4 : 0]rd_w_addr_EX_MEM;
reg  [`REG_BUS] rd_w_data_EX_MEM;

// mem_stage -> wb_stage
wire rd_w_ena_MEM_WB;
wire [4 : 0]rd_w_addr_MEM_WB;
reg  [`REG_BUS] rd_w_data_MEM_WB;


// wb_stage -> register
wire rd_w_ena_WB_REG;
wire [4 : 0]rd_w_addr_WB_REG;
reg  [`REG_BUS] rd_w_data_WB_REG;


if_stage u_if_stage(
    .clk         ( clk        ),
    .rst         ( rst        ),
    .pc_o        ( pc_IF_ID   ),
     //.inst_addr_o ( inst_addr  ),
    .inst_ena_o  ( inst_ena   ) 
);


id_stage u_id_stage(
    .rst           ( rst              ),
    .clk           ( clk              ),
    .pc_i          ( pc_IF_ID         ),
    .inst_i        ( inst             ),
    .rs1_data_i    ( r_data1_REG_ID   ),
    .rs2_data_i    ( r_data2_REG_ID   ),
    .rs1_r_ena_o   ( rs1_r_ena_ID_REG     ),
    .rs1_r_addr_o  ( rs1_r_addr_ID_REG    ),
    .rs2_r_ena_o   ( rs2_r_ena_ID_REG     ),
    .rs2_r_addr_o  ( rs2_r_addr_ID_REG    ),
    .pc_o          ( pc_ID_EX             ),
    .inst_num_o    ( inst_num_ID_EX    ),  
    .inst_opcode_o ( inst_opcode_ID_EX ),
    .op1_o         ( op1_ID_EX         ),
    .op2_o         ( op2_ID_EX         ),
    .offset_o      ( offset_ID_EX),
    .rd_w_ena_o    ( rd_w_ena_ID_EX    ),
    .rd_w_addr_o   ( rd_w_addr_ID_EX   )
);



exe_stage u_exe_stage(
    .rst           ( rst               ),
    .clk           ( clk               ),
    .pc_i          ( pc_ID_EX          ),
    .inst_num_i    ( inst_num_ID_EX    ),
    .inst_opcode_i ( inst_opcode_ID_EX ),
    .op1_i         ( op1_ID_EX         ),
    .op2_i         ( op2_ID_EX         ),
    .offset_i      ( offset_ID_EX      ),
    .rd_w_ena_i    ( rd_w_ena_ID_EX    ),
    .rd_w_addr_i   ( rd_w_addr_ID_EX   ),
    .rd_w_ena_o    ( rd_w_ena_EX_MEM   ),
    .rd_w_addr_o   ( rd_w_addr_EX_MEM  ),
    .rd_w_data_o   ( rd_w_data_EX_MEM  ),
    .pc_o          ( inst_addr         )
);


mem_stage u_mem_stage(
    .rst         ( rst         ),
    //.clk         ( clk         ),
    .rd_w_data_i ( rd_w_data_EX_MEM ),
    .rd_w_ena_i  ( rd_w_ena_EX_MEM  ),
    .rd_w_addr_i ( rd_w_addr_EX_MEM ),
    .rd_w_ena_o  ( rd_w_ena_MEM_WB  ),
    .rd_w_addr_o ( rd_w_addr_MEM_WB ),
    .rd_w_data_o ( rd_w_data_MEM_WB )
    
);


wb_stage u_wb_stage(
    .rst         ( rst         ),
  //  .clk         ( clk         ),
    .rd_w_data_i ( rd_w_data_MEM_WB ),
    .rd_w_ena_i  ( rd_w_ena_MEM_WB  ),
    .rd_w_addr_i ( rd_w_addr_MEM_WB ),
    .rd_w_ena_o  ( rd_w_ena_WB_REG  ),
    .rd_w_addr_o ( rd_w_addr_WB_REG ),
    .rd_w_data_o ( rd_w_data_WB_REG )
);



regfile u_regfile(
   .clk       ( clk       ),
   .rst       ( rst       ),


    .r_addr1_i (  rs1_r_addr_ID_REG ),
    .r_ena1_i  ( rs1_r_ena_ID_REG   ),
    .r_addr2_i (  rs2_r_addr_ID_REG ),
    .r_ena2_i  ( rs2_r_ena_ID_REG   ),
    .w_addr_i  ( rd_w_addr_WB_REG   ),
    .w_data_i  ( rd_w_data_WB_REG   ),
    .w_ena_i   (  rd_w_ena_WB_REG   ),
    .r_data1_o ( r_data1_REG_ID     ),
    .r_data2_o ( r_data2_REG_ID     )
);



endmodule

