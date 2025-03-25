module ALU (
    input [3:0] ALUCtl,
    input [31:0] A,B,
    output reg [31:0] ALUOut,
    output zero
);
    // ALU has two operand, it execute different operator based on ALUctl wire 
    // output zero is for determining taking branch or not 

    // TODO: implement your ALU here
    // Hint: you can use operator to implement
    
    always @(*) begin
        case(ALUCtl)
        4'b0001: ALUOut = A + B; //for ADD
        4'b0010: ALUOut = A - B; // for SUB
        4'b0011: ALUOut = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; //for comparision(SLTI)
        4'b0100: ALUOut = A | B; //for (ORI) and OR related operations
        4'b0101: ALUOut = A & B; //AND
        4'b0110: ALUOut = A ^ B; //XOR
        4'b0111: ALUOut = ($signed(A)) >> (B & 5'b11111); //for (SRA) shift right arithmetic
        4'b1000: ALUOut = A << (B & 5'b11111); //(SLL)for shifting left we do AND operation with first 5 bits of B because max shift of more than 32 bit does not make sense. 
        4'b1001: ALUOut = ($unsigned(A)) >> (B & 5'b11111); //for shifting right same logic here (SRL) 
        4'b1010: ALUOut = ($unsigned(A) <$unsigned(B)) ? 32'b1 : 32'b0; //SLTU 
        default: ALUOut = 32'b0; //perform nothing if if ALUCtl is 0000
        endcase
    end

    assign zero = (ALUOut == 32'b0); //used for checking as equality condition for instructions like beq
endmodule

ALUCTRL:
module ALUCtrl (
    input [1:0] ALUOp,
    input [6:0] funct7,  // Corrected to full 7-bit input
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

    always @(*) begin
        case(ALUOp)

            //I-type
            2'b00:
            begin
                case(funct3)
                    3'b000: ALUCtl = 4'b0001;    // ADDI
                    3'b010: ALUCtl = 4'b0011;    // SLTI
                    3'b011: ALUCtl = 4'b1010;    // SLTIU
                    3'b100: ALUCtl = 4'b0110;    // XORI
                    3'b110: ALUCtl = 4'b0100;    // ORI
                    3'b111: ALUCtl = 4'b0101;    // ANDI
                    3'b001: ALUCtl = 4'b1000;    // SLLI (Shift Left Logical Immediate)
                    3'b101:begin
                        if(funct7 == 7'b0000000)  
                            ALUCtl = 4'b1001;   // SRLI (Shift Right Logical Immediate)
                        else if(funct7 == 7'b0100000)  
                            ALUCtl = 4'b0111;   // SRAI (Shift Right Arithmetic Immediate)
                        else
                            ALUCtl = 4'b0000;   // Default (No Operation)
                        end
                    default: ALUCtl = 4'b0000;   // Default to No Operation
                endcase
            end

            //B-type
            2'b01: ALUCtl = 4'b0010;   // BEQ uses subtraction

            //R-type
            2'b10: 
                case(funct3)
                    3'b000:begin
                        if(funct7 == 7'b0000000)  
                            ALUCtl = 4'b0001;   // ADD
                        else if(funct7 == 7'b0100000)
                            ALUCtl = 4'b0010;   // SUB
                        else
                            ALUCtl = 4'b0000;   // Default
                        end
                    3'b001: ALUCtl = 4'b1000;  // SLL (Shift Left Logical)
                    3'b010: ALUCtl = 4'b0011;  // SLT (Set Less Than)
                    3'b011: ALUCtl = 4'b1010;  // SLTU (Set Less Than Unsigned)
                    3'b100: ALUCtl = 4'b0110;  // XOR
                    3'b101:begin
                        if(funct7 == 7'b0000000)  
                            ALUCtl = 4'b1001;   // SRL (Shift Right Logical)
                        else if(funct7 == 7'b0100000)  
                            ALUCtl = 4'b0111;   // SRA (Shift Right Arithmetic)
                        else
                            ALUCtl = 4'b0000;   // Default
                        end
                    3'b110: ALUCtl = 4'b0100;  // OR
                    3'b111: ALUCtl = 4'b0101;  // AND
                    default: ALUCtl = 4'b0000; // No operation
                endcase
            
            //for memory load store
            2'b11: ALUCtl = 4'b0001;    // LW and SW perform addition for address calculation

            default: ALUCtl = 4'b0000;  // No operation
        endcase
    end
endmodule
