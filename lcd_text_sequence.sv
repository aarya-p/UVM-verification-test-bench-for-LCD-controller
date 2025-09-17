//===============================================================================
// Enhanced LCD Sequence with Predefined Text
//===============================================================================
class lcd_text_sequence extends uvm_sequence#(lcd_seq_item);
   
    `uvm_object_utils(lcd_text_sequence)
    
    string line1_text = "Hello World!    ";
    string line2_text = "UVM Testbench  ";
    
    function new (string name = "lcd_text_sequence");
        super.new(name);
    endfunction
   
    task body;
        lcd_seq_item lcd_seq_item_h;
        
        `uvm_info("LCD_TEXT_SEQUENCE", "Sending predefined text to LCD", UVM_LOW);
       
        lcd_seq_item_h = lcd_seq_item::type_id::create("lcd_seq_item_h");
       
        start_item(lcd_seq_item_h);
        
        // Set specific text instead of random
        lcd_seq_item_h.set_line1_string(line1_text);
        lcd_seq_item_h.set_line2_string(line2_text);
        
        `uvm_info("LCD_TEXT_SEQUENCE", $sformatf("Sending:\n  Line1: '%s'\n  Line2: '%s'", 
                 line1_text, line2_text), UVM_LOW);
       
        finish_item(lcd_seq_item_h);
    endtask
endclass