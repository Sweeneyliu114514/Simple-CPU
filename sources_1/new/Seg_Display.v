module Seg_Display (
    input         clk,
    input         rst_n,
    input  [15:0] acc_data,      //后四个数码管显示ACC数据,按照十六进制显示
    input  [15:0] mr_data,       //前四个数码管显示MR数据,按照十六进制显示
    input  [31:0] reset_num,     //按下复位键时数码管显示的数字,按照十六进制显示
    output [ 7:0] anode_select,  //数码管位选信号,低电平选中
    output [ 6:0] seg_select     //数码管段选信号,低电平点亮
);
    reg [7:0] anode_select_reg;
    reg [6:0] seg_select_reg;
    assign anode_select = anode_select_reg;
    assign seg_select   = seg_select_reg;
    parameter sys_clk_freq = 32'd10_000_000;  //系统时钟频率,单位为Hz
    parameter refresh_freq = 32'd75;  //数码管刷新频率,单位为Hz,这里设置为75Hz,即每个数码管刷新周期为13.33ms
    reg [31:0] cnt_max = sys_clk_freq / (8 * refresh_freq);  //计数器最大值
    reg [31:0] cnt;
    reg        clk_refresh;  //用于动态刷新数码管的时钟信号
    //时钟分频,用于产生动态刷新数码管的时钟信号
    always @(posedge clk) begin
        if (cnt == 32'd0) begin
            cnt         <= 32'd1;
            clk_refresh <= 1'b0;
        end else begin
            if (cnt == cnt_max - 1) begin
                cnt         <= 32'd0;
                clk_refresh <= ~clk_refresh;
            end else begin
                cnt         <= cnt + 32'd1;
                clk_refresh <= clk_refresh;
            end
        end
    end
    //位选信号的循环移位,
    always @(posedge clk_refresh) begin
        if (anode_select_reg == 8'b0000_0000) anode_select_reg <= 8'b1111_1110;
        else anode_select_reg <= {anode_select_reg[6:0], anode_select_reg[7]};
    end
    reg [3:0] current_digit;  //当前位选信号对应的数码管显示的数字
    always @(*) begin
        if (!rst_n) begin  //复位时数码管显示自己设定的数字
            case (anode_select_reg)
                8'b1111_1110: current_digit <= reset_num[3:0];
                8'b1111_1101: current_digit <= reset_num[7:4];
                8'b1111_1011: current_digit <= reset_num[11:8];
                8'b1111_0111: current_digit <= reset_num[15:12];
                8'b1110_1111: current_digit <= reset_num[19:16];
                8'b1101_1111: current_digit <= reset_num[23:20];
                8'b1011_1111: current_digit <= reset_num[27:24];
                8'b0111_1111: current_digit <= reset_num[31:28];
                default: current_digit <= 4'b0000;
            endcase
        end 
        else begin  //正常运行时数码管显示ACC和MR数据
            case (anode_select_reg)
                8'b1111_1110: current_digit <= acc_data[3:0];
                8'b1111_1101: current_digit <= acc_data[7:4];
                8'b1111_1011: current_digit <= acc_data[11:8];
                8'b1111_0111: current_digit <= acc_data[15:12];
                8'b1110_1111: current_digit <= mr_data[3:0];
                8'b1101_1111: current_digit <= mr_data[7:4];
                8'b1011_1111: current_digit <= mr_data[11:8];
                8'b0111_1111: current_digit <= mr_data[15:12];
                default: current_digit <= 4'b0000;
            endcase
        end
    end
    always @(*) begin  //共阳极数码管的0~F的十六进制编码
        case (current_digit)
            4'd0: seg_select_reg <= 7'b0000001;
            4'd1: seg_select_reg <= 7'b1001111;
            4'd2: seg_select_reg <= 7'b0010010;
            4'd3: seg_select_reg <= 7'b0000110;
            4'd4: seg_select_reg <= 7'b1001100;
            4'd5: seg_select_reg <= 7'b0100100;
            4'd6: seg_select_reg <= 7'b0100000;
            4'd7: seg_select_reg <= 7'b0001111;
            4'd8: seg_select_reg <= 7'b0000000;
            4'd9: seg_select_reg <= 7'b0000100;
            4'd10: seg_select_reg <= 7'b0001000;
            4'd11: seg_select_reg <= 7'b1100000;
            4'd12: seg_select_reg <= 7'b0110001;
            4'd13: seg_select_reg <= 7'b1000010;
            4'd14: seg_select_reg <= 7'b0110000;
            4'd15: seg_select_reg <= 7'b0111000;
            default: seg_select_reg <= 7'b0000001;
        endcase
    end
endmodule
