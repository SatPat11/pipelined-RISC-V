`include "saxl_lfsr.v"
`include "s_m_hist.v"
`include "axi_ram.v"

module lfsr_histogram_system (
    input aclk,
    input aresetn,
    
    // AXI-Lite interface for LFSR configuration
    input [3:0] s_axi_awaddr,
    input s_axi_awvalid,
    output s_axi_awready,
    
    input [31:0] s_axi_wdata,
    input s_axi_wvalid,
    output s_axi_wready,
    
    output [1:0] s_axi_bresp,
    output s_axi_bvalid,
    input s_axi_bready,
    
    input [3:0] s_axi_araddr,
    input s_axi_arvalid,
    output s_axi_arready,
    
    output [31:0] s_axi_rdata,
    output [1:0] s_axi_rresp,
    output s_axi_rvalid,
    input s_axi_rready
);

    // Internal AXI-Stream connections
    wire [31:0] lfsr_to_hist_tdata;
    wire lfsr_to_hist_tvalid;
    wire lfsr_to_hist_tready;
    
    wire [31:0] hist_to_ram_tdata;
    wire hist_to_ram_tvalid;
    wire hist_to_ram_tready;
    
    // Instantiate LFSR with AXI-Lite interface
    s_axil #(
        .C_AXIL_ADDR_WIDTH(4),
        .C_AXIL_DATA_WIDTH(32)
    ) lfsr_inst (
        .aclk(aclk),
        .aresetn(aresetn),
        
        // AXI-Lite Slave interface
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
        .s_axi_rready(s_axi_rready),
        
        // AXI-Stream Master interface to histogram
        .m_axis_tdata(lfsr_to_hist_tdata),
        .m_axis_tvalid(lfsr_to_hist_tvalid),
        .m_axis_tready(lfsr_to_hist_tready)
    );
    
    // Instantiate Histogram Binning Module
    s_m_hist hist_inst (
        .aclk(aclk),
        .aresetn(aresetn),
        
        // AXI-Stream Slave interface from LFSR
        .s_axis_tdata(lfsr_to_hist_tdata),
        .s_axis_tvalid(lfsr_to_hist_tvalid),
        .s_axis_tready(lfsr_to_hist_tready),
        
        // AXI-Stream Master interface to RAM
        .m_axis_tdata(hist_to_ram_tdata),
        .m_axis_tvalid(hist_to_ram_tvalid),
        .m_axis_tready(hist_to_ram_tready)
    );
    
    // Instantiate AXI RAM
    axi_ram ram_inst (
        .aclk(aclk),
        .aresetn(aresetn),
        
        // AXI-Stream Slave interface from Histogram
        .s_axis_tdata(hist_to_ram_tdata),
        .s_axis_tvalid(hist_to_ram_tvalid),
        .s_axis_tready(hist_to_ram_tready),
        
        // AXI-Stream Master interface (not used in this design)
        .m_axis_tdata(),
        .m_axis_tvalid(),
        .m_axis_tready(1'b1) // Always ready
    );

endmodule