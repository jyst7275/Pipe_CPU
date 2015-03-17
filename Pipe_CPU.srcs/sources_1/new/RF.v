`timescale 1ns / 1ps

module RF(
    input clk,Con_RegWr,
    input [31:0] data_in,
    input [4:0] data_wr_addr,
    input [4:0] rf_src_a,rf_src_b,
    output [31:0] data_out_a,data_out_b
    );
    reg [31:0]mem[31:0];
    
    integer i;
    initial
    for(i = 0;i < 32; i = i + 1)
        mem[i] = 0;

    always@(negedge clk)
    if (Con_RegWr) mem[data_wr_addr] = data_in;
    assign data_out_a = mem[rf_src_a];
    assign data_out_b = mem[rf_src_b];
    
endmodule
