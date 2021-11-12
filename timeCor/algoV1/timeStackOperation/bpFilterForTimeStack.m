%该脚本为时间堆栈数据进行带通滤波
%存储每一列的时间堆栈滤完波之后的信号


function bpFilterForTimeStack(fileInfo)
%     clear;
%     clc;
%     fileInfo.file_path = "..\selectPic\afterPer\双月湾第二组变换后\变换后图片2相关处理\变换后图片2时间堆栈\";
%     addpath(fileInfo.file_path);
%     fileInfo.file_name = string(ls(fileInfo.file_path));
%     fileInfo.file_name = fileInfo.file_name(3:end);
%     fileInfo.file_num = size(fileInfo.file_name,1);
%     src = load(fileInfo.file_path+fileInfo.file_name(1));
%     [timeStack.row,timeStack.col] = size(src.row_timestack);

    filter_len = length(fileInfo.bp_filter.used_filter.bpfilter);
    bpfilter = fileInfo.bp_filter.used_filter.bpfilter;
    afterFilt = zeros(fileInfo.org_imag.pic_row, fileInfo.org_imag.pic_num);
    filter_half =  floor(filter_len/2);
    f_start = filter_half + 1;
    % 对每一个时间堆栈数据进行0.05-0.5hz的滤波,注意在设计滤波器时所选择的采样频率
    target_dir_filter = fileInfo.bp_filter.file_path;
%     target_dir_part = fileInfo.partition.file_path;
    
    for i = 1:fileInfo.time_stack.file_num
        row_data = load(fileInfo.time_stack.file_path+"col"+num2str(i)+".mat"); %原始数据
        det_data = detrend(double(row_data.row_timestack)')';% 去除趋势化(师兄说这样可以去除直流分量)经过测试果然可以，值得学习
        
        for j = 1:fileInfo.org_imag.pic_row
            temp = [det_data(j,:),zeros(1,filter_len)]; %滤波过程
            temp = filter(bpfilter,1,temp); 
            afterFilt(j,:) = temp(f_start:fileInfo.org_imag.pic_num+filter_half);
        end
        
%         part = afterFilt(:,fileInfo.partition.begin:fileInfo.partition.end); %截取部分
        save(target_dir_filter+"col"+num2str(i)+".mat","afterFilt");
%         save(target_dir_part+"col"+num2str(i)+".mat","part");
    end
end

