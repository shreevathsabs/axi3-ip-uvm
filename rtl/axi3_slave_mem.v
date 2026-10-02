`timescale 1ns/1ps

module axi3_slave_mem #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter MEM_DEPTH  = 1024
)(
    input  wire                   ACLK,
    input  wire                   ARESETn,

    // Write Address Channel (AW)
    input  wire [ID_WIDTH-1:0]    AWID,
    input  wire [ADDR_WIDTH-1:0]  AWADDR,
    input  wire [3:0]             AWLEN,
    input  wire [2:0]             AWSIZE,
    input  wire [1:0]             AWBURST,
    input  wire                   AWVALID,
    output reg                    AWREADY,

    // Write Data Channel (W)
    input  wire [ID_WIDTH-1:0]    WID,
    input  wire [DATA_WIDTH-1:0]  WDATA,
    input  wire [(DATA_WIDTH/8)-1:0] WSTRB,
    input  wire                   WLAST,
    input  wire                   WVALID,
    output reg                    WREADY,

    // Write Response Channel (B)
    output reg  [ID_WIDTH-1:0]    BID,
    output reg  [1:0]             BRESP,
    output reg                    BVALID,
    input  wire                   BREADY,

    // Read Address Channel (AR)
    input  wire [ID_WIDTH-1:0]    ARID,
    input  wire [ADDR_WIDTH-1:0]  ARADDR,
    input  wire [3:0]             ARLEN,
    input  wire [2:0]             ARSIZE,
    input  wire [1:0]             ARBURST,
    input  wire                   ARVALID,
    output reg                    ARREADY,

    // Read Data Channel (R)
    output reg  [ID_WIDTH-1:0]    RID,
    output reg  [DATA_WIDTH-1:0]  RDATA,
    output reg  [1:0]             RRESP,
    output reg                    RLAST,
    output reg                    RVALID,
    input  wire                   RREADY
);

    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    // Write State Machine
    localparam WR_IDLE = 2'd0, WR_DATA = 2'd1, WR_RESP = 2'd2;
    reg [1:0] wr_state;
    reg [ADDR_WIDTH-1:0] wr_addr;
    reg [ID_WIDTH-1:0]   wr_id;

    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            wr_state <= WR_IDLE;
            AWREADY  <= 1'b0;
            WREADY   <= 1'b0;
            BVALID   <= 1'b0;
            BID      <= {ID_WIDTH{1'b0}};
            BRESP    <= 2'b00;
            wr_addr  <= {ADDR_WIDTH{1'b0}};
            wr_id    <= {ID_WIDTH{1'b0}};
        end else begin
            case (wr_state)
                WR_IDLE: begin
                    AWREADY <= 1'b1;
                    WREADY  <= 1'b0;
                    BVALID  <= 1'b0;
                    if (AWVALID && AWREADY) begin
                        wr_addr <= AWADDR;
                        wr_id   <= AWID;
                        AWREADY <= 1'b0;
                        WREADY  <= 1'b1;
                        wr_state <= WR_DATA;
                    end
                end

                WR_DATA: begin
                    if (WVALID && WREADY) begin
                        if (WSTRB[0]) mem[wr_addr[11:2]][7:0]   <= WDATA[7:0];
                        if (WSTRB[1]) mem[wr_addr[11:2]][15:8]  <= WDATA[15:8];
                        if (WSTRB[2]) mem[wr_addr[11:2]][23:16] <= WDATA[23:16];
                        if (WSTRB[3]) mem[wr_addr[11:2]][31:24] <= WDATA[31:24];
                        wr_addr <= wr_addr + 4;
                        if (WLAST) begin
                            WREADY   <= 1'b0;
                            BVALID   <= 1'b1;
                            BID      <= wr_id;
                            BRESP    <= 2'b00;
                            wr_state <= WR_RESP;
                        end
                    end
                end

                WR_RESP: begin
                    if (BVALID && BREADY) begin
                        BVALID   <= 1'b0;
                        AWREADY  <= 1'b1;
                        wr_state <= WR_IDLE;
                    end
                end
            endcase
        end
    end

    // Read State Machine
    localparam RD_IDLE = 2'd0, RD_BURST = 2'd1;
    reg [1:0] rd_state;
    reg [ADDR_WIDTH-1:0] rd_addr;
    reg [ID_WIDTH-1:0]   rd_id;
    reg [3:0]            rd_len_cnt;

    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            rd_state   <= RD_IDLE;
            ARREADY    <= 1'b0;
            RVALID     <= 1'b0;
            RLAST      <= 1'b0;
            RID        <= {ID_WIDTH{1'b0}};
            RRESP      <= 2'b00;
            RDATA      <= {DATA_WIDTH{1'b0}};
            rd_addr    <= {ADDR_WIDTH{1'b0}};
            rd_id      <= {ID_WIDTH{1'b0}};
            rd_len_cnt <= 4'd0;
        end else begin
            case (rd_state)
                RD_IDLE: begin
                    ARREADY <= 1'b1;
                    RLAST   <= 1'b0;
                    if (ARVALID && ARREADY) begin
                        rd_addr    <= ARADDR;
                        rd_id      <= ARID;
                        rd_len_cnt <= ARLEN;
                        ARREADY    <= 1'b0;
                        RVALID     <= 1'b1;
                        RID        <= ARID;
                        RRESP      <= 2'b00;
                        RDATA      <= mem[ARADDR[11:2]];
                        RLAST      <= (ARLEN == 4'd0);
                        rd_state   <= RD_BURST;
                    end
                end

                RD_BURST: begin
                    if (RVALID && RREADY) begin
                        if (rd_len_cnt == 4'd0) begin
                            RVALID   <= 1'b0;
                            RLAST    <= 1'b0;
                            ARREADY  <= 1'b1;
                            rd_state <= RD_IDLE;
                        end else begin
                            rd_len_cnt <= rd_len_cnt - 1'b1;
                            rd_addr    <= rd_addr + 4;
                            RDATA      <= mem[(rd_addr + 4) >> 2];
                            RLAST      <= (rd_len_cnt == 4'd1);
                        end
                    end
                end
            endcase
        end
    end

endmodule
