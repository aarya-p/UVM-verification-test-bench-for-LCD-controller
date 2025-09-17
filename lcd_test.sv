class lcd_test extends uvm_test;
    `uvm_component_utils(lcd_test)
   
    lcd_env lcd_env_h;
    lcd_sequence lcd_sequence_h;  // Use text sequence instead of random
    
    function new(string name = "lcd_test", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("LCD_TEST", "Inside the constructor of test", UVM_MEDIUM);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("LCD_TEST", "Inside the build of test", UVM_MEDIUM);
        
        lcd_env_h = lcd_env::type_id::create("lcd_env_h", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("LCD_TEST", "Inside the connect of test", UVM_MEDIUM);
    endfunction
   
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("LCD_TEST", "Inside the end of elaboration of test", UVM_MEDIUM);
        uvm_top.print_topology();
    endfunction
   
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("LCD_TEST", "Starting LCD test", UVM_LOW);
       
        // Set expected data in scoreboard BEFORE starting sequence
        // Create and start sequence
        lcd_sequence_h = lcd_sequence::type_id::create("lcd_sequence_h");
        
        // FIXED: Correct path to sequencer
        lcd_sequence_h.start(lcd_env_h.lcd_agent_h.lcd_sequencer_h);
        
        `uvm_info("LCD_TEST", "Sequence completed - waiting for LCD processing", UVM_LOW);
        
        // Wait long enough for LCD initialization and several refresh cycles
        #50ms;  // 50 milliseconds for complete verification
        
        phase.drop_objection(this);
    endtask
endclass
