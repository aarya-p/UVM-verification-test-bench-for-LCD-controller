module lcd_top;
    import lcd_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
   
    reg clk;
    reg rst;
   
    lcd_interface lcd_intf(clk, rst);
    
    // FIXED: Port connections
    lcd16x2_ctrl lcd_design(
        .clk(lcd_intf.clk), 
        .rst(lcd_intf.rst), 
        .lcd_e(lcd_intf.lcd_e), 
        .lcd_rs(lcd_intf.lcd_rs), 
        .lcd_rw(lcd_intf.lcd_rw),              // FIXED: was .rw
        .lcd_db(lcd_intf.lcd_db), 
        .line1_buffer(lcd_intf.line1), 
        .line2_buffer(lcd_intf.line2)
    );
   
    initial begin
        `uvm_info("LCD_TOP", "LCD Top module initialized", UVM_LOW);
    end
   
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();  // Better coverage
        run_test("lcd_test");
    end
   
    // Clock generation (50MHz)
    initial begin
        clk = 1'b0;
        forever begin
            #10 clk = ~clk;  // 20ns period
        end
    end
    
    // Reset generation
    initial begin
        rst = 1'b1;
        #20 rst = 1'b0;  // Hold reset longer
        `uvm_info("LCD_TOP", "Reset released", UVM_MEDIUM);
    end
   
    // FIXED: Set interface for both driver AND monitor
    initial begin
        uvm_config_db#(virtual lcd_interface)::set(null, "*lcd_driver*", "vif", lcd_intf);
        `uvm_info("LCD_TOP", "Virtual interfaces configured", UVM_MEDIUM);
    end
  
endmodule
