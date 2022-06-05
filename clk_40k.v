module clk_40k(
    clk, 
    reset, 
    clk_40K
);

input           clk;
input           reset;
output          clk_40K;

reg             clk_40K;

parameter   CNT = 16'd1250;

reg     [15:0]  count;

always @(posedge clk or posedge reset)
begin
    if(reset) begin
        clk_40K <= 1'b0;
        count <= 16'd0;
    end
    else begin
        count <= (count==CNT-16'd1) ? 16'd0 : count + 16'd1;
        clk_40K <= (count==16'd0) ? ~clk_40K : clk_40K;
    end
end

endmodule