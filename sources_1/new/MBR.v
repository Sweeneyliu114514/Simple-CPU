module MBR (
    input         clk,
    input         rst_n,
    input  [15:0] control_signals,
    input  [15:0] acc2mbr,
    input  [15:0] mem2mbr,
    output [15:0] mbr_data
);
    reg [15:0] mbr_data_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) mbr_data_reg <= 16'd0;
        else begin
            if (control_signals[10] == 1'b1) mbr_data_reg <= acc2mbr;
            else if (control_signals[5] == 1'b1) mbr_data_reg <= mem2mbr;
        end
    end
    assign mbr_data = mbr_data_reg;
endmodule
