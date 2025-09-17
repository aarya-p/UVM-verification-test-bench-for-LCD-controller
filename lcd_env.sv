class lcd_env extends uvm_env;
    `uvm_component_utils(lcd_env)
    
    lcd_agent      lcd_agent_h;
    // ADD SCOREBOARD
    
    function new(string name = "lcd_env", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("LCD_ENV", "Inside the constructor of env", UVM_HIGH);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("LCD_ENV", "Inside the build of env", UVM_HIGH);
        
        lcd_agent_h = lcd_agent::type_id::create("lcd_agent_h", this);
  
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("LCD_ENV", "Inside the connect of env", UVM_HIGH);
        
        // CONNECT MONITOR TO SCOREBOARD
        
    endfunction
endclass
