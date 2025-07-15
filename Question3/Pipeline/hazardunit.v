module hazard_unit(
    input rst,
    input RegWriteM,
    input RegWriteW,
    input MemReadE,        // New: indicates if EX stage instruction is a load
    input [4:0] RD_M,
    input [4:0] RD_W,
    input [4:0] RD_E,      // Destination reg in EX stage (needed for load-use check)
    input [4:0] Rs1_E,
    input [4:0] Rs2_E,
    input [4:0] Rs1_D,     // Source regs in ID stage (for stall detection)
    input [4:0] Rs2_D,
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,
    output reg stall       // New: stall signal to pause pipeline
);

    // Forwarding logic for ALU inputs in EX stage
    always @(*) begin
        if (rst == 1'b0) begin
            ForwardAE = 2'b00;
            ForwardBE = 2'b00;
        end else begin
            // Forward for Rs1_E
            if ((RegWriteM == 1'b1) && (RD_M != 5'b00000) && (RD_M == Rs1_E))
                ForwardAE = 2'b10;   // Forward from MEM stage
            else if ((RegWriteW == 1'b1) && (RD_W != 5'b00000) && (RD_W == Rs1_E))
                ForwardAE = 2'b01;   // Forward from WB stage
            else
                ForwardAE = 2'b00;   // No forwarding

            // Forward for Rs2_E
            if ((RegWriteM == 1'b1) && (RD_M != 5'b00000) && (RD_M == Rs2_E))
                ForwardBE = 2'b10;   // Forward from MEM stage
            else if ((RegWriteW == 1'b1) && (RD_W != 5'b00000) && (RD_W == Rs2_E))
                ForwardBE = 2'b01;   // Forward from WB stage
            else
                ForwardBE = 2'b00;   // No forwarding
        end
    end

    // Stall detection for load-use hazard:
    // Stall if EX stage instruction is a load (MemReadE == 1) and its destination register
    // matches either source register of the instruction in ID stage (Rs1_D or Rs2_D)
    always @(*) begin
        if (rst == 1'b0) begin
            stall = 1'b0;
        end else begin
            if (MemReadE == 1'b1 && (
                (RD_E != 5'b00000) && 
                ( (RD_E == Rs1_D) || (RD_E == Rs2_D) )
                ))
                stall = 1'b1;   // Stall needed for load-use hazard
            else
                stall = 1'b0;   // No stall
        end
    end

endmodule
