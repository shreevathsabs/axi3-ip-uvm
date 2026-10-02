`ifndef AXI3_BASE_SEQ_SV
`define AXI3_BASE_SEQ_SV

class axi3_write_read_seq extends uvm_sequence #(axi3_seq_item);
    `uvm_object_utils(axi3_write_read_seq)

    function new(string name = "axi3_write_read_seq");
        super.new(name);
    endfunction

    task body();
        axi3_seq_item wr_tr;
        axi3_seq_item rd_tr;

        for (int i = 0; i < 10; i++) begin
            bit [31:0] target_addr = 32'h0000_1000 + (i * 32'h40);
            bit [3:0]  burst_len   = $urandom_range(0, 3);

            `uvm_do_with(wr_tr, {
                trans_type == AXI_WRITE;
                addr       == target_addr;
                len        == burst_len;
                id         == i[3:0];
            })

            `uvm_do_with(rd_tr, {
                trans_type == AXI_READ;
                addr       == target_addr;
                len        == burst_len;
                id         == i[3:0];
            })
        end
    endtask
endclass

`endif
