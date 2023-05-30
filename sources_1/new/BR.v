module BR (
    input                clk,
    input                rst_n,
    input         [15:0] control_signals,
    input         [15:0] mbr2br,
    output signed [15:0] br_data
);
    reg [15:0] br_data_reg;
    assign br_data = br_data_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            br_data_reg <= 16'd0;
        end 
        else begin
            if (control_signals[8] == 1'b1) br_data_reg <= mbr2br;
        end
    end
endmodule
