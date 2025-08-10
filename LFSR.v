//======================================================================
//  Module      : LFSR
//  Designer    : Ahmed Alaa
//  Description : Linear Feedback Shift Register for CRC calculation.
//                Takes input data and generates a CRC value based on
//                polynomial taps. Can work in active mode (shift & XOR)
//                or as a memory (hold state).
//  Date        : 10-Aug-2025
//
//  Ports:
//    DATA    : Input data to the LFSR (1 byte to 4 bytes).
//    ACTIVE  : Active signal; high for normal LFSR operation, low for memory mode.
//    CLK     : Clock signal for CRC logic.
//    RST     : Asynchronous active-low reset.
//    CRC     : Serial output of the CRC value.
//    valid   : Output flag indicating CRC is valid.
//
//  Notes:
//    - SEED initializes the LFSR.
//    - Taps defines the feedback polynomial.
//======================================================================

module LFSR (
    input  wire  DATA,             // Input data to the LFSR (1 byte to 4 bytes)
    input  wire  ACTIVE,           // Active signal: high = LFSR works, low = memory mode
    input  wire  CLK,              // Clock for the CRC
    input  wire  RST,              // Asynchronous active-low reset
    output reg   CRC,              // Serial output of the CRC
    output reg   valid             // Valid signal for CRC output
);

    localparam SEED = 8'hD8 ;
    localparam Taps = 7'b0111011 ; 
    integer i;   

    // Internal signals
    reg   [7:0] LFSR ;
    wire        feedback ;
    reg         counter_enable ;
    reg   [3:0] counter ;           // Used to output bits sequentially to CRC
    reg         flag ;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            LFSR  <= SEED ;
            CRC   <= 0 ;
            valid <= 0 ;
            counter_enable <= 0 ;
            flag <= 0 ;
        end
        else begin
            if(ACTIVE) begin
                counter_enable <= 0;
                flag <= 0 ;
                LFSR[7] <= feedback ;
                for (i = 6; i > 0; i = i - 1) begin
                    if(Taps[i]) begin
                        LFSR[i] <= LFSR[i+1] ;
                    end
                    else begin
                        LFSR[i] <= LFSR[i+1] ^ feedback ;
                    end
                end  
            end
            else if(!ACTIVE && flag == 0) begin
                counter_enable <= 1 ;
                if(counter < 8) begin
                    {LFSR[6:0], CRC} <= LFSR ;
                    valid <= 1'b1 ;
                end
                else begin
                    flag <= 1 ;
                    CRC <= 0 ;
                    counter_enable <= 0;
                    valid <= 0 ;
                end
            end
        end
    end
    
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            counter <= 0;
        end
        else begin
            if(counter_enable)
                counter <= (counter > 8) ? 0 : counter + 1 ;
            else 
                counter <= 0 ;
        end
    end

    assign feedback = DATA ^ LFSR[0] ;

endmodule
