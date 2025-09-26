
# UVM Verification test bench for LCD controller

# 📌 Project Description

This project implements and verifies a **16x2 LCD Controller** using **SystemVerilog and UVM**.  
The goal is to design a controller that can **initialize, control, and send data/commands** to a standard HD44780-compatible 16x2 character LCD, and then verify its correctness using a **Universal Verification Methodology (UVM) environment**.

---

## 🔄 Design and Verification Flow

1. **Design (DUT - lcd16x2_ctrl.sv)**  
   - Implements the logic required to drive a 16x2 LCD.  
   - Handles initialization, command decoding, timing, and data display.  

2. **Testbench Top (lcd_top.sv)**  
   - Instantiates the DUT and connects it with the verification environment via an **interface**.  
   - Acts as the integration point between RTL and UVM.  

3. **Interface (lcd_interface.sv)**  
   - Defines all the signals between DUT and testbench (clock, reset, data bus, control signals).  
   - Provides a clean abstraction for drivers and monitors.  

4. **UVM Environment (lcd_env.sv)**  
   - Container for the verification components: **agent, scoreboard, monitor, driver, sequencer**.  
   - Manages communication and hierarchy in the UVM testbench.  

5. **Agent (lcd_agent.sv)**  
   - Encapsulates driver, monitor, and sequencer.  
   - Responsible for generating stimulus and observing DUT response.  

6. **Driver (lcd_driver.sv)**  
   - Converts high-level transactions (sequence items) into pin-level signal activity on the DUT interface.  
   - Sends commands and data to the LCD controller.  

7. **Sequencer (lcd_sequencer.sv)**  
   - Coordinates sequences and provides transactions to the driver.  

8. **Sequence & Transactions**  
   - **lcd_seq_item.sv** → Defines the transaction object (e.g., command, data, address).  
   - **lcd_sequence.sv** → Base sequence that generates generic LCD operations.  
   - **lcd_text_sequence.sv** → Higher-level sequence to send ASCII text strings to be displayed.  

9. **Test (lcd_test.sv)**  
   - Top-level UVM test class.  
   - Configures the environment, starts sequences, and controls simulation flow.  

10. **Package (lcd_pkg.sv)**  
    - Collects all UVM components into a single package for easy compilation.  

11. **Filelist (lcd.f)**  
    - Contains the list of all design and testbench files for compilation with the simulator.  

12. **Simulation Outputs**  
    - **dump.vcd** → Waveform dump for viewing in GTKWave.  
    - **xrun.log** → Simulation log with UVM messages, errors, and reports.  
    - **simvision.dsn/trn** → Database for Cadence SimVision waveform debugging.  

---

## 📊 Verification Flow Summary

1. **Sequence generates a transaction** (command/data for LCD).  
2. **Sequencer sends the transaction** to the **driver**.  
3. **Driver converts it** into pin-level signals and drives them into the **DUT (lcd16x2_ctrl)** via the **interface**.  
4. **Monitor observes DUT outputs** and converts them back into transaction-level data.  
5. **Scoreboard (inside environment)** checks correctness by comparing DUT outputs with expected results.  
6. **Results are logged**, and **waveforms dumped** for debugging.  

---

This flow ensures that the **LCD Controller** design is functionally correct and behaves as expected under different input scenarios.



## Deployment

To deploy this project run

```bash
xrun -uvm -access +rwf -f lcd.f -l run.log 
```

To obtain the waveforms

```bash
simvision dump.vcd
```


## Output


<img width="1920" height="1080" alt="Screenshot from 2025-09-13 12-52-53 1" src="https://github.com/user-attachments/assets/efdc3317-335e-4c24-8970-b2add5cf7573" />
