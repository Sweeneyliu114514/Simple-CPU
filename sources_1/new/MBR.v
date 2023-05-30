module MBR (
    input         clk,
    input         rst_n,
    input  [15:0] control_signals,
    input  [15:0] acc2mbr,
    input  [15:0] mem2mbr,          //从RAM中读取的指令
    output [15:0] mbr_data          //MBR的数据输出
);
    reg [15:0] mbr_data_reg;
    assign mbr_data = mbr_data_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mbr_data_reg <= 16'd0;
        end else begin
            if (control_signals[10] == 1'b1) mbr_data_reg <= acc2mbr;
            else if (control_signals[5] == 1'b1) mbr_data_reg <= mem2mbr;
        end
    end
endmodule
