`timescale 1ns / 1ps
`include "iNode.vh"
module Mem(
    input [31:0] mem_addr_in,
    input [31:0] mem_data_in,
    input clk,mem_wr,mem_rd,
    output [31:0] mem_data_out
    );
    reg [31:0] mem[65535:0];
    
    integer i;
    initial
    begin
    mem[0] = {`LW,5'h0,5'h2,16'h6};
    mem[1] = {`LW,5'h0,5'h3,16'h7};
    mem[2] = {`OPER,5'h2,5'h3,5'h4,5'h0,`OPER_PLUS};
    mem[3] = {`LW,5'h0,5'h5,16'h8};
    mem[4] = {`JMP,26'h50};
    //mem[4] = {`BEQ,5'h4,5'h5,16'h35};
    mem[5] = {`LW,5'h0,5'h2,16'h20};
    mem[6] = 32'h2;
    mem[7] = 32'h2;
    mem[8] = 32'h4;
    for(i = 9; i < 65536; i = i+1)
    mem[i] = 0;
    end
    
    assign mem_data_out = mem[mem_addr_in];
    always@(negedge clk)
    if (mem_wr) mem[mem_addr_in] = mem_data_in;
endmodule
