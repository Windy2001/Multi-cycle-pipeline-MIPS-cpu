`timescale 1ns / 1ps
module test_cpu();
    
    reg reset;
    reg clk;
    wire [3:0] an;
    wire [7:0] Cathodes;
    
    PipelineCPU PipelineCPU_1(reset, clk,an,Cathodes);
    
    initial begin
        reset = 1;
        clk = 1;
        #100 reset = 0;
    end
    
    always #50 clk = ~clk;
    
endmodule
