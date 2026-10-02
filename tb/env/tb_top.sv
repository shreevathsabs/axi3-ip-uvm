`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import axi3_env_pkg::*;

    logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #25 rst_n = 1;
    end

    axi3_if intf(.ACLK(clk), .ARESETn(rst_n));

    axi3_slave_mem #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .ID_WIDTH(4),
        .MEM_DEPTH(1024)
    ) dut (
        .ACLK(intf.ACLK),
        .ARESETn(intf.ARESETn),
        .AWID(intf.AWID),
        .AWADDR(intf.AWADDR),
        .AWLEN(intf.AWLEN),
        .AWSIZE(intf.AWSIZE),
        .AWBURST(intf.AWBURST),
        .AWVALID(intf.AWVALID),
        .AWREADY(intf.AWREADY),
        .WID(intf.WID),
        .WDATA(intf.WDATA),
        .WSTRB(intf.WSTRB),
        .WLAST(intf.WLAST),
        .WVALID(intf.WVALID),
        .WREADY(intf.WREADY),
        .BID(intf.BID),
        .BRESP(intf.BRESP),
        .BVALID(intf.BVALID),
        .BREADY(intf.BREADY),
        .ARID(intf.ARID),
        .ARADDR(intf.ARADDR),
        .ARLEN(intf.ARLEN),
        .ARSIZE(intf.ARSIZE),
        .ARBURST(intf.ARBURST),
        .ARVALID(intf.ARVALID),
        .ARREADY(intf.ARREADY),
        .RID(intf.RID),
        .RDATA(intf.RDATA),
        .RRESP(intf.RRESP),
        .RLAST(intf.RLAST),
        .RVALID(intf.RVALID),
        .RREADY(intf.RREADY)
    );

    initial begin
        uvm_config_db#(virtual axi3_if)::set(null, "*", "vif", intf);
        run_test("axi3_base_test");
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
    end
endmodule
