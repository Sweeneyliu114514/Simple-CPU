module ACC (
    input         clk,
    input         rst_n,
    input         acc_alu_io_rw,    //ALU与ACC之间的IO读写控制信号,1为写ACC,0为读ACC
    input  [15:0] alu2acc,          //来自ALU的数据
    output [15:0] acc_data          //ACC的数据输出
);
    reg [15:0] acc_data_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) acc_data_reg <= 16'd0;
        else begin
            if (acc_alu_io_rw == 1'b1) acc_data_reg <= alu2acc;
        end
    end

    assign acc_data = acc_data_reg;

endmodule
