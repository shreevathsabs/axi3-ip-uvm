`ifndef AXI3_SCOREBOARD_SV
`define AXI3_SCOREBOARD_SV

class axi3_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi3_scoreboard)

    uvm_analysis_imp #(axi3_seq_item, axi3_scoreboard) item_export;
    bit [31:0] ref_mem [bit [31:0]];

    int match_count = 0;
    int mismatch_count = 0;

    function new(string name = "axi3_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        item_export = new("item_export", this);
    endfunction

    function void write(axi3_seq_item tr);
        bit [31:0] curr_addr;
        curr_addr = tr.addr;

        if (tr.trans_type == AXI_WRITE) begin
            for (int i = 0; i <= tr.len; i++) begin
                ref_mem[curr_addr] = tr.data[i];
                `uvm_info("SCB_WR", $sformatf("Addr: 0x%08h | Written: 0x%08h", curr_addr, tr.data[i]), UVM_HIGH)
                curr_addr += 4;
            end
        end else begin
            for (int i = 0; i <= tr.len; i++) begin
                if (ref_mem.exists(curr_addr)) begin
                    if (ref_mem[curr_addr] === tr.rdata[i]) begin
                        match_count++;
                        `uvm_info("SCB_PASS", $sformatf("MATCH at 0x%08h: Read 0x%08h", curr_addr, tr.rdata[i]), UVM_LOW)
                    end else begin
                        mismatch_count++;
                        `uvm_error("SCB_FAIL", $sformatf("MISMATCH at 0x%08h: Exp 0x%08h, Got 0x%08h",
                                  curr_addr, ref_mem[curr_addr], tr.rdata[i]))
                    end
                end else begin
                    `uvm_warning("SCB_UNINIT", $sformatf("Read from uninitialized addr 0x%08h: 0x%08h", curr_addr, tr.rdata[i]))
                end
                curr_addr += 4;
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB_REPORT", $sformatf("Simulation Completed -> Matches: %0d, Mismatches: %0d", match_count, mismatch_count), UVM_NONE)
    endfunction
endclass

`endif
