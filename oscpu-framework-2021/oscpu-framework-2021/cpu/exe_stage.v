
//--xuezhen--

`include "defines.v"

module exe_stage(
  input wire rst,
  
 //from exe_stage
  input wire [63 : 0]pc_i,
  input wire [6 : 0]inst_num_i,
  input wire [6 : 0]inst_opcode_i,

  input wire [`REG_BUS]op1_i,
  input wire [`REG_BUS]op2_i,
  input wire [`REG_BUS]offset_i,

  input wire rd_w_ena_i,
  input wire [4 : 0]rd_w_addr_i,



  //trans to mem_stage
  output wire rd_w_ena_o,
  output wire [4 : 0]rd_w_addr_o, 
  output reg  [`REG_BUS]rd_w_data_o,

  output wire [63 : 0] pc_o

);

//assign inst_type_o = inst_type_i;
assign rd_w_ena_o = rd_w_ena_i;
assign rd_w_addr_o = rd_w_addr_i;

//第二个操作数的补码
wire [`REG_BUS ] op2_mux = (~op2_i)+1;
wire [`REG_BUS ] sub_result = op1_i + op2_mux;

/*      
 *根据inst_opcode指示的运算类型进行相应的逻辑操作
 */
always@( * )
begin
  if( rst ==  `RST_ENABLE )
  begin
    rd_w_data_o = `ZERO_WORD;
    pc_o=pc_i;
  end


  else begin
    rd_w_data_o = `ZERO_WORD;
    
    case( inst_opcode_i )
      
      //I addi slti sltiu xori ori andi slli srli srai
      `OPCODE_0010011: begin 
        pc_o=pc_i+4;
        case(inst_num_i)
          //addi  ignore arithmetic overflow
          `EXE_ADDI:begin
            rd_w_data_o = op1_i + op2_i; 
          end
          //slti 有符号比较
          `EXE_SLTI:begin
            //op1<0 op2<0 op1-op2<0 op1<op2
            //op1<0 op2>0 op1<op2
            //op1>0 op2>0 op1-op2<0 op1<op2
             if((op1_i[63]&&op2_i[63]&&sub_result[63]) || (op1_i[63]&& !op2_i[63]) || (!op1_i[63] && !op2_i[63] && sub_result[63])) begin
               rd_w_data_o=1;
             end else begin
               rd_w_data_o=0;
             end
             
          
          end
          //sltiu
          `EXE_SLTIU:begin
             rd_w_data_o = (op1_i<op2_i)?1:0; 
             //if(op1_i==ZERO_WORD) begin rd_w_data_o = 1; end
          end

          //xori 
          `EXE_XORI:begin
             rd_w_data_o = op1_i^op2_i; 
          end

          //ori 
          `EXE_ORI:begin
             rd_w_data_o = op1_i | op2_i; 
          end

          //andi
          `EXE_ANDI:begin
            rd_w_data_o = op1_i & op2_i; 
          end
          
          //slli
          `EXE_SLLI:begin
            rd_w_data_o = op1_i << op2_i[5:0];
          end
          //srli
          `EXE_SRLI:begin
            rd_w_data_o = op1_i >> op2_i[5:0];
          end

          //srai
          `EXE_SRAI:begin
            rd_w_data_o = ($signed(op1_i)) >>> op2_i[5:0];
          end

          default:begin rd_w_data_o=`ZERO_WORD; end
        endcase
        
      end

      //R add sub sll slt sltu xor srl sra or and 
      `OPCODE_0110011 :begin
        pc_o=pc_i+4;
        case(inst_num_i)
          //add
          `EXE_ADD: begin
            rd_w_data_o = op1_i + op2_i;
          end
          //sub
          `EXE_SUB:begin
            rd_w_data_o = op1_i - op2_i; 
          end
          //sll
          `EXE_SLL:begin
            rd_w_data_o = op1_i << op2_i[5:0];
          end
          //slt01
          `EXE_SLTI:begin 
          //op1<0 op2<0 op1-op2<0 op1<op2
          //op1<0 op2>0 op1<op2
          //op1>0 op2>0 op1-op2<0 op1<op2
            if((op1_i[63]&&op2_i[63]&&sub_result[63]) || (op1_i[63]&& !op2_i[63]) || (!op1_i[63] && !op2_i[63] && sub_result[63])) begin
              rd_w_data_o=1;
            end else begin
              rd_w_data_o=0;
            end
          end
          //sltu
          `EXE_SLTIU:begin
            rd_w_data_o = (op1_i<op2_i)?1:0; 
            if(op1_i==`ZERO_WORD) begin rd_w_data_o = 1; end
          end
          //xor
          `EXE_XOR:begin
            rd_w_data_o = op1_i ^ op2_i; 
          end

          //or
          `EXE_OR:begin
            rd_w_data_o = op1_i | op2_i; 
          end

          //and
          `EXE_AND:begin
            rd_w_data_o = op1_i & op2_i; 
          end
          
         
          //srl
          `EXE_SRL:begin
            rd_w_data_o = op1_i >> op2_i[5:0];
          end

          //sra
          `EXE_SRA:begin
            rd_w_data_o = ($signed(op1_i)) >>> op2_i[5:0];
          end

          default:begin rd_w_data_o=`ZERO_WORD; end
        endcase


      end


      //B beq bne blt bge bltu bgeu
      `OPCODE_1100011 :begin
        
        case(inst_num_i)
          //beq
          `EXE_BEQ:begin
            if(op1_i == op2_i) begin pc_o = pc_i +offset_i;  end
            else begin pc_o=pc_i + 4;end
          end
          //bne
          `EXE_BNE:begin
            if(op1_i != op2_i) begin pc_o = pc_i +offset_i;  end
            else begin pc_o=pc_i + 4;end
          end
          //blt  均视为补码来比较
          //op1<0 op2>=0
          //op1<0 op2<0  op1<op2
          //op1>0 op2>0  op1<op2
          `EXE_BLT:begin
            if((op1_i[63]&& !op2_i[63]) || ( !op1_i[63]&& !op2_i[63] && (op1_i < op2_i)) ||(op1_i[63]&&op2_i[63]&&(op1_i < op2_i))) begin
              pc_o=pc_i+offset_i;
            end  else  begin 
              pc_o=pc_i + 4;
            end
            
          end
          //bge >=
          //op1>0 op2<0
          //op1<0 op2<0  op1>=op2
          //op1>0 op2>0  op1>=op2
          `EXE_BGE:begin
             if((!op1_i[63]&& op2_i[63]) || (!op1_i[63]&& !op2_i[63] && (op1_i >= op2_i)) || (op1_i[63]&&op2_i[63]&&(op1_i>=op2_i))) begin
              pc_o=pc_i+offset_i;
             end  else begin 
              pc_o=pc_i + 4;
            end
          end
          //bltu
          `EXE_BLTU:begin
            if(op1_i < op2_i) begin pc_o = pc_i +offset_i;  end
            else begin 
              pc_o=pc_i + 4;
            end
          end
          //bgeu
          `EXE_BGEU:begin
            if(op1_i >= op2_i) begin pc_o = pc_i +offset_i;  end
            else begin 
              pc_o=pc_i + 4;
            end
          end
          default:begin pc_o=pc_i +4 ;   end
        endcase




      end

      //lui
      `OPCODE_0110111 :begin
        pc_o=pc_i+4;
        rd_w_data_o = op1_i << 12 ;
      end

      //auipc
      `OPCODE_0010111:begin
        pc_o=pc_i+4;
        rd_w_data_o = op1_i << 12 +pc_i;
      end

      //jal
      `OPCODE_1101111:begin
        
        rd_w_data_o = pc_i+4;
        pc_o= pc_i + op1_i;

      end

      //jalr
      `OPCODE_1100111:begin
        
        rd_w_data_o = pc_i+4;
        pc_o= (op1_i+op2_i)&(~1);

      end

      //
      `OPCODE_1110011:begin
        pc_o= pc_i+4;
        rd_w_data_o = `ZERO_WORD; 
        case(inst_num_i)
          //ecall
          `EXE_ECALL:begin
            
          end
          //ebreak
          `EXE_EBREAK:begin
            
          end
          //csrrw
          `EXE_CSRRW:begin
            
          end
          //csrrs
          `EXE_CSRRS:begin
            
          end
          //csrrc
          `EXE_CSRRC:begin
            
          end
          //csrrwi
          `EXE_CSRRWI:begin
            
          end
          //cssrrsi
          `EXE_CSSRRSI:begin
            
          end
          //csrrci
          `EXE_CSRRCI:begin
            
          end

          default:begin ; end

        endcase



      end



      default:begin 
        rd_w_data_o = `ZERO_WORD; 
        pc_o= pc_i+4;
      end
	  endcase
  end
end



endmodule
