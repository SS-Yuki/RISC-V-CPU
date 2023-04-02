`ifndef _PC_REG_SV
`define _PC_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module pc_reg
    import common::*;
    import pipes::*;(
    output u64 counter,
    output u64 pc,
    input u64 pc_nxt,
    input u1 clk,
    input u1 reset,
    input u1 load_stall,
    input u1 jump_flag,
    input u1 handshake_stall,
    input u1 csr_flush
);
    always_ff @(posedge clk) begin
		if (reset) begin
			pc <= 64'h8000_0000;
            counter <= '0;
		end 
        else if (handshake_stall) begin
            pc <= pc;
            counter <= counter + 1;
        end
        else if (jump_flag | csr_flush) begin
            pc <= pc_nxt;
            counter <= '0;
        end
        else if (load_stall) begin
            pc <= pc;
            counter <= '0;
            counter <= counter + 1;
        end
        else begin
			pc <= pc_nxt;
            counter <= '0;
		end
	end
endmodule

`endif 