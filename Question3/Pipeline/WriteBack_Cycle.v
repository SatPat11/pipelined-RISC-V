module WriteBack(RegWriteW, memtoRegW, ALUOutW, InstrW, readDataW, Write_data_Register_final, RegWrite_final_to_E, Write_reg_4bit);

    input   RegWriteW, memtoRegW;
    input  [31:0]  ALUOutW, InstrW, readDataW;
    
    output RegWrite_final_to_E;
    output [31:0] Write_data_Register_final;
    output [4:0] Write_reg_4bit;

    assign RegWrite_final_to_E = RegWriteW;
    assign Write_reg_4bit = InstrW[11:7];

    Mux2to1 #(.size(32)) m_Mux_WB(
        .sel(memtoRegW),
        .s0(ALUOutW),
        .s1(readDataW),
        .out(Write_data_Register_final)
    );

endmodule
