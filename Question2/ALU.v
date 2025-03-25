module ALU (
    input [3:0] ALUCtl,
    input [31:0] A, B,
    output reg [31:0] ALUOut,
    output zero
);
    // ALU operations for ADD, SUB, SLTI, ORI
    wire [31:0] sum;
    wire [31:0] diff;
    wire [31:0] ori;
    wire [31:0] slti;

    assign sum = A + B;
    assign diff = A - B;
    assign ori = A | B;
    assign slti = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // SLTI: signed comparison

    always @(*) begin
        case(ALUCtl)
            4'b0000: ALUOut = sum;    // ADD/ADDI
            4'b0001: ALUOut = diff;   // SUB
            4'b0010: ALUOut = slti;   // SLTI
            4'b0011: ALUOut = ori;    // ORI

            // CTZ operation (count trailing zeros)
            4'b0100: begin
                integer i, count;
                count = 0;
                for (i = 0; i < 32; i = i + 1) begin
                        if (A[i] == 1'b0)
                            count = count + 1;
                        else
                            i=32;
                end
                ALUOut = count;
            end

            default: ALUOut = 32'b0; // default to 0 if something is off
        endcase
    end

    assign zero = (ALUOut == 32'b0);
endmodule
