`ifndef _WRITE_MEMORY_SV
`define _WRITE_MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif 

module write_memory
    import common::*;
    import pipes::*;(
    input u64 mem_addr,
    input word_t rd2,
    input msize_t msize,
    input u1 memwrite,
    output word_t wd,
    output strobe_t strobe
);
    u3 addr3;
    u2 addr2;
    u1 addr1;
    assign addr3 = mem_addr[2:0];
    assign addr2 = mem_addr[2:1];
    assign addr1 = mem_addr[2];
    always_comb begin
        strobe = '0;
        wd = '0;
        if (memwrite) begin
            unique case(msize)
                MSIZE1: begin
                    unique case(addr3)
                        THREE_TH0: begin
                            wd[7-:8] = rd2[7:0];
                            strobe = 8'b0000_0001;
                        end
                        THREE_TH1: begin
                            wd[15-:8] = rd2[7:0];
                            strobe = 8'b0000_0010;
                        end
                        THREE_TH2: begin
                            wd[23-:8] = rd2[7:0];
                            strobe = 8'b0000_0100;
                        end
                        THREE_TH3: begin
                            wd[31-:8] = rd2[7:0];
                            strobe = 8'b0000_1000;
                        end
                        THREE_TH4: begin
                            wd[39-:8] = rd2[7:0];
                            strobe = 8'b0001_0000;
                        end
                        THREE_TH5: begin
                            wd[47-:8] = rd2[7:0];
                            strobe = 8'b0010_0000;
                        end
                        THREE_TH6: begin
                            wd[55-:8] = rd2[7:0];
                            strobe = 8'b0100_0000;
                        end
                        THREE_TH7: begin
                            wd[63-:8] = rd2[7:0];
                            strobe = 8'b1000_0000;
                        end
                        default: begin
                        end
                    endcase
                end
                MSIZE2: begin
                    unique case(addr2)
                        TWO_TH0: begin
                            wd[15-:16] = rd2[15:0];
                            strobe = 8'b0000_0011;
                        end
                        TWO_TH1: begin
                            wd[31-:16] = rd2[15:0];
                            strobe = 8'b0000_1100;
                        end
                        TWO_TH2: begin
                            wd[47-:16] = rd2[15:0];
                            strobe = 8'b0011_0000;
                        end
                        TWO_TH3: begin
                            wd[63-:16] = rd2[15:0];
                            strobe = 8'b1100_0000;
                        end
                        default: begin
                        end
                    endcase
                end
                MSIZE4: begin
                    unique case(addr1)
                        TH0: begin
                            wd[31-:32] = rd2[31:0];
                            strobe = 8'b0000_1111;
                        end
                        TH1: begin
                            wd[63-:32] = rd2[31:0];
                            strobe = 8'b1111_0000;
                        end
                        default: begin
                        end
                    endcase
                end
                MSIZE8: begin
                    wd = rd2;
                    strobe = 8'b1111_1111;        
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