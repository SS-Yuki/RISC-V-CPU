`ifndef _READ_MEMORY_SV
`define _READ_MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module read_memory
    import common::*;
    import pipes::*;(
    input word_t mem_data,
    input u64 mem_addr,
    input msize_t msize,
    input u1 mem_unsigned,
    output word_t data
);
    u1 sign_bit;
    u3 addr3;
    u2 addr2;
    u1 addr1;
    assign addr3 = mem_addr[2:0];
    assign addr2 = mem_addr[2:1];
    assign addr1 = mem_addr[2];

    always_comb begin
        data = 'x;
        sign_bit = 'x;
        unique case(msize)
            MSIZE1: begin 
                unique case(addr3)
                    THREE_TH0: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[7];
                        data = {{56{sign_bit}}, mem_data[7-:8]};
                    end
                    THREE_TH1: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[15];
                        data = {{56{sign_bit}}, mem_data[15-:8]};
                    end
                    THREE_TH2: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[23];
                        data = {{56{sign_bit}}, mem_data[23-:8]};
                    end
                    THREE_TH3: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[31];
                        data = {{56{sign_bit}}, mem_data[31-:8]};
                    end
                    THREE_TH4: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[39];
                        data = {{56{sign_bit}}, mem_data[39-:8]};
                    end
                    THREE_TH5: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[47];
                        data = {{56{sign_bit}}, mem_data[47-:8]};
                    end
                    THREE_TH6: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[55];
                        data = {{56{sign_bit}}, mem_data[55-:8]};
                    end
                    THREE_TH7: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[63];
                        data = {{56{sign_bit}}, mem_data[63-:8]};
                    end
                    default begin
                    end
                endcase
            end
            MSIZE2: begin 
                unique case(addr2)
                    TWO_TH0: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[15];
                        data = {{48{sign_bit}}, mem_data[15-:16]};
                    end
                    TWO_TH1: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[31];
                        data = {{48{sign_bit}}, mem_data[31-:16]};
                    end
                    TWO_TH2: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[47];
                        data = {{48{sign_bit}}, mem_data[47-:16]};
                    end
                    TWO_TH3: begin
                       sign_bit = mem_unsigned ? 1'b0 : mem_data[63];
                        data = {{48{sign_bit}}, mem_data[63-:16]};
                    end
                    default begin
                    end
                endcase
            end
            MSIZE4: begin 
                unique case(addr1)
                    TH0: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[31];
                        data = {{32{sign_bit}}, mem_data[31-:32]};
                    end
                    TH1: begin
                        sign_bit = mem_unsigned ? 1'b0 : mem_data[63];
                        data = {{32{sign_bit}}, mem_data[63-:32]};
                    end
                    default begin
                    end
                endcase
            end
            MSIZE8: begin 
                data = mem_data;
            end
            default: begin
            end
        endcase
   end
    
endmodule

`endif 