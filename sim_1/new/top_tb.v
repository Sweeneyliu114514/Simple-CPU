`timescale 1ns / 1ps
module top_tb ();
    reg        clk_100MHz;
    reg        rst_n;
    reg        continue_btn;
    wire [3:0] alu_flags;
    Top top_inst (
        .clk_100MHz  (clk_100MHz),
        .rst_n       (rst_n),
        .continue_btn(continue_btn),
        .alu_flags   (alu_flags)
    );
    always #5 clk_100MHz = ~clk_100MHz;
    initial begin
        clk_100MHz   = 0;
        rst_n        = 1'b1;
        continue_btn = 1'b0;
        #2000 rst_n = 1'b0;
        #1000 rst_n = 1'b1;
        #170000 continue_btn = 1'b1;//将5050算术右移一位即2525
        #1500 continue_btn = 1'b0;
        #5000 continue_btn = 1'b1;//将5050算术左移一位即5050
        #1500 continue_btn = 1'b0;
        #5000 continue_btn = 1'b1;//将5050按位取反即-5051
        #1500 continue_btn = 1'b0;
        #5000 continue_btn = 1'b1;//将-5051减去100即-5151
        #1500 continue_btn = 1'b0;
        #5000 continue_btn = 1'b1;//将-5151乘以-5050即018C_FFA5
        #1500 continue_btn = 1'b0;
        #5000 continue_btn = 1'b1;//加法溢出测试,使用32767(16位有符号数最大正数)加上1,得到-32768
        #1500 continue_btn = 1'b0;
        #5000 continue_btn = 1'b1;//将-32768按位取反,即32767
        #1500 continue_btn = 1'b0;
        #5000 continue_btn = 1'b1;//JMPGEZ测试,跳转至地址0
        #1500 continue_btn = 1'b0;
    end
endmodule
