`timescale 1ns / 1ps
module IFIDReg(reset, clk, PC_IFIDi, Instruction_IFIDi, 
               PC_IFIDo, Instruction_IFIDo);
    //Input Clock Signals
    input reset;
    input clk;
    //Input Data
    input [31:0] PC_IFIDi;
	input [31:0] Instruction_IFIDi;
    //Output Data
    output reg [31:0] PC_IFIDo;
	output reg [31:0] Instruction_IFIDo;
    
    always@(posedge reset or posedge clk) begin
        if (reset) begin
            PC_IFIDo <= 32'h00000000;
			Instruction_IFIDo <= {6'h11,24'h000000,2'b00};  // no command 0x11
        end else begin
            PC_IFIDo <= PC_IFIDi;
			Instruction_IFIDo <= Instruction_IFIDi;
        end
    end
endmodule
