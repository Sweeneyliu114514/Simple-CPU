clc;
fileID = fopen('ram_test_lxx.coe', 'w');
% 写关键字
fprintf(fileID, 'memory_initialization_radix=16;\n');
fprintf(fileID, 'memory_initialization_vector=\n');

code_seg_start = 0;
code_seg_end = 122;% 该参数根据需要测试的汇编指令数目进行修改,这里是测试了123条指令
initial_data_num = 101;
initial_data_start = 131; % 存放初始数据的起始地址
initial_data_end = initial_data_start+initial_data_num-1;% 231
result_start = initial_data_start+initial_data_num; % 232
%%% 写入指令
% 将1 LOAD进ACC
fprintf(fileID,append('02',string(dec2hex(initial_data_start,2)),',\n'));
% 从1加到100，共99次ADD
for i = initial_data_start+1:result_start-2 
    fprintf(fileID,append('03',string(dec2hex(i,2)),',\n'));
end
% 将1加到100的结果5050存入到地址232
fprintf(fileID,append('01',string(dec2hex(result_start,2)),',\n'));
% HALT暂停
fprintf(fileID,'0700,\n' );
% 将1加到100的结果算术右移一位,即2525/09ddH,地址保持232不变
fprintf(fileID,append('0C',string(dec2hex(result_start,2)),',\n'));
fprintf(fileID,'0700,\n' );
% 将1加到100的结果算术左移一位,即5050/13baH,地址保持232不变
fprintf(fileID,append('0D',string(dec2hex(result_start,2)),',\n'));
fprintf(fileID,'0700,\n' );
% 将5050按位取反,即-5051/ec45H,将结果存入地址233
fprintf(fileID,append('0B',string(dec2hex(result_start,2)),',\n'));
fprintf(fileID,append('01',string(dec2hex(result_start+1,2)),',\n'));
fprintf(fileID,'0700,\n' );
% 将-5051减去100,即-5151/ebe1H,将结果存入地址234
fprintf(fileID,append('02',string(dec2hex(result_start+1,2)),',\n'));%LOAD -5051进ACC
fprintf(fileID,append('04',string(dec2hex(initial_data_end-1,2)),',\n'));
fprintf(fileID,append('01',string(dec2hex(result_start+2,2)),',\n'));
fprintf(fileID,'0700,\n' );
% 将-5151乘以-5051,即018c_ffa5H
fprintf(fileID,append('02',string(dec2hex(result_start+2,2)),',\n'));%LOAD -5151进ACC
fprintf(fileID,append('08',string(dec2hex(result_start+1,2)),',\n'));
fprintf(fileID,'0700,\n' );
% 加法溢出测试,使用32767(16位有符号数最大正数)加上1,得到-32768/8000H,显然结果是错误的,发生溢出,结果存入地址235
fprintf(fileID,append('02',string(dec2hex(initial_data_end,2)),',\n'));%LOAD 32767进ACC
fprintf(fileID,append('03',string(dec2hex(initial_data_start,2)),',\n'));
fprintf(fileID,append('01',string(dec2hex(result_start+3,2)),',\n'));
fprintf(fileID,'0700,\n' );
% 将-32768按位取反,即32767/7fffH
fprintf(fileID,append('0B',string(dec2hex(result_start+3,2)),',\n'));
fprintf(fileID,'0700,\n' );
% JMPGEZ测试,跳转至地址0
fprintf(fileID,append('0500',',\n'));
% 将指令与数据之间的存储器空间填充为0
for i = code_seg_end+1:initial_data_start-1
    fprintf(fileID,'0000,\n' );
end

%%% 写入数据
% 将1至100存入地址131~230
for j = 1:initial_data_num-1
    fprintf(fileID,append(string(dec2hex(j,4)),',\n'));
end
% 将32767存入地址231
fprintf(fileID,append(string(dec2hex(32767,4)),';'));
fclose(fileID);