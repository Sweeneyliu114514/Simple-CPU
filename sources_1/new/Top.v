module Top (
    input        clk_100MHz,
    input        rst_n,
    input        continue_btn,
    output       continue_btn_indicator,
    output       rst_indicator,
    output       clk_locked,
    output [7:0] anode_select,            //数码管位选信号,低电平选中
    output [6:0] seg_select,              //数码管段选信号,低电平点亮
    output [3:0] alu_flags                //ALU的标志寄存器
);
    wire [15:0] data_in;
    wire [15:0] data_out;
    wire [ 7:0] address;
    wire        ram_rw;
    wire        continue_flag;
    assign continue_btn_indicator = continue_btn;
    assign rst_indicator          = rst_n;
    wire clk;
    clk_wiz_0 clk_div (
        // Clock out ports
        .clk_out1(clk),         // output clk_out1
        // Status and control signals
        .reset   (1'b0),        // input reset
        .locked  (clk_locked),  // output locked
        // Clock in ports
        .clk_in1 (clk_100MHz)
    );  // input clk_in1
    CPU cpu_inst (
        .clk          (clk),
        .rst_n        (rst_n),
        .continue_flag(continue_flag),
        .data_in      (data_in),
        .data_out     (data_out),
        .ram_rw       (ram_rw),
        .address      (address),
        .alu_flags    (alu_flags),
        .anode_select (anode_select),
        .seg_select   (seg_select)
    );
    cpu_ram ram_inst (
        .clka (clk),       // input wire clka
        .ena  (1),         // input wire ena
        .wea  (ram_rw),    // input wire [0 : 0] wea
        .addra(address),   // input wire [7 : 0] addra
        .dina (data_out),  // input wire [15 : 0] dina
        .douta(data_in)    // output wire [15 : 0] douta
    );
    Key_Debounce continue_btn_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .key_in  (continue_btn),
        .key_flag(continue_flag)
    );


endmodule
