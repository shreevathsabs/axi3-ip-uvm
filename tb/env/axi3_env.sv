`ifndef AXI3_ENV_SV
`define AXI3_ENV_SV

class axi3_env extends uvm_env;
    `uvm_component_utils(axi3_env)

    axi3_agent_pkg::axi3_agent agent;
    axi3_scoreboard            scb;

    function new(string name = "axi3_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = axi3_agent_pkg::axi3_agent::type_id::create("agent", this);
        scb   = axi3_scoreboard::type_id::create("scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.mon_ap.connect(scb.item_export);
    endfunction
endclass

`endif
