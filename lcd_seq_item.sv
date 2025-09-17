//===============================================================================
// Fixed LCD Sequence Item
//===============================================================================
class lcd_seq_item extends uvm_sequence_item;
   
    rand bit [127:0] line1;
    rand bit [127:0] line2;
    
    // Fixed: Changed from apb_seq_item to lcd_seq_item
    `uvm_object_utils_begin(lcd_seq_item)
        `uvm_field_int(line1, UVM_ALL_ON)
        `uvm_field_int(line2, UVM_ALL_ON)
    `uvm_object_utils_end
   
    // Fixed: Changed constructor name
    function new(string name = "lcd_seq_item");
        super.new(name);
    endfunction
    
    // Utility functions for easier test writing
   
endclass
