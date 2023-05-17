module CPU (
    input         clk,
    input         rst_n,
    input         continue_flag,
    input  [15:0] data_in,
    output [15:0] data_out,
    output        ram_rw,
    output [ 7:0] address,
    output [ 3:0] alu_flags,
    output [ 7:0] anode_select,
    output [ 6:0] seg_select
    
);
    wire        acc_alu_io_rw;
    wire [15:0] control_signals;
    wire [15:0] mr_data;
    wire [15:0] acc_data;
    wire [15:0] br_data;
    wire [ 7:0] ir_data;
    wire [15:0] mbr_data;
    wire [ 7:0] mar_data;
    wire [ 7:0] pc_data;
    wire [15:0] alu2acc;
    assign data_out = mbr_data;
    assign address  = mar_data;
    //raw_rw为1时cpu写ram,为0时cpu读ram
    assign ram_rw   = ({control_signals[11], control_signals[5]} == 2'b10) ? 1'b1 : 1'b0;
    //自行设置reset时数码管显示的数字
    reg [31:0] reset_num = {4'd10,4'd10,4'd1,4'd1,4'd4,4'd5,4'd1,4'd4};//aa114514
    Seg_Display seg_display_inst (
        .clk          (clk),
        .rst_n        (rst_n),
        .acc_data     (acc_data),
        .mr_data      (mr_data),
        .reset_num    (reset_num),
        .anode_select (anode_select),
        .seg_select   (seg_select)
    );
    ACC acc_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .acc_alu_io_rw  (acc_alu_io_rw),
        .alu2acc        (alu2acc),
        .acc_data       (acc_data)
    );
    ALU alu_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .acc_alu_io_rw  (acc_alu_io_rw),
        .control_signals(control_signals),
        .br2alu         (br_data),
        .acc2alu        (acc_data),
        .alu2acc        (alu2acc),
        .mr_data        (mr_data),
        .alu_flags      (alu_flags)
    );
    BR br_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .control_signals(control_signals),
        .mbr2br         (mbr_data),
        .br_data        (br_data)
    );
    CU cu_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .continue_flag  (continue_flag),
        .flags          (alu_flags),
        .ir             (ir_data),
        .acc_alu_io_rw  (acc_alu_io_rw),
        .control_signals(control_signals)
    );
    IR ir_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .control_signals(control_signals),
        .mbr2ir         (mbr_data[15:8]),
        .ir_data        (ir_data)
    );
    MAR mar_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .control_signals(control_signals),
        .mbr2mar        (mbr_data[7:0]),
        .pc2mar         (pc_data),
        .mar_data       (mar_data)
    );
    MBR mbr_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .control_signals(control_signals),
        .acc2mbr        (acc_data),
        .mem2mbr        (data_in),
        .mbr_data       (mbr_data)
    );
    PC pc_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .control_signals(control_signals),
        .mbr2pc         (mbr_data[7:0]),
        .pc_data        (pc_data)
    );
endmodule
