`timescale 1ns/1ps
`include "saxl_lfsr.v"
module tb_s_axil_basic();

    parameter CLK_PERIOD = 10;  // 100 MHz clock
    parameter SIM_DURATION = 1000; // 1us total simulation
    parameter TIMEOUT = 100; // Timeout for AXI transactions

    reg aclk;
    reg aresetn;
    
    // AXI-Lite Interface
    reg [3:0] s_axi_awaddr;
    reg s_axi_awvalid;
    wire s_axi_awready;
    
    reg [31:0] s_axi_wdata;
    reg s_axi_wvalid;
    wire s_axi_wready;
    
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    reg s_axi_bready;
    
    // AXI-Stream Interface
    wire [31:0] m_axis_tdata;
    wire m_axis_tvalid;
    reg m_axis_tready;

    // Instantiate DUT
    s_axil dut (
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
        .s_axi_araddr(4'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_arready(),
        .s_axi_rdata(),
        .s_axi_rresp(),
        .s_axi_rvalid(),
        .s_axi_rready(1'b0),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );

    // Generate VCD file
    initial begin
        $dumpfile("lfsr_wave.vcd");
        $dumpvars(0, tb_s_axil_basic);
    end

    // Clock generation
    initial begin
        aclk = 0;
        forever #(CLK_PERIOD/2) aclk = ~aclk;
    end

    // Simulation timeout
    initial begin
        #SIM_DURATION;
        $display("Simulation finished");
        $finish;
    end

    // Main test sequence
    reg test_failed;
    initial begin
        test_failed = 0;
        
        // Initialize
        aresetn = 0;
        s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 1;
        m_axis_tready = 1;
        
        // Reset
        #100;
        aresetn = 1;
        #100;
        
        // Test sequence
        $display("Starting test sequence");
        
        // 1. Set seed
        axi_write(4'h8, 32'h000000A5);
        if (test_failed) begin
            $display("Error: Failed to set seed");
            $finish;
        end
        
        // 2. Start LFSR
        axi_write(4'h0, 32'h00000001);
        if (test_failed) begin
            $display("Error: Failed to start LFSR");
            $finish;
        end
        
        // 3. Let it run
        #500;
        
        // 4. Stop LFSR
        axi_write(4'h4, 32'h00000001);
        if (test_failed) begin
            $display("Error: Failed to stop LFSR");
            $finish;
        end
        
        #100;
        $display("Test completed successfully");
        $finish;
    end

    // AXI-Lite write task with timeout (Verilog style)
    task axi_write;
        input [3:0] addr;
        input [31:0] data;
        integer timeout;
        begin
            test_failed = 0;
            timeout = 0;
            
            @(posedge aclk);
            s_axi_awaddr = addr;
            s_axi_awvalid = 1;
            s_axi_wdata = data;
            s_axi_wvalid = 1;
            
            while (!(s_axi_awready && s_axi_wready) && timeout < TIMEOUT) begin
                @(posedge aclk);
                timeout = timeout + 1;
            end
            
            if (timeout >= TIMEOUT) begin
                $display("Timeout waiting for write ready");
                s_axi_awvalid = 0;
                s_axi_wvalid = 0;
                test_failed = 1;
                disable axi_write;
            end
            
            @(posedge aclk);
            s_axi_awvalid = 0;
            s_axi_wvalid = 0;
            
            timeout = 0;
            while (!s_axi_bvalid && timeout < TIMEOUT) begin
                @(posedge aclk);
                timeout = timeout + 1;
            end
            
            if (timeout >= TIMEOUT) begin
                $display("Timeout waiting for write response");
                test_failed = 1;
                disable axi_write;
            end
            
            if (s_axi_bresp !== 2'b00) begin
                $display("Write error response: %b", s_axi_bresp);
                test_failed = 1;
                disable axi_write;
            end
            
            @(posedge aclk);
        end
    endtask

    // Monitor LFSR output
    always @(posedge aclk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $display("LFSR output: 0x%h", m_axis_tdata[7:0]);
        end
    end

endmodule