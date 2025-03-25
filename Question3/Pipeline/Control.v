module Control (
    input [6:0] opcode,
    output  branch,
    output  memRead,
    output  memtoReg,
    output  [1:0] ALUOp,
    output  memWrite,
    output  ALUSrc,
    output  regWrite
    );


    // TODO: implement your Control here
    // Hint: follow the Architecture to set output signal

    //for now only implementing:  ADD, SUB, LW, SW, BEQ, BGT, ADDI, SLTI, ORI and JAL

    // set branch flag to 1 when opcode is 1100011
    assign branch = (opcode == 7'b1100011);

    //memread is set when LW called which is opcode = 0000011
    assign memRead = (opcode == 7'b0000011);

    //assign memtoReg is also called when LW is there
    assign memtoReg = (opcode == 7'b0000011);

    //memwrite is set when SW is called opcode = 0100011
    assign memWrite = (opcode == 7'b0100011);

    //we use alusrc to see if we are gonna do memory operation or register 
    //so looking at greencard imm is used for I type instructions: ADDI SLTI ORI opcode = 0010011
    // also set for lw(0000011) and sw(0100011)
    assign ALUSrc = (opcode == 7'b0010011) || (opcode == 7'b0000011) || (opcode == 7'b0100011); 

    //regwrite is used whenever we wanna write to the register so basically all alu results will set it
    // it will also be set for lw because that is literally writing to register
    // it will also be set for JAK
    assign regWrite = (opcode == 7'b0110011) || (opcode == 7'b0010011) || (opcode == 7'b0000011) || (opcode == 7'b1101111);

    //for ALUOP the following convention is followed:
    /*
    2'b00 - for the immediate stuff excluding lw and sw (for address calculation)
    2'b01 - for branch instructions similar to cmp beq bne
    2'b10 - for the R type traditional add/sub
    2'b11 - for immediate stuff but only for lw/sw
    */
    // we can only use the ternary because the always case won't word because it is not reg
    assign ALUOp = (opcode == 7'b1100011) ? 2'b01:  // B type
                   (opcode == 7'b0110011) ? 2'b10:  // R type
                   (opcode == 7'b0010011) ? 2'b00:   // I type
                    2'b11;
endmodule




