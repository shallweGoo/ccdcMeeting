function getSignalFromTimeStack(fileInfo,pattern)

% pattern 模式说明
% pattern == 0 为3维数组版本
% pattern == 1 为未归一化元胞版本
% == 2,为归一化版本


if nargin<2
    pattern = 2;
end

%从截取的信号的文件夹中获取整张图片信号
% fileInfo.file_path = "..\selectPic\afterPer\双月湾第二组变换后\变换后图片2相关处理\变换后图片2数据截断\数据截断1\";
% % addpath(fileInfo.file_path);
% fileInfo.file_name = string(ls(fileInfo.file_path));
% fileInfo.file_name = fileInfo.file_name(3:end);
% fileInfo.file_num = size(fileInfo.file_name,1); 

% src = load(fileInfo.file_path+fileInfo.file_name(1));
% [timeStack.row,timeStack.col] = size(src.part);

% 图片大小为361*271

% 从原来的程序改进，尝试用一个三维数组存储数据,不知道能不能提高效率
% usefulData = zeros(361,271,timeStack.col);


% 元胞数组版本
% org_path ="..\selectPic\afterPer\双月湾第二组变换后\变换后图片2\";
% org_name = string(ls(org_path));
% org_name = org_name(3:end);
% org = imread(org_path+org_name(1));

% 数据结构初始化
% usefulData = cell(fileInfo.org_imag.pic_row,fileInfo.org_imag.pic_col);

% if isfield(fileInfo,'time_lag')
%     beforeData = cell(fileInfo.org_imag.pic_row,fileInfo.org_imag.pic_col);
%     afterData = cell(fileInfo.org_imag.pic_row,fileInfo.org_imag.pic_col);
% end



% temp = fileInfo.partition.file_path; %减少开销
temp = fileInfo.bp_filter.file_path;





switch pattern 
    case 0
    % 3维数组版本数据，之后需要reshape
        for i = 1:fileInfo.time_stack.file_num
            mat_file = load(temp+"col"+num2str(i)+".mat"); %数据的mat格式文件
            usefulData{:,i} = mat_file.part;
        end
    case 1
    % 元胞数组版本，需要双循环，索引方便（还是感觉元胞数组这个数据结构方便使用） 未归一化
    temp = fileInfo.file_path; %减少开销
        for i = 1:fileInfo.time_stack.file_num
            mat_file = load(temp+"col"+num2str(i)+".mat"); %数据的mat格式文件
            temp_mat = mat_file.part;
            for j= 1:size(temp_mat,1)
                usefulData{j,i} = temp_mat(j,:);
            end
        end
    case 2
    % 元胞数组版本归一化版本，需要双循环，索引方便（还是感觉元胞数组这个数据结构方便使用） v1.0
    % 2021.05.26：结果改为数组版本
        for i = 1 :fileInfo.time_stack.file_num
            
            mat_file = load(temp+"col"+num2str(i)+".mat"); %数据的mat格式文件
%             temp_mat = mat_file.part;
            temp_mat = mat_file.afterFilt;
            for j= 1:size(temp_mat,1)
                signal =  temp_mat(j,:)./max(abs(temp_mat(j,:)));
%                 usefulData{j,i} = signal;
                usefulData(j,i,:) = signal;
                if isfield(fileInfo,'time_lag')
                    if mod(fileInfo.time_lag.timelag,fileInfo.time_lag.delta_t) ~= 0
                        error("you need to reselect fixed_time in interval time's integer multiple");
                    end
                    beforeData(j,i,:) = signal(:,1:end-fileInfo.time_lag.timelag/fileInfo.time_lag.delta_t);
                    afterData(j,i,:) = signal(:,fileInfo.time_lag.timelag/fileInfo.time_lag.delta_t+1:end);
                    
               end
            end
            
            disp("data prepare" + num2str(i/fileInfo.time_stack.file_num*100) + "% completed ..." ) ;
        end
end

target_dir = fileInfo.create_cell.file_path;
save(target_dir + "data_cell_det&nor.mat","usefulData"); %得到去直流分量（0频）并归一化的数据

if isfield(fileInfo, 'time_lag')
    target_dir = fileInfo.time_lag.file_path;
    save(target_dir + fileInfo.time_lag.save_name_before,"beforeData"); %得到前三秒数据，(先发生)
    save(target_dir + fileInfo.time_lag.save_name_after,"afterData"); %得到后三秒数据,(后发生)
end

end