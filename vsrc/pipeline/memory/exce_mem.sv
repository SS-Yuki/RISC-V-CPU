`ifndef _EXCE_MEM_SV
`define _EXCE_MEM_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module exce_mem
    import common::*;
    import pipes::*;(
    input u64 addr,
    input u1 memread,
    input u1 memwrite,
    input msize_t msize,
    input u1 en,
    output u1 is_exception,
    output exception_t exception
);
    always_comb begin 
        {is_exception, exception} = '0;

        if (en) begin
            unique case (msize)
                MSIZE2: begin
                    if (~(addr[0] == 1'b0)) begin
                        if (memread) begin
                            is_exception = ON;
                            exception = EXCEPTION_LOAD_ADDR_MISALIGNED;
                        end
                        else if (memwrite) begin
                            is_exception = ON;
                            exception = EXCEPTION_STORE_ADDR_MISALIGNED;
                        end
                        else begin
                            
                        end
                    end
                    else begin
                        
                    end
                end
                MSIZE4: begin
                    if (~(addr[0] == 1'b0)) begin
                        if (memread) begin
                            is_exception = ON;
                            exception = EXCEPTION_LOAD_ADDR_MISALIGNED;
                        end
                        else if (memwrite) begin
                            is_exception = ON;
                            exception = EXCEPTION_STORE_ADDR_MISALIGNED;
                        end
                        else begin
                            
                        end
                    end
                    else begin
                        
                    end
                end
                MSIZE8: begin
                    if (~(addr[0] == 1'b0)) begin
                        if (memread) begin
                            is_exception = ON;
                            exception = EXCEPTION_LOAD_ADDR_MISALIGNED;
                        end
                        else if (memwrite) begin
                            is_exception = ON;
                            exception = EXCEPTION_STORE_ADDR_MISALIGNED;
                        end
                        else begin
                            
                        end
                    end
                    else begin
                        
                    end
                end
                default: begin
                    
                end
            endcase
        end
        else begin
            
        end
        
    
    end
    
endmodule

`endif 