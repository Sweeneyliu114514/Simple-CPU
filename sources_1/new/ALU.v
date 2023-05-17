module ALU (
    input                clk,
    input                rst_n,
    input                acc_alu_io_rw,    //ALU与ACC之间的IO读写控制信号,1为写ACC,0为读ACC
    input         [15:0] control_signals,  //来自CU的控制信号
    input  signed [15:0] br2alu,           //来自BR的数据
    input  signed [15:0] acc2alu,          //来自ACC的数据
    output        [15:0] alu2acc,          //输出给ACC的数据
    output        [15:0] mr_data,          //存储乘法运算结果LSB的MR
    output        [ 3:0] alu_flags
    /* 
    alu_flags为标志寄存器
    alu_flags[0]标志运算结果正负,1为负,0为正
    alu_flags[1]标志运算结果是否为零,1为零,0为非零
    alu_flags[2]标志运算结果溢出,1为溢出,0为未溢出
    alu_flags[3]标志是否启用MR存储乘法结果LSB,1为启用,0为不启用
    */
);
    reg [15:0] result_MSB, result_LSB;  //ALU的运算结果
    reg [3:0] flags_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_MSB <= 16'd0;
            result_LSB <= 16'd0;
            flags_reg  <= 4'b0010;
        end else begin
            if (control_signals[15:12] >= 1 && control_signals[15:12] <= 9) begin
                case (control_signals[15:12])
                    4'b0001: begin  //ACC置零
                        result_LSB <= 16'd0;
                        flags_reg  <= 4'b0010;
                    end
                    4'b0010: begin  //ADD
                        result_MSB   <= 16'd0;
                        result_LSB   <= acc2alu + br2alu;
                        flags_reg[0] <= result_LSB[15];
                        flags_reg[1] <= ~|result_LSB;
                        flags_reg[2] <= (acc2alu[15] == br2alu[15]) && (result_LSB[15] != acc2alu[15]);
                        flags_reg[3] <= 1'b0;
                    end
                    4'b0011: begin  //SUB
                        result_MSB   <= 16'd0;
                        result_LSB   <= acc2alu - br2alu;
                        flags_reg[0] <= result_LSB[15];
                        flags_reg[1] <= ~|result_LSB;
                        flags_reg[2] <= (acc2alu[15] != br2alu[15]) && (result_LSB[15] != acc2alu[15]);
                        flags_reg[3] <= 1'b0;
                    end
                    4'b0100: begin  //MPY
                        {result_MSB, result_LSB} <= acc2alu * br2alu;
                        flags_reg[0]             <= result_MSB[15];
                        flags_reg[1]             <= ~|{result_MSB, result_LSB};
                        flags_reg[2]             <= 1'b0;  //启用MR后乘法运算不会溢出
                        flags_reg[3]             <= 1'b1;  //启用MR存储乘法运算结果的LSB
                    end
                    4'b0101: begin  //AND
                        result_MSB     <= 16'd0;
                        result_LSB     <= acc2alu & br2alu;
                        flags_reg[0]   <= result_LSB[15];
                        flags_reg[1]   <= ~|result_LSB;
                        flags_reg[3:2] <= 2'b00;
                    end
                    4'b0110: begin  //OR
                        result_MSB     <= 16'd0;
                        result_LSB     <= acc2alu | br2alu;
                        flags_reg[0]   <= result_LSB[15];
                        flags_reg[1]   <= ~|result_LSB;
                        flags_reg[3:2] <= 2'b00;
                    end
                    4'b0111: begin  //NOT
                        result_MSB     <= 16'd0;
                        result_LSB     <= ~acc2alu;
                        flags_reg[0]   <= result_LSB[15];
                        flags_reg[1]   <= ~|result_LSB;
                        flags_reg[3:2] <= 2'b00;
                    end
                    4'b1000: begin  //SHIFTL
                        result_MSB   <= 16'd0;
                        result_LSB   <= acc2alu << 1;  //逻辑左移
                        flags_reg[0] <= result_LSB[15];
                        flags_reg[1] <= ~|result_LSB;
                        flags_reg[2] <= 1'b0;
                    end
                    4'b1001: begin  //SHIFTR
                        result_MSB     <= 16'd0;
                        result_LSB     <= acc2alu >> 1;  //逻辑右移
                        flags_reg[0]   <= result_LSB[15];
                        flags_reg[1]   <= ~|result_LSB;
                        flags_reg[3:2] <= 2'b00;
                    end
                endcase
            end
        end
    end
    assign alu2acc   = result_LSB;
    assign mr_data   = result_MSB;
    assign alu_flags = flags_reg;
endmodule
