module ImmGen#(parameter Width = 32) (
    input [Width-1:0] inst,
    output reg signed [Width-1:0] imm
);
    // ImmGen generate imm value based on opcode

    wire [6:0] opcode = inst[6:0];
    always @(*) 
    begin
        case(opcode)
            
            // TODO: implement your ImmGen here
            // Hint: follow the RV32I opcode map table to set imm value

            // when I set ALU functions (opcode = 010011) or lw (opcode = 0000011) is used we
            //simply need to extend the sign bit 
            7'b0010011, 
            7'b0000011:
                //imm[11:0] - 12bit -> 20 extension needed
                imm = {{20{inst[31]}}, inst[31:20]};
                //sign extension logic: initially this was stored as 31:20
                // imm[31] is msb -> sign extend to cover all places so it becomes 31:0
                //concatenation is carried out with repeating inst[31] 20 times

            // S-type instruction: SW (opcode 0100011)
            7'b0100011: 
                //imm[11:5], imm[4:0] - 12bit -> 20 extension needed
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
               //first 11:5 stored and then 4:0 then sign extend it

            // B-type instructions: BEQ, BGT (opcode 1100011)
            //imm[12], imm[10:5], imm[4:1], imm[11] - 13bit -> 19bit extension
            // Immediate is formed as: {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}
            7'b1100011: 
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
                //There is 0 at end because
                // RISC‑V J‑type format defines that bit 0 of the offset is zer0 ensuring halfword alignment.

            // imm[20], imm[10:1], imm[11], imm[19:12]
            // J-type instruction: JAL (opcode 1101111)
            // Immediate is formed as: {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}
            7'b1101111: 
                imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
                //zero placed at the end for alignment reasons

            // Default case to avoid errors
            default:    
                imm = 0;

	endcase
    end
            
endmodule

