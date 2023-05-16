module MAR (
    input         clk,
    input         rst_n,
    input  [15:0] control_signals,
    input  [ 7:0] mbr2mar,
    input  [ 7:0] pc2mar,
    output [ 7:0] mar_data
);
    reg [7:0] mar_data_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mar_data_reg <= 8'd0;
        end else begin
            if (control_signals[7] == 4'b1) mar_data_reg <= mbr2mar;
            else if (control_signals[3] == 4'b1) mar_data_reg <= pc2mar;
        end
    end
    assign mar_data = mar_data_reg;
endmodule
