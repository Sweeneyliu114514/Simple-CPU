module PC (
    input         clk,
    input         rst_n,
    input  [15:0] control_signals,
    input  [ 7:0] mbr2pc,
    output [ 7:0] pc_data
);
    reg [7:0] pc_data_reg;
    reg       flag;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_data_reg <= 8'd0;
            flag        <= 1'b0;
        end 
        else begin
            if (control_signals[9] == 4'b1) pc_data_reg <= mbr2pc;
            else if (control_signals[4] == 4'b1) begin
                if (flag == 1'b0) pc_data_reg <= pc_data_reg + 8'd1;
                flag <= ~flag;
                /* 控制信号每两个时钟周期改变一次,为了防止PC多加一次1需要设置flag判断 */
            end
        end
    end
    assign pc_data = pc_data_reg;
endmodule
