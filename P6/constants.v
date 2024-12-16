/******** ALUCtrl ********/
`define aluAdd 4'd0
`define aluSub 4'd1
`define aluAnd 4'd2
`define aluOr 4'd3
`define aluSlt 4'd4
`define aluSltu 4'd5
`define aluLui 4'd6
`define aluOri 4'd7
`define aluAddi 4'd8
`define aluAndi 4'd9

/******** HILOCtrl ********/
`define mduMfhi 4'd0
`define mduMflo 4'd1
`define mduMthi 4'd2
`define mduMtlo 4'd3
`define mduMult 4'd4
`define mduMultu 4'd5
`define mduDiv 4'd6
`define mduDivu 4'd7

/******** PCSel ********/
`define pc4 3'd0
`define pcBeq 3'd1
`define pcJump 3'd2
`define pcJr 3'd3
`define pcBne 3'd4

/******** WDSel ********/
`define wdDM 2'd0
`define wdAO 2'd1
`define wdPC8 2'd2

/******** RegDst ********/
`define a3rt 2'd0
`define a3rd 2'd1
`define a3ra 2'd2

/******** AOSel ********/
`define aoALU 1'd0
`define aoMDU 1'd1

/******** Controller ********/
// Opcode
`define special 6'b000000
`define lui 6'b001111
`define addi 6'b001000
`define andi 6'b001100
`define ori 6'b001101
`define lb 6'b100000
`define lh 6'b100001
`define lw 6'b100011
`define sb 6'b101000
`define sh 6'b101001
`define sw  6'b101011
`define beq 6'b000100
`define bne 6'b000101
`define jal 6'b000011

// Func
`define add 6'b100000
`define sub 6'b100010
`define and_ 6'b100100
`define or_ 6'b100101
`define slt 6'b101010
`define sltu 6'b101011
`define mult 6'b011000
`define multu 6'b011001
`define div 6'b011010
`define divu 6'b011011
`define mfhi 6'b010000
`define mflo 6'b010010
`define mthi 6'b010001
`define mtlo 6'b010011
`define jr 6'b001000
`define nop 6'b000000

/******** Instr ********/
`define OpCode Instr[31:26]
`define Rs Instr[25:21]
`define Rt Instr[20:16]
`define Rd Instr[15:11]
`define IMM16 Instr[15:0]
`define IMM26 Instr[25:0]
`define Func Instr[5:0]

/******** A-T ********/
// R
`define R_rs_Tuse 2'd1
`define R_rt_Tuse 2'd1
`define R_E_Tnew 2'd1
`define R_M_Tnew 2'd0
`define R_W_Tnew 2'd0
// I
`define I_rs_Tuse 2'd1
`define I_rt_Tuse 2'd3
`define I_E_Tnew 2'd1
`define I_M_Tnew 2'd0
`define I_W_Tnew 2'd0
// Load
`define Load_rs_Tuse 2'd1
`define Load_rt_Tuse 2'd3
`define Load_E_Tnew 2'd2
`define Load_M_Tnew 2'd1
`define Load_W_Tnew 2'd0
// Store
`define Store_rs_Tuse 2'd1
`define Store_rt_Tuse 2'd1
`define Store_E_Tnew 2'd0
`define Store_M_Tnew 2'd0
`define Store_W_Tnew 2'd0
// Md
`define Md_rs_Tuse 2'd1
`define Md_rt_Tuse 2'd1
`define Md_E_Tnew 2'd0
`define Md_M_Tnew 2'd0
`define Md_W_Tnew 2'd0
// Ht
`define Mt_rs_Tuse 2'd1
`define Mt_rt_Tuse 2'd3
`define Mt_E_Tnew 2'd0
`define Mt_M_Tnew 2'd0
`define Mt_W_Tnew 2'd0
// Mf
`define Mf_rs_Tuse 2'd3
`define Mf_rt_Tuse 2'd3
`define Mf_E_Tnew 2'd1
`define Mf_M_Tnew 2'd0
`define Mf_W_Tnew 2'd0
// Branch
`define Branch_rs_Tuse 2'd0
`define Branch_rt_Tuse 2'd0
`define Branch_E_Tnew 2'd0
`define Branch_M_Tnew 2'd0
`define Branch_W_Tnew 2'd0
// Jump
`define Jump_rs_Tuse 2'd3
`define Jump_rt_Tuse 2'd3
`define Jump_E_Tnew 2'd2
`define Jump_M_Tnew 2'd1
`define Jump_W_Tnew 2'd0
// Jr
`define Jr_rs_Tuse 2'd0
`define Jr_rt_Tuse 2'd3
`define Jr_E_Tnew 2'd0
`define Jr_M_Tnew 2'd0
`define Jr_W_Tnew 2'd0 
// Nop
`define Nop_rs_Tuse 2'd3
`define Nop_rt_Tuse 2'd3
`define Nop_E_Tnew 2'd0
`define Nop_M_Tnew 2'd0
`define Nop_W_Tnew 2'd0