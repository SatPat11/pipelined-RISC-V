module decode_cycle(clk, rst, InstrD, InstrE, PCD, RegWriteW, WriteDataW, 
BranchE, MemReadE, ALUOpE, MemWriteE, ALUSrcE, RegWriteE, PCE, ReadData1E, ReadData2E, memtoRegE, immediateE, Write_reg_4bit);

    // Declaring I/O
    input clk, rst, RegWriteW;
    input [31:0] InstrD, PCD;
    input [4:0] Write_reg_4bit;
    input [31:0] WriteDataW;
    
    output RegWriteE, BranchE, ALUSrcE, MemReadE, MemWriteE, memtoRegE;
    output [1:0] ALUOpE;
    output [31:0] PCE, immediateE, InstrE, ReadData1E, ReadData2E;

    wire [31:0] ReadData1D, ReadData2D;

    Register m_Register(
        .clk(clk),
        .rst(rst),
        .regWrite(RegWriteW),
        .readReg1(InstrD[19:15]),
        .readReg2(InstrD[24:20]),
        .writeReg(Write_reg_4bit),
        .writeData(WriteDataW),
        .readData1(ReadData1D),
        .readData2(ReadData2D)
    );

    wire BranchD, ALUSrcD, RegWriteD, MemReadD, memtoRegD, MemWriteD;
    wire [1:0] ALUOpD;
    Control m_Control(
        .opcode(InstrD[6:0]),
        .branch(BranchD),
        .memRead(MemReadD),
        .memtoReg(memtoRegD),
        .ALUOp(ALUOpD),
        .memWrite(MemWriteD),
        .ALUSrc(ALUSrcD),
        .regWrite(RegWriteD)
    );

    wire [31:0] immediateD;
    ImmGen #(.Width(32)) m_ImmGen(
        .inst(InstrD),
        .imm(immediateD)
    );

    // Declare pipeline registers
    reg BranchD_r;
    reg ALUSrcD_r;
    reg RegWriteD_r;
    reg MemReadD_r;
    reg memtoRegD_r;
    reg MemWriteD_r;
    reg [1:0] ALUOpD_r;
    reg [31:0] immediateD_r;
    reg [31:0] ReadData1D_r;
    reg [31:0] ReadData2D_r;
    reg [31:0] PCD_r;
    reg [31:0] InstrD_r;

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            BranchD_r    <= 1'b0;
            ALUSrcD_r    <= 1'b0;
            RegWriteD_r  <= 1'b0;
            MemReadD_r   <= 1'b0;
            memtoRegD_r  <= 1'b0;
            MemWriteD_r  <= 1'b0;
            ALUOpD_r     <= 2'b00;
            immediateD_r <= 32'b0;
            ReadData1D_r <= 32'b0;
            ReadData2D_r <= 32'b0;
            PCD_r        <= 32'b0;
            InstrD_r     <= 32'b0;
        end
        else begin
            BranchD_r    <= BranchD;
            ALUSrcD_r    <= ALUSrcD;
            RegWriteD_r  <= RegWriteD;
            MemReadD_r   <= MemReadD;
            memtoRegD_r  <= memtoRegD;
            MemWriteD_r  <= MemWriteD;
            ALUOpD_r     <= ALUOpD;
            immediateD_r <= immediateD;
            ReadData1D_r <= ReadData1D;
            ReadData2D_r <= ReadData2D;
            PCD_r        <= PCD;
            InstrD_r     <= InstrD;
        end
    end

    // Continuous assignments to E outputs
    assign BranchE    = BranchD_r;
    assign ALUSrcE    = ALUSrcD_r;
    assign RegWriteE  = RegWriteD_r;
    assign MemReadE   = MemReadD_r;
    assign memtoRegE  = memtoRegD_r;
    assign MemWriteE  = MemWriteD_r;
    assign ALUOpE     = ALUOpD_r;
    assign immediateE = immediateD_r;
    assign ReadData1E = ReadData1D_r;
    assign ReadData2E = ReadData2D_r;
    assign PCE        = PCD_r;
    assign InstrE     = InstrD_r;


endmodule