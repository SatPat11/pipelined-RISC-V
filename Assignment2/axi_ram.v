/// use this module to create a RAM with AXI-Stream interface
/// you are allowed to change the input interface to axi-lite if you want

module axi_ram (
    input aclk,
    input aresetn,

    // AXI-Stream Slave
    input [31:0]s_axis_tdata,
    input s_axis_tvalid,
    output reg s_axis_tready,

    // AXI-Stream Master 
    output reg [31:0]m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready
);

    // Memory array - 0x120 bytes (288 decimal)
    reg [7:0] mem [0:287];
    
    // Input parsing
    wire [7:0] write_addr;
    wire [23:0] write_data;
    
    // Extract address and data from input
    assign write_addr = s_axis_tdata[31:24];
    assign write_data = s_axis_tdata[23:0];
    
    // RAM operation states
    localparam IDLE = 2'b00;
    localparam WRITE = 2'b01;
    localparam READ = 2'b10;
    
    reg [1:0] state;
    reg [7:0] read_addr;
    
    // Initialize RAM
    integer i;
    initial begin
        for (i = 0; i < 288; i = i + 1) begin
            mem[i] = 8'h0;
        end
    end
    
    // RAM control state machine
    always @(posedge aclk) begin
        if (!aresetn) begin
            state <= IDLE;
            s_axis_tready <= 1'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata <= 32'h0;
            read_addr <= 8'h0;
            
            // Reset memory
            for (i = 0; i < 288; i = i + 1) begin
                mem[i] <= 8'h0;
            end
        end else begin
            case (state)
                IDLE: begin
                    // Ready to accept data for writing
                    s_axis_tready <= 1'b1;
                    
                    // If valid data available, process write
                    if (s_axis_tvalid && s_axis_tready) begin
                        state <= WRITE;
                        s_axis_tready <= 1'b0; // Not ready for new data during write
                    end
                end
                
                WRITE: begin
                    // Write data to memory
                    if (write_addr < 8'h120) begin // Ensure address is within range
                        mem[write_addr] <= write_data[7:0];
                        // For bin count registers (32-bit values at 4-byte aligned addresses)
                        if (write_addr[1:0] == 2'b00 && write_addr < 8'h20) begin
                            mem[write_addr+1] <= write_data[15:8];
                            mem[write_addr+2] <= write_data[23:16];
                            mem[write_addr+3] <= 8'h0; // Upper byte is always 0
                        end
                    end
                    
                    // Return to idle
                    state <= IDLE;
                    s_axis_tready <= 1'b1;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule