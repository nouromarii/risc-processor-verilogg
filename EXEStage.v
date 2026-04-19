module EXEStage (
    input wire clk,
    input wire [31:0] Imm_EXE,
    input wire [31:0] Bus1_EXE,  // From forwarding or ID/EX register
    input wire [31:0] Bus2_EXE,
    input wire ALUSrc1_signal,  // Selects between Bus1 and constant (if used)
    input wire ALUSrc2_signal,  // Selects between Bus2 and Imm
    input wire [2:0] ALUOp,     // Operation control
    output wire [31:0] ALUOut_EXE // ALU output
); 

    wire [31:0] ALUSrc1, ALUSrc2;

    // ALU operand MUXes
    assign ALUSrc1 = ALUSrc1_signal ? 32'd1 : Bus1_EXE;  // if ALUSrc1_signal==1 use constant 1
    assign ALUSrc2 = ALUSrc2_signal ? Imm_EXE : Bus2_EXE;

    // ALU instance
    ALU alu (
        .ALUSrc1(ALUSrc1),
        .ALUSrc2(ALUSrc2),
        .ALUOut(ALUOut_EXE),
        .ALUOp(ALUOp)
    );	  

endmodule
