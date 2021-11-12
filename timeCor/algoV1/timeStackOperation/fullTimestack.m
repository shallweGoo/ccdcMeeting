%该程序为了得到所有目标图像每一列的时间堆栈图
%例如图像为361*271，一共有1000张图，那么可以得到271张时间序列的图(TimeStack)
% clc
% 

function fullTimestack(fileInfo)
    % fileInfo.file_path="F:\workSpace\matlabWork\dispersion\selectPic\afterPer\双月湾第二组变换后\变换后图片3\";
    % addpath(fileInfo.file_path);
    % fileInfo.pic_name = string(ls(fileInfo.file_path));
    % fileInfo.pic_name = fileInfo.pic_name(3:end);
    % fileInfo.pic_num = size(fileInfo.pic_name,1);
    % src=imread(fileInfo.pic_name(1));
    % [picInfo.row,picInfo.col] = size(src);
    TimeStack.pic_num = fileInfo.org_imag.pic_col;
    TimeStack.timestack = cell(1,TimeStack.pic_num);

%每张图片读取一列
    for i = 1:fileInfo.org_imag.pic_num
        temp_pic = imread(fileInfo.org_imag.file_path+fileInfo.org_imag.pic_name(i));
        for j = 1:fileInfo.org_imag.pic_col
            TimeStack.timestack{j}(:,i) = temp_pic(:,j);
        end
    end

%存为.mat文件，要是存为图片格式文件会报错
% for i = 1:TimeStack.pic_num
%     row_timestack = TimeStack.timestack{i};
%     save("..\selectPic\afterPer\双月湾第二组变换后\变换后图片3相关处理\变换后图片3时间堆栈\"+"col"+num2str(i)+".mat","row_timestack");
% end

    target_dir = fileInfo.file_dir.dir_name + fileInfo.file_dir.res_dir(1) + "\";
    for i = 1 : TimeStack.pic_num
        row_timestack = TimeStack.timestack{i};
        save(target_dir+"col"+num2str(i)+".mat", "row_timestack");
    end
end
    

    
    