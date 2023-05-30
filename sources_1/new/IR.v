module IR (
    input         clk,
    input         rst_n,
    input  [15:0] control_signals,
    input  [ 7:0] mbr2ir,           //MBR->IR
    output [ 7:0] ir_data           //IR的数据输出
);
    reg [7:0] ir_data_reg;
    assign ir_data = ir_data_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ir_data_reg <= 8'd0;
        end else begin
            if (control_signals[6] == 4'b1) ir_data_reg <= mbr2ir;
        end
    end
endmodule
