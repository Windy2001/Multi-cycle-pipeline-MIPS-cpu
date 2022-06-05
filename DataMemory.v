`timescale 1ns / 1ps
module DataMemory(reset, clk, Address, Write_data, 
                  MemRead, MemWrite, Mem_data);
	//Input Clock Signals
	input reset;
	input clk;
	//Input Data Signals
	input [31:0] Address;
	input [31:0] Write_data;
	//Input Control Signals
	input MemRead;
	input MemWrite;
	//Output Data
	output [31:0] Mem_data;
	
	reg [3:0] AN;
	reg [7:0] CATHODES;
	
	parameter RAM_SIZE = 512;
	parameter RAM_SIZE_BIT = 8;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];
	reg [1:0] cnt;
	reg [3:0] figure3,figure2,figure1,figure0;

	//read data
	assign Mem_data = MemRead? RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;
	
	//write data
	integer i;
	always @(posedge reset or posedge clk) begin
		if (reset) begin
		    RAM_data[0] <= 32'h0000000c;
			RAM_data[1] <= 32'h0000000d;
			RAM_data[2] <= 32'h00000002;
			RAM_data[3] <= 32'h00000001;
			RAM_data[4] <= 32'h00000003;
			RAM_data[5] <= 32'h00000003;
			RAM_data[6] <= 32'h00000004;
			RAM_data[7] <= 32'h00000005;
			RAM_data[8] <= 32'h00000007;
			RAM_data[9] <= 32'h00000009;
			RAM_data[10] <= 32'h00000002;
			RAM_data[11] <= 32'h0000000c;
			RAM_data[12] <= 32'h00000001;
			RAM_data[13] <= 32'h0000000a;
			RAM_data[14] <= 32'h00000003;
			RAM_data[15] <= 32'h00000014;
			RAM_data[16] <= 32'h00000002;
			RAM_data[17] <= 32'h0000000f;
			RAM_data[18] <= 32'h00000001;
			RAM_data[19] <= 32'h00000008;
			RAM_data[20] <= 32'h00000004;
			RAM_data[21] <= 32'h0000001a;
			RAM_data[22] <= 32'h00000002;
			RAM_data[23] <= 32'h0000001a;
			RAM_data[24] <= 32'h00000003;
			RAM_data[25] <= 32'h0000000f;
			for (i = 26; i < RAM_SIZE; i = i + 1)
				RAM_data[i] <= 32'h00000000;
			
			AN <= 4'b1111;
			CATHODES <= 8'b11111111;
			cnt <= 0;
		end else if (MemWrite) begin
		    if(Address == 32'h40000010) begin
			    figure3 <= Write_data[15:12];
				figure2 <= Write_data[11:8];
				figure1 <= Write_data[7:4];
				figure0 <= Write_data[3:0];
				case(cnt)
				  2'b00:
					begin
					  CATHODES<=(figure3==0)?8'b1100_0000:
							   (figure3==1)?8'b1111_1001:
							   (figure3==2)?8'b1010_0100:
							   (figure3==3)?8'b1011_0000:
							   (figure3==4)?8'b1001_1001:
							   (figure3==5)?8'b1001_0010:
							   (figure3==6)?8'b1000_0010:
							   (figure3==7)?8'b1111_1000:
							   (figure3==8)?8'b1000_0000:
							   (figure3==9)?8'b1001_0000:
							   (figure3==10)?8'b1000_1000://A
							   (figure3==11)?8'b1000_0011://b
							   (figure3==12)?8'b1100_0110://C
							   (figure3==13)?8'b1010_0001://d
							   (figure3==14)?8'b1000_0110://E
							   (figure3==15)?8'b1000_1110://F
							   8'b1111_1111;
					  AN<=4'b0111;
					  cnt <= cnt+1;
					end
				  2'b01:
					begin
					  CATHODES<=(figure2==0)?8'b1100_0000:
							   (figure2==1)?8'b1111_1001:
							   (figure2==2)?8'b1010_0100:
							   (figure2==3)?8'b1011_0000:
							   (figure2==4)?8'b1001_1001:
							   (figure2==5)?8'b1001_0010:
							   (figure2==6)?8'b1000_0010:
							   (figure2==7)?8'b1111_1000:
							   (figure2==8)?8'b1000_0000:
							   (figure2==9)?8'b1001_0000:
							   (figure2==10)?8'b1000_1000://A
							   (figure2==11)?8'b1000_0011://b
							   (figure2==12)?8'b1100_0110://C
							   (figure2==13)?8'b1010_0001://d
							   (figure2==14)?8'b1000_0110://E
							   (figure2==15)?8'b1000_1110://F
								8'b1111_1111;
					  AN<=4'b1011;
					  cnt <= cnt+1;
					end
				  2'b10:
					begin
					  CATHODES<=(figure1==0)?8'b1100_0000:
							   (figure1==1)?8'b1111_1001:
							   (figure1==2)?8'b1010_0100:
							   (figure1==3)?8'b1011_0000:
							   (figure1==4)?8'b1001_1001:
							   (figure1==5)?8'b1001_0010:
							   (figure1==6)?8'b1000_0010:
							   (figure1==7)?8'b1111_1000:
							   (figure1==8)?8'b1000_0000:
							   (figure1==9)?8'b1001_0000:
							   (figure1==10)?8'b1000_1000://A
							   (figure1==11)?8'b1000_0011://b
							   (figure1==12)?8'b1100_0110://C
							   (figure1==13)?8'b1010_0001://d
							   (figure1==14)?8'b1000_0110://E
							   (figure1==15)?8'b1000_1110://F
							   8'b1111_1111;
					  AN<=4'b1101;
					  cnt <= cnt+1;
					end
				  2'b11:
					begin
					  CATHODES<=(figure0==0)?8'b1100_0000:
							   (figure0==1)?8'b1111_1001:
							   (figure0==2)?8'b1010_0100:
							   (figure0==3)?8'b1011_0000:
							   (figure0==4)?8'b1001_1001:
							   (figure0==5)?8'b1001_0010:
							   (figure0==6)?8'b1000_0010:
							   (figure0==7)?8'b1111_1000:
							   (figure0==8)?8'b1000_0000:
							   (figure0==9)?8'b1001_0000:
							   (figure0==10)?8'b1000_1000://A
							   (figure0==11)?8'b1000_0011://b
							   (figure0==12)?8'b1100_0110://C
							   (figure0==13)?8'b1010_0001://d
							   (figure0==14)?8'b1000_0110://E
							   (figure0==15)?8'b1000_1110://F
							   8'b1111_1111;
					AN<=4'b1110;
					cnt<=0;
					end
				endcase
			end
			else begin
			    RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
			end
		end
	end

endmodule
