
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSED */

`include "defines.v"

module id_stage(
  input wire rst,
  input wire clk,

  input wire [63 : 0] pc_i,
  input wire [31 : 0]inst_i,
  //operand
  input wire [`REG_BUS]rs1_data_i,//from register
  input wire [`REG_BUS]rs2_data_i,//from register
  
  //trans to register
  output reg  rs1_r_ena_o,
  output wire [4 : 0]rs1_r_addr_o,
  output reg  rs2_r_ena_o,
  output wire [4 : 0]rs2_r_addr_o,


  //trans to exe_stage
  output wire [63 : 0] pc_o,
  //instruction
  output wire [6 : 0]inst_num_o,  
  output wire [6 : 0]inst_opcode_o,//opcode
  //operan1  operand2
  output wire [`REG_BUS]op1_o, //64 bit
  output wire [`REG_BUS]op2_o, //64 bit
  //offset
  output wire [`REG_BUS] offset_o,
  //rd  register  ena  addr
  output reg rd_w_ena_o,   //指令是否要写寄存器
  output wire [4 : 0]rd_w_addr_o    //要写的目的寄存器的地址
);




wire [6  : 0]opcode = inst_i[6  :  0];
wire [4  : 0]rd = inst_i[11 :  7];
wire [2  : 0]func3 = inst_i[14 : 12];
wire [4  : 0]rs1 = inst_i[19 : 15];
wire [11 : 0]imm = inst_i[31 : 20];
wire [4  : 0]shamt = inst_i[24 : 20];
wire [4  : 0]rs2 = inst_i[24 : 20];
wire [6  : 0]offset = inst_i[31:25];

