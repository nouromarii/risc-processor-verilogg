

module fetch(
    input clk,
    input reset,
    input pc_write,
    input [31:0] next_pc,
    output reg [31:0] pc_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 0;
        else if (pc_write)
            pc_out <= next_pc;
    end
endmodule


module InstructionMemory(
    input [7:0] addr,
    output [31:0] instr
);
    reg [31:0] memory [0:255];

    assign instr = memory[addr];

    initial begin
      
        memory[0] = 32'h00000000;
        memory[1] = 32'h11112222;
        
    end
endmodule


module IR(
    input clk,
    input IRWrite,
    input [31:0] instr_in,
    output reg [31:0] instr_out
);
    always @(posedge clk) begin
        if (IRWrite)
            instr_out <= instr_in;
    end
endmodule


module regfile(
    input clk,
    input we,
    input [3:0] read_reg1,
    input [3:0] read_reg2,
    input [3:0] write_reg,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] registers[0:15];

    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

    always @(posedge clk) begin
        if (we) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule

module PCControl(
    input [31:0] rs_value,
    input [31:0] target_address,
    input [31:0] pc_plus4,
    input [3:0] pc_op, //to control opcodes
    output reg [31:0] next_pc
);
    always @(*) begin
        case (pc_op)
            4'b0000: next_pc = pc_plus4;//PC+4 default case 
            4'b1010: next_pc = (rs_value == 0)  ? target_address : pc_plus4; //BZ 10 decimal==binary 1010
            4'b1011: next_pc = ($signed(rs_value) > 0) ? target_address : pc_plus4; //BGZ 11 decimal==1011 binary
            4'b1100: next_pc = ($signed(rs_value) < 0) ? target_address : pc_plus4; //BLZ 12 dec
            4'b1101: next_pc = rs_value; // JR 13 dec
            4'b1110: next_pc = target_address;// J 14 dec
            4'b1111: next_pc = target_address;// CLL 15 decimal
            default: next_pc = pc_plus4;
        endcase
    end
endmodule




module testbench;
    reg clk = 0;
    reg reset = 1;
    wire [31:0] pc;
    wire [31:0] instr;

    wire pc_write;
    wire [31:0] next_pc;
    wire [31:0] pc_plus4;
    assign pc_plus4 = pc + 4;
    assign pc_write = 1'b1;

  //used here to generate pc and to check if everything rightor no.
    fetch fetch_u(
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .next_pc(next_pc),
        .pc_out(pc)
    );
										 
    InstructionMemory instr_mem_u(
	.addr(pc[9:2]),//its similar to division by four but here its shifted by 2 
	//basically calculate instruction index where we will continye to access all 256 words
        .instr(instr)
    );

   
    wire [31:0] instr_reg;
    IR ir_u(
        .clk(clk),
        .IRWrite(1'b1),
        .instr_in(instr),
        .instr_out(instr_reg)
    );

   
    wire [31:0] read_data1, read_data2;
    regfile rf_u(
        .clk(clk),
        .we(1'b0),
        .read_reg1(4'd1),
        .read_reg2(4'd2),
        .write_reg(4'd1),
        .write_data(32'd0),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );


    reg [3:0] pc_op;
    reg [31:0] rs_val;
    reg [31:0] tgt_addr;

    PCControl pcc_u(
        .rs_value(rs_val),
        .target_address(tgt_addr),
        .pc_plus4(pc_plus4),
        .pc_op(pc_op),
        .next_pc(next_pc)
    );


    always #5 clk = ~clk;

initial begin
    $display("Time\tPC\tNext_PC\tRS_val\tTarget\tpc_op");
    $monitor("%0t\t%h\t%h\t%d\t%h\t%b", $time, pc, next_pc, rs_val, tgt_addr, pc_op);

    reset = 1;
    #10 reset = 0;

    //BZ opcode eq 10 decimal
    pc_op = 4'd10;
    rs_val = 0;
    tgt_addr = 32'h00000040;
    #20;

    rs_val = 5;
    #20;

    //BGZ
    pc_op = 4'd11;
    rs_val = 10;
    tgt_addr = 32'h00000080;
    #20;

    rs_val = -5;
    #20;

    //BLZ 
    pc_op = 4'd12;
    rs_val = -10;
    tgt_addr = 32'h000000C0;
    #20;

    rs_val = 5;
    #20;

    //JR
    pc_op = 4'd13;
    rs_val = 32'h00000100;
    tgt_addr = 0;
    #20;

    //J
    pc_op = 4'd14;
    rs_val = 0;
    tgt_addr = 32'h00000140;
    #20;

    //CLL
    pc_op = 4'd15;
    rs_val = 0;
    tgt_addr = 32'h00000180;
    #20;

    $stop;  
end

endmodule
