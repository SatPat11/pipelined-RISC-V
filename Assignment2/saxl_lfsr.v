module s_axil #(
    parameter C_AXIL_ADDR_WIDTH = 4,
    parameter C_AXIL_DATA_WIDTH = 32
)(
    input aclk,
    input aresetn,

    // AXI-Lite Slave Interface
    input  [C_AXIL_ADDR_WIDTH-1:0] s_axi_awaddr,
    input                       s_axi_awvalid,
    output reg                  s_axi_awready,

    input  [C_AXIL_DATA_WIDTH-1:0] s_axi_wdata,
    input                       s_axi_wvalid,
    output reg                  s_axi_wready,

    output reg [1:0]            s_axi_bresp,
    output reg                  s_axi_bvalid,
    input                       s_axi_bready,

    input  [C_AXIL_ADDR_WIDTH-1:0] s_axi_araddr,
    input                       s_axi_arvalid,
    output reg                  s_axi_arready,

    output reg [C_AXIL_DATA_WIDTH-1:0] s_axi_rdata,
    output reg [1:0]            s_axi_rresp,
    output reg                  s_axi_rvalid,
    input                       s_axi_rready,

    // AXI - Stream Master Interface
    output reg [C_AXIL_DATA_WIDTH-1:0] m_axis_tdata,
    output reg                    m_axis_tvalid,
    input                         m_axis_tready
);

    // Address map for these registers
    // 0x00 - start_reg
    // 0x04 - stop_reg
    // 0x08 - seed_reg
    // 0x0C - taps_reg

    // Registers
    reg start_reg;
    reg stop_reg;
    reg [7:0] seed_reg;
    reg [7:0] taps_reg;
    
    // LFSR registers
    reg [7:0] lfsr_reg;
    reg lfsr_valid;
    wire feedback;
    
    // AXI-Lite write address channel
    reg write_enable;
    reg [C_AXIL_ADDR_WIDTH-1:0] write_addr;
    
    // AXI-Lite read address channel
    reg read_enable;
    reg [C_AXIL_ADDR_WIDTH-1:0] read_addr;
    
    // LFSR ready for next transfer
    wire lfsr_ready;
    assign lfsr_ready = m_axis_tready || !m_axis_tvalid;
    
    // AXI-Lite write address channel logic
    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axi_awready <= 1'b0;
            write_enable <= 1'b0;
            write_addr <= {C_AXIL_ADDR_WIDTH{1'b0}};
        end else begin
            if (s_axi_awvalid && !s_axi_awready && s_axi_wvalid && !write_enable) begin
                s_axi_awready <= 1'b1;
                write_addr <= s_axi_awaddr;
                write_enable <= 1'b1;
            end else begin
                s_axi_awready <= 1'b0;
                if (s_axi_bready && s_axi_bvalid) begin
                    write_enable <= 1'b0;
                end
            end
        end
    end
    
    // AXI-Lite write data channel logic
    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axi_wready <= 1'b0;
            s_axi_bvalid <= 1'b0;
            s_axi_bresp <= 2'b00;
            start_reg <= 1'b0;
            stop_reg <= 1'b0;
            seed_reg <= 8'h01;  // Default non-zero seed
            taps_reg <= 8'hB8;  // Default taps (x^8 + x^6 + x^5 + x^4 + 1)
        end else begin
            if (s_axi_wvalid && !s_axi_wready && write_enable) begin
                s_axi_wready <= 1'b1;
                
                // Register writes based on address
                case (write_addr)
                    4'h0: start_reg <= s_axi_wdata[0];
                    4'h4: stop_reg <= s_axi_wdata[0];
                    4'h8: seed_reg <= s_axi_wdata[7:0];
                    4'hC: taps_reg <= s_axi_wdata[7:0];
                    default: begin end
                endcase
                
                // Write response
                s_axi_bresp <= 2'b00;  // OKAY response
                s_axi_bvalid <= 1'b1;
            end else begin
                s_axi_wready <= 1'b0;
                if (s_axi_bready && s_axi_bvalid) begin
                    s_axi_bvalid <= 1'b0;
                end
            end
        end
    end
    
    // AXI-Lite read address channel logic
    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axi_arready <= 1'b0;
            read_enable <= 1'b0;
            read_addr <= {C_AXIL_ADDR_WIDTH{1'b0}};
        end else begin
            if (s_axi_arvalid && !s_axi_arready && !read_enable) begin
                s_axi_arready <= 1'b1;
                read_addr <= s_axi_araddr;
                read_enable <= 1'b1;
            end else begin
                s_axi_arready <= 1'b0;
                if (s_axi_rready && s_axi_rvalid) begin
                    read_enable <= 1'b0;
                end
            end
        end
    end
    
    // AXI-Lite read data channel logic
    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rdata <= {C_AXIL_DATA_WIDTH{1'b0}};
            s_axi_rresp <= 2'b00;
        end else begin
            if (read_enable && !s_axi_rvalid) begin
                s_axi_rvalid <= 1'b1;
                s_axi_rresp <= 2'b00;  // OKAY response
                
                // Register reads based on address
                case (read_addr)
                    4'h0: s_axi_rdata <= {{C_AXIL_DATA_WIDTH-1{1'b0}}, start_reg};
                    4'h4: s_axi_rdata <= {{C_AXIL_DATA_WIDTH-1{1'b0}}, stop_reg};
                    4'h8: s_axi_rdata <= {{C_AXIL_DATA_WIDTH-8{1'b0}}, seed_reg};
                    4'hC: s_axi_rdata <= {{C_AXIL_DATA_WIDTH-8{1'b0}}, taps_reg};
                    default: s_axi_rdata <= {C_AXIL_DATA_WIDTH{1'b0}};
                endcase
            end else begin
                if (s_axi_rready && s_axi_rvalid) begin
                    s_axi_rvalid <= 1'b0;
                end
            end
        end
    end
    
    // LFSR feedback calculation
    // XOR the bits selected by the taps_reg
    assign feedback = ^(lfsr_reg & taps_reg);
    
    // LFSR operation
    always @(posedge aclk) begin
        if (!aresetn) begin
            lfsr_reg <= 8'h01;  // Default non-zero value
            lfsr_valid <= 1'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata <= {C_AXIL_DATA_WIDTH{1'b0}};
        end else begin
            if (start_reg && !stop_reg && lfsr_ready) begin
                // Load seed if LFSR is in reset state (all zeros)
                if (lfsr_reg == 8'h00) begin
                    lfsr_reg <= seed_reg;
                end else begin
                    // Normal LFSR operation
                    lfsr_reg <= {lfsr_reg[6:0], feedback};
                end
                
                // Set valid flag for new data
                lfsr_valid <= 1'b1;
            end
            
            // Handle seed loading when start is first asserted
            if (start_reg && !lfsr_valid) begin
                lfsr_reg <= seed_reg;
                lfsr_valid <= 1'b1;
            end
            
            // Reset operation
            if (stop_reg) begin
                lfsr_valid <= 1'b0;
            end
            
            // AXI-Stream master output
            if (lfsr_valid && lfsr_ready) begin
                m_axis_tvalid <= 1'b1;
                // Output the 8-bit LFSR value zero-padded to 32-bits
                m_axis_tdata <= {{(C_AXIL_DATA_WIDTH-8){1'b0}}, lfsr_reg};
            end else if (m_axis_tready && m_axis_tvalid) begin
                m_axis_tvalid <= 1'b0;
            end
        end
    end

endmodule