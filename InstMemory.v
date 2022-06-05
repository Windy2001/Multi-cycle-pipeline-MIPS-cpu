`timescale 1ns / 1ps
module InstMemory(reset, clk, Address, Mem_data);
	//Input Clock Signals
	input reset;
	input clk;
	//Input Data Signals
	input [31:0] Address;
	//Output Data
	output [31:0] Mem_data;
	
	parameter RAM_SIZE_BIT = 8;
	parameter RAM_INST_SIZE = 60;
	
	reg [31:0] RAM_data[RAM_INST_SIZE - 1: 0];

	//read data
	assign Mem_data = RAM_data[Address[RAM_SIZE_BIT + 1:2]];
	
	//write data
	integer i;
	always @(posedge reset or posedge clk) begin
		if (reset) begin
		    // init instruction memory
			//main:
			  //add $a1 $0 $0  0x00002820
			  RAM_data[8'd0] <= {6'h00,5'd0,5'd0,5'd5,5'd0,6'h20};
			  //lw $s0 4($a1)  0x8cb00004
			  RAM_data[8'd1] <= {6'h23,5'd5,5'd16,16'h0004};
			  //lw $s1 0($a1)  0x8cb10000
			  RAM_data[8'd2] <= {6'h23,5'd5,5'd17,16'h0000};
			  //addi $a1 $a1 8  0x20a50008
			  RAM_data[8'd3] <= {6'h08,5'd5,5'd5,16'h0008};
			  //addi $a0 $s0 0  0x22040000
			  RAM_data[8'd4] <= {6'h08,5'd16,5'd4,16'h0000};
			  //addi $a2 $s1 0  0x22260000
			  RAM_data[8'd5] <= {6'h08,5'd17,5'd6,16'h0000};
			  //jal knapsack_dp_loop  0x0c00000b
			  RAM_data[8'd6] <= {6'h03,26'd11};
			  
			//beforeloop:
			  //拆分addi $t0 $0 32'h40000010
			  //lui $t0 16'h4000
			  RAM_data[8'd7] <= {6'h0f,5'd0,5'd8,16'h4000};
			  //addi $t0 $t0 16'h0010
			  RAM_data[8'd8] <= {6'h08,5'd8,5'd8,16'h0010};
			//loop:
			  //sw $v0 0($t0)
			  RAM_data[8'd9] <= {6'h2b,5'd8,5'd2,16'h0000};
			  //beq $0 $0 loop  11->9  -2=16'hfffe 0x1000fffe
			  RAM_data[8'd10] <= {6'h04,5'd0,5'd0,16'hfffe}; 
			  
			//knapsack_dp_loop:
			  //addi $sp $sp -12  0x23bdfff4
			  RAM_data[8'd11] <= {6'h08,5'd29,5'd29,16'hfff4};
			  //sw $ra 8($sp)  0xafbf0008
			  RAM_data[8'd12] <= {6'h2b,5'd29,5'd31,16'h0008};
			  //sw $s0 4($sp)  0xafb00004
			  RAM_data[8'd13] <= {6'h2b,5'd29,5'd16,16'h0004};
			  //sw $s1 0($sp)  0xafb10000
			  RAM_data[8'd14] <= {6'h2b,5'd29,5'd17,16'h0000};
			  //addi $s2 $0 26  # $s2 = MAX_CAPACITY + 1  0x20120040
			  RAM_data[8'd15] <= {6'h08,5'd0,5'd18,16'h0040};
			  //add $t2 $0 $0  0x00005020
			  RAM_data[8'd16] <= {6'h00,5'd0,5'd0,5'd10,5'd0,6'h20};
			  //sll $s2 $s2 2  0x00129080
			  RAM_data[8'd17] <= {6'h00,5'd0,5'd18,5'd18,5'd2,6'h00};
			  //sub $sp $sp $s2  0x03b2e822
			  RAM_data[8'd18] <= {6'h00, 5'd29,5'd18,5'd29,5'd0,6'h22};
			  
			  //for:
				//add $t3 $t2 $sp  0x015d5820
				RAM_data[8'd19] <= {6'h00,5'd10,5'd29,5'd11,5'd0,6'h20};
				//sw $0 0($t3)  0xad600000
				RAM_data[8'd20] <= {6'h2b,5'd11,5'd0,16'h0000};
				//addi $t2 $t2 4  0x214a0004
				RAM_data[8'd21] <= {6'h08,5'd10,5'd10,16'h0004};
				//bne $t2 $s2 for   23-->19  ofset=-4=0xfffc  0x1552fffc
				RAM_data[8'd22] <= {6'h05,5'd10,5'd18,16'hfffc};
				//add $t0 $0 $0  0x00004020
				RAM_data[8'd23] <= {6'h00,5'd0,5'd0,5'd8,5'd0,6'h20};
				  
				  //for2:
					//sll $t4 $t0 3  0x000850c0
					RAM_data[8'd24] <= {6'h00,5'd0,5'd8,5'd12,5'd3,6'h00};
					//add $t1 $t4 $a1  0x01854820
					RAM_data[8'd25] <= {6'h00,5'd12,5'd5,5'd9,5'd0,6'h20};
					//lw $t2 0($t1)  0x8d2a0000
					RAM_data[8'd26] <= {6'h23,5'd9,5'd10,16'h0000};
					//addi $t1 $t1 4  0x21290004
					RAM_data[8'd27] <= {6'h08,5'd9,5'd9,16'h0004};
					//lw $t3 0($t1)  0x8d2b0000
					RAM_data[8'd28] <= {6'h23, 5'd9,5'd11,16'h0000};
					//addi $t5 $a2 0  0x20cd0000
					RAM_data[8'd29] <= {6'h08,5'd6,5'd13,16'h0000};
						  
						  //for3:
							   //拆分blt $t5 $t2 next3  if($t5<$t2) $t5-$t2<0
							//sub $s4 $t5 $t2   $t8=$t5-$t2  0x01aa8022
							RAM_data[8'd30] <= {6'h00,5'd13,5'd10,5'd20,5'd0,6'h22};
							//bltz $s4 next3 32->43  11  0x0600000b
							RAM_data[8'd31] <= {6'h01,5'd20,5'd0,16'h000b};
							//sll $t6 $t5 2  0x000d7080
							RAM_data[8'd32] <= {6'h00,5'd0,5'd13,5'd14,5'd2,6'h00};
							//add $t6 $t6 $sp  0x01dd7020
                            RAM_data[8'd33] <= {6'h00,5'd14,5'd29,5'd14,5'd0,6'h20};	
							//sub $t7 $t5 $t2  0x0116a7822
							RAM_data[8'd34] <= {6'h00,5'd13,5'd10,5'd15,5'd0,6'h22};
							//sll $t7 $t7 2  0x000f7880
							RAM_data[8'd35] <= {6'h00,5'd0,5'd15,5'd15,5'd2,6'h00};
							//add $t7 $t7 $sp  0x01fd7820
							RAM_data[8'd36] <= {6'h00,5'd15,5'd29,5'd15,5'd0,6'h20};
							//lw $t8 0($t7)  0x8df00000
							RAM_data[8'd37] <= {6'h23,5'd15,5'd24,16'h0000};
							//lw $t9 0($t6)  0x8dd10000
							RAM_data[8'd38] <= {6'h23,5'd14,5'd25,16'h0000};
							//add $t8 $t8 $t3  0x020b8020
							RAM_data[8'd39] <= {6'h00,5'd24,5'd11,5'd24,5'd0,6'h20};
							//拆分bgt $t9 $t8 next3 if($t9>$t8) $t9-$t8>0
							//sub $s3 $t9 $t8  0x02309822
							RAM_data[8'd40] <= {6'h00,5'd25,5'd24,5'd19,5'd0,6'h22};
							//bgtz $s3 offset 42->43 = 1 = 16'h0001  0x1e600001
							RAM_data[8'd41] <= {6'h07,5'd19,5'd0,16'h0001};
							//sw $t8 0($t6)  0xadd00000
						    RAM_data[8'd42] <= {6'h2b,5'd14,5'd24,16'h0000};
								  //next3:
									//addi $t5 $t5 -1  0x21adffff
									RAM_data[8'd43] <= {6'h08,5'd13,5'd13,16'hffff};
									//拆分bgez $t5 for3
									//sub $s3 $0 $t5    $s3 = -$t5  0x000b9822
                                    RAM_data[8'd44] <= {6'h00,5'd0,5'd13,5'd19,5'd0,6'h22};
									//blez $s3 offset 46->30 -16=0xfff0  0x1a60fff0
                                    RAM_data[8'd45] <= {6'h06,5'd19,5'd0,16'hfff0};
									
					//addi $t0 $t0 1  0x21080001
                    RAM_data[8'd46] <= {6'h08,5'd8,5'd8,16'h0001};
					//bne $t0 $a0 for2 48->24 -24=0xffe8  0x1504ffe8
                    RAM_data[8'd47] <= {6'h05,5'd8,5'd4,16'hffe8};
					
			  //continue:(for)
				//sll $t0 $a2 2  0x00064080
				RAM_data[8'd48] <= {6'h00,5'd0,5'd6,5'd8,5'd2,6'h00};
				//add $t0 $t0 $sp  0x011d4020
				RAM_data[8'd49] <= {6'h00,5'd8,5'd29,5'd8,5'd0,6'h20};
				//lw $v0 0($t0)  0x8d020000
				RAM_data[8'd50] <= {6'h23,5'd8,5'd2,16'h0000};
				//add $sp $sp $s2  0x03b2e820
				RAM_data[8'd51] <= {6'h00,5'd29,5'd18,5'd29,5'd0,6'h20};
				//lw $s1 0($sp)  0x8fd10000
				RAM_data[8'd52] <= {6'h23,5'd29,5'd17,16'h0000};
				//lw $s0 4($sp)  0x8fb00004
				RAM_data[8'd53] <= {6'h23,5'd29,5'd16,16'h0004};
				//lw $ra 8($sp)  0x8fbf0008
				RAM_data[8'd54] <= {6'h23,5'd29,5'd31,16'h0008};
				//addi $sp $sp 12  0x23bd000c
				RAM_data[8'd55] <= {6'h08,5'd29,5'd29,16'h000c};
				//jr $ra  0x03e00008
				RAM_data[8'd56] <= {6'h00,5'd31,15'd0,6'h08};
		end 
	end

endmodule
