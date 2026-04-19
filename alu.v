																// =========================
// Enhanced ALU Module
// =========================
module ALU(
    input wire [31:0] ALUSrc1,  // First operand
    input wire [31:0] ALUSrc2,  // Second operand
    input wire [3:0] ALUOp,     // Operation code
    output reg [31:0] ALUOut,   // Result
    output reg BranchTaken      // For branch instructions
);

    // Operation codes (aligned with ISA)
    parameter ALU_OP_OR   = 4'b0000;  // Bitwise OR
    parameter ALU_OP_ADD  = 4'b0001;  // Addition
    parameter ALU_OP_SUB  = 4'b0010;  // Subtraction
    parameter ALU_OP_CMP  = 4'b0011;  // Signed comparison (-1/0/+1)
    parameter ALU_OP_ORI  = 4'b0100;  // OR with immediate (zero-extended)
    parameter ALU_OP_ADDI = 4'b0101;  // Add with immediate (sign-extended)
    parameter ALU_OP_BZ   = 4'b1010;  // Branch if zero
    parameter ALU_OP_BGZ  = 4'b1011;  // Branch if greater than zero
    parameter ALU_OP_BLZ  = 4'b1100;  // Branch if less than zero

    always @(*) begin
        BranchTaken = 0;  // Default
        case (ALUOp)
            ALU_OP_OR:   ALUOut = ALUSrc1 | ALUSrc2;
            ALU_OP_ADD:  ALUOut = ALUSrc1 + ALUSrc2;
            ALU_OP_SUB:  ALUOut = ALUSrc1 - ALUSrc2;

            // Signed comparison (outputs -1, 0, or 1)
            ALU_OP_CMP: begin
                if ($signed(ALUSrc1) < $signed(ALUSrc2)) ALUOut = 32'hFFFFFFFF; // -1
                else if ($signed(ALUSrc1) == $signed(ALUSrc2)) ALUOut = 32'd0;
                else ALUOut = 32'd1;
            end

            // ORI (bitwise OR with zero-extended immediate)
            ALU_OP_ORI: ALUOut = ALUSrc1 | ALUSrc2;

            // ADDI (addition with sign-extended immediate)
            ALU_OP_ADDI: ALUOut = ALUSrc1 + ALUSrc2;

            // Branch conditions (also sets BranchTaken)
            ALU_OP_BZ: begin
                ALUOut = (ALUSrc1 == 0);
                BranchTaken = (ALUSrc1 == 0);
            end
            ALU_OP_BGZ: begin
                ALUOut = ($signed(ALUSrc1) > 0);
                BranchTaken = ($signed(ALUSrc1) > 0);
            end
            ALU_OP_BLZ: begin
                ALUOut = ($signed(ALUSrc1) < 0);
                BranchTaken = ($signed(ALUSrc1) < 0);
            end

            default: ALUOut = 32'd0;
        endcase
    end
endmodule
// =========================
// Comprehensive Testbench with SUB added
// =========================
module ALU_TB;
    reg [31:0] ALUSrc1, ALUSrc2;
    reg [3:0] ALUOp;
    wire [31:0] ALUOut;
    wire BranchTaken;

    ALU uut (
        .ALUSrc1(ALUSrc1),
        .ALUSrc2(ALUSrc2),
        .ALUOp(ALUOp),
        .ALUOut(ALUOut),
        .BranchTaken(BranchTaken)
    );

    initial begin
        $display("Time\tOperation\t\tALUSrc1\t\tALUSrc2\t\tResult\tBranch");
        
        // Test OR
        ALUOp = 4'b0000; ALUSrc1 = 32'h0F0F0F0F; ALUSrc2 = 32'hF0F0F0F0;
        #10 $display("%0t\tOR\t\t\t%h\t%h\t%h\t%b", $time, ALUSrc1, ALUSrc2, ALUOut, BranchTaken);
        
        // Test ADD
        ALUOp = 4'b0001; ALUSrc1 = 32'd100; ALUSrc2 = 32'd50;
        #10 $display("%0t\tADD\t\t\t%d\t%d\t%d\t%b", $time, ALUSrc1, ALUSrc2, ALUOut, BranchTaken);

        // Test SUB (new)
        ALUOp = 4'b0010; ALUSrc1 = 32'd150; ALUSrc2 = 32'd75;
        #10 $display("%0t\tSUB\t\t\t%d\t%d\t%d\t%b", $time, ALUSrc1, ALUSrc2, ALUOut, BranchTaken);
        
        // Test CMP (Rs == Rt)
        ALUOp = 4'b0011; ALUSrc1 = 32'd10; ALUSrc2 = 32'd10;
        #10 $display("%0t\tCMP (Rs==Rt)\t%d\t%d\t%d\t%b", $time, ALUSrc1, ALUSrc2, $signed(ALUOut), BranchTaken);

        // Test ORI (OR with immediate - zero extended)
        ALUOp = 4'b0100; ALUSrc1 = 32'h00FF00FF; ALUSrc2 = 32'h000000F0; // Immediate in ALUSrc2
        #10 $display("%0t\tORI\t\t\t%h\t%h\t%h\t%b", $time, ALUSrc1, ALUSrc2, ALUOut, BranchTaken);

        // Test ADDI (Add with immediate - sign extended)
        ALUOp = 4'b0101; ALUSrc1 = 32'd1000; ALUSrc2 = 32'hFFFFFFF6; // -10 as sign extended immediate
        #10 $display("%0t\tADDI\t\t%d\t%d\t%d\t%b", $time, ALUSrc1, $signed(ALUSrc2), $signed(ALUOut), BranchTaken);

        // Test BZ (taken)
        ALUOp = 4'b1010; ALUSrc1 = 32'd0; ALUSrc2 = 32'd0;
        #10 $display("%0t\tBZ (taken)\t%d\t%d\t%d\t%b", $time, ALUSrc1, ALUSrc2, ALUOut, BranchTaken);
        
        // Test BGZ (not taken)
        ALUOp = 4'b1011; ALUSrc1 = 32'hFFFFFFFF; ALUSrc2 = 32'd0; // -1
        #10 $display("%0t\tBGZ (not taken)\t%d\t%d\t%d\t%b", $time, $signed(ALUSrc1), ALUSrc2, ALUOut, BranchTaken);

        // Test BLZ (taken)
        ALUOp = 4'b1100; ALUSrc1 = 32'hFFFFFFFE; ALUSrc2 = 32'd0; // -2
        #10 $display("%0t\tBLZ (taken)\t%d\t%d\t%d\t%b", $time, $signed(ALUSrc1), ALUSrc2, ALUOut, BranchTaken);

        // Test BLZ (not taken)
        ALUOp = 4'b1100; ALUSrc1 = 32'd10; ALUSrc2 = 32'd0; // positive 10
        #10 $display("%0t\tBLZ (not taken)\t%d\t%d\t%d\t%b", $time, ALUSrc1, ALUSrc2, ALUOut, BranchTaken);
        
        $finish;
    end
endmodule
