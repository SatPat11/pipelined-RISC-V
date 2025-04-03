//////////////////////////////////////////////////////////////////////////////////////////////////
////      Edit to create a block to create a data processing block, which takes in data //////////
/// from the lfsr through a AXI-Stream slave interface, and categorises them into bins  //////////
/////      The output data includes the  count value of numbers in each bin and data    //////////
////     + address in ram , which the data is supposed to be written to as provided in  //////////
////                            the address map below                                   //////////
////     The output data is to sent out through a AXI-Stream master/AXI-Lite interface.    ///////
//////////////////////////////////////////////////////////////////////////////////////////////////


//  -------------------------------------------------
//  | Bin Number |    Range of Values               |
//  -------------------------------------------------
//  | Bin 0      |        1   -  32                 |
//  | Bin 1      |       33   -  64                 |
//  | Bin 2      |       65   -  96                 |
//  | Bin 3      |       97   - 128                 |
//  | Bin 4      |      129   - 160                 |
//  | Bin 5      |      161   - 192                 |
//  | Bin 6      |      193   - 224                 |
//  | Bin 7      |      225   - 255                 |
//  -------------------------------------------------


// assume the ram to be 0x120 x 8 bit 

// ----------------------------------------------------------------------------------------
// | Address Range      | Register / Memory     | Description                              |
// ----------------------------------------------------------------------------------------
// | 0x00              | Bin 0 Count           | Count for values in range 1-32           |
// | 0x04              | Bin 1 Count           | Count for values in range 33-64          |
// | 0x08              | Bin 2 Count           | Count for values in range 65-96          |
// | 0x0C              | Bin 3 Count           | Count for values in range 97-128         |
// | 0x10              | Bin 4 Count           | Count for values in range 129-160        |
// | 0x14              | Bin 5 Count           | Count for values in range 161-192        |
// | 0x18              | Bin 6 Count           | Count for values in range 193-224        |
// | 0x1C              | Bin 7 Count           | Count for values in range 225-255        |
// ----------------------------------------------------------------------------------------
// | 0x20 - 0x3F       | Bin 0 Data Storage    | Stores values belonging to Bin 0         |
// | 0x40 - 0x5F       | Bin 1 Data Storage    | Stores values belonging to Bin 1         |
// | 0x60 - 0x7F       | Bin 2 Data Storage    | Stores values belonging to Bin 2         |
// | 0x80 - 0x9F       | Bin 3 Data Storage    | Stores values belonging to Bin 3         |
// | 0xA0 - 0xBF       | Bin 4 Data Storage    | Stores values belonging to Bin 4         |
// | 0xC0 - 0xDF       | Bin 5 Data Storage    | Stores values belonging to Bin 5         |
// | 0xE0 - 0xFF       | Bin 6 Data Storage    | Stores values belonging to Bin 6         |
// | 0x100 - 0x11F     | Bin 7 Data Storage    | Stores values belonging to Bin 7         |
// ----------------------------------------------------------------------------------------





