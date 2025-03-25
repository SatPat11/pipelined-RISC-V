module memory_cycle(clk, rst, BranchM, RegWriteM, MemReadM, memtoRegM, MemWriteM, InstrM, ReadData2M, ZeroM, ALUOutM, PCSrc_final, PCTargetM,
RegWriteW, readDataW, ALUOutW, PCTarget_final, InstrW, memtoRegW);


    input  clk, rst, BranchM, RegWriteM, MemReadM, memtoRegM, MemWriteM, ZeroM;
    input  [31:0]  InstrM, ReadData2M, ALUOutM, PCTargetM;

    output PCSrc_final;
    output RegWriteW, memtoRegW;
    output [31:0] readDataW, ALUOutW, PCTarget_final, InstrW;

    wire PCSrcM;
    //assign PCSrcM = ZeroM & BranchM;
    assign PCTarget_final = PCTargetM;
    assign PCSrc_final = ZeroM & BranchM;
    
    wire [31:0] readDataM;
    DataMemory m_DataMemory(
        .rst(rst),
        .clk(clk),
        .memWrite(MemWriteM),
        .memRead(MemReadM),
        .address(ALUOutM),
        .writeData(ReadData2M),
        .readData(readDataM)
    );

    
    reg RegWriteM_r;
    reg memtoRegM_r;
    reg [31:0] ALUOutM_r;
    reg [31:0] InstrM_r;
    reg [31:0] readDataM_r;
    reg PCSrcM_r;
    reg [31:0] PCTargetM_r;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            RegWriteM_r <= 1'b0;
            memtoRegM_r <= 1'b0;
            ALUOutM_r   <= 32'b0;
            InstrM_r    <= 32'b0;
            readDataM_r <= 32'b0;
            PCSrcM_r    <= 1'b0;
            PCTargetM_r <= 32'b0;
        end
        else begin
            RegWriteM_r <= RegWriteM;
            memtoRegM_r <= memtoRegM;
            ALUOutM_r   <= ALUOutM;
            InstrM_r    <= InstrM;
            readDataM_r <= readDataM;
            //PCSrcM_r    <= PCSrcM;
            //PCTargetM_r <= PCTargetM;
        end
    end

    assign RegWriteW   = RegWriteM_r;
    assign memtoRegW   = memtoRegM_r;
    assign ALUOutW     = ALUOutM_r;
    assign InstrW      = InstrM_r;
    assign readDataW   = readDataM_r;
    //assign PCSrc_final = PCSrcM_r;
    //assign PCTarget_final = PCTargetM_r;


endmodule
