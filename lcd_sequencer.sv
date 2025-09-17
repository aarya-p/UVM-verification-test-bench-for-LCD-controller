class lcd_sequencer extends uvm_sequencer#(lcd_seq_item);
    `uvm_component_utils(lcd_sequencer)
    
    function new(string name = "lcd_sequencer", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("LCD_SEQUENCER", "Inside the constructor of sequencer", UVM_HIGH);
    endfunction
endclass