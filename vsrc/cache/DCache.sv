`ifndef __DCACHE_SV
`define __DCACHE_SV

`ifdef VERILATOR
`include "include/common.sv"
/* You should not add any additional includes in this file */
`endif

module DCache 
	import common::*; #(
		/* You can modify this part to support more parameters */
		/* e.g. OFFSET_BITS, INDEX_BITS, TAG_BITS */
		parameter X = 1
	)(
	input logic clk, reset,

	input  dbus_req_t  dreq,
    output dbus_resp_t dresp,
    output cbus_req_t  creq,
    input  cbus_resp_t cresp
);

`ifndef REFERENCE_CACHE

	/* TODO: Lab3 Cache */
    
    localparam WORDS_PER_LINE = 16;
    localparam ASSOCIATIVITY = 2;
    localparam SET_NUM = 8;

    localparam OFFSET_BITS = $clog2(WORDS_PER_LINE);
    localparam INDEX_BITS = $clog2(SET_NUM);
    localparam TAG_BITS = 32 - INDEX_BITS - OFFSET_BITS - 3; /* Maybe 32, or smaller */

    localparam ASSOCIATIVITY_BITS = $clog2(ASSOCIATIVITY);

    localparam type offset_t = logic [OFFSET_BITS-1:0];
    localparam type index_t = logic [INDEX_BITS-1:0];
    localparam type tag_t = logic [TAG_BITS-1:0];

    localparam DATA_BYTE_WIDTH = 8;
    localparam DATA_BYTE_PER_WORD = 8;
    localparam DATA_WORD_WIDTH = DATA_BYTE_WIDTH * DATA_BYTE_PER_WORD;
    localparam DATA_ADDR_WIDTH = OFFSET_BITS + INDEX_BITS + ASSOCIATIVITY_BITS;

    typedef struct packed {
        u1 valid;
        u1 dirty;
        tag_t tag;
        u1 age;
    } meta_t;

    localparam type datastrobe_t = u8;
    localparam type metastrobe_t = u1;

    function offset_t get_offset(addr_t addr);
        return addr[3+OFFSET_BITS-1:3];
    endfunction

    function index_t get_index(addr_t addr);
        return addr[3+INDEX_BITS+OFFSET_BITS-1:OFFSET_BITS+3];
    endfunction

    function tag_t get_tag(addr_t addr);
        return addr[3+INDEX_BITS+OFFSET_BITS+TAG_BITS-1:3+INDEX_BITS+OFFSET_BITS];
    endfunction

    localparam type state_t = enum logic[2:0] {
        INIT, IDLE, FETCH, WRITEBACK, UNCACHED
    };

    localparam type metas_t = meta_t [ASSOCIATIVITY-1:0];

    struct packed {
        logic en;
        datastrobe_t strobe;
        word_t wdata;
    } data_in;
    u8 data_in_addr;


    struct packed {
        logic en;
        metastrobe_t strobe;
        metas_t wdata;
    } meta_in;
    u3 meta_in_addr;

    u1 hit, full, dirty;
    u1 hit_line, empty_line, replace_line, choose_line;
    u1 addr_uncache;

    state_t state;

    metas_t metas_r;
    word_t data_r;

    offset_t addr_offset;
    offset_t offset_reg;
    tag_t addr_tag;
    tag_t replace_tag;
    tag_t tag_reg;
    index_t addr_index;
    u8 counter;
    u1 choose_line_reg;

    //data RAM
    RAM_SinglePort #(
		.ADDR_WIDTH(DATA_ADDR_WIDTH),
		.DATA_WIDTH(DATA_WORD_WIDTH),
		.BYTE_WIDTH(DATA_BYTE_WIDTH),
		.READ_LATENCY(0)
	) ram_data (
        .clk, 
        .en(data_in.en),
        .addr(data_in_addr),
        .strobe(data_in.strobe),
        .wdata(data_in.wdata),
        .rdata(data_r)
    );


    //meta RAM
    RAM_SinglePort #(
		.ADDR_WIDTH(INDEX_BITS),
		.DATA_WIDTH($bits(meta_t) * ASSOCIATIVITY),
		.BYTE_WIDTH($bits(meta_t) * ASSOCIATIVITY),
		.READ_LATENCY(0)
    ) ram_meta (
        .clk, 
        .en(meta_in.en),
        .addr(meta_in_addr),
        .strobe(meta_in.strobe),
        .wdata(meta_in.wdata),
        .rdata(metas_r)
    );

    assign addr_offset = get_offset(dreq.addr);
    assign addr_tag = get_tag(dreq.addr);
    assign addr_index = get_index(dreq.addr);
    assign addr_uncache = ~dreq.addr[31];

    assign hit =  (metas_r[0].valid && metas_r[0].tag == addr_tag) || (metas_r[1].valid && metas_r[1].tag == addr_tag);
    assign hit_line = metas_r[1].tag == addr_tag;
    assign full = metas_r[0].valid && metas_r[1].valid;
    assign empty_line = metas_r[0].valid;
    assign dirty = (metas_r[0].age && metas_r[0].dirty) || (metas_r[1].age && metas_r[1].dirty);
    assign replace_line = metas_r[1].age;
    assign replace_tag = metas_r[replace_line].tag;
    assign choose_line = full ? replace_line : empty_line;
    

    // DBus driver
    assign dresp.addr_ok = (state == IDLE);
    assign dresp.data_ok = (((state == IDLE) && hit) || ((state == UNCACHED) && cresp.ready)) && dreq.valid;
    assign dresp.data    = (state == UNCACHED) ? cresp.data : data_r;

    // CBus driver
     always_comb begin
        unique case (state)
            UNCACHED: begin
                creq.valid    = 1'b1;
                creq.is_write = (|dreq.strobe);
                creq.size     = dreq.size;
                creq.addr     = dreq.addr;
                creq.strobe   = dreq.strobe;
                creq.data     = dreq.data;
                creq.len      = MLEN1;
                creq.burst	 = AXI_BURST_FIXED;
            end

            default: begin
                creq.valid    = (state == FETCH) || (state == WRITEBACK);
                creq.is_write = (state == WRITEBACK);
                creq.size     = MSIZE8;
                creq.addr     = (state == WRITEBACK) ? {{32{1'b0}}, tag_reg, addr_index, 7'b0}
                                                    : {dreq.addr[63:7], {7{1'b0}}};
                creq.strobe   = 8'b11111111;
                creq.data     = data_r;
                creq.len      = MLEN16;
                creq.burst	 = AXI_BURST_INCR;
            end
        endcase
     end


    assign meta_in_addr = (state == INIT) ? counter[2:0] : addr_index;

    always_comb begin
        meta_in = '0;
        data_in = '0;
        data_in_addr = '0;
        meta_in.wdata = metas_r;
        unique case (state)
            INIT:begin
                meta_in.en = 1'b1;
                meta_in.strobe = 1'b1; 

                data_in.en = 1'b1;
                data_in.strobe = 8'b11111111;
                data_in_addr = counter[7:0];
            end
            IDLE:begin
                if (dreq.valid) begin
                    if (hit) begin
                        data_in.en = (|dreq.strobe);
                        data_in_addr = {addr_index, hit_line, addr_offset};
                        data_in.strobe = dreq.strobe;
                        data_in.wdata = dreq.data;

                        meta_in.en = 1'b1;
                        meta_in.strobe = 1'b1; 
                        if (hit_line) begin
                            meta_in.wdata[1].age = 1'b0;
                            meta_in.wdata[0].age = 1'b1;
                        end
                        else begin
                            meta_in.wdata[0].age = 1'b0;
                            meta_in.wdata[1].age = 1'b1;
                        end  

                        if (|dreq.strobe) begin
                            if (hit_line) begin
                                meta_in.wdata[1].dirty = 1'b1;
                            end
                            else begin
                                meta_in.wdata[0].dirty = 1'b1;
                            end  
                        end
                    end

                end
            end

            FETCH: begin
                data_in.en = cresp.ready;
                data_in_addr = {addr_index, choose_line_reg, offset_reg};
                data_in.strobe = 8'b11111111;
                data_in.wdata = cresp.data;

                meta_in.en = 1'b1;
                meta_in.strobe = 1'b1;
                if (choose_line_reg) begin
                    meta_in.wdata[1].valid = 1'b1;
                    meta_in.wdata[1].dirty = 1'b0;
                    meta_in.wdata[1].tag = addr_tag;
                end
                else begin
                    meta_in.wdata[0].valid = 1'b1;
                    meta_in.wdata[0].dirty = 1'b0;
                    meta_in.wdata[0].tag = addr_tag;
                end
                
            end

            WRITEBACK: begin
                data_in_addr = {addr_index, choose_line_reg, offset_reg};
            end
            
            UNCACHED: begin
              
            end

            default: begin
            
            end
            
        endcase 
    end
    
    always_ff @(posedge clk) begin
        counter <= counter + 1;
    end

    always_ff @(posedge clk) begin
        if (~reset) begin
            unique case (state)
                INIT: begin
                    state <= IDLE;
                end

                IDLE: begin
                    if (dreq.valid) begin
                        if (addr_uncache) begin
                            state <= UNCACHED;
                        end
                        else if (~hit) begin
                            if (~full) begin
                                state <= FETCH;
                            end
                            else begin
                                if (dirty) begin
                                    state <= WRITEBACK;
                                end 
                                else begin
                                    state <= FETCH;
                                end
                            end
                        end
                        choose_line_reg <= choose_line;
                        tag_reg <= replace_tag;
                        offset_reg <= '0;
                    
                    end
                end

                FETCH: begin
                    if (cresp.ready) begin
                        state  <= cresp.last ? IDLE : FETCH;
                        offset_reg <= offset_reg + 1;
                    end
                end

                WRITEBACK: begin
                    if (cresp.ready) begin
                        state  <= cresp.last ? FETCH : WRITEBACK;
                        offset_reg <= offset_reg + 1;
                    end
                end

                UNCACHED: begin
                    if (cresp.ready) begin
                        state  <= IDLE;
                    end
                end
                default: begin
                    
                end
            endcase    
        end 
        else begin
            state <= INIT;
        end
    end
    

//----------------------------------------------------------------

`else

	typedef enum u2 {
		IDLE,
		FETCH,
		READY,
		FLUSH
	} state_t /* verilator public */;

	// typedefs
    typedef union packed {
        word_t data;
        u8 [7:0] lanes;
    } view_t;

    typedef u4 offset_t;

    // registers
    state_t    state /* verilator public_flat_rd */;
    dbus_req_t req;  // dreq is saved once addr_ok is asserted.
    offset_t   offset;

    // wires
    offset_t start;
    assign start = dreq.addr[6:3];

    // the RAM
    struct packed {
        logic    en;
        strobe_t strobe;
        word_t   wdata;
    } ram;
    word_t ram_rdata;

    always_comb
    unique case (state)
    FETCH: begin
        ram.en     = 1;
        ram.strobe = 8'b11111111;
        ram.wdata  = cresp.data;
    end

    READY: begin
        ram.en     = 1;
        ram.strobe = req.strobe;
        ram.wdata  = req.data;
    end

    default: ram = '0;
    endcase

    RAM_SinglePort #(
		.ADDR_WIDTH(4),
		.DATA_WIDTH(64),
		.BYTE_WIDTH(8),
		.READ_LATENCY(0)
	) ram_inst (
        .clk(clk), .en(ram.en),
        .addr(offset),
        .strobe(ram.strobe),
        .wdata(ram.wdata),
        .rdata(ram_rdata)
    );

    // DBus driver
    assign dresp.addr_ok = state == IDLE;
    assign dresp.data_ok = state == READY;
    assign dresp.data    = ram_rdata;

    // CBus driver
    assign creq.valid    = state == FETCH || state == FLUSH;
    assign creq.is_write = state == FLUSH;
    assign creq.size     = MSIZE8;
    assign creq.addr     = req.addr;
    assign creq.strobe   = 8'b11111111;
    assign creq.data     = ram_rdata;
    assign creq.len      = MLEN16;
	assign creq.burst	 = AXI_BURST_INCR;

    // the FSM
    always_ff @(posedge clk)
    if (~reset) begin
        unique case (state)
        IDLE: if (dreq.valid) begin
            state  <= FETCH;
            req    <= dreq;
            offset <= start;
        end

        FETCH: if (cresp.ready) begin
            state  <= cresp.last ? READY : FETCH;
            offset <= offset + 1;
        end

        READY: begin
            state  <= (|req.strobe) ? FLUSH : IDLE;
        end

        FLUSH: if (cresp.ready) begin
            state  <= cresp.last ? IDLE : FLUSH;
            offset <= offset + 1;
        end

        endcase
    end else begin
        state <= IDLE;
        {req, offset} <= '0;
    end

`endif

endmodule

`endif
