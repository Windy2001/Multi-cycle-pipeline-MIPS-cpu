`timescale 1ns / 1ps
module Controller(OpCode, Funct,ExtOp,LuiOp,
                Jump,Branch,RegWrite,ALUSrcA,ALUSrcB,ALUOp,
				RegDst,MemRead,MemWrite,MemtoReg);
    //Input Signals
    input  [5:0] OpCode;
    input  [5:0] Funct;
    //Output Control Signals
	output reg ExtOp;
	output reg LuiOp;
    output reg [1:0] Jump;
	output reg Branch;
	output reg RegWrite;
	output reg [1:0] ALUSrcA;
	output reg [1:0] ALUSrcB;
	output reg [3:0] ALUOp;
	output reg [1:0] RegDst;
	output reg MemRead;
	output reg MemWrite;
	output reg [1:0] MemtoReg;
    
	reg [3:0] inst_type;
	  
    always @(*)
    begin
      case(OpCode)
        6'h00: inst_type <= (Funct == 6'h08)? 4'b0001 : //jr
                         (Funct == 6'h09)? 4'b0010 : //jalr
                         4'b0000 ; //R-type
        6'h02: inst_type <= 4'b0001 ; //j
        6'h03: inst_type <= 4'b0010 ; //jal
        6'h23: inst_type <= 4'b0011 ; //lw
        6'h2b: inst_type <= 4'b0111 ; //sw
        6'h0f: inst_type <= 4'b0100 ; //lui
        6'h08: inst_type <= 4'b0101 ; //I-type
        6'h09: inst_type <= 4'b0101 ; //I-type
        6'h0c: inst_type <= 4'b0101 ; //I-type
        6'h0a: inst_type <= 4'b0101 ; //I-type
        6'h0b: inst_type <= 4'b0101 ; //I-type
        6'h04: inst_type <= 4'b0110 ; //beq
		6'h05: inst_type <= 4'b0110 ; //bne
		6'h06: inst_type <= 4'b1001 ; //blez
		6'h07: inst_type <= 4'b1001 ; //bgtz
		6'h01: inst_type <= 4'b1011 ; //bltz
		default: inst_type <= 4'b1000; // no command/ cancel command
      endcase
	  case(inst_type)
	    4'b1000: // no command or cancel command
		begin
		  Jump <= 2'b00;
		  Branch <= 0;
		  RegWrite <= 0;
		  MemRead <= 0;
		  MemWrite <= 0;
		end
		4'b0000: // R-type
		begin 
		  Jump <= 2'b00;
		  Branch <= 0;
		  RegWrite <= 1;
		  ALUSrcA <= (Funct==6'h00 || Funct==6'h02 ||
					  Funct==6'h03)? 2'b11 : 2'b10; // 2'b11-Shamt,2'b00-0,else:A
		  ALUSrcB <= 2'b11; // 2'b11-B,2'b01-ImmExtOut,2'b10-ImmExtShift,2'b00-0
		  ALUOp[3] <= OpCode[0];
		  ALUOp[2:0] <= 3'b010;
		  RegDst <= 2'b00; // 2'b11-rt,2'b00-rd,else:ra
		  MemRead <= 0;
		  MemWrite <= 0;
		  MemtoReg <= 2'b00;
		end
		4'b0001: // jr,j
		begin 
		  Jump <= (OpCode == 6'h02)? 2'b10 : 2'b01;
		  Branch <= 0;
		  RegWrite <= 0;
		  MemRead <= 0;
		  MemWrite <= 0;
		end
		4'b0010: // jalr,jal
		begin 
		  Jump <= (OpCode == 6'h03)? 2'b10 : 2'b01;
		  Branch <= 0;
		  RegWrite <= 1;
		  RegDst <= 2'b10; // 2'b11-rt,2'b00-rd,else:ra
		  MemRead <= 0;
		  MemWrite <= 0;
		  MemtoReg <= 2'b01;
		end
		4'b0011: // lw
		begin 
		  Jump <= 2'b00;
		  Branch <= 0;
		  RegWrite <= 1;
		  ALUSrcA <= 2'b10; // 2'b11-Shamt,2'b00-0,else:A
		  ExtOp <= 1;
		  LuiOp <= 0;
		  ALUSrcB <= 2'b01; // 2'b11-B,2'b01-ImmExtOut,2'b10-ImmExtShift,2'b00-0
		  ALUOp[3] <= OpCode[0];
		  ALUOp[2:0] <= 3'b000;
		  RegDst <= 2'b11; // 2'b11-rt,2'b00-rd,else:ra
		  MemRead <= 1;
		  MemWrite <= 0;
		  MemtoReg <= 2'b11;
		end
		4'b0100: // lui
		begin 
		  Jump <= 2'b00;
		  Branch <= 0;
		  RegWrite <= 1;
		  ALUSrcA <= 2'b00; // 2'b11-Shamt,2'b00-0,else:A
		  ExtOp <= 0;
		  LuiOp <= 1;
		  ALUSrcB <= 2'b01; // 2'b11-B,2'b01-ImmExtOut,2'b10-ImmExtShift,2'b00-0
		  ALUOp[3] <= OpCode[0];
		  ALUOp[2:0] <= 3'b000;
		  RegDst <= 2'b11; // 2'b11-rt,2'b00-rd,else:ra
		  MemRead <= 0;
		  MemWrite <= 0;
		  MemtoReg <= 2'b00;
		end
		4'b0101: // I-type
		begin 
		  Jump <= 2'b00;
		  Branch <= 0;
		  RegWrite <= 1;
		  ALUSrcA <= 2'b10; // 2'b11-Shamt,2'b00-0,else:A
		  LuiOp <= 0;
		  ExtOp <= 1;
		  ALUSrcB <= 2'b01; // 2'b11-B,2'b01-ImmExtOut,2'b10-ImmExtShift,2'b00-0
		  ALUOp[3] <= OpCode[0];
		  ALUOp[2:0] <= (OpCode == 6'h0c)? 3'b100 : 
				   (OpCode == 6'h0a || OpCode == 6'h0b)? 3'b101 : 3'b000;
		  RegDst <= 2'b11; // 2'b11-rt,2'b00-rd,else:ra
		  MemRead <= 0;
		  MemWrite <= 0;
		  MemtoReg <= 2'b00;
		end
		4'b0110: // beq,bne
		begin 
		  Jump <= 2'b00;
		  Branch <= 1;
		  RegWrite <= 0;
		  ALUSrcA <= 2'b10; // 2'b11-Shamt,2'b00-0,else:A
		  LuiOp <= 0;
		  ExtOp <= 1;
		  ALUSrcB <= 2'b11; // 2'b11-B,2'b01-ImmExtOut,2'b10-ImmExtShift,2'b00-0
		  ALUOp[3] <= 0;
		  ALUOp[2:0] <= 3'b001;
		  MemRead <= 0;
		  MemWrite <= 0;
		end
		4'b1001: //blez,bgtz
		begin
		  Jump <= 2'b00;
		  Branch <= 1;
		  RegWrite <= 0;
		  ALUSrcA <= 2'b10; // 2'b11-Shamt,2'b00-0,else:A
		  LuiOp <= 0;
		  ExtOp <= 1;
		  ALUSrcB <= 2'b11; // 2'b11-B,2'b01-ImmExtOut,2'b10-ImmExtShift,2'b00-0
		  ALUOp[3] <= 0;
		  ALUOp[2:0] <= 3'b011;
		  MemRead <= 0;
		  MemWrite <= 0;
		end
		4'b1011: //bltz
		begin
		  Jump <= 2'b00;
		  Branch <= 1;
		  RegWrite <= 0;
		  ALUSrcA <= 2'b10; // 2'b11-Shamt,2'b00-0,else:A
		  LuiOp <= 0;
		  ExtOp <= 1;
		  ALUSrcB <= 2'b11; // 2'b11-B,2'b01-ImmExtOut,2'b10-ImmExtShift,2'b00-0
		  ALUOp[3] <= 0;
		  ALUOp[2:0] <= 3'b101;
		  MemRead <= 0;
		  MemWrite <= 0;
		end
		4'b0111: // sw
		begin 
		  Jump <= 2'b00;
		  Branch <= 0;
		  RegWrite <= 0;
		  ALUSrcA <= 2'b10; // 2'b11-Shamt,2'b00-0,else:A
		  ExtOp <= 1;
		  LuiOp <= 0;
		  ALUSrcB <= 2'b01; // 2'b11-B,2'b01-ImmExtOut,2'b10-ImmExtShift,2'b00-0
		  ALUOp[3] <= OpCode[0];
		  ALUOp[2:0] <= 3'b000;
		  MemRead <= 0;
		  MemWrite <= 1;
		end
		default:begin end
	  endcase
    end
    
endmodule