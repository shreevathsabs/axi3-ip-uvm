`ifndef AXI3_BASE_TEST_SV
`define AXI3_BASE_TEST_SV

class axi3_base_test extends uvm_test;
    `uvm_component_utils(axi3_base_test)

    axi3_env env;

    function new(string name = "axi3_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi3_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        axi3_write_read_seq seq;
        seq = axi3_write_read_seq::type_id::create("seq");

        phase.raise_objection(this);
        seq.start(env.agent.sqr);
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

`endif
