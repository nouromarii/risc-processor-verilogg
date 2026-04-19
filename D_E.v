module ID_EXE(
    input wire clk,
    input wire reset,
    
    input wire [3:0] ID_Rd,
    input wire ID_RegWr,
    input wire [2:0] ID_ALUOp,
    input wire ID_MemR,
    input wire ID_MemW,
    input wire ID_WB,
    input wire ID_ALUSrc2,
    input wire [31:0] ID_Imm,
    input wire ID_ALUSrc1,
    input wire [31:0] ID_Bus1,
    input wire [31:0] ID_Bus2,
    input wire ID_is_ldw_sdw,
    
    output reg [3:0] EXE_Rd,
    output reg EXE_RegWr,
    output reg [2:0] EXE_ALUOp,
    output reg EXE_MemR,
    output reg EXE_MemW,
    output reg EXE_WB,
    output reg EXE_ALUSrc2,
    output reg [31:0] EXE_Imm,
    output reg EXE_ALUSrc1,
    output reg [31:0] EXE_Bus1,
    output reg [31:0] EXE_Bus2,
    output reg EXE_is_ldw_sdw
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EXE_Rd <= 4'b0;
            EXE_RegWr <= 1'b0;
            EXE_ALUOp <= 3'b0;
            EXE_MemR <= 1'b0;
            EXE_MemW <= 1'b0;
            EXE_WB <= 1'b0;
            EXE_ALUSrc2 <= 1'b0;
            EXE_Imm <= 32'b0;
            EXE_ALUSrc1 <= 1'b0;
            EXE_Bus1 <= 32'b0;
            EXE_Bus2 <= 32'b0;
            EXE_is_ldw_sdw <= 1'b0;
        end else begin
            EXE_Rd <= ID_Rd;
            EXE_RegWr <= ID_RegWr;
            EXE_ALUOp <= ID_ALUOp;
            EXE_MemR <= ID_MemR;
            EXE_MemW <= ID_MemW;
            EXE_WB <= ID_WB;
            EXE_ALUSrc2 <= ID_ALUSrc2;
            EXE_Imm <= ID_Imm;
            EXE_ALUSrc1 <= ID_ALUSrc1;
            EXE_Bus1 <= ID_Bus1;
            EXE_Bus2 <= ID_Bus2;
            EXE_is_ldw_sdw <= ID_is_ldw_sdw;
        end
    end

endmodule
