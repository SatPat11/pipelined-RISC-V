`include "Fetch_Cycle.v"
`include "Decode_Cycle.v"
`include "Execute_Cycle.v"
`include "Memory_Cycle.v"
`include "WriteBack_Cycle.v"
`include "Mux2to1.v"
`include "PC.v"
`include "InstructionMemory.v"
`include "Adder.v"
`include "Register.v"
`include "Control.v"
`include "ImmGen.v"
`include "ALU.v"
`include "ALUCtrl.v"
`include "DataMemory.v"

module Pipeline(clk, rst);

    input clk, rst;

    wire PCSrc_final, RegWriteW, BranchE, MemReadE, MemWriteE, ALUSrcE, RegWriteE, memtoRegE;
    wire BranchM, RegWriteM, MemReadM, memtoRegM, MemWriteM, ZeroM, memtoRegW;
    wire [31:0] PCTarget_final, InstrD, PCD, InstrE, WriteDataW, PCE, ReadData1E, ReadData2E, immediateE;
    wire [31:0] InstrM, ReadData2M, ALUOutM, readDataW, ALUOutW, InstrW, PCTargetM;
    wire [4:0] Write_reg_4bit;
    wire [1:0] ALUOpE;

    Fetch_Cycle fetch_cycle_inst (
        .clk(clk),
        .rst(rst),
        .PCSrc_final(PCSrc_final),
        .PCTarget_final(PCTarget_final),
        .InstrD(InstrD),
        .PCD(PCD)
    );    

    decode_cycle decode_cycle_inst (
        .clk(clk),
        .rst(rst),
        .InstrD(InstrD),
        .InstrE(InstrE),
        .PCD(PCD),
        .RegWriteW(RegWriteW),
        .WriteDataW(WriteDataW),
        .BranchE(BranchE),
        .MemReadE(MemReadE),
        .ALUOpE(ALUOpE),
        .MemWriteE(MemWriteE),
        .ALUSrcE(ALUSrcE),
        .RegWriteE(RegWriteE),
        .PCE(PCE),
        .ReadData1E(ReadData1E),
        .ReadData2E(ReadData2E),
        .memtoRegE(memtoRegE),
        .immediateE(immediateE),
        .Write_reg_4bit(Write_reg_4bit)
    );

    execute_cycle execute_cycle_inst (
        .clk(clk),
        .rst(rst),
        .BranchE(BranchE),
        .ALUSrcE(ALUSrcE),
        .RegWriteE(RegWriteE),
        .MemReadE(MemReadE),
        .memtoRegE(memtoRegE),
        .MemWriteE(MemWriteE),
        .InstrE(InstrE),
        .ALUOpE(ALUOpE),
        .immediateE(immediateE),
        .ReadData1E(ReadData1E),
        .ReadData2E(ReadData2E),
        .PCE(PCE),
        .BranchM(BranchM),
        .RegWriteM(RegWriteM),
        .MemReadM(MemReadM),
        .memtoRegM(memtoRegM),
        .MemWriteM(MemWriteM),
        .InstrM(InstrM),
        .ZeroM(ZeroM),
        .ReadData2M(ReadData2M),
        .ALUOutM(ALUOutM),
        .PCTargetM(PCTargetM)
    );

    memory_cycle memory_cycle_inst (
        .clk(clk),
        .rst(rst),
        .BranchM(BranchM),
        .RegWriteM(RegWriteM),
        .MemReadM(MemReadM),
        .memtoRegM(memtoRegM),
        .MemWriteM(MemWriteM),
        .InstrM(InstrM),
        .ReadData2M(ReadData2M),
        .ZeroM(ZeroM),
        .ALUOutM(ALUOutM),
        .PCSrc_final(PCSrc_final),
        .PCTargetM(PCTargetM),
        .RegWriteW(RegWriteW),
        .readDataW(readDataW),
        .ALUOutW(ALUOutW),
        .PCTarget_final(PCTarget_final),
        .InstrW(InstrW),
        .memtoRegW(memtoRegW)
    );

    WriteBack writeback_inst (
        .RegWriteW(RegWriteW),
        .memtoRegW(memtoRegW),
        .ALUOutW(ALUOutW),
        .InstrW(InstrW),
        .readDataW(readDataW),
        .Write_data_Register_final(WriteDataW),
        .RegWrite_final_to_E(RegWriteW), 
        .Write_reg_4bit(Write_reg_4bit)
    );


endmodule