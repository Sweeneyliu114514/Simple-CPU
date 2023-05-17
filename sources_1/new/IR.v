module IR (
    input         clk,
    input         rst_n,
    input  [15:0] control_signals,
    input  [ 7:0] mbr2ir,
    output [ 7:0] ir_data
);
    reg [7:0] ir_data_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) ir_data_reg <= 8'd0;
        else if (control_signals[6] == 4'b1) ir_data_reg <= mbr2ir;
    end
    assign ir_data = ir_data_reg;
endmodule
