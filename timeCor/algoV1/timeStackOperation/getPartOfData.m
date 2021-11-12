% 该函数进行数据截断，信号开始和结尾的地方可能从波形上看来不太好，尝试用中间一段

clc
clear;
%%  选点进行估计，尝试用Interval的范围进行运算
fileInfo.file_path = "..\selectPic\afterPer\双月湾第二组变换后\变换后图片3相关处理\变换后图片3带通滤波\";
addpath(fileInfo.file_path);
fileInfo.file_name = string(ls(fileInfo.file_path));
fileInfo.file_name = fileInfo.file_name(3:end);
fileInfo.file_num = size(fileInfo.file_name,1);

src = load(fileInfo.file_path+fileInfo.file_name(1));
[timeStack.row,timeStack.col] = size(src.afterFilt);
clear src;


%信号区间的选择
Interval = 100:900;
%

part = zeros(timeStack.row,Interval(end)-Interval(1)+1);


temp = fileInfo.file_path;
%% 总体数据没有detrend,然后进行截断版本

for i = 1:fileInfo.file_num
        load(temp+"col"+num2str(i)+".mat"); %原始数据
        row_data = afterFilt;
    parfor j = 1:timeStack.row
        part(j,:) = row_data(j,Interval);
    end
        save("..\selectPic\afterPer\双月湾第二组变换后\变换后图片2相关处理\变换后图片3数据截断\数据截断1\col"+num2str(i)+".mat","part");
end



%% 总体detrend然后进行截断版本
% for i = 1:fileInfo.file_num
%     load(temp+"col"+num2str(i)+".mat"); %原始数据
%     row_data = afterFilt;
%     row_data = detrend(row_data')';
%     parfor j = 1:timeStack.row
%         part(j,:) = row_data(j,Interval);
%     end
%         save("F:\workSpace\matlabWork\dispersion\selectPic\afterPer\双月湾第二组变换后\数据截断5\col"+num2str(i)+".mat","part");
% end


