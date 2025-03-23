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

    /*
    ALUCtl Encoding:
    0000 - ADD/ADDI (A + B)
    0001 - SUB     (A - B)
    0010 - SLTI    (A < B ? 1 : 0, signed)
    0011 - ORI     (A | B)
    */

    wire [31:0] sum;
    wire [31:0] diff;
    wire [31:0] ori;
    wire [31:0] slti;

    assign sum = A + B;
    assign diff = A - B;
    assign ori = A | B;
    assign slti = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; //slti is signed operation

    always @(*) begin
        case(ALUCtl)
        4'b0000: ALUOut = sum;
        4'b0001: ALUOut = diff;
        4'b0010: ALUOut = slti;
        4'b0011: ALUOut = ori;
        default: ALUOut = 32'b0; //default to 0 if something is off
        endcase
    end

    assign zero = (ALUOut == 32'b0);
endmodule

