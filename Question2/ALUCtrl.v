module ALUCtrl (
    input [1:0] ALUOp,
    input funct7,
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);
   // ALUCtrl selects ALU operations based on ALUOp, funct7, and funct3.
   // ALUOp Encoding:
   // 00 - immediate instructions (e.g. ADDI, SLTI, ORI) 
   // 01 - branch instructions (use subtraction)
   // 10 - R-type instructions (decide based on funct7)
   // 11 - memory calculations (addition)
   
   // ALUCtl Encoding:
   // 0000 - ADD/ADDI
   // 0001 - SUB
   // 0010 - SLTI
   // 0011 - ORI
   // 0100 - CTZ (count trailing zeros)

   always @(*) begin
        case(ALUOp)
            2'b00: begin  // Immediate instructions
                case(funct3)
                    3'b000: ALUCtl = 4'b0000;  // ADDI
                    3'b010: ALUCtl = 4'b0010;  // SLTI
                    3'b110: ALUCtl = 4'b0011;  // ORI
                    3'b101: ALUCtl = 4'b0100;  // CTZ custom instruction
                    default: ALUCtl = 4'b0000;  // Default to ADD
                endcase
            end

            2'b01: ALUCtl = 4'b0001;   // Branch instructions (SUB)
            
            2'b10: begin // R-type instructions
                case(funct3)
                    3'b000: begin // ADD/SUB: determined by funct7
                        if (funct7 == 1'b0)
                            ALUCtl = 4'b0000;  // ADD
                        else
                            ALUCtl = 4'b0001;  // SUB (e.g. funct7 = 1 for SUB)
                    end
                    default: ALUCtl = 4'b0000;  // default to ADD
                endcase
            end
            
            2'b11: ALUCtl = 4'b0000;   // Memory calculations (lw/sw: ADD)
            
            default: ALUCtl = 4'b0000;  // default to ADD
        endcase
   end
endmodule
