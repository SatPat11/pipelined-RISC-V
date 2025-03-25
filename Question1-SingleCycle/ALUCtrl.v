module ALUCtrl (
    input [1:0] ALUOp,
    input funct7,
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

   // TODO: implement your ALU ALUCtl here
   // Hint: using ALUOp, funct7, funct3 to select exact operation
   
   /*
    ALUOp
    00 - for the immediate stuff excluding lw and sw (for address calculation)
    01 - for branch instructions similar to cmp beq bne
    10 - for the R type traditional add/sub
    11 - for memory calculations 

    ALUCtl Encoding:
    0000 - ADD/ADDI (A + B)
    0001 - SUB     (A - B)
    0010 - SLTI    (A < B ? 1 : 0, signed)
    0011 - ORI     (A | B)
    */

    //output is reg can use case
    always @(*) begin

        case(ALUOp)

            //if ALUOp = 0, I type instruction performed -> decide based on R3
            2'b00:
            begin
                case(funct3)
                    3'b000: ALUCtl = 4'b0;    // funct3 addi = 000 & addition performed
                    3'b010: ALUCtl = 4'b0010; // funct3 stli = 010 & stli performed
                    3'b110: ALUCtl = 4'b0011; // funct3 ori = 110 & ori performed
                    default: ALUCtl = 4'b0000; // Default to ADD if unknown
                endcase
            end

            //if ALUOp = 1, B type instructions performed
            2'b01: ALUCtl = 4'b0001;   //for comparisions like beq bne we use subtraction 

            //if AlUOp = 10, R type instructions performed -> decide based on R3 & R7
            2'b10: 
                case(funct3)
                    3'b000:                     //for add and sub both R3 is 0
                    begin
                        if(funct7 == 1'b0)  //funct7 is 0 for addition
                            ALUCtl = 4'b0000;   //R type addition
                        else
                            ALUCtl = 4'b0001;   //funct7 is 0100000 for sub
                    end
                    default: ALUCtl = 4'b0;     // default to addition if some error
                endcase
            
            2'b11: ALUCtl = 4'b0000;    // for lw/sw calculations we will only resort to addition

            default: ALUCtl = 4'b0;     // default to addition if some error

        endcase

    end
endmodule

