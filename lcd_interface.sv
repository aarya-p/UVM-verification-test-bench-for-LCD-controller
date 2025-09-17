//===============================================================================
// Updated LCD Interface
//===============================================================================
interface lcd_interface(input clk, input rst);
   
    // Input data buffers (to DUT)
    logic [127:0] line1;
    logic [127:0] line2;
    
    // LCD control outputs (from DUT)
    logic lcd_e;
    logic lcd_rs;
    logic lcd_rw;
    logic [7:4] lcd_db;
    
    // Utility function for string conversion
endinterface
