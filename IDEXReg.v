`timescale 1ns / 1ps
module IDEXReg(reset, clk,OpCode_i, PC_i,ReadData1in,ReadData2in,Shamtin,ImmExtOutin,ImmExtShiftin,rsin,rdin,rtin,
               Branchin,RegWritein,ALUSrcAin,ALUSrcBin,ALUOpin,Functin,
				RegDstin,MemReadin,MemWritein,MemtoRegin,ReadData1out,
				ReadData2out,Shamtout,ImmExtOutout,ImmExtShiftout,rsout,rdout,rtout,Branchout,RegWriteout,
				ALUSrcAout,ALUSrcBout,ALUOpout,Functout,RegDstout,MemReadout,MemWriteout,
				MemtoRegout,PC_o,OpCode_o);
    //Input Clock Signals
    input reset;
    input clk;
    //Input Data
	input [5:0] OpCode_i;
	input [31:0] PC_i;
    input [31:0] ReadData1in;
	input [31:0] ReadData2in;
	input [4:0] Shamtin;
	input [31:0] ImmExtOutin;
	input [31:0] ImmExtShiftin;
	input [4:0] rsin;
	input [4:0] rdin;
	input [4:0] rtin;
	input [5:0] Functin;
	//Input Control Signals
	input Branchin;
	input RegWritein;
	input [1:0] ALUSrcAin;
	input [1:0] ALUSrcBin;
	input [3:0] ALUOpin;
	input [1:0] RegDstin;
	input MemReadin;
	input MemWritein;
	input [1:0] MemtoRegin;
    //Output Data
	output reg [5:0] OpCode_o;
    output reg [31:0] ReadData1out;
	output reg [31:0] ReadData2out;
	output reg [4:0] Shamtout;
	output reg [31:0] ImmExtOutout;
	output reg [31:0] ImmExtShiftout;
	output reg [4:0] rsout;
	output reg [4:0] rdout;
	output reg [4:0] rtout;
	output reg [5:0] Functout;
	//Output Control Signals
	output reg Branchout;
	output reg RegWriteout;
	output reg [1:0] ALUSrcAout;
	output reg [1:0] ALUSrcBout;
	output reg [3:0] ALUOpout;
	output reg [1:0] RegDstout;
	output reg MemReadout;
	output reg MemWriteout;
	output reg [1:0] MemtoRegout;
	output reg [31:0] PC_o;
    
    always@(posedge reset or posedge clk) begin
        if (reset) begin
			Branchout <= 0;
			RegWriteout <= 0;
			MemReadout <= 0;
			MemWriteout <= 0;
			PC_o <= 32'h00000000;
        end else begin
		    OpCode_o <= OpCode_i;
            ReadData1out <= ReadData1in;
			ReadData2out <= ReadData2in;
			Shamtout <= Shamtin;
			ImmExtOutout <= ImmExtOutin;
			ImmExtShiftout <= ImmExtShiftin;
			rsout <= rsin;
			rdout <= rdin;
			rtout <= rtin;
			Branchout <= Branchin;
			RegWriteout <= RegWritein;
			ALUSrcAout <= ALUSrcAin;
			ALUSrcBout <= ALUSrcBin;
			ALUOpout <= ALUOpin;
			RegDstout <= RegDstin;
			MemReadout <= MemReadin;
			MemWriteout <= MemWritein;
			MemtoRegout <= MemtoRegin;
			Functout <= Functin;
			PC_o <= PC_i;
		end
	end
endmodule
