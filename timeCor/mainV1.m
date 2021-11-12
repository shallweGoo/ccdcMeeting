%该函数为深度反演的主函数

%% 配置相关参数
dbstop if all error  % 方便调试

% addpath('./algoV1/timeStackOperation/');
addpath(genpath('./algoV1'));
addpath(genpath('./common'));
fold_path = "F:/workSpace/matlabWork/corNeed_imgResult/";
station_str = 'phantom4';
% 执行参数注入
eval(station_str);

% 获取处理好的时间序列数据

% 1、图片信息
id = 14;
pic_info = loadTimeStack(id, fold_path, params);
% 2、世界信息
world_info = getWorldInfo(params, pic_info);
% 3、提供计算交叉谱所需要的信息
cpsdVar.waveLow  = 0.05; %计算代表频率所要用的交叉谱频率范围
cpsdVar.waveHigh = 0.25;
cpsdVar.Fs = params.fs;%采样频率，单位hz

% prepare里面的先验参数
% N = prepare.N; % 采样点个数
% n = 0:N-1; % 采样点（向量）
% t = prepare.t; % 时间


% 设置范围数组
range = zeros(pic_info.row, pic_info.col);
point.speed = zeros(pic_info.row, pic_info.col);
point.f = zeros(pic_info.row, pic_info.col);

%  从离岸最远的像素点进行估计,顺便进行深度反演
seaDepth = NaN(pic_info.row, pic_info.col);
fixed_time = 3; %固定时间为3s，论文得到的最适合时间




% 傅里叶变换找出最相关的信号和频率
%1.确定范围：找出每个点对应最相关的点，再这个点的范围内进行估计
pic_info.waveLengthInfo = findWaveLength(pic_info);
pic_info.dist = 2; %在cross shore方向上隔多少米估计一次
pic_info.pixelResolution = 0.5; % 像素分辨率
%2、利用fft分析方法确定出一些主频和不相关的分量，学习cBathy，在一个区域内进行fft互功率谱分析，筛选相关频率
    


%% 主流程
% 对互相关进行计算（改进版，尝试每次用一列数据加快运算速度），目前失败了
% 利用一个数组来存放每一行的索引值
%设置使用的方法
%1为中点取速度法（UAV-based mapping of nearshore bathymetry over broad areas）
%2为固定时间为3s
mode = 1;

if mode == 1
    % 没见过的全新版本
%     seaDepth = correlationProcess(picInfo,cpsdVar);
    
    %旧版本
    for i = 1:pic_info.col
    %     t1 = cputime;
        [point.f(:,i), point.speed(:,i)] = corForFC(pic_info, params, i, cpsdVar);
        seaDepth(:,i) = calDepth(point.speed(:,i), point.f(:,i));
        disp(['process:' num2str(i/pic_info.col*100) '% completed']);
    %     run_time = cputime-t1;
    end
    
% 采用固定时间的方式来进行估计速度的估计
% 每一列进行范围估计

% 分辨率改了要记得该参数
elseif mode == 2
    for i = 1:pic_info.col                  
        [TimeStack1,TimeStack2] = getTimeStack(pic_info,i,fixed_time);
        res = fixedTimeForCor(TimeStack1,TimeStack2); 
        [~,idx] = max(res,[],2); %计算每行的相关系数
        idx(1:49) = nan;  %直接设置1：49为不估计的范围
        point.speed(:,i) = idx*pic_info.pixel2Distance/fixed_time;
%         point.f(:,i) = fixedTimeCorForF(idx,i,picInfo,cpsdVar);
        point.f(:,i) = fixedTimeCorForF_PS(i,pic_info,cpsdVar);
        seaDepth(:,i) = calDepth(point.speed(:,i),point.f(:,i));
        disp(['progress:' num2str(i/pic_info.col*100) '% completed']);
    end
    % 加平滑处理的过程
    
end
        
    
%% 为固定时间的结果加一个平均操作

%     mean_seaDepth = seaDepth;
%     for i = 1:picInfo.col
%         for j = 1:5:picInfo.row
%             if j+2 <= picInfo.row
%                 mean_seaDepth(j:j+5,i) = mean(seaDepth(j:j+2,i));
%             else
%                 mean_seaDepth(j:end,i) = mean(seaDepth(j:end,i));
%             end
%         end
%     end
%    
   
    

        
%% 进行plot

    
    seaDepth(imag(seaDepth)~=0) = nan; % 虚部为0的直接搞成nan
    
    figure;   
    plotBathy(world_info,seaDepth);
%     figure;
%     plotBathy(world,mean_seaDepth);
    
%% 可以进行线性插值，补上值为nan的,用中点方法计算时就会出现很多空

if mode == 1 
    %
    interpolation.seaDepth = seaDepth;
    for i = 1:pic_info.col
        interpolation.total_x = 1:pic_info.row;
        interpolation.now_y  = interpolation.seaDepth(:,i)';
        interpolation.temp = interpolation.now_y;
        interpolation.insert_x = find(isnan(interpolation.now_y));
        interpolation.terminate_x = find(~isnan(interpolation.now_y),1,'last');
        interpolation.first_x = find(~isnan(interpolation.now_y),1,'first');
        interpolation.insert_x_idx = find(interpolation.insert_x>=interpolation.first_x & interpolation.insert_x <= interpolation.terminate_x);
        interpolation.insert_x = interpolation.insert_x(interpolation.insert_x_idx);
        interpolation.total_x(interpolation.insert_x) = [];
        interpolation.now_y(interpolation.insert_x) = [];
        interpolation.insert_y = interp1(interpolation.total_x,interpolation.now_y,interpolation.insert_x,'nearest');
        interpolation.temp(interpolation.insert_x) = interpolation.insert_y;
        interpolation.seaDepth(:,i) = interpolation.temp;
    end
    figure;
    plotBathy(world_info,interpolation.seaDepth);
end
   





            
            









    

    
    
  
    
    