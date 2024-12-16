// ALUCtrl
`define aluAdd 3'd0
`define aluSub 3'd1
`define aluOri 3'd2
`define aluLui 3'd3

// PCSel
`define pc4 3'd0
`define pcBeq 3'd1
`define pcJal 3'd2
`define pcJr 3'd3

// WDSel
`define wdDM 2'd0
`define wdAO 2'd1
`define wdPC8 2'd2

// RegDst
`define a3rt 2'd0
`define a3rd 2'd1
`define a3ra 2'd2

// Controller
`define nop 6'b000000
`define add 6'b100000
`define sub 6'b100010
`define ori 6'b001101
`define lui 6'b001111
`define lw  6'b100011
`define sw  6'b101011
`define beq 6'b000100
`define jal 6'b000011
`define jr  6'b001000

// Instr
`define OpCode Instr[31:26]
`define Rs Instr[25:21]
`define Rt Instr[20:16]
`define Rd Instr[15:11]
`define IMM16 Instr[15:0]
`define IMM26 Instr[25:0]
`define Func Instr[5:0]

// A-T
/********  add  ********/
`define add_rs_Tuse 2'd1
`define add_rt_Tuse 2'd1
`define add_E_Tnew 2'd1
`define add_M_Tnew 2'd0
`define add_W_Tnew 2'd0
/********  sub  ********/
`define sub_rs_Tuse 2'd1
`define sub_rt_Tuse 2'd1
`define sub_E_Tnew 2'd1
`define sub_M_Tnew 2'd0
`define sub_W_Tnew 2'd0
/********  ori  ********/
`define ori_rs_Tuse 2'd1
`define ori_rt_Tuse 2'd3
`define ori_E_Tnew 2'd1
`define ori_M_Tnew 2'd0
`define ori_W_Tnew 2'd0
/********  lui  ********/
`define lui_rs_Tuse 2'd1
`define lui_rt_Tuse 2'd3
`define lui_E_Tnew 2'd1
`define lui_M_Tnew 2'd0
`define lui_W_Tnew 2'd0
/********  lw   ********/
`define lw_rs_Tuse 2'd1
`define lw_rt_Tuse 2'd3
`define lw_E_Tnew 2'd2
`define lw_M_Tnew 2'd1
`define lw_W_Tnew 2'd0
/********  sw   ********/
`define sw_rs_Tuse 2'd1
`define sw_rt_Tuse 2'd1
`define sw_E_Tnew 2'd0
`define sw_M_Tnew 2'd0
`define sw_W_Tnew 2'd0
/********  beq  ********/
`define beq_rs_Tuse 2'd0
`define beq_rt_Tuse 2'd0
`define beq_E_Tnew 2'd0
`define beq_M_Tnew 2'd0
`define beq_W_Tnew 2'd0
/********  nop  ********/
`define nop_rs_Tuse 2'd3
`define nop_rt_Tuse 2'd3
`define nop_E_Tnew 2'd0
`define nop_M_Tnew 2'd0
`define nop_W_Tnew 2'd0
/********  jal  ********/
`define jal_rs_Tuse 2'd3
`define jal_rt_Tuse 2'd3
`define jal_E_Tnew 2'd2
`define jal_M_Tnew 2'd1
`define jal_W_Tnew 2'd0
/********  jr   ********/
`define jr_rs_Tuse 2'd0
`define jr_rt_Tuse 2'd3
`define jr_E_Tnew 2'd0
`define jr_M_Tnew 2'd0
`define jr_W_Tnew 2'd0 