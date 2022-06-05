`timescale 1ns / 1ps
//create_clock -period 10.000 -name CLK -waveform {0.000 5.000} [get_ports clk]
module PipelineCPU (reset,clk,an,Cathodes);
    //Input Clock Signals
    input reset;
    input clk;
	
	//output
	output reg [3:0] an;
	output reg [7:0] Cathodes;
	
	//forwarding and hazard unit
	wire [1:0] ALUA;
	wire [1:0] ALUB;
	
	
	//IF stage
	//PC
	wire [31:0] IFIDPCAddout;
	wire [31:0] PC_o;
	wire [31:0] PC_i;
	wire [31:0] PC_new;
	wire [31:0] PC_Jump_Address;
	wire PCSource;
	wire Branch;
	wire Zero;
	wire PCInputMux;
	wire [1:0] Jump;
	//InstMemory
	wire [31:0] Instruction;
	
	
	//IFIDReg
	wire [31:0] PC_IFIDi;
	wire [31:0] PC_IFIDo;
	wire [31:0] Instruction_IFIDi;
	wire [31:0] Instruction_IFIDo;
	wire [1:0] IFIDInputMux;
	
	
	//ID stage
	//Decode
	wire [5:0] OpCode;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [4:0] Shamt;
	wire [5:0] Funct;
	//Controller
	wire ExtOp;
	wire LuiOp;
	wire RegWrite;
	wire MemRead;
	wire MemWrite;
	wire [1:0] MemtoReg;
	wire [1:0] ALUSrcA;
	wire [1:0] ALUSrcB;
	wire [1:0] RegDst;
	wire [3:0] ALUOp;
	//ImmProcess
	wire [15:0] Immediate;
	wire [31:0] ImmExtOut;
	wire [31:0] ImmExtShift;
	//RegisterFile
	wire [4:0] Write_Register;
	wire [31:0] Reg_Write_data;
	wire [31:0] Read_data1;
	wire [31:0] Read_data2;
	
	
	//IDEXReg 
	wire IDEXInputMux;
	wire IDEXBranchin;
	wire IDEXBranchout;
	wire IDEXRegWritein;
	wire IDEXRegWriteout;
	wire IDEXMemReadin;
	wire IDEXMemReadout;
	wire IDEXMemWritein;
	wire IDEXMemWriteout;
	wire [1:0] IDEXMemtoRegout;
	wire [1:0] IDEXALUSrcAout;
	wire [1:0] IDEXALUSrcBout;
	wire [1:0] IDEXRegDstout;
	wire [3:0] IDEXALUOpout;
	wire [4:0] IDEXShamtout;
	wire [4:0] IDEXrsout;
	wire [4:0] IDEXrdout;
	wire [4:0] IDEXrtout;
	wire [5:0] IDEXFunctout;
	wire [5:0] IDEXOpCode_o;
	wire [31:0] IDEXReadData1out;
	wire [31:0] IDEXReadData2out;
	wire [31:0] IDEXImmExtOutout;
	wire [31:0] IDEXImmExtShiftout;
	wire [31:0] PC_IDEXo;
	
	
	//EX stage
	//PCAdder
	wire [31:0] IDEXPCAddout;
	//ALUControl
	wire Sign;
	wire [4:0] ALUConf;
	//ALU
	wire [31:0] DataA;
	wire [31:0] DataB;
	wire [31:0] In1;
	wire [31:0] In2;
	wire [31:0] ALUOut;
	
	
	//EXMEMReg
	wire EXMEMMemReadout;
	wire EXMEMMemWriteout;
	wire [1:0] EXMEMMemtoRegout;
	wire EXMEMRegWriteout;
	wire [4:0] EXMEMWriteRegisterin;
	wire [4:0] EXMEMWriteRegisterout;
	wire [31:0] EXMEMALUOutout;
	wire [31:0] PC_EXMEMo;
	wire [31:0] EXMEMWrite_Data_out;
	
	
	//MEM stage
	//DataMemory
	wire [31:0] DataMemory_data;
	//MDR
	wire [31:0] MDR_o;
	
	//MEMWBReg
	wire MEMWBRegWriteout;
	wire [1:0] MEMWBMemtoRegout;
	wire [4:0] MEMWBWriteRegisterout;
	wire [31:0] PC_MEMWBo;
	wire [31:0] MEMWBWrite_Data_out;
	wire [31:0] MEMWBALUOut;
	
	
	//WB stage
	wire [31:0] MEMWBWrite_Data_decided;
	
	wire clk_40k_gen;
	reg [3:0] AN;
	reg [7:0] CATHODES;

    parameter ra = 5'b11111;
	
	clk_40k myclk_40k(clk,reset,clk_40k_gen);
	
	////////////////////// forwarding & hazard unit ////////////////////////
	//forwarding
	assign ALUA = (EXMEMRegWriteout && (EXMEMWriteRegisterout != 0) && (EXMEMWriteRegisterout == IDEXrsout) )? 2'b10 :
	              ( MEMWBRegWriteout && (MEMWBWriteRegisterout != 0) &&( MEMWBWriteRegisterout == IDEXrsout) && ( EXMEMWriteRegisterout != IDEXrsout || ~EXMEMRegWriteout) )? 2'b01 :
	              2'b00;
	assign ALUB = (EXMEMRegWriteout && (EXMEMWriteRegisterout != 0) &&(EXMEMWriteRegisterout == IDEXrtout) )? 2'b10 :
	              ( MEMWBRegWriteout && (MEMWBWriteRegisterout != 0) &&( MEMWBWriteRegisterout == IDEXrtout) && ( EXMEMWriteRegisterout != IDEXrtout || ~EXMEMRegWriteout) )? 2'b01 :
	              2'b00;
	//hazard
	assign IFIDInputMux = (IDEXMemReadout && ( (IDEXrtout == rs) || (IDEXrtout == rt) ) )?2'b11 : 
	                      PCSource? 2'b00 :
	                      (OpCode == 6'h02 || OpCode == 6'h03 || ((OpCode == 6'h00) && (Funct == 6'h08 || Funct == 6'h09)))?2'b00 :
	                       2'b10;
	assign PCInputMux = (IDEXMemReadout && ( (IDEXrtout == rs) || (IDEXrtout == rt) ) )? 0 : 1;
	assign IDEXInputMux = (IDEXMemReadout && ( (IDEXrtout == rs) || (IDEXrtout == rt) ) )? 0 :
	                      PCSource? 0 : 1;
	
	//////////////////// IF stage ////////////////////////////////
    //PC register
    //PC(reset, clk, PC_i, PC_o);
	assign IFIDPCAddout = PC_o + 4;
	//beq 6'h04, bne 6'h05, blez 6'h06, bgtz 6'h07, bltz 6'h01
	assign PCSource = (IDEXOpCode_o == 6'h04)? IDEXBranchout && Zero : 
	                  (IDEXOpCode_o == 6'h05)? IDEXBranchout && (!Zero) :
					  (IDEXOpCode_o == 6'h06)? IDEXBranchout && (!ALUOut):
					  IDEXBranchout && ALUOut;
   // assign PC_i = reset? 0 : (Jump==2'b10)? PC_Jump_Address : 
   //              (Jump==2'b01)? Read_data1 : 
   //              PCSource? IDEXPCAddout : IFIDPCAddout;
	assign PC_i = reset? 0 : PCSource? IDEXPCAddout : 
	             (Jump == 2'b10)? PC_Jump_Address : 
	             (Jump == 2'b01)? Read_data1 :
	             IFIDPCAddout ;
    PC myPC(reset,clk_40k_gen,PC_new,PC_o);
    assign PC_new = reset? 0 : PCInputMux? PC_i : PC_IFIDo;
    
    //Instruction Memory
    //InstMemory(reset, clk, Address, Mem_data);
    InstMemory myInstMemory(reset,clk_40k_gen,PC_o,Instruction);
	////////////////////////////////////////////////////////////
	
    //IFIDReg(reset, clk, PC_IFIDi, Instruction_IFIDi, 
    //           PC_IFIDo, Instruction_IFIDo);
	assign Instruction_IFIDi = (IFIDInputMux == 2'b00)? {6'h11,24'h000000,2'b00} : // cancel command in IF if Opcode i 0x11(I defined this)
	                           (IFIDInputMux == 2'b11)? Instruction_IFIDo :
							   Instruction;
	assign PC_IFIDi = (IFIDInputMux == 2'b11)? PC_IFIDo : IFIDPCAddout;
	IFIDReg myIFIDReg(reset,clk_40k_gen,PC_IFIDi,
	                  Instruction_IFIDi,PC_IFIDo,Instruction_IFIDo);
					  
	//////////////////////////////////////////////////////////////////
	
	//////////////////////// ID stage ///////////////////////////////////////
    //Decode
	assign OpCode = Instruction_IFIDo[31:26];
	assign rs = Instruction_IFIDo[25:21];
	assign rt = Instruction_IFIDo[20:16];
	assign rd = Instruction_IFIDo[15:11];
	assign Shamt = Instruction_IFIDo[10:6];
	assign Funct = Instruction_IFIDo[5:0];
	
    //Controller
    //Controller(OpCode, Funct,ExtOp,LuiOp,
    //            Jump,Branch,RegWrite,ALUSrcA,ALUSrcB,ALUOp,
	//			RegDst,MemRead,MemWrite,MemtoReg);
	Controller myController(Instruction_IFIDo[31:26],
	                        Instruction_IFIDo[5:0],ExtOp,LuiOp,Jump,
	                        Branch,RegWrite,ALUSrcA,ALUSrcB,ALUOp,
							RegDst,MemRead,MemWrite,MemtoReg);
							
    //ImmExt, ImmExtShift
    //ImmProcess(ExtOp, LuiOp, Immediate, ImmExtOut, ImmExtShift);
    assign Immediate = Instruction_IFIDo[15:0];
    ImmProcess myImmProcess(ExtOp,LuiOp,Immediate,ImmExtOut,ImmExtShift);
    
    //RegisterFile
    //RegisterFile(reset, clk, RegWrite, Read_register1, Read_register2,
    //          	Write_Register, Write_data, Read_data1, Read_data2);
    assign Write_Register = MEMWBWriteRegisterout;
    RegisterFile myRegisterFile(reset,clk_40k_gen,MEMWBRegWriteout,rs,rt,MEMWBWriteRegisterout,
	                            MEMWBWrite_Data_decided,Read_data1,Read_data2);
	//Jump address
	assign PC_Jump_Address = {PC_IFIDo[31:28],Instruction_IFIDo[25:0],2'b00};
	
    ///////////////////////////////////////////////////////////////////////////
	
	//IDEXReg
	//IDEXReg(reset, clk, OpCode_i,PC_i,ReadData1in,ReadData2in,Shamtin,ImmExtOutin,
    //          ImmExtShiftin,rsin,rdin,rtin,Branchin,RegWritein,
	//			ALUSrcAin,ALUSrcBin,ALUOpin,Functin,RegDstin,MemReadin,
	//			MemWritein,MemtoRegin,ReadData1out,ReadData2out,Shamtout,
	//          ImmExtOutout,ImmExtShiftout,rsout,rdout,rtout,Branchout,
	//			RegWriteout,ALUSrcAout,ALUSrcBout,ALUOpout,Functout,RegDstout,
	//			MemReadout,MemWriteout,MemtoRegout,PC_o,OpCode_o);
	assign IDEXBranchin = IDEXInputMux? Branch : 0;
	assign IDEXRegWritein = IDEXInputMux? RegWrite : 0;
	assign IDEXMemReadin = IDEXInputMux? MemRead : 0;
	assign IDEXMemWritein = IDEXInputMux? MemWrite : 0;
	IDEXReg myIDEXReg(reset,clk_40k_gen,OpCode,PC_IFIDo,Read_data1,Read_data2,Shamt,ImmExtOut,
               ImmExtShift,rs,rd,rt,IDEXBranchin,IDEXRegWritein,
			   ALUSrcA,ALUSrcB,ALUOp,Funct,RegDst,IDEXMemReadin,
			   IDEXMemWritein,MemtoReg,IDEXReadData1out,IDEXReadData2out,
			   IDEXShamtout,IDEXImmExtOutout,IDEXImmExtShiftout,IDEXrsout,IDEXrdout,
			   IDEXrtout,IDEXBranchout,IDEXRegWriteout,
			   IDEXALUSrcAout,IDEXALUSrcBout,IDEXALUOpout,IDEXFunctout,
			   IDEXRegDstout,IDEXMemReadout,IDEXMemWriteout,IDEXMemtoRegout,PC_IDEXo,IDEXOpCode_o);
	
	/////////////////////////// EX stage///////////////////////////////////////
    
    //ALUControl
    //ALUControl(ALUOp, Funct, ALUConf, Sign);
    ALUControl myALUControl(IDEXALUOpout,IDEXFunctout,ALUConf,Sign);
    
    //ALU
    //ALU(ALUConf, Sign, In1, In2, Zero, Result);
    assign DataA = (ALUA == 2'b00)? IDEXReadData1out :
	               (ALUA == 2'b10)? EXMEMALUOutout :
                   (MEMWBMemtoRegout == 2'b11)? MEMWBWrite_Data_out :
                   (MEMWBMemtoRegout == 2'b00)? MEMWBALUOut : 0;
    assign DataB = (ALUB == 2'b00)? IDEXReadData2out :
	               (ALUB == 2'b10)? EXMEMALUOutout :
                   (MEMWBMemtoRegout == 2'b11)? MEMWBWrite_Data_out :
                   (MEMWBMemtoRegout == 2'b00)?  MEMWBALUOut : 0;			   
    assign In1 = (IDEXALUSrcAout == 2'b00)? 0 :
	             (IDEXALUSrcAout == 2'b11)? IDEXShamtout : DataA;
    assign In2 = (IDEXALUSrcBout == 2'b00)? 0 :
	             (IDEXALUSrcBout == 2'b11)? DataB :
				 (IDEXALUSrcBout == 2'b10)? IDEXImmExtShiftout : IDEXImmExtOutout;
    ALU myALU(ALUConf,Sign,In1,In2,Zero,ALUOut);
	
	//choose reg destination,2'b00-rs,2'b01-rt,2'b10-ra
	assign EXMEMWriteRegisterin = (IDEXRegDstout == 2'b00)? IDEXrdout :
	                              (IDEXRegDstout == 2'b11)? IDEXrtout :ra;
    
	//PCAdder
	assign IDEXPCAddout = PC_IDEXo + IDEXImmExtShiftout;
	
	//////////////////////////////////////////////////////////////////////////////
	//EXMEMReg
	//EXMEMReg(reset, clk,PC_i,ALUOutin,Write_Data_in,
    //            Write_Register_in,MemReadin,MemWritein,
	//			MemtoRegin,RegWritein,PC_o,ALUOutout,
	//			Write_Data_out,Write_Register_out,MemReadout,
	//			MemWriteout,MemtoRegout,RegWriteout);
	EXMEMReg myEXMEMReg(reset,clk_40k_gen,PC_IDEXo,ALUOut,IDEXReadData2out,EXMEMWriteRegisterin,
	                    IDEXMemReadout,IDEXMemWriteout,IDEXMemtoRegout,IDEXRegWriteout,
						PC_EXMEMo,EXMEMALUOutout,EXMEMWrite_Data_out,EXMEMWriteRegisterout,
						EXMEMMemReadout,EXMEMMemWriteout,EXMEMMemtoRegout,EXMEMRegWriteout);
						
	/////////////////////// MEM stage /////////////////////////////////////////
	
	//DataMemory
	//DataMemory(reset, clk, Address, Write_data, MemRead, MemWrite, Mem_data);
	DataMemory myDataMemory(reset,clk_40k_gen,EXMEMALUOutout,EXMEMWrite_Data_out,
	                        EXMEMMemReadout,EXMEMMemWriteout,DataMemory_data);
	
    //Memory data register
    //RegTemp(reset, clk, Data_i, Data_o);
    RegTemp MDR(reset,clk_40k_gen,DataMemory_data,MDR_o);
	
	/////////////////////////////////////////////////////////////////////
	
	//MEMWBReg
	//MEMWBReg(reset, clk,PC_i,ALUOutin,Write_Data_in,
    //            Write_Register_in,MemtoRegin,RegWritein,
	//			PC_o,ALUOutout,Write_Data_out,Write_Register_out,
	//			MemtoRegout,RegWriteout);
	MEMWBReg myMEMWBReg(reset,clk_40k_gen,PC_EXMEMo,EXMEMALUOutout,DataMemory_data,
	                    EXMEMWriteRegisterout,EXMEMMemtoRegout,EXMEMRegWriteout,
						PC_MEMWBo,MEMWBALUOut,MEMWBWrite_Data_out,
						MEMWBWriteRegisterout,MEMWBMemtoRegout,MEMWBRegWriteout);
	
	/////////////////// WB stage /////////////////////////////////////////
	assign MEMWBWrite_Data_decided = (MEMWBMemtoRegout == 2'b11)? MEMWBWrite_Data_out : 
	                                 (MEMWBMemtoRegout == 2'b00)? MEMWBALUOut :
	                                 PC_MEMWBo;
	always @(posedge reset or posedge clk_40k_gen)
	begin
	  if(reset)begin
	    an <= 4'b1111;
	    Cathodes <= 8'b11111111;
	  end
	  else
	  begin
	    an <= myDataMemory.AN;
	    Cathodes <= myDataMemory.CATHODES;
	  end
	end
endmodule