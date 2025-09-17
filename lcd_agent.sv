class lcd_agent extends uvm_agent;
    `uvm_component_utils(lcd_agent)
    
    lcd_driver    lcd_driver_h;
    lcd_sequencer lcd_sequencer_h;

    
    function new(string name = "lcd_agent", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("LCD_AGENT", "Inside the constructor of agent", UVM_HIGH);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("LCD_AGENT", "Inside the build of agent", UVM_HIGH);
        
        lcd_driver_h    = lcd_driver::type_id::create("lcd_driver_h", this);
        lcd_sequencer_h = lcd_sequencer::type_id::create("lcd_sequencer_h", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("LCD_AGENT", "Inside the connect of agent", UVM_HIGH);
        
        lcd_driver_h.seq_item_port.connect(lcd_sequencer_h.seq_item_export);
    endfunction
endclass
