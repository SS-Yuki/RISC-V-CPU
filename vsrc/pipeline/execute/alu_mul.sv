`ifndef __ALU_MUL_SV
`define __ALU_MUL_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif


module alu_mul
	import common::*;
	import pipes::*;(
    input u1 clk, 
    input u1 reset, 
	input word_t a,
	input word_t b,
	input alufunc_t alufunc,
    input u1 valid,
	output word_t alu_result,
    output u1 data_ok
);
    u1 multiplier_64_valid, divider_32_valid, divider_64_valid;
    u1 multiplier_64_done, divider_32_done, divider_64_done;

    u64 multiplier_64_a, multiplier_64_b;
    u32 divider_32_a, divider_32_b;
    u64 divider_64_a, divider_64_b;
    u64 divider_32_c;
    u128 multiplier_64_c, divider_64_c;

    u32 tem;

    multiplier_64 multiplier_64(
        .clk, 
        .reset, 
        .valid(multiplier_64_valid),
        .a(multiplier_64_a), 
        .b(multiplier_64_b),
        .done(multiplier_64_done), 
        .c(multiplier_64_c)
    );

    divider_32 divider_32(
        .clk, 
        .reset, 
        .valid(divider_32_valid),
        .a(divider_32_a), 
        .b(divider_32_b),
        .done(divider_32_done), 
        .c(divider_32_c)
    );

    divider_64 divider_64(
        .clk, 
        .reset, 
        .valid(divider_64_valid),
        .a(divider_64_a), 
        .b(divider_64_b),
        .done(divider_64_done), 
        .c(divider_64_c)
    );

    always_comb begin
        alu_result = '0; 
        data_ok = '0;
        tem = '0;
        {multiplier_64_valid, divider_32_valid, divider_64_valid} = '0;
        {multiplier_64_a, multiplier_64_b, divider_32_a, divider_32_b, divider_64_a, divider_64_b} = '0;
        unique case(valid)
            ON: unique case(alufunc)
                    ALU_MUL: begin
                        multiplier_64_valid = ON;
                        data_ok = multiplier_64_done;
                        multiplier_64_a = a;
                        multiplier_64_b = b;
                        alu_result = multiplier_64_c[63:0];
                    end

                    ALU_MULW: begin
                        multiplier_64_valid = ON;
                        data_ok = multiplier_64_done;
                        multiplier_64_a = a;
                        multiplier_64_b = b;
                        alu_result = {{32{multiplier_64_c[31]}}, multiplier_64_c[31:0]};
                    end

                    ALU_DIV: begin
                        if (b == '0) begin
                            alu_result = '1;
                            data_ok = ON;
                        end
                        else begin
                            divider_64_valid = ON;
                            data_ok = divider_64_done;
                            if (a[63] == 1'b0 && b[63] == 1'b0) begin
                                divider_64_a = a;
                                divider_64_b = b;
                                alu_result = divider_64_c[63:0];
                            end
                            else if (a[63] == 1'b0 && b[63] == 1'b1) begin
                                divider_64_a = a;
                                divider_64_b = -$signed(b);
                                alu_result = -$signed(divider_64_c[63:0]);
                            end
                            else if (a[63] == 1'b1 && b[63] == 1'b0) begin
                                divider_64_a = -$signed(a);
                                divider_64_b = b;
                                alu_result = -$signed(divider_64_c[63:0]);
                            end
                            else begin
                                divider_64_a = -$signed(a);
                                divider_64_b = -$signed(b);
                                alu_result = divider_64_c[63:0];
                            end
                        end
                    end

                    ALU_DIVU: begin
                        if (b == '0) begin
                            alu_result = '1;
                            data_ok = ON;
                        end
                        else begin
                            divider_64_valid = ON;
                            data_ok = divider_64_done;
                            divider_64_a = a;
                            divider_64_b = b;
                            alu_result = divider_64_c[63:0];
                        end    
                    end

                    ALU_DIVW: begin
                        if (b[31:0] == '0) begin
                            alu_result = '1;
                            data_ok = ON;
                        end
                        else begin
                            divider_32_valid = ON;
                            data_ok = divider_32_done;
                            if (a[31] == 1'b0 && b[31] == 1'b0) begin
                                divider_32_a = a[31:0];
                                divider_32_b = b[31:0];
                                alu_result = {{32{divider_32_c[31]}}, divider_32_c[31:0]};
                            end
                            else if (a[31] == 1'b0 && b[31] == 1'b1) begin
                                divider_32_a = a[31:0];
                                divider_32_b = -$signed(b[31:0]);
                                tem = -$signed(divider_32_c[31:0]);
                                alu_result = {{32{tem[31]}}, tem};
                            end
                            else if (a[31] == 1'b1 && b[31] == 1'b0) begin
                                divider_32_a = -$signed(a[31:0]);
                                divider_32_b = b[31:0];
                                tem = -$signed(divider_32_c[31:0]);
                                alu_result = {{32{tem[31]}}, tem};
                            end
                            else begin
                                divider_32_a = -$signed(a[31:0]);
                                divider_32_b = -$signed(b[31:0]);
                                tem = divider_32_c[31:0];
                                alu_result = {{32{tem[31]}}, tem};
                            end
                        end
                    end

                    ALU_DIVUW: begin
                        if (b[31:0] == '0) begin
                            alu_result = '1;
                            data_ok = ON;
                        end
                        else begin
                            divider_32_valid = ON;
                            data_ok = divider_32_done;
                            divider_32_a = a[31:0];
                            divider_32_b = b[31:0];
                            alu_result = {{32{divider_32_c[31]}}, divider_32_c[31:0]};
                        end
                    end

                    ALU_REM: begin
                        if (b == '0) begin
                            alu_result = a;
                            data_ok = ON;
                        end
                        else begin
                            divider_64_valid = ON;
                            data_ok = divider_64_done;
                            if (a[63] == 1'b0 && b[63] == 1'b0) begin
                                divider_64_a = a;
                                divider_64_b = b;
                                alu_result = divider_64_c[127:64];
                            end
                            else if (a[63] == 1'b0 && b[63] == 1'b1) begin
                                divider_64_a = a;
                                divider_64_b = -$signed(b);
                                alu_result = divider_64_c[127:64];
                            end
                            else if (a[63] == 1'b1 && b[63] == 1'b0) begin
                                divider_64_a = -$signed(a);
                                divider_64_b = b;
                                alu_result = -$signed(divider_64_c[127:64]);
                            end
                            else begin
                                divider_64_a = -$signed(a);
                                divider_64_b = -$signed(b);
                                alu_result = -$signed(divider_64_c[127:64]);
                            end
                        end
                    end

                    ALU_REMU: begin
                        if (b == '0) begin
                            alu_result = a;
                            data_ok = ON;
                        end
                        else begin
                            divider_64_valid = ON;
                            data_ok = divider_64_done;
                            divider_64_a = a;
                            divider_64_b = b;
                            alu_result = divider_64_c[127:64];
                        end
                    end

                    ALU_REMW: begin
                        if (b[31:0] == '0) begin
                            alu_result = {{32{a[31]}}, a[31:0]};
                            data_ok = ON;
                        end
                        else begin
                            divider_32_valid = ON;
                            data_ok = divider_32_done;
                            if (a[31] == 1'b0 && b[31] == 1'b0) begin
                                divider_32_a = a[31:0];
                                divider_32_b = b[31:0];
                                alu_result = {{32{divider_32_c[63]}}, divider_32_c[63:32]};
                            end
                            else if (a[31] == 1'b0 && b[31] == 1'b1) begin
                                divider_32_a = a[31:0];
                                divider_32_b = -$signed(b[31:0]);
                                alu_result = {{32{divider_32_c[63]}}, divider_32_c[63:32]};
                            end
                            else if (a[31] == 1'b1 && b[31] == 1'b0) begin
                                divider_32_a = -$signed(a[31:0]);
                                divider_32_b = b[31:0];
                                tem = -$signed(divider_32_c[63:32]);
                                alu_result = {{32{tem[31]}}, tem};
                            end
                            else begin
                                divider_32_a = -$signed(a[31:0]);
                                divider_32_b = -$signed(b[31:0]);
                                tem = -$signed(divider_32_c[63:32]);
                                alu_result = {{32{tem[31]}}, tem};
                            end
                        end
                    end

                    ALU_REMUW: begin
                        if (b[31:0] == '0) begin
                            alu_result = {{32{a[31]}}, a[31:0]};
                            data_ok = ON;
                        end
                        else begin
                            divider_32_valid = ON;
                            data_ok = divider_32_done;
                            divider_32_a = a[31:0];
                            divider_32_b = b[31:0];
                            alu_result = {{32{divider_32_c[63]}}, divider_32_c[63:32]};
                        end
                    end
                    default: begin
                        
                    end
                endcase

            OFF: begin
                
            end 
        
        endcase
        
    end
	
endmodule

`endif

