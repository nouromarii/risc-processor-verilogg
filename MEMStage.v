module MEMStage (
    input wire clk,
    input wire [31:0] ALUOut_MEM,    // From EX stage (ALU result)
    input wire [31:0] Bus2_MEM,      // From EX stage (register value to store)
    input wire MemRead_MEM,          // Memory Read control
    input wire MemWrite_MEM,         // Memory Write control
    input wire WB_MEM,               // Write Back control (select between ALUOut and MemoryOut)

    output wire [31:0] MemoryOut_MEM, // Output from Data Memory
    output wire [31:0] WBData_MEM     // Data to be written back to Register File
);

    // Data Memory
    DataMemory data_memory (
        .clk(clk),
        .MemR(MemRead_MEM),
        .MemW(MemWrite_MEM),
        .Address(ALUOut_MEM),
        .DataIn(Bus2_MEM),
        .MemoryOut(MemoryOut_MEM)
    );

    // Write Back Data MUX: selects between MemoryOut and ALUOut
    mux_2 #(.LENGTH(32)) mux_WBData (
        .in1(MemoryOut_MEM),  // From DataMemory
        .in2(ALUOut_MEM),     // From EX stage
        .sel(WB_MEM),         // Control signal for write-back source
        .out(WBData_MEM)
    );

endmodule
