//===============================================================================
// Fixed LCD Sequence
//===============================================================================
class lcd_sequence extends uvm_sequence#(lcd_seq_item);
   
    `uvm_object_utils(lcd_sequence)
    lcd_seq_item lcd_seq_item_h;
    function new (string name = "lcd_sequence");
        super.new(name);
    endfunction
   
    task body;
        
        `uvm_info("LCD_SEQUENCE", "Entered inside body of sequence", UVM_MEDIUM);
       
        lcd_seq_item_h = lcd_seq_item::type_id::create("lcd_seq_item_h");
       
        start_item(lcd_seq_item_h);
           
        // Fixed: Changed from apb_seq_item_h to lcd_seq_item_h
        if(!lcd_seq_item_h.randomize()) begin
            `uvm_error("RANDOMIZATION_FAILED", "randomization failed");
        end else begin
            `uvm_info("LCD_SEQUENCE", "randomization successful with the following values", UVM_MEDIUM);
            lcd_seq_item_h.print();
        end
       
        finish_item(lcd_seq_item_h);
       
        `uvm_info("LCD_SEQUENCE", "Exiting body of sequence", UVM_MEDIUM);
    endtask
endclass