module s_m_hist (
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

    // Bin parameters
    localparam NUM_BINS = 8;
    localparam BIN_SIZE = 32;
    
    // States for the state machine
    localparam IDLE = 2'b00;
    localparam PROCESS = 2'b01;
    localparam WRITE_COUNT = 2'b10;
    localparam WRITE_DATA = 2'b11;
    
    // Registers to store bin counts and internal state
    reg [31:0] bin_counts[0:NUM_BINS-1];
    reg [7:0] bin_data[0:NUM_BINS-1][0:BIN_SIZE-1]; // Storage for values in each bin
    reg [4:0] bin_indices[0:NUM_BINS-1]; // Current index for each bin (max 32 items per bin)
    
    // Control state
    reg [1:0] state;
    reg [2:0] current_bin; // 3 bits to address 8 bins
    reg [4:0] data_index;  // Index within current bin's data array
    reg [7:0] current_value;
    
    // Address calculation
    reg [7:0] address;
    
    // Initialize bin counts and indices
    integer i, j;
    initial begin
        for (i = 0; i < NUM_BINS; i = i + 1) begin
            bin_counts[i] = 32'h0;
            bin_indices[i] = 5'h0;
            for (j = 0; j < BIN_SIZE; j = j + 1) begin
                bin_data[i][j] = 8'h0;
            end
        end
    end
    
    // Determine bin for a given value
    function [2:0] get_bin;
        input [7:0] value;
        begin
            if (value > 0 && value <= 32)
                get_bin = 3'd0;
            else if (value >= 33 && value <= 64)
                get_bin = 3'd1;
            else if (value >= 65 && value <= 96)
                get_bin = 3'd2;
            else if (value >= 97 && value <= 128)
                get_bin = 3'd3;
            else if (value >= 129 && value <= 160)
                get_bin = 3'd4;
            else if (value >= 161 && value <= 192)
                get_bin = 3'd5;
            else if (value >= 193 && value <= 224)
                get_bin = 3'd6;
            else if (value >= 225 && value <= 255)
                get_bin = 3'd7;
            else 
                get_bin = 3'd0; // Default bin for 0 or invalid values
        end
    endfunction
    
    // Main state machine
    always @(posedge aclk) begin
        if (!aresetn) begin
            // Reset all state
            state <= IDLE;
            current_bin <= 3'd0;
            data_index <= 5'd0;
            address <= 8'h0;
            s_axis_tready <= 1'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata <= 32'h0;
            
            // Reset bin counts and indices
            for (i = 0; i < NUM_BINS; i = i + 1) begin
                bin_counts[i] <= 32'h0;
                bin_indices[i] <= 5'h0;
            end
        end else begin
            case (state)
                IDLE: begin
                    // Ready to accept data
                    s_axis_tready <= 1'b1;
                    m_axis_tvalid <= 1'b0;
                    
                    // If valid data available, process it
                    if (s_axis_tvalid && s_axis_tready) begin
                        current_value <= s_axis_tdata[7:0]; // Use only the lower 8 bits
                        state <= PROCESS;
                        s_axis_tready <= 1'b0; // Not ready for new data until processing complete
                    end
                end
                
                PROCESS: begin
                    // Determine bin for the value
                    current_bin <= get_bin(current_value);
                    
                    // Check if current value is valid (1-255)
                    if (current_value >= 8'd1 && current_value <= 8'd255) begin
                        // Update bin count and store value if there's space
                        if (bin_indices[get_bin(current_value)] < BIN_SIZE) begin
                            bin_data[get_bin(current_value)][bin_indices[get_bin(current_value)]] <= current_value;
                            bin_indices[get_bin(current_value)] <= bin_indices[get_bin(current_value)] + 1'b1;
                        end
                        bin_counts[get_bin(current_value)] <= bin_counts[get_bin(current_value)] + 1'b1;
                    end
                    
                    // Start writing results
                    state <= WRITE_COUNT;
                    current_bin <= 3'd0;
                end
                
                WRITE_COUNT: begin
                    // Output bin count and address to RAM
                    if (m_axis_tready || !m_axis_tvalid) begin
                        // Generate the address and data for the current bin count
                        address <= current_bin << 2; // Multiply by 4 to get address (0x00, 0x04, etc.)
                        m_axis_tdata <= {address, bin_counts[current_bin]};
                        m_axis_tvalid <= 1'b1;
                        
                        // Move to next bin or start writing data
                        if (current_bin == NUM_BINS - 1) begin
                            state <= WRITE_DATA;
                            current_bin <= 3'd0;
                            data_index <= 5'd0;
                        end else begin
                            current_bin <= current_bin + 1'b1;
                        end
                    end
                end
                
                WRITE_DATA: begin
                    // Output bin data values to RAM
                    if (m_axis_tready || !m_axis_tvalid) begin
                        // Only write if we have data in this bin and haven't reached the end
                        if (data_index < bin_indices[current_bin]) begin
                            // Calculate address: base address for bin + index
                            // Bin 0: 0x20-0x3F, Bin 1: 0x40-0x5F, etc.
                            address <= 8'h20 + (current_bin << 5) + data_index;
                            m_axis_tdata <= {address, 24'h0, bin_data[current_bin][data_index]};
                            m_axis_tvalid <= 1'b1;
                            data_index <= data_index + 1'b1;
                        end else begin
                            // Move to next bin
                            current_bin <= current_bin + 1'b1;
                            data_index <= 5'd0;
                            
                            // If we've processed all bins, go back to IDLE
                            if (current_bin == NUM_BINS - 1) begin
                                state <= IDLE;
                                m_axis_tvalid <= 1'b0;
                            end
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
            
            // Clear valid flag after data is accepted
            if (m_axis_tvalid && m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
            end
        end
    end

endmodule