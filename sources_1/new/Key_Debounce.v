module Key_Debounce (
    input  clk,
    input  rst_n,
    input  key_in,   //按键输入
    output key_flag  //消抖后的按键输出,消去前抖动,有按键按下时由0变为1且只保持一个时钟周期
);
    //系统时钟频率,单位为MHz
    parameter sys_clk_freq = 32'd10;  
    //按键保持时间,单位为us,根据测试按钮的保持时间最好设置为20ms,若进行仿真测试,可设置为1us
    parameter hold_time = 32'd1;  
    reg [31:0] cnt_max = sys_clk_freq * hold_time;
    reg [31:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cnt <= 31'd0;
        else begin
            if (key_in == 1'b0) cnt <= 31'd0;
            else if (key_in == 1'b1 && cnt == cnt_max) cnt <= cnt;
            else cnt <= cnt + 31'd1;
        end
    end
    assign key_flag = (cnt == cnt_max - 1) ? 1'b1 : 1'b0;
endmodule
