`timescale 1ns / 1ps
`include "iNode.vh"
module Alu(
    input [31:0] alu_src_a,alu_src_b,
    input [5:0] aluop,
    output branch,
    output [31:0] alu_out
    );
    reg s,ss,branch_reg;
    reg [31:0] alu_out_reg;
    assign alu_out = alu_out_reg;
    assign branch = branch_reg;
    always@(*)
    case(aluop[5:4])
        2'h0 :
        begin
            branch_reg = 0;    
        case(aluop)
            `OPER_PLUS : alu_out_reg = alu_src_a + alu_src_b;
            `OPER_MINUS : alu_out_reg = alu_src_a - alu_src_b;
            `OPER_MUL : alu_out_reg = alu_src_a * alu_src_b;
            `OPER_DIV : alu_out_reg = alu_src_a / alu_src_b;
            `OPER_AND : alu_out_reg = alu_src_a & alu_src_b;
            `OPER_OR : alu_out_reg = alu_src_a | alu_src_b;
            `OPER_XOR : alu_out_reg = alu_src_a ^ alu_src_b;
            `OPER_SLL : alu_out_reg = alu_src_a << alu_src_b;
            `OPER_SLR : alu_out_reg = alu_src_a >> alu_src_b;
            `OPER_SRL : alu_out_reg = alu_src_a <<< alu_src_b;
            `OPER_SRR : alu_out_reg = alu_src_a >>> alu_src_b;
            `OPER_PLUSU : {s,alu_out_reg} = {1'b0,alu_src_a} + {1'b0,alu_src_b};
            `OPER_MINUSU : {s,alu_out_reg} = {1'b0,alu_src_a} - {1'b0,alu_src_b};
            `OPER_MULU : {ss,alu_out_reg} = {1'b0,alu_src_a} * {1'b0,alu_src_b};
            `OPER_DIVU : {s,alu_out_reg} = {2'b00,alu_src_a} / {1'b0,alu_src_b};
        endcase
        end
        2'h1 : 
        begin
            alu_out_reg = alu_src_a + alu_src_b;
            case(aluop)
            `OPER_AGTB : branch_reg = (alu_src_a > alu_src_b) ? 1 : 0;
            `OPER_AGEB : branch_reg = (alu_src_a >= alu_src_b) ? 1 : 0;
            `OPER_ALEB : branch_reg = (alu_src_a <= alu_src_b) ? 1 : 0;
            `OPER_ALTB : branch_reg = (alu_src_a < alu_src_b) ? 1 : 0;
            `OPER_AEQB : branch_reg = (alu_src_a == alu_src_b) ? 1 : 0;
            `OPER_ANEQB : branch_reg = (alu_src_a != alu_src_b) ? 1 : 0;
            default : branch_reg = 0;
            endcase
        end
        default :
            begin
                alu_out_reg = alu_src_a + alu_src_b;
                branch_reg = 0;
            end
        endcase
    
endmodule
