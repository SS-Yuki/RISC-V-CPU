`ifndef _PCSELECT_SV
`define _PCSELECT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 


module pcselect 
    import common::*;
    import pipes::*;(
    input u64 pcplus4,
    input u64 pcjump,
    input control_t ctl,
    input u1 branch_flag,
    input u1 csr_flush,
    output u64 pc_nxt,
    output u1 jump_flag
);  
    always_comb begin
        if (ctl.jalr) begin
            pc_nxt = pcjump & {{63{1'b1}}, 1'b0};
            jump_flag = ON;
        end
        else if ((ctl.branch && branch_flag) || ctl.jump) begin
            pc_nxt = pcjump;
            jump_flag = ON;
        end
        else begin
            pc_nxt = pcplus4;
            jump_flag = OFF;
        end
    end

    
    
endmodule

`endif 