always(*) begin
  
  if(rst == `RST_ENABLE) begin 
    //to register 
    rs1_r_ena_o=`REG_R_DISABLE;
    rs1_r_addr_o=`NO_REG;
    rs2_r_ena_o=`REG_R_DISABLE;
    rs2_r_addr_o=`NO_REG;
    //to exe_stage
    //about rd
    pc_o=`ZERO_WORD;
    rd_w_addr_o = `NO_REG;
    rd_w_ena_o = `REG_W_DISABLE;
    //about inst
  
    inst_opcode_o =  `OPCODE_rst;//opcode
  end else begin
    //
    
    inst_opcode_o =  opcode;//opcode
    pc_o=pc_i;
    rd_w_ena_o=`REG_W_DISABLE;
    rd_w_addr_o=`NO_REG;
    rs1_r_ena_o=`REG_R_DISABLE;
    rs1_r_addr_o=`NO_REG;
    rs2_r_ena_o=`REG_R_DISABLE;
    rs2_r_addr_o=`NO_REG;

    case(opcode)
       //I addi slti sltiu xori ori andi slli srli srai
      `OPCODE_0010011:  begin
        //All instruction used
        assign rd_w_ena_o = `REG_W_ENABLE;
        assign rd_w_addr_o= rd;
        assign rs1_r_ena_o  = `REG_R_ENABLE;
        assign rs1_r_addr_o = rs1;
        assign rs2_r_ena_o = `REG_R_DISABLE;
        assign rs2_r_addr_o= `NO_REG;
        assign op1_o= rs1_data_i ;
        assign offset_o=`ZERO_WORD;
        case(func3)
          //addi
          `FUNC3_ADDI: begin
            assign op2_o=  { {52{imm[11]}}, imm } ;
            assign inst_num_o= `EXE_ADDI;
          end

          //slti   有符号数对比
          `FUNC3_SLTI:begin
            assign op2_o=  { {52{imm[11]}}, imm } ;
             assign inst_num_o= `EXE_SLLI;
          end

          //sltiu   无符号数对比
          `FUNC3_SLTIU:begin
            assign op2_o=  { {52{imm[11]}}, imm } ; 
             assign inst_num_o= `EXE_SLTIU; 
          end
          //xori
          `FUNC3_XORI:begin   
            assign op2_o=  { {52{imm[11]}}, imm } ;
             assign inst_num_o= `EXE_XORI;
          end

          //ori
          `FUNC3_ORI:begin
            
            assign op2_o=  { {52{imm[11]}}, imm }   ;
             assign inst_num_o= `EXE_ORI;
          end

          //andi
          `FUNC3_ANDI:begin
            assign op2_o=  { {52{imm[11]}}, imm }  ; 
             assign inst_num_o= `EXE_ANDI;
          end

          //slli
          `FUNC3_SLLI:begin 
            assign op2_o[4:0]= shamt;
            assign inst_num_o= `EXE_SLLI;
           
          end

          //srli srai
           `FUNC3_SRLI_SRAI:begin
            assign op2_o[4:0]= shamt;
            case(inst_i[30]) 
              1'b0: begin
                assign inst_num_o= `EXE_SRLI;
              end
              1'b1:begin
                assign inst_num_o= `EXE_SRAI;
              end
            endcase
            
          end
          default: begin
             assign op2_o=`ZERO_WORD;
          end
        endcase  


      end

      //R add sub sll slt sltu xor srl sra or and 
      `OPCODE_0110011:begin
        //All instruction used
        assign rd_w_ena_o = `REG_W_ENABLE;
        assign rd_w_addr_o= rd;
        assign rs1_r_ena_o  = `REG_R_ENABLE;
        assign rs1_r_addr_o = rs1;
        assign rs2_r_ena_o = `REG_R_ENABLE;
        assign rs2_r_addr_o= rs2;
        assign op1_o= rs1_data_i;
        assign op2_o= rs2_data_i;
        assign offset_o=`ZERO_WORD;
        case(func3)
          `FUNC3_ADD_SUB: begin 
              case(inst_i[30]) 
              1'b0: begin
                assign inst_num_o= `EXE_ADD;
              end
              1'b1: begin
                assign inst_num_o= `EXE_SUB;
              end
              endcase
          end
          `FUNC3_SLL: begin assign inst_num_o= `EXE_SLL; end
          `FUNC3_SLT: begin assign inst_num_o= `EXE_SLT; end
          `FUNC3_SLTU: begin assign inst_num_o= `EXE_SLTU; end
          `FUNC3_XOR: begin assign inst_num_o= `EXE_XOR; end
          `FUNC3_SRL_SRA: begin 
             case(inst_i[30]) 
              1'b0: begin
                assign inst_num_o= `EXE_SRL;
              end
              1'b1: begin
                assign inst_num_o= `EXE_SRA;
              end
             endcase
            end
          `FUNC3_OR: begin assign inst_num_o= `EXE_OR; end
          `FUNC3_AND: begin assign inst_num_o= `EXE_AND; end
          default:begin ; end
          
        endcase

      end

      //B beq bne blt bge bltu bgeu
      `OPCODE_1100011:begin
        
        assign rs1_r_ena_o  = `REG_R_ENABLE;
        assign rs1_r_addr_o = rs1;
        assign rs2_r_ena_o = `REG_R_DISABLE;
        assign rs2_r_addr_o= rs2;
        assign op1_o= rs1_data_i ;
        assign op2_o= rs2_data_i;
        assign offset_o={ {57{offset[6]}}, offset } ;
        assign rd_w_ena_o = `REG_W_DISABLE;
        assign rd_w_addr_o= `ZERO_WORD;

        case(func3)
          `FUNC3_BEQ: begin assign inst_num_o= `EXE_BEQ; end
          `FUNC3_BNE: begin assign inst_num_o= `EXE_BNE; end
          `FUNC3_BLT: begin assign inst_num_o= `EXE_BLT; end
          `FUNC3_BGE: begin assign inst_num_o= `EXE_BGE; end
          `FUNC3_BLTU: begin assign inst_num_o= `EXE_BLTU; end
          `FUNC3_BGEU: begin assign inst_num_o= `EXE_BGEU; end
          default:begin ; end
        endcase


      end

      //I lb lh lw lbu lhu
      `OPCODE_0000011:begin
        assign rd_w_ena_o = `REG_W_ENABLE;
        assign rd_w_addr_o= rd;
        assign rs1_r_ena_o  = `REG_R_ENABLE;
        assign rs1_r_addr_o = rs1;
        assign rs2_r_ena_o = `REG_R_DISABLE;
        assign rs2_r_addr_o= rs2;
        assign op1_o= rs1_data_i ;
        assign op2_o= rs2_data_i;

        case(func3)
          `FUNC3_LB : begin assign inst_num_o= `EXE_LB; end
          `FUNC3_LH: begin assign inst_num_o= `EXE_LH; end
          `FUNC3_LW: begin assign inst_num_o= `EXE_LW; end
          `FUNC3_LBU: begin assign inst_num_o= `EXE_LBU; end
          `FUNC3_LHU: begin assign inst_num_o= `EXE_LHU; end
          default:begin ; end
       
        endcase
      end

      //S sb sh sw
      `OPCODE_0100011:begin
        assign rd_w_ena_o = `REG_W_ENABLE;
        assign rd_w_addr_o= rd;
        assign rs1_r_ena_o  = `REG_R_ENABLE;
        assign rs1_r_addr_o = rs1;
        assign rs2_r_ena_o = `REG_R_DISABLE;
        assign rs2_r_addr_o= `NO_REG;
        assign op1_o= rs1_data_i ;

        case(func3)
          `FUNC3_SB: begin assign inst_num_o= `EXE_SB; end
          `FUNC3_SH: begin assign inst_num_o= `EXE_SH; end
          `FUNC3_SW: begin assign inst_num_o= `EXE_SW; end
          default:begin ; end
        endcase
      end


      //I fence fence.i
      `OPCODE_0001111:begin
        assign rd_w_ena_o = `REG_W_ENABLE;
        assign rd_w_addr_o= rd;
        assign rs1_r_ena_o  = `REG_R_ENABLE;
        assign rs1_r_addr_o = rs1;
        assign rs2_r_ena_o = `REG_R_DISABLE;
        assign rs2_r_addr_o= `NO_REG;
        assign op1_o= rs1_data_i ;

        case(func3)
          `FUNC3_FENCE: begin assign inst_num_o= `EXE_FENCE; end
          `FUNC3_FENCEI: begin assign inst_num_o= `EXE_FENCEI; end
          default:begin ; end
          
        endcase
      end



      //I ecall ebreak csrrw csrrs csrrc csrrwi cssrrsi csrrci
      `OPCODE_1110011:begin
        assign rd_w_ena_o = `REG_W_ENABLE;
        assign rd_w_addr_o= rd;
        assign rs1_r_ena_o  = `REG_R_ENABLE;
        assign rs1_r_addr_o = rs1;
        assign rs2_r_ena_o = `REG_R_DISABLE;
        assign rs2_r_addr_o= `NO_REG;
        assign op1_o= rs1_data_i ;

         case(func3)
          `FUNC3_EBREAK_ECALL : begin
            if(inst_i[20]==0) begin
              inst_num_o= `EXE_ECALL; 
            end else begin
              inst_num_o= `EXE_EBREAK;
            end
            end
          
          `FUNC3_CSRRW: begin assign inst_num_o= `EXE_CSRRW; end
          `FUNC3_CSRRS: begin assign inst_num_o= `EXE_CSRRS; end
          `FUNC3_CSRRC: begin assign inst_num_o= `EXE_CSRRC; end
          `FUNC3_CSRRWI: begin assign inst_num_o= `EXE_CSRRWI; end
          `FUNC3_CSSRRSI: begin assign inst_num_o= `EXE_CSSRRSI; end
          `FUNC3_CSRRCI: begin assign inst_num_o= `EXE_CSRRCI; end
          default:begin ; end
        endcase

      end

      //U lui
      `OPCODE_0110111:begin
        assign rd_w_ena_o = `REG_W_ENABLE;
        assign rd_w_addr_o= rd;
        assign rs1_r_ena_o  = `REG_R_DISABLE;
        assign rs1_r_addr_o = `NO_REG;
        assign rs2_r_ena_o = `REG_R_DISABLE;
        assign rs2_r_addr_o= `NO_REG;

        assign inst_num_o= `EXE_LUI;
        assign op1_o =  { {44{inst_i[31]}}, inst_i[31:12] } ;
        assign op2_o = `ZERO_WORD;
      end


      //U auipc
      `OPCODE_0010111:begin
        assign rd_w_ena_o = `REG_W_ENABLE;
        assign rd_w_addr_o= rd;
        assign rs1_r_ena_o  = `REG_R_DISABLE;
        assign rs1_r_addr_o = `NO_REG;
        assign rs2_r_ena_o = `REG_R_DISABLE;
        assign rs2_r_addr_o= `NO_REG;
        assign inst_num_o= `EXE_AUIPC;
        assign op1_o =  { {44{inst_i[31]}}, inst_i[31:12] } ;
        assign op2_o = `ZERO_WORD;
      end

      //J jal
      `OPCODE_1101111:begin
        assign rd_w_ena_o = `REG_W_ENABLE;
        assign rd_w_addr_o= rd;
        assign rs1_r_ena_o  = `REG_R_DISABLE;
        assign rs1_r_addr_o = `NO_REG;
        assign rs2_r_ena_o = `REG_R_DISABLE;
        assign rs2_r_addr_o= `NO_REG;
        assign inst_num_o= `EXE_JAL;
        assign op1_o =  { {44{inst_i[31]}}, inst_i[31:12] } ;
        assign op2_o = `ZERO_WORD;
      end

      //I  jalr
      `OPCODE_1100111:begin
        assign rd_w_ena_o = `REG_W_ENABLE;
        assign rd_w_addr_o= rd;
        assign rs1_r_ena_o  = `REG_R_ENABLE;
        assign rs1_r_addr_o = rs1;
        assign rs2_r_ena_o = `REG_R_DISABLE;
        assign rs2_r_addr_o= `NO_REG;
        assign op1_o= rs1_data_i ;
        assign inst_num_o= `EXE_JALR;
        assign op2_o=   { {52{imm[11]}}, imm } ;
      end
    
    
    default:begin ; end
    endcase
    
  end
end





/*

wire inst_addi =   ~opcode[2] & ~opcode[3] & opcode[4] & ~opcode[5] & ~opcode[6]
                 & ~func3[0] & ~func3[1] & ~func3[2];


// arith inst: 10000; logic: 01000;
// load-store: 00100; j: 00010;  sys: 000001
assign inst_type_o[4] = ( rst == `RST_ENABLE  ) ? 0 : inst_addi;

