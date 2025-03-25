module tb_riscv_pipelined;
//cpu testbench

reg clk;
reg rst;

Pipeline pipeDUT(.clk(clk), .rst(rst));

initial
	forever #5 clk = ~clk;

initial begin
	$dumpfile("dump.vcd"); // Specifies the output VCD file name
    $dumpvars;             // Dumps all variables for waveform analysis
	clk = 0;
	rst = 0;
	#10 rst = 1;

	#3000 $finish; 

end

endmodule
