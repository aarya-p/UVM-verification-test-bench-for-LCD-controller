package lcd_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Transaction types for monitor/scoreboard
    
    
    // Include all component files
    `include "lcd_seq_item.sv"
    `include "lcd_sequence.sv"

    `include "lcd_driver.sv"
    `include "lcd_sequencer.sv"   // ADD SCOREBOARD  
    `include "lcd_agent.sv"
    `include "lcd_env.sv"
    `include "lcd_test.sv"
endpackage