assign inst_opcode_o[0] = (  rst == `RST_ENABLE ) ? 0 : inst_addi;
assign inst_opcode_o[1] = (  rst == `RST_ENABLE  ) ? 0 : 0;
assign inst_opcode_o[2] = (  rst == `RST_ENABLE  ) ? 0 : 0;
assign inst_opcode_o[3] = (  rst == `RST_ENABLE  ) ? 0 : 0;
assign inst_opcode_o[4] = (  rst == `RST_ENABLE  ) ? 0 : inst_addi;
assign inst_opcode_o[5] = (  rst == `RST_ENABLE  ) ? 0 : 0;
assign inst_opcode_o[6] = (  rst == `RST_ENABLE  ) ? 0 : 0;
assign inst_opcode_o[7] = (  rst == `RST_ENABLE  ) ? 0 : 0;




assign rs1_r_ena_o  = ( rst == `RST_ENABLE  ) ? 0 : inst_type_o[4];
assign rs1_r_addr_o = ( rst == `RST_ENABLE  ) ? 0 : ( inst_type_o[4] == 1'b1 ? rs1 : 0 );
assign rs2_r_ena_o = 0;
assign rs2_r_addr_o= 0;

assign rd_w_ena_o = ( rst == `RST_ENABLE  ) ? 0 : inst_type_o[4];
assign rd_w_addr_o = ( rst == `RST_ENABLE  ) ? 0 : ( inst_type_o[4] == 1'b1 ? rd  : 0 );

assign op1_o = ( rst == `RST_ENABLE  ) ? 0 : ( inst_type_o[4] == 1'b1 ? rs1_data_i : 0 );
assign op2_o= (rst == `RST_ENABLE  ) ? 0 : ( inst_type_o[4] == 1'b1 ? { {52{imm[11]}}, imm } : 0 );

*/



endmodule
