`ifndef _DIVIDER_64_SV
`define _DIVIDER_64_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module divider_64
    import common::*;
    import pipes::*;(
    input u1 clk, 
    input u1 reset, 
    input u1 valid,
    input word_t a, 
    input word_t b,
    output u1 done, 
    output u128 c 
);
    enum i1 { INIT, DOING } state, state_nxt;
    i65 count, count_nxt;
    localparam i65 DIV_DELAY = {1'b1, 64'b0};

    assign done = (state_nxt == INIT);

    always_ff @(posedge clk) begin
        if (reset) begin
            {state, count} <= '0;
        end else begin
            {state, count} <= {state_nxt, count_nxt};
        end
    end
    
    always_comb begin
        {state_nxt, count_nxt} = {state, count}; 
        unique case(state)
            INIT: begin
                if (valid) begin
                    state_nxt = DOING;
                    count_nxt = DIV_DELAY;
                end
            end
            DOING: begin
                count_nxt = {1'b0, count_nxt[64:1]};
                if (count_nxt == '0) begin
                    state_nxt = INIT;
                end
            end
        endcase
    end

    i128 p, p_nxt;

    always_ff @(posedge clk) begin
        if (reset) begin
            p <= '0;
        end else begin
            p <= p_nxt;
        end
    end

    always_comb begin
        p_nxt = p;
        unique case(state)
            INIT: begin
                p_nxt = {{64{1'b0}}, a};
            end
            DOING: begin
                p_nxt = {p_nxt[126:0], 1'b0};
                if (p_nxt[127:64] >= b) begin
                    p_nxt[127:64] -= b;
                    p_nxt[0] = 1'b1;
                end
            end
        endcase
    end

    assign c = p;
endmodule

`endif 