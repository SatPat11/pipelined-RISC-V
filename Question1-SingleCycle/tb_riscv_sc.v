module tb_riscv_sc;
//cpu testbench

reg clk;
reg start;

SingleCycleCPU riscv_DUT(clk, start);

initial
	forever #5 clk = ~clk;

initial begin
	$dumpfile("dump.vcd"); // Specifies the output VCD file name
    $dumpvars;             // Dumps all variables for waveform analysis
	clk = 0;
	start = 0;
	#10 start = 1;

	#3000 $finish;

end

endmodule
