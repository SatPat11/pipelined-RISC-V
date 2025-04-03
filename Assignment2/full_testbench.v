`timescale 1ns / 1ps
`include "histogram_lfsr_system.v"
module lfsr_histogram_system_tb();
    // Clock and reset signals
    reg aclk;
    reg aresetn;
    
    // AXI-Lite signals for LFSR configuration
    reg [3:0] s_axi_awaddr;
    reg s_axi_awvalid;
    wire s_axi_awready;
    
    reg [31:0] s_axi_wdata;
    reg s_axi_wvalid;
    wire s_axi_wready;
    
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    reg s_axi_bready;
    
    reg [3:0] s_axi_araddr;
    reg s_axi_arvalid;
    wire s_axi_arready;
    
    wire [31:0] s_axi_rdata;
    wire [1:0] s_axi_rresp;
    wire s_axi_rvalid;
    reg s_axi_rready;
    
    // Clock generation
    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk; // 100MHz clock
    end
    
    // Instantiate the DUT
    lfsr_histogram_system dut (
        .aclk(aclk),
        .aresetn(aresetn),
        
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready)
    );
    
    // Task to perform AXI-Lite write
    task axi_write;
        input [3:0] addr;
        input [31:0] data;
        begin
            // Address phase
            @(posedge aclk);
            s_axi_awaddr = addr;
            s_axi_awvalid = 1;
            s_axi_wdata = data;
            s_axi_wvalid = 1;
            s_axi_bready = 1;
            
            // Wait for address and data to be accepted
            wait(s_axi_awready && s_axi_wready);
            @(posedge aclk);
            s_axi_awvalid = 0;
            s_axi_wvalid = 0;
            
            // Wait for write response
            wait(s_axi_bvalid);
            @(posedge aclk);
            s_axi_bready = 0;
        end
    endtask
    
    // Task to perform AXI-Lite read
    task axi_read;
        input [3:0] addr;
        begin
            // Address phase
            @(posedge aclk);
            s_axi_araddr = addr;
            s_axi_arvalid = 1;
            s_axi_rready = 1;
            
            // Wait for address to be accepted
            wait(s_axi_arready);
            @(posedge aclk);
            s_axi_arvalid = 0;
            
            // Wait for read data
            wait(s_axi_rvalid);
            @(posedge aclk);
            s_axi_rready = 0;
        end
    endtask
    
    // Main test sequence
    initial begin
        // Initialize signals
        aresetn = 0;
        s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_araddr = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
        
        // Apply reset
        #20;
        aresetn = 1;
        #20;
        
        // Configure LFSR
        axi_write(4'hC, 32'h1B);  // Configure taps (x^8 + x^4 + x^3 + x^2 + 1)
        axi_write(4'h8, 32'h45);  // Set seed to 0x45
        
        // Start LFSR
        axi_write(4'h0, 32'h1);
        
        // Let it run for a while (generate sufficient samples)
        #2000;
        
        // Stop LFSR
        axi_write(4'h4, 32'h1);
        
        // Wait a bit more to ensure all processing is complete
        #500;
        
        // Read back some registers to verify operation
        axi_read(4'h0);  // Read start_reg
        axi_read(4'h4);  // Read stop_reg
        axi_read(4'h8);  // Read seed_reg
        axi_read(4'hC);  // Read taps_reg
        
        // End simulation
        #100;
        $finish;
    end
    
    // Simple RAM content monitoring - access the RAM through the hierarchy
    // This is for waveform visibility
    wire [7:0] bin0_count = dut.ram_inst.mem[0];
    wire [7:0] bin1_count = dut.ram_inst.mem[4];
    wire [7:0] bin2_count = dut.ram_inst.mem[8];
    wire [7:0] bin3_count = dut.ram_inst.mem[12];
    wire [7:0] bin4_count = dut.ram_inst.mem[16];
    wire [7:0] bin5_count = dut.ram_inst.mem[20];
    wire [7:0] bin6_count = dut.ram_inst.mem[24];
    wire [7:0] bin7_count = dut.ram_inst.mem[28];
    
    // Monitor some bin data for first few values
    wire [7:0] bin0_data0 = dut.ram_inst.mem[32]; // First value in bin 0
    wire [7:0] bin1_data0 = dut.ram_inst.mem[64]; // First value in bin 1
    wire [7:0] bin2_data0 = dut.ram_inst.mem[96]; // First value in bin 2
    
    // Monitor internal LFSR value for debugging
    wire [7:0] lfsr_value = dut.lfsr_inst.lfsr_reg;

endmodule