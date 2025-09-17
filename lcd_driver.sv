class lcd_driver extends uvm_driver#(lcd_seq_item);
    `uvm_component_utils(lcd_driver)
    
    virtual lcd_interface lcd_vintf;
   
    function new(string name = "lcd_driver", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("LCD_DRIVER", "Inside the constructor of driver", UVM_HIGH);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("LCD_DRIVER", "Inside the build of driver", UVM_HIGH);
       
        if(!(uvm_config_db#(virtual lcd_interface)::get(this, "", "vif", lcd_vintf))) begin
            `uvm_fatal("GET_FAILED", "lcd_intf was not set properly");
        end else begin
            `uvm_info("LCD_DRIVER", "LCD_interface get is successful", UVM_MEDIUM);
        end
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("LCD_DRIVER", "Inside the connect of driver", UVM_HIGH);
    endfunction
   
    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
               
            req.print();
            
            // Check for reset before driving
            check_reset();
            
            // Drive the transaction
            perform_transaction(req.line1, req.line2);
           
            seq_item_port.item_done(req);
        end
    endtask
   
    task check_reset();
        if(lcd_vintf.rst) begin
            `uvm_info("LCD_DRIVER", "Reset detected - clearing outputs", UVM_MEDIUM);
            @(posedge lcd_vintf.clk);
            lcd_vintf.line1 <= 128'b0;
            lcd_vintf.line2 <= 128'b0;
            
            wait(!(lcd_vintf.rst));
            `uvm_info("LCD_DRIVER", "Reset is deasserted", UVM_MEDIUM);
            
            // Wait a few clocks after reset release
            repeat(3) @(posedge lcd_vintf.clk);
        end
    endtask
   
    task perform_transaction(bit [127:0] l1, bit[127:0] l2);
        `uvm_info("LCD_DRIVER", "Driving transaction to DUT", UVM_HIGH);
        
        @(posedge lcd_vintf.clk);
        lcd_vintf.line1 <= l1;
        lcd_vintf.line2 <= l2;
        
        // Hold values for sufficient time (let LCD controller process)
        repeat(10000) @(posedge lcd_vintf.clk);  // ~200us at 50MHz for LCD processing
        
        `uvm_info("LCD_DRIVER", "Transaction completed", UVM_HIGH);
    endtask
endclass
