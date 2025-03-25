module Fetch_Cycle(clk, rst, PCSrc_final, PCTarget_final, InstrD, PCD);

    //the inputs and outputs of the module
    input clk, rst;
    input [31:0] PCTarget_final;
    input PCSrc_final;
    output [31:0] InstrD, PCD;

    // the wires for in between flow
    wire [31:0] input_to_PC, output_from_PC, PCPlus4F;
    wire [31:0] instruction;

    // Declaration of Register
    reg [31:0] instruction_reg;
    reg [31:0] output_from_PC_reg;


    // Initiation of Modules
    // Declare PC Mux
    Mux2to1 #(.size(32)) m_Mux_PC(
        .sel(PCSrc_final),
        .s0(PCPlus4F),
        .s1(PCTarget_final),
        .out(input_to_PC)
        );

    // Declare PC Counter
    PC m_PC(
        .clk(clk),
        .rst(start),
        .pc_i(input_to_PC),          
        .pc_o(output_from_PC)       
        );

    // Declare Instruction Memory
    InstructionMemory m_InstMem(
            .readAddr(output_from_PC),                    
            .inst(instruction)
        );

    // Declare PC adder
    Adder m_Adder_1(
            .a(output_from_PC),
            .b(32'd4),
            .sum(PCPlus4F)
        );

    // the register logic for the fetch cycle:
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            instruction_reg <= 32'h00000000;
            output_from_PC_reg <= 32'h00000000;
        end
        else begin
            instruction_reg <= instruction;
            output_from_PC_reg <= output_from_PC;
        end
    end


    // Assigning Registers Value to the Output port
    assign  InstrD = instruction_reg;
    assign  PCD = output_from_PC_reg;

endmodule

