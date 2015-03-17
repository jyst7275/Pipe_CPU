`timescale 1ns / 1ps
`include "iNode.vh"
module Pipe_Cpu(
    input clk
    );

    reg [4:0] de_rs = 0,de_rt = 0,de_rd = 0,ex_reg_wb = 0,me_reg_wb = 0,wb_reg_wb = 0;
    reg [31:0] de_imme = 0,de_branch_addr = 0,ex_vala = 0,ex_valb = 0,ex_branch_addr = 0,me_vale = 0,me_rt_val = 0,wb_val_alu = 0,wb_val_mem = 0;
    
    reg de_MemRd = 0,de_MemWr = 0,de_RegWr = 0,de_MemtoReg = 0,de_Branch = 0,de_ImmeEn = 0;
    reg ex_MemRd = 0,ex_MemWr = 0,ex_RegWr = 0,ex_MemtoReg = 0,ex_Branch = 0;
    reg me_MemRd = 0,me_MemWr = 0,me_RegWr = 0,me_MemtoReg = 0;
    reg wb_RegWr = 0,wb_MemtoReg = 0,clear = 0,halt = 0;
    reg [5:0] de_aluop = 0,ex_aluop = 0;
    
    reg [31:0] PC = 0;
    reg [20:0] Call_List;
    wire [4:0] rs_wire,rt_wire,rd_wire;
    wire [5:0] Con_aluop_wire;
    wire [31:0] ins_wire,imme_wire,branch_addr_wire,rf_out_a_wire,rf_out_b_wire,alu_out_wire,mem_data_wire,wb_data_wire,Fw_a_wire,Fw_b_wire;
    wire alu_branch_wire,Con_MemRd_wire,Con_MemWr_wire,Con_RegWr_wire,Con_MemtoReg_wire,Con_Branch_wire,Con_ImmeEn_wire;
    
            
    Mem ins_mem(.mem_addr_in(PC),.mem_data_in(0),.clk(clk),.mem_wr(0),.mem_rd(1),.mem_data_out(ins_wire));
    Mem data_mem(.mem_addr_in(me_vale),.mem_data_in(me_rt_val),.clk(clk),.mem_wr(me_MemWr),.mem_rd(me_MemRd),.mem_data_out(mem_data_wire));
    RF RegsterFi(.clk(clk),.Con_RegWr(wb_RegWr),.data_in(wb_data_wire),.data_wr_addr(wb_reg_wb),.rf_src_a(de_rs),.rf_src_b(de_rd),.data_out_a(rf_out_a_wire),.data_out_b(rf_out_b_wire));
    Alu Alunit(.alu_src_a(ex_vala),.alu_src_b(ex_valb),.aluop(ex_aluop),.branch(alu_branch_wire),.alu_out(alu_out_wire));
    deCoder dC(.Ins(ins_wire),.PC_Current(PC),.Rs(rs_wire),.Rt(rt_wire),.Rd(rd_wire),.Imme(imme_wire),.Branch_Addr(branch_addr_wire),
                .Con_Aluop(Con_aluop_wire),.Con_MemRd(Con_MemRd_wire),.Con_MemWr(Con_MemWr_wire),.Con_RegWr(Con_RegWr_wire),
                .Con_MemtoReg(Con_MemtoReg_wire),.Con_Branch(Con_Branch_wire),.Con_ImmeEn(Con_ImmeEn_wire),.Con_Jump(Con_Jump_wire));
    
    assign wb_data_wire = wb_MemtoReg ? wb_val_mem : wb_val_alu;
    assign Fw_a_wire = (de_rs == ex_reg_wb && ex_RegWr) ? alu_out_wire : (
                        (de_rs == me_reg_wb && me_RegWr) ? (me_MemtoReg ? mem_data_wire : me_vale) : rf_out_a_wire);
    assign Fw_b_wire = (de_rt == ex_reg_wb && ex_RegWr && !de_ImmeEn) ? alu_out_wire : (
                        (de_rt == me_reg_wb && me_RegWr && !de_ImmeEn) ? (me_MemtoReg ? mem_data_wire : me_vale) : (
                        de_ImmeEn ? de_imme : rf_out_b_wire));
    
    always@(negedge clk) begin
        clear = alu_branch_wire;
        halt = (ex_MemRd && ((de_rs === ex_reg_wb) || (de_rt === ex_reg_wb && !de_ImmeEn))) ? 1 : 0;
    end
    
    always@(posedge clk)
    begin
            de_rs <= halt ? de_rs : rs_wire;
            de_rt <= halt ? de_rt : rt_wire;
            de_rd <= halt ? de_rd : rd_wire;
            de_imme <= halt ? de_imme : imme_wire;
            de_branch_addr <= halt ? de_branch_addr : branch_addr_wire;
            de_aluop <= halt ? de_aluop : Con_aluop_wire;
            de_MemRd <= clear ? 0 : (halt ? de_MemRd : Con_MemRd_wire);
            de_MemWr <= clear ? 0 : (halt ? de_MemWr : Con_MemWr_wire);
            de_RegWr <= clear ? 0 : (halt ? de_RegWr : Con_RegWr_wire);
            de_MemtoReg <= clear ? 0 : (halt ? de_MemtoReg : Con_MemtoReg_wire);
            de_Branch <= clear ? 0 : (halt ? de_Branch : Con_Branch_wire);
            de_ImmeEn <= clear ? 0 : (halt ? de_ImmeEn : Con_ImmeEn_wire);
            

            ex_reg_wb <= de_ImmeEn ? de_rt : de_rd;
            ex_branch_addr <= de_branch_addr;
            ex_vala <= Fw_a_wire;
            ex_valb <= Fw_b_wire;
            ex_aluop <= de_aluop;
            ex_MemtoReg <= (clear || halt) ? 0 : de_MemtoReg;   
            ex_RegWr <= (clear || halt) ? 0 : de_RegWr;
            ex_MemRd <= (clear || halt) ? 0 : de_MemRd;            
            ex_MemWr <= (clear || halt) ? 0 : de_MemWr;
            ex_Branch <= (clear || halt) ? 0 : de_Branch;
                                                            
            me_reg_wb <= ex_reg_wb;    
            me_MemtoReg <= clear ? 0 : ex_MemtoReg;    
            me_RegWr <= clear ? 0 : ex_RegWr;
            me_rt_val <= ex_valb;
            me_vale <= alu_out_wire;
            me_MemRd <= clear ? 0 : ex_MemRd;
            me_MemWr <= clear ? 0 : ex_MemWr;
            
            wb_val_alu <= me_vale;
            wb_val_mem <= mem_data_wire;
            wb_reg_wb <= me_reg_wb;
            wb_RegWr <= me_RegWr;
            wb_MemtoReg <= me_MemtoReg;

            PC = alu_branch_wire ? ex_branch_addr : (Con_Jump_wire ? {6'h0,ins_wire[25:0]} : (halt ? PC : PC + 1));
      end
      
endmodule
