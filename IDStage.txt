module IDStage (
    input wire clk,
    input wire [14:0] controlsignals,
    input wire [1:0] ForwardA, ForwardB,
    input wire [31:0] instruction, PC, NextPC,
    input wire [3:0] DestinationRegister_WB,
    input wire [31:0] ALUOut, MemoryOut, WBData,
    input wire RRWE, JumpSrc, RegWr_WB, kill, stall,

    output reg [2:0] ALUOp,
    output reg RegWr, MemR, MemW, WB, ALUSrc1, Destination, Source1, Source2, ALUSrc2, ExOp, CompSrc, J,
    output reg [3:0] Rs1, Rs2, Rd,
    output reg [31:0] Bus1, Bus2,
    output reg [31:0] imm,
    output reg comp_res,
    output reg [31:0] Branch_TA, Jump_TA, For_TA,
    output reg [2:0] func,
    output reg [5:0] opcode,
    output reg [31:0] num_lw, num_sw, num_alu, num_control, num_executed_instructions
);

    wire [13:0] offset;
    wire [31:0] Data1, Data2;
    wire [31:0] extended_imm;
    wire [31:0] comp_input;
    reg [31:0] RR;

    // Initialize counters
    initial begin
        num_lw = 0; num_sw = 0;
        num_alu = 0; num_control = 0;
        num_executed_instructions = 0;
    end

    assign opcode = instruction[31:26];
    assign func = instruction[2:0];

    assign Rs1 = (Source1 == 0) ? instruction[21:18] : 
                 (Source1 == 1) ? instruction[25:22] : 4'b0;

    assign Rs2 = (Source2 == 0) ? instruction[17:14] : 
                 (Source2 == 1) ? instruction[21:18] : 4'b0;

    assign Rd = (Destination == 0) ? instruction[25:22] : 
                (Destination == 1) ? instruction[21:18] : 4'b0;

    assign offset = instruction[13:0];

    // Update control signal outputs
    always @(*) begin
        ALUOp = controlsignals[14:12];
        RegWr = controlsignals[11];
        MemR = controlsignals[10];
        MemW = controlsignals[9];
        WB = controlsignals[8];
        ALUSrc1 = controlsignals[7];
        Destination = controlsignals[6];
        Source1 = controlsignals[5];
        Source2 = controlsignals[4];
        ALUSrc2 = controlsignals[3];
        ExOp = controlsignals[2];
        CompSrc = controlsignals[1];
        J = controlsignals[0];
    end

    // RR = return address storage
    always @(posedge clk) begin
        if (RRWE) RR <= NextPC;
    end

    // Register file access
    RegisterFile reg_file (
        .clk(clk),
        .Rs1(Rs1),
        .Rs2(Rs2),
        .Rd(DestinationRegister_WB),
        .RegWr(RegWr_WB), 
        .WBbus(WBData),
        .Bus1(Data1),
        .Bus2(Data2)
    );

    // Forwarding logic
    mux_4 #(.LENGTH(32)) mux_ForwardA (
        .in1(Data1),
        .in2(ALUOut),
        .in3(MemoryOut),
        .in4(WBData),
        .sel(ForwardA),
        .out(Bus1)
    );

    mux_4 #(.LENGTH(32)) mux_ForwardB (
        .in1(Data2),
        .in2(ALUOut),
        .in3(MemoryOut),
        .in4(WBData),
        .sel(ForwardB),
        .out(Bus2)
    );

    mux_2 #(.LENGTH(32)) mux_comp_input (
        .in1(Bus1),
        .in2(32'b0),
        .sel(CompSrc),
        .out(comp_input)
    );

    Compare comp (
        .A(Bus2),
        .B(comp_input),
        .comp_res(comp_res)
    );

    // Immediate extension
    Extender extend (
        .in(offset),
        .ExtOp(ExOp),
        .out(extended_imm)
    );

    assign imm = extended_imm;
    assign Branch_TA = PC + extended_imm;
    assign Jump_TA = (JumpSrc == 0) ? {PC[31:14], offset} : RR;
    assign For_TA = Bus1;

    // Instruction count tracking
    always @(posedge clk) begin
        if (!kill && instruction !== 32'bx && instruction != 32'b0 && !stall) begin
            num_executed_instructions <= num_executed_instructions + 1;

            case (opcode)
                6'b000000, 6'b000010, 6'b000011: num_alu <= num_alu + 1; // ADD, SUB, OR, etc.
                6'b000100: num_lw <= num_lw + 1;
                6'b000101: num_sw <= num_sw + 1;
                6'b000001, 6'b000110, 6'b000111: num_control <= num_control + 1;
                default: ; // Do nothing
            endcase
        end
    end

endmodule
