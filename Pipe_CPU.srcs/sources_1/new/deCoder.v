`timescale 1ns / 1ps
`include "iNode.vh"
module deCoder(
    input [31:0] Ins,PC_Current,
    output [4:0] Rs,Rt,Rd,
    output [31:0] Imme,Branch_Addr,
    output [5:0] Con_Aluop,
    output Con_MemRd,Con_MemWr,Con_RegWr,Con_MemtoReg,Con_Branch,Con_ImmeEn,Con_Jump
    );
    reg Con_MemRd_reg,Con_MemWr_reg,Con_RegWr_reg,Con_MemtoReg_reg,Con_Branch_reg,Con_ImmeEn_reg,Con_Jump_reg;
    reg [5:0] Con_Aluop_reg;
    assign Rs = Ins[25:21];
    assign Rt = Ins[20:16];
    assign Rd = Ins[15:11];
    assign Imme = {Ins[15],16'h0000,Ins[14:0]};
    assign Branch_Addr = PC_Current + {Ins[15],16'h0000,Ins[14:0]};
    assign Con_MemRd = Con_MemRd_reg;
    assign Con_MemWr = Con_MemWr_reg;
    assign Con_RegWr = Con_RegWr_reg;
    assign Con_MemtoReg = Con_MemtoReg_reg;
    assign Con_Branch = Con_Branch_reg;
    assign Con_ImmeEn =Con_ImmeEn_reg;
    assign Con_Jump = Con_Jump_reg;
    assign Con_Aluop = Con_Aluop_reg;
    always@(Ins)
    casez(Ins[31:26])
                `SW : begin
                        Con_Aluop_reg = `OPER_PLUS;
                        Con_MemRd_reg =  0;
                        Con_MemWr_reg = 1;
                        Con_RegWr_reg = 0;
                        Con_MemtoReg_reg = 0;
                        Con_Branch_reg = 0;
                        Con_ImmeEn_reg = 1;
                        Con_Jump_reg = 0;
                      end
                `LW : begin
                        Con_Aluop_reg = `OPER_PLUS;
                        Con_MemRd_reg =  1;
                        Con_MemWr_reg = 0;
                        Con_RegWr_reg = 1;
                        Con_MemtoReg_reg = 1;
                        Con_Branch_reg = 0;
                        Con_ImmeEn_reg = 1;
                        Con_Jump_reg = 0;
                      end
                `JMP :
                      begin
                        Con_Aluop_reg = `OPER_PLUS;
                        Con_MemRd_reg =  0;
                        Con_MemWr_reg = 0;
                        Con_RegWr_reg = 0;
                        Con_MemtoReg_reg = 0;
                        Con_Branch_reg = 0;
                        Con_ImmeEn_reg = 0;
                        Con_Jump_reg = 1;
                      end
        6'h1z : begin
                Con_MemRd_reg =  0;
                Con_MemWr_reg = 0;
                Con_RegWr_reg = 1;
                Con_MemtoReg_reg = 0;
                Con_Branch_reg = 0;
                Con_Aluop_reg = Ins[5:0];
                Con_ImmeEn_reg = 0;
                Con_Jump_reg = 0;
            end
        6'h2z : 
            begin
                Con_MemRd_reg =  0;
                Con_MemWr_reg = 0;
                Con_RegWr_reg = 1;
                Con_MemtoReg_reg = 0;
                Con_Branch_reg = 0;
                Con_ImmeEn_reg = 1;
                Con_Jump_reg = 0;
            case(Ins[31:26])
                `PLUSI : Con_Aluop_reg = `OPER_PLUS;
                `MINUSI : Con_Aluop_reg = `OPER_MINUS;
                `MULI : Con_Aluop_reg = `OPER_MUL;
                `DIVI : Con_Aluop_reg = `OPER_DIV;
                `ANDI : Con_Aluop_reg = `OPER_AND;
                `ORI : Con_Aluop_reg = `OPER_OR;
                `XORI : Con_Aluop_reg = `OPER_XOR;
                `SLLI : Con_Aluop_reg = `OPER_SLL;
                `SLRI : Con_Aluop_reg = `OPER_SLR;
                `SRLI : Con_Aluop_reg = `OPER_SRL;
                `SRRI : Con_Aluop_reg = `OPER_SRR;
                `PLUSUI : Con_Aluop_reg = `OPER_PLUSU;
                `MINUSUI : Con_Aluop_reg = `OPER_MINUSU;
                `MULUI : Con_Aluop_reg = `OPER_MULU;
                `DIVUI : Con_Aluop_reg = `OPER_DIVU;
            endcase
            end
        6'h3z : 
        begin
            Con_MemRd_reg =  0;
            Con_MemWr_reg = 0;
            Con_RegWr_reg = 0;
            Con_MemtoReg_reg = 0;
            Con_Branch_reg = 1;;
            Con_ImmeEn_reg = 0;    
            Con_Jump_reg = 0;
            case (Ins[31:26])
            `BGT : Con_Aluop_reg = `OPER_AGTB;
            `BGE : Con_Aluop_reg = `OPER_AGEB;
            `BLE : Con_Aluop_reg = `OPER_ALEB;
            `BLT : Con_Aluop_reg = `OPER_ALTB;
            `BEQ : Con_Aluop_reg = `OPER_AEQB;
            `BNE : Con_Aluop_reg = `OPER_ANEQB;
            default : Con_Aluop_reg = `OPER_PLUS;
            endcase
        end
        default :
        begin
            Con_MemRd_reg =  0;
            Con_MemWr_reg = 0;
            Con_RegWr_reg = 0;
            Con_MemtoReg_reg = 0;
            Con_Branch_reg = 0;
            Con_Aluop_reg = `OPER_PLUS;
            Con_ImmeEn_reg = 0;    
            Con_Jump_reg = 0;
        end
        endcase

endmodule
