
`timescale 1ns / 1ps

`define ZERO_WORD  64'h00000000_00000000   
`define REG_BUS    63 : 0 
`define NO_REG     5'b00000    // rst valid  regester address turns to 0

`define INST_ADD   8'h11

`define REG_W_DISABLE  1'b0 
`define REG_W_ENABLE  1'b1
`define REG_R_DISABLE  1'b0
`define REG_R_ENABLE  1'b1
`define RST_ENABLE 1'b1


//******************OPCODE**************
//rst valid
`define OPCODE_rst        7'b0000000
//U lui 
`define OPCODE_0110111    7'b0110111
//U auipc
`define OPCODE_0010111    7'b0010111
//J jal 
`define OPCODE_1101111    7'b1101111
//I jalr
`define OPCODE_1100111    7'b1100111
//B beq bne blt bge bltu bgeu
`define OPCODE_1100011    7'b1100011
//I lb lh lw lbu lhu
`define OPCODE_0000011    7'b0000011
//S sb sh sw
`define OPCODE_0100011    7'b0100011
//I addi slti sltiu xori ori andi slli srli srai
`define OPCODE_0010011    7'b0010011
//R add sub sll slt sltu xor srl sra or and 
`define OPCODE_0110011    7'b0110011
//I fence fence.i
`define OPCODE_0001111    7'b0001111
//I ecall ebreak csrrw csrrs csrrc csrrwi cssrrsi csrrci
`define OPCODE_1110011    7'b1110011



//*************func3*****************
//rst valid
`define FUNC3_rst        3'b000



//opcode:1100011
//B beq bne blt bge bltu bgeu
`define FUNC3_BEQ       3'b000
`define FUNC3_BNE       3'b001
`define FUNC3_BLT       3'b100
`define FUNC3_BGE       3'b101
`define FUNC3_BLTU      3'b110
`define FUNC3_BGEU      3'b111


//opcode:0000011 
//I lb lh lw lbu lhu
`define FUNC3_LB        3'b000
`define FUNC3_LH        3'b001
`define FUNC3_LW        3'b010
`define FUNC3_LBU       3'b100
`define FUNC3_LHU       3'b101

//opcode:0100011
//S sb sh sw
`define FUNC3_SB        3'b000
`define FUNC3_SH        3'b001
`define FUNC3_SW        3'b010
//opcode:0010011
//addi slti sltiu xori ori andi slli srli srai

`define FUNC3_ADDI       3'b000
`define FUNC3_SLTI       3'b010
`define FUNC3_SLTIU      3'b011
`define FUNC3_XORI       3'b100
`define FUNC3_ORI        3'b110
`define FUNC3_ANDI       3'b111
`define FUNC3_SLLI       3'b001
`define FUNC3_SRLI_SRAI  3'b101


//opceode: 01110011
//R add sub sll slt sltu xor srl sra or and 
`define FUNC3_ADD_SUB    3'b000
`define FUNC3_SLL        3'b001
`define FUNC3_SLT        3'b010
`define FUNC3_SLTU       3'b011
`define FUNC3_XOR        3'b100
`define FUNC3_SRL_SRA    3'b101
`define FUNC3_OR         3'b110
`define FUNC3_AND        3'b111

//opcede: 0001111
//I fence fence.i
`define FUNC3_FENCE     3'b000
`define FUNC3_FENCEI     3'b001

//opcode: 1110011
//I ecall ebreak csrrw csrrs csrrc csrrwi cssrrsi csrrci
`define FUNC3_EBREAK_ECALL   3'b000

`define FUNC3_CSRRW   3'b001

`define FUNC3_CSRRS   3'b010
`define FUNC3_CSRRC   3'b011
`define FUNC3_CSRRWI   3'b101
`define FUNC3_CSSRRSI   3'b110
`define FUNC3_CSRRCI   3'b111






//***************inst exe num***************


`define EXE_LUI       7'b0000001
`define EXE_AUIPC     7'b0000010
`define EXE_JAL       7'b0000011
`define EXE_JALR      7'b0000100
`define EXE_BEQ       7'b0000101
`define EXE_BNE       7'b0000110
`define EXE_BLT       7'b0000111
`define EXE_BGE       7'b0001000
`define EXE_BLTU      7'b0001001
`define EXE_BGEU      7'b0001010
`define EXE_LB        7'b0001011
`define EXE_LH        7'b0001100
`define EXE_LW        7'b0001101
`define EXE_LBU       7'b0001110
`define EXE_LHU       7'b0001111
`define EXE_SB        7'b0010000
`define EXE_SH        7'b0010001
`define EXE_SW        7'b0010010
`define EXE_ADDI      7'b0010011
`define EXE_SLTI      7'b0010100
`define EXE_SLTIU     7'b0010101
`define EXE_XORI      7'b0010110
`define EXE_ORI       7'b0010111
`define EXE_ANDI      7'b0011000
`define EXE_SLLI      7'b0011001
`define EXE_SRLI      7'b0011010
`define EXE_SRAI      7'b0011011
`define EXE_ADD       7'b0011100
`define EXE_SUB       7'b0011101
`define EXE_SLL       7'b0011110
`define EXE_SLT       7'b0011111
`define EXE_SLTU      7'b0100000
`define EXE_XOR       7'b0100001
`define EXE_SRL       7'b0100010
`define EXE_SRA       7'b0100011
`define EXE_OR        7'b0100100
`define EXE_AND       7'b0100101
`define EXE_FENCE     7'b0100110
`define EXE_FENCEI    7'b0100111
`define EXE_ECALL     7'b0101000
`define EXE_EBREAK    7'b0101001
`define EXE_CSRRW     7'b0101010
`define EXE_CSRRS     7'b0101011
`define EXE_CSRRC     7'b0101100
`define EXE_CSRRWI    7'b0101101
`define EXE_CSSRRSI   7'b0101110
`define EXE_CSRRCI    7'b0101111