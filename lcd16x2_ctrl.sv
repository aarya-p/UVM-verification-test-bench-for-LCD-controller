//-------------------------------------------------------------------------------
// Title      : 16x2 LCD controller
// Project    : 
//-------------------------------------------------------------------------------
// File       : lcd16x2_ctrl.sv
// Author     : Converted from VHDL
// Company    : 
// Created    : 2012-07-28
// Last update: 2012-11-28
// Platform   : 
// Standard   : SystemVerilog
//-------------------------------------------------------------------------------
// Description: The controller initializes the display when rst goes to '0'.
//              After that it writes the content of the input signals
//              line1_buffer and line2_buffer continuously to the display.
//-------------------------------------------------------------------------------

module lcd16x2_ctrl #(
    parameter int CLK_PERIOD_NS = 20  // 50MHz
)(
    input  logic        clk,
    input  logic        rst,
    output logic        lcd_e,
    output logic        lcd_rs,
    output logic        lcd_rw,
    output logic [7:4]  lcd_db,
    input  logic [127:0] line1_buffer,  // 16x8bit
    input  logic [127:0] line2_buffer
);

    // Delay constants
    localparam int DELAY_15_MS   = 15 * 1000000 / CLK_PERIOD_NS + 1;
    localparam int DELAY_1640_US = 1640 * 1000 / CLK_PERIOD_NS + 1;
    localparam int DELAY_4100_US = 4100 * 1000 / CLK_PERIOD_NS + 1;
    localparam int DELAY_100_US  = 100 * 1000 / CLK_PERIOD_NS + 1;
    localparam int DELAY_40_US   = 40 * 1000 / CLK_PERIOD_NS + 1;

    localparam int DELAY_NIBBLE     = 1000 / CLK_PERIOD_NS + 1;
    localparam int DELAY_LCD_E      = 230 / CLK_PERIOD_NS + 1;
    localparam int DELAY_SETUP_HOLD = 40 / CLK_PERIOD_NS + 1;

    localparam int MAX_DELAY = DELAY_15_MS;

    // Operation record structure
    typedef struct packed {
        logic       rs;
        logic [7:0] data;
        int         delay_h;
        int         delay_l;
    } op_t;

    // Default and predefined operations
    localparam op_t default_op      = '{rs: 1'b1, data: 8'h00, delay_h: DELAY_NIBBLE, delay_l: DELAY_40_US};
    localparam op_t op_select_line1 = '{rs: 1'b0, data: 8'h80, delay_h: DELAY_NIBBLE, delay_l: DELAY_40_US};
    localparam op_t op_select_line2 = '{rs: 1'b0, data: 8'hC0, delay_h: DELAY_NIBBLE, delay_l: DELAY_40_US};

    // Configuration operations array
    localparam op_t config_ops[6] = '{
        '{rs: 1'b0, data: 8'h33, delay_h: DELAY_4100_US, delay_l: DELAY_100_US},  // index 5
        '{rs: 1'b0, data: 8'h32, delay_h: DELAY_40_US,   delay_l: DELAY_40_US},   // index 4
        '{rs: 1'b0, data: 8'h28, delay_h: DELAY_NIBBLE,  delay_l: DELAY_40_US},   // index 3
        '{rs: 1'b0, data: 8'h06, delay_h: DELAY_NIBBLE,  delay_l: DELAY_40_US},   // index 2
        '{rs: 1'b0, data: 8'h0C, delay_h: DELAY_NIBBLE,  delay_l: DELAY_40_US},   // index 1
        '{rs: 1'b0, data: 8'h01, delay_h: DELAY_NIBBLE,  delay_l: DELAY_1640_US}  // index 0
    };

    op_t this_op;

    // Operation state machine
    typedef enum logic [3:0] {
        IDLE,
        WAIT_SETUP_H,
        ENABLE_H,
        WAIT_HOLD_H,
        WAIT_DELAY_H,
        WAIT_SETUP_L,
        ENABLE_L,
        WAIT_HOLD_L,
        WAIT_DELAY_L,
        DONE
    } op_state_t;

    op_state_t op_state, next_op_state;
    int cnt, next_cnt;

    // Main state machine
    typedef enum logic [2:0] {
        RESET,
        CONFIG,
        SELECT_LINE1,
        WRITE_LINE1,
        SELECT_LINE2,
        WRITE_LINE2
    } state_t;

    state_t state, next_state;
    logic [3:0] ptr, next_ptr;

    // Main state machine process
    always_comb begin
        case (state)
            RESET: begin
                this_op    = default_op;
                next_state = CONFIG;
                next_ptr   = 4'd5;  // config_ops array high index
            end

            CONFIG: begin
                this_op    = config_ops[ptr];
                next_ptr   = ptr;
                next_state = CONFIG;
                if (op_state == DONE) begin
                    next_ptr = ptr - 1;
                    if (ptr == 0) begin
                        next_state = SELECT_LINE1;
                    end
                end
            end

            SELECT_LINE1: begin
                this_op  = op_select_line1;
                next_ptr = 4'd15;
                if (op_state == DONE) begin
                    next_state = WRITE_LINE1;
                end else begin
                    next_state = SELECT_LINE1;
                end
            end

            WRITE_LINE1: begin
                this_op      = default_op;
                this_op.data = line1_buffer[ptr*8 +: 8];
                next_ptr     = ptr;
                next_state   = WRITE_LINE1;
                if (op_state == DONE) begin
                    next_ptr = ptr - 1;
                    if (ptr == 0) begin
                        next_state = SELECT_LINE2;
                    end
                end
            end

            SELECT_LINE2: begin
                this_op  = op_select_line2;
                next_ptr = 4'd15;
                if (op_state == DONE) begin
                    next_state = WRITE_LINE2;
                end else begin
                    next_state = SELECT_LINE2;
                end
            end

            WRITE_LINE2: begin
                this_op      = default_op;
                this_op.data = line2_buffer[ptr*8 +: 8];
                next_ptr     = ptr;
                next_state   = WRITE_LINE2;
                if (op_state == DONE) begin
                    next_ptr = ptr - 1;
                    if (ptr == 0) begin
                        next_state = SELECT_LINE1;
                    end
                end
            end

            default: begin
                this_op    = default_op;
                next_state = RESET;
                next_ptr   = 4'd0;
            end
        endcase
    end

    // State register
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= RESET;
            ptr   <= 4'd0;
        end else begin
            state <= next_state;
            ptr   <= next_ptr;
        end
    end

    // We never read from the LCD
    assign lcd_rw = 1'b0;

    // Operation state machine process
    always_comb begin
        case (op_state)
            IDLE: begin
                lcd_db        = 4'b0000;
                lcd_rs        = 1'b0;
                lcd_e         = 1'b0;
                next_op_state = WAIT_SETUP_H;
                next_cnt      = DELAY_SETUP_HOLD;
            end

            WAIT_SETUP_H: begin
                lcd_db = this_op.data[7:4];
                lcd_rs = this_op.rs;
                lcd_e  = 1'b0;
                if (cnt == 0) begin
                    next_op_state = ENABLE_H;
                    next_cnt      = DELAY_LCD_E;
                end else begin
                    next_op_state = WAIT_SETUP_H;
                    next_cnt      = cnt - 1;
                end
            end

            ENABLE_H: begin
                lcd_db = this_op.data[7:4];
                lcd_rs = this_op.rs;
                lcd_e  = 1'b1;
                if (cnt == 0) begin
                    next_op_state = WAIT_HOLD_H;
                    next_cnt      = DELAY_SETUP_HOLD;
                end else begin
                    next_op_state = ENABLE_H;
                    next_cnt      = cnt - 1;
                end
            end

            WAIT_HOLD_H: begin
                lcd_db = this_op.data[7:4];
                lcd_rs = this_op.rs;
                lcd_e  = 1'b0;
                if (cnt == 0) begin
                    next_op_state = WAIT_DELAY_H;
                    next_cnt      = this_op.delay_h;
                end else begin
                    next_op_state = WAIT_HOLD_H;
                    next_cnt      = cnt - 1;
                end
            end

            WAIT_DELAY_H: begin
                lcd_db = 4'b0000;
                lcd_rs = 1'b0;
                lcd_e  = 1'b0;
                if (cnt == 0) begin
                    next_op_state = WAIT_SETUP_L;
                    next_cnt      = DELAY_SETUP_HOLD;
                end else begin
                    next_op_state = WAIT_DELAY_H;
                    next_cnt      = cnt - 1;
                end
            end

            WAIT_SETUP_L: begin
                lcd_db = this_op.data[3:0];
                lcd_rs = this_op.rs;
                lcd_e  = 1'b0;
                if (cnt == 0) begin
                    next_op_state = ENABLE_L;
                    next_cnt      = DELAY_LCD_E;
                end else begin
                    next_op_state = WAIT_SETUP_L;
                    next_cnt      = cnt - 1;
                end
            end

            ENABLE_L: begin
                lcd_db = this_op.data[3:0];
                lcd_rs = this_op.rs;
                lcd_e  = 1'b1;
                if (cnt == 0) begin
                    next_op_state = WAIT_HOLD_L;
                    next_cnt      = DELAY_SETUP_HOLD;
                end else begin
                    next_op_state = ENABLE_L;
                    next_cnt      = cnt - 1;
                end
            end

            WAIT_HOLD_L: begin
                lcd_db = this_op.data[3:0];
                lcd_rs = this_op.rs;
                lcd_e  = 1'b0;
                if (cnt == 0) begin
                    next_op_state = WAIT_DELAY_L;
                    next_cnt      = this_op.delay_l;
                end else begin
                    next_op_state = WAIT_HOLD_L;
                    next_cnt      = cnt - 1;
                end
            end

            WAIT_DELAY_L: begin
                lcd_db = 4'b0000;
                lcd_rs = 1'b0;
                lcd_e  = 1'b0;
                if (cnt == 0) begin
                    next_op_state = DONE;
                    next_cnt      = 0;
                end else begin
                    next_op_state = WAIT_DELAY_L;
                    next_cnt      = cnt - 1;
                end
            end

            DONE: begin
                lcd_db        = 4'b0000;
                lcd_rs        = 1'b0;
                lcd_e         = 1'b0;
                next_op_state = IDLE;
                next_cnt      = 0;
            end

            default: begin
                lcd_db        = 4'b0000;
                lcd_rs        = 1'b0;
                lcd_e         = 1'b0;
                next_op_state = IDLE;
                next_cnt      = 0;
            end
        endcase
    end

    // Operation state register
    always_ff @(posedge clk) begin
        if (state == RESET) begin
            op_state <= IDLE;
        end else begin
            op_state <= next_op_state;
            cnt      <= next_cnt;
        end
    end

endmodule