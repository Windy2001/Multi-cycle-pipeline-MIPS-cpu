`timescale 1ns / 1ps
module EXMEMReg(reset, clk,PC_i,ALUOutin,Write_Data_in,
                Write_Register_in,MemReadin,MemWritein,
				MemtoRegin,RegWritein,PC_o,ALUOutout,
				Write_Data_out,Write_Register_out,MemReadout,
				MemWriteout,MemtoRegout,RegWriteout);
    //Input Clock Signals
    input reset;
    input clk;
    //Input Data
	input [31:0] PC_i;
    input [31:0] ALUOutin;
	input [31:0] Write_Data_in;
	input [4:0] Write_Register_in;
	//Input Control Signals
	input MemReadin;
	input MemWritein;
	input [1:0] MemtoRegin;
	input RegWritein;
    //Output Data
	output reg [31:0] PC_o;
	output reg [31:0] ALUOutout;
	output reg [31:0] Write_Data_out;
	output reg [4:0] Write_Register_out;
	//Output Control Signals
	output reg MemReadout;
	output reg MemWriteout;
	output reg [1:0] MemtoRegout;
	output reg RegWriteout;
	
    
    always@(posedge reset or posedge clk) begin
        if (reset) begin
			RegWriteout <= 0;
			MemReadout <= 0;
			MemWriteout <= 0;
			PC_o <= 32'h00000000;
        end else begin
			PC_o <= PC_i;
			ALUOutout <= ALUOutin;
			Write_Data_out <= Write_Data_in;
			Write_Register_out <= Write_Register_in;
			MemReadout <= MemReadin;
			MemWriteout <= MemWritein;
			MemtoRegout <= MemtoRegin;
			RegWriteout <= RegWritein;
		end
	end
endmodule
