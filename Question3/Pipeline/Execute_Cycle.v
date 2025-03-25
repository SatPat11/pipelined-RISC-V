module execute_cycle(clk, rst, BranchE, ALUSrcE, RegWriteE, MemReadE, memtoRegE, MemWriteE, InstrE, ALUOpE, immediateE, ReadData1E, ReadData2E, PCE, 
BranchM, RegWriteM, MemReadM, memtoRegM, MemWriteM, InstrM, ZeroM, ReadData2M, ALUOutM, PCTargetM);


    input  clk, rst, BranchE, ALUSrcE, RegWriteE, MemReadE, memtoRegE, MemWriteE;
    input  [1:0]   ALUOpE;
    input  [31:0]  immediateE, ReadData1E, ReadData2E, PCE, InstrE;

    output BranchM, RegWriteM, MemReadM, memtoRegM, MemWriteM, ZeroM;
    output [31:0] InstrM, ReadData2M, ALUOutM, PCTargetM;
    // Execute stage logic here
 
    wire [31:0] mux_input_to_ALU_BE;
    Mux2to1 #(.size(32)) m_Mux_ALU(
        .sel(ALUSrcE),
        .s0(ReadData2E),
        .s1(immediateE),
        .out(mux_input_to_ALU_BE)
    );

    wire [3:0] ALUCtl;
    ALUCtrl m_ALUCtrl(
        .ALUOp(ALUOpE),
        .funct7(InstrE[30]),
        .funct3(InstrE[14:12]),
        .ALUCtl(ALUCtl)
    );

    wire [31:0] PCTargetE;
    Adder m_Adder_2(
        .a(immediateE),
        .b(PCE),
        .sum(PCTargetE)
    );

    wire zeroE;
    wire [31:0] ALUOutE;
    ALU m_ALU(
        .ALUCtl(ALUCtl),
        .A(ReadData1E),
        .B(mux_input_to_ALU_BE),
        .ALUOut(ALUOutE),
        .zero(zeroE)
    );

    // Pipeline registers for E-to-M stage signals
    // Pipeline registers for E-to-M stage signals
    reg BranchE_r;
    reg RegWriteE_r;
    reg MemReadE_r;
    reg memtoRegE_r;
    reg MemWriteE_r;
    reg [31:0] InstrE_r;
    reg [31:0] ReadData2E_r;
    reg  zeroE_r;    // Pipeline register for zeroE, drives ZeroM
    reg [31:0] ALUOutE_r;
    reg [31:0] PCTargetE_r;

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            BranchE_r    <= 1'b0;
            RegWriteE_r  <= 1'b0;
            MemReadE_r   <= 1'b0;
            memtoRegE_r  <= 1'b0;
            MemWriteE_r  <= 1'b0;
            InstrE_r     <= 32'b0;
            ReadData2E_r <= 32'b0;
            ALUOutE_r    <= 32'b0;
            zeroE_r      <= 1'b0;
            PCTargetE_r  <= 32'b0;
        end
        else begin
            BranchE_r    <= BranchE;
            RegWriteE_r  <= RegWriteE;
            MemReadE_r   <= MemReadE;
            memtoRegE_r  <= memtoRegE;
            MemWriteE_r  <= MemWriteE;
            InstrE_r     <= InstrE;
            ReadData2E_r <= ReadData2E;
            zeroE_r      <= zeroE;
            ALUOutE_r    <= ALUOutE;
            PCTargetE_r  <= PCTargetE;
        end
    end

    // Output assign statements for the M stage
    assign BranchM    = BranchE_r;
    assign RegWriteM  = RegWriteE_r;
    assign MemReadM   = MemReadE_r;
    assign memtoRegM  = memtoRegE_r;
    assign MemWriteM  = MemWriteE_r;
    assign InstrM     = InstrE_r;
    assign ReadData2M = ReadData2E_r;
    assign ZeroM      = zeroE_r;
    assign ALUOutM    = ALUOutE_r;
    assign PCTargetM  = PCTargetE_r;

endmodule
