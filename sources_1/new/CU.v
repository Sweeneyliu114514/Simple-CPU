module CU (
    input         clk,
    input         rst_n,
    input         continue_flag,   //外部按钮输入,决定在HALT后是否继续执行后面的指令
    input  [ 3:0] flags,           //ALU的标志寄存器
    input  [ 7:0] ir,              //指令寄存器IR
    output        acc_alu_io_rw,   //ALU与ACC之间的IO读写控制信号,1为写ACC,0为读ACC
    output [15:0] control_signals  //生成的控制信号

);
    reg  [ 7:0] CAR_Inc;  //CAR++
    reg  [ 7:0] Opcode_mapped;  //Opcode映射后的值
    wire [15:0] CBR;  //Control Bus Register
    reg  [ 7:0] CAR;  //Control Address Register
    reg         flag;
    // ALU与ACC之间的IO读写控制信号的生成逻辑，由于控制信号均维持两个时钟周期，
    // 因此可以在涉及ACC和BR的算术逻辑微操作的控制信号发出后,在其前一个时钟周期
    // 将acc_alu_io_rw置为0,将ACC的值读出至ALU,在其后一个时钟周期将acc_alu_io_rw
    // 置为1,将ALU的运算结果写入ACC 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) flag <= 1'b0;
        else begin
            if (CBR[15:12] != 4'b0000) flag <= ~flag;
            else flag <= 1'b0;
        end
    end
    assign acc_alu_io_rw = flag;
    //Contorl Memory调用ROM IP核实现,CAR作为ROM的地址,输出CBR
    cu_rom control_memory (
        .clka (clk),  // input wire clka
        .addra(CAR),  // input wire [7 : 0] addra
        .ena  (1),    // input wire ena
        .douta(CBR)   // output wire [15 : 0] douta
    );
    assign control_signals = CBR;
    //Opcode映射逻辑,根据IR的值决定Opcode映射后的值
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            CAR_Inc       <= 8'd0;
            Opcode_mapped <= 8'd0;
        end else begin
            CAR_Inc <= CAR + 8'd1;  //CAR自加一,作为MUX中三个输入之一
            case (ir)  //mapping logic between IR and CAR
                8'h01:   Opcode_mapped <= 8'd4;  //STORE X
                8'h02:   Opcode_mapped <= 8'd7;  //LOAD X
                8'h03:   Opcode_mapped <= 8'd11;  //ADD X
                8'h04:   Opcode_mapped <= 8'd15;  //SUB X
                8'h05:  //JMPGEZ X
                begin
                    if (flags[0] == 1'b0) Opcode_mapped <= 8'd19;  //ACC>=0,JMP X
                    else Opcode_mapped <= 8'd20;  //ACC<0,PC++
                end
                8'h06:   Opcode_mapped <= 8'd19;  //JMP X
                8'h07:   Opcode_mapped <= 8'd21;  //HALT
                8'h08:   Opcode_mapped <= 8'd23;  //MPY X
                8'h09:   Opcode_mapped <= 8'd27;  //AND X
                8'h0A:   Opcode_mapped <= 8'd31;  //OR X
                8'h0B:   Opcode_mapped <= 8'd35;  //NOT X
                8'h0C:   Opcode_mapped <= 8'd40;  //SHIFTR X
                8'h0D:   Opcode_mapped <= 8'd47;  //SHIFIL X
                default: Opcode_mapped <= 8'h00;  //回到取指令的地址处
            endcase
        end
    end
    //CAR的控制逻辑,根据CBR低三位的值决定CAR下一时刻的值,即数据选择器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            CAR <= 8'd0;
        end else begin
            if (CBR[0] == 1'b1) CAR <= CAR_Inc;  //CAR++
            else if (CBR[1] == 1'b1) CAR <= Opcode_mapped;  //CAR跳转到Opcode映射后的地址
            else if (CBR[2] == 1'b1) CAR <= 8'd0;  //CAR置零
            //若CBR均为0说明当前指令为HALT,需要根据外部按键决定是否退出HALT状态,继续执行下一条指令
            else begin
                //对应按钮按下,退出HALT状态,继续执行下一条指令
                if (continue_flag == 1'b1) CAR <= 8'd0;
                //没有按钮按下,继续保持HALT状态,CAR不变 
                else
                    CAR <= CAR;
            end
        end
    end

endmodule
