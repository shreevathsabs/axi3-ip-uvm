`ifndef AXI3_ENV_PKG_SV
`define AXI3_ENV_PKG_SV

package axi3_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import axi3_agent_pkg::*;

    `include "axi3_scoreboard.sv"
    `include "axi3_env.sv"
    `include "axi3_base_seq.sv"
    `include "axi3_base_test.sv"
endpackage

`endif
