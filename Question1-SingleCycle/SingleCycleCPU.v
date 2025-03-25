`include "Adder.v"
`include "ALU.v"
`include "ALUCtrl.v"
`include "Control.v"
`include "DataMemory.v"
`include "ImmGen.v"
`include "InstructionMemory.v"
`include "Mux2to1.v"
`include "PC.v"
`include "Register.v"
`include "ShiftLeftOne.v"

module SingleCycleCPU (
    input clk,
    input start
);

// When input start is zero, cpu should reset
// When input start is high, cpu start running

// TODO: connect wire to realize SingleCycleCPU
// The following provides simple template,


// wire definintions for PC. pc_next_def = pc_current +  4 (def means no offset)
//pc_current will now be transferred onto the instmem to generate instr
wire [31:0] pc_current;
wire [31:0] pc_next_def;

PC m_PC(
    .clk(clk),
    .rst(start),
    .pc_i(pc_next),         // in this we actually give the next as the input and current output because 
    .pc_o(pc_current)       // ouput holds current value and next holds what current will have become
);

Adder m_Adder_1(
    .a(pc_current),
    .b(32'd4),
    .sum(pc_next_def)
);

//initialise a 32 bit instruction array which will be later passed on to the other blocks
wire [31:0] instruction;
InstructionMemory m_InstMem(
    .readAddr(pc_current),       //pc_current is the address that will be read by instruction memory and it will provide
                                 //relevant instructions to the other units based off that
    .inst(instruction)
);


//last 7bits [6:0] is passed off as opcode and then we will have to initialize wires for remaining output wires
wire branch;
wire memRead;
wire memtoReg;
wire [1:0] ALUOp;
wire memWrite;
wire ALUSrc;
wire regWrite;
// these wires will be fed into the instance 

Control m_Control(
    .opcode(instruction[6:0]),
    .branch(branch),
    .memRead(memRead),
    .memtoReg(memtoReg),
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .ALUSrc(ALUSrc),
    .regWrite(regWrite)
);

// Wires for register file outputs
wire [31:0] regReadData1;
wire [31:0] regReadData2;
// here is how the instruction is split into the Register:
/*  The source register addresses are extracted from the instruction fields.
    readReg1 is from bits [19:15] (rs1)
    readReg2 is from bits [24:20] (rs2)
    writeReg is from bits [11:7] (rd)
*/
//regWrite - coming from contorl unit
//writeData will be coming from the memory later

// IMP - REMEMBER TO PLACE FOR WIRE FOR WriteData -> NOT DONE YET


Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regWrite),
    .readReg1(instruction[19:15]),
    .readReg2(instruction[24:20]),
    .writeReg(instruction[11:7]),
    .writeData(writeData),
    .readData1(regReadData1),
    .readData2(regReadData2)
);

// take a wire for output with the immGen and it will take in full 32 bit instruction
wire [31:0] immediate;

ImmGen #(.Width(32)) m_ImmGen(
    .inst(instruction),
    .imm(immediate)
);

// assume the next 2 line shifrting and the adding are meant for the PC offseting(JAL)
// take in the immediate input -> shift it by left 1
// then add it to the pc then use mux to select and decide if branching or no
// but this shifting offset is done by concatenation already so no need
ShiftLeftOne m_ShiftLeftOne(
    .i(),
    .o()
);

//we will add a wire to the PC mux input which will be the offset given to the PC
wire [31:0] offset_PC;
Adder m_Adder_2(
    .a(pc_current),
    .b(immediate),
    .sum(offset_PC)
);

// and gate of branch and zero flag is sel for PC mux
assign PC_sel_mux = branch & zero;
wire [31:0] pc_next;
Mux2to1 #(.size(32)) m_Mux_PC(
    .sel(PC_sel_mux),
    .s0(pc_next_def),
    .s1(offset_PC),
    .out(pc_next)
);

//wire for the mux output which is input to alu aka actual ALUSRC
wire [31:0] mux_input_to_ALU_B;
Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(ALUSrc),
    .s0(regReadData2),
    .s1(immediate),
    .out(mux_input_to_ALU_B)
);

//func7 is basically instruction[30] - 0 for add 1 for sub
wire [3:0] ALUCtl;
ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp),
    .funct7(instruction[30]),
    .funct3(instruction[14:12]),
    .ALUCtl(ALUCtl)
);

//reg for alu outs
wire [31:0] ALUOut;
wire zero;
ALU m_ALU(
    .ALUCtl(ALUCtl),
    .A(regReadData1),
    .B(mux_input_to_ALU_B),
    .ALUOut(ALUOut),
    .zero(zero)
);

wire [31:0] readDataMux1;
DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite),
    .memRead(memRead),
    .address(ALUOut),
    .writeData(regReadData2),
    .readData(readDataMux1)
);

//finally iniitalize the missing writeData
wire [31:0] writeData;
Mux2to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoReg),
    .s0(ALUOut),
    .s1(readDataMux1),
    .out(writeData)
);

endmodule
