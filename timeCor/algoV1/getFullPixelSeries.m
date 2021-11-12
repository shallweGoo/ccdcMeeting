function getFullPixelSeries(picInfo,world,cpsdVar)

%% 先进行图片基本信息的录入
%  picInfo.file_path =  "F:\workSpace\matlabWork\dispersion\selectPic\afterPer\双月湾第二组变换后\变换后图片1\";% 图像文件夹路径
%  对应组别序号
%      picInfo.idx = 14;
     picInfo.idx = num2str(picInfo.idx);

     picInfo.file_path =  "F:\workSpace\matlabWork\dispersion\selectPic\afterPer\双月湾第二组变换后\变换后图片"+picInfo.idx+"\";% 图像文件夹路径

     picInfo.allPic = string(ls(picInfo.file_path));%直接包括所有的文件名
     picInfo.allPic = picInfo.allPic(3:end);

     picInfo.picnum = size(picInfo.allPic,1);%统计所有照片的数量

     src=imread(picInfo.file_path+picInfo.allPic(1));
     [picInfo.row,picInfo.col] = size(src);
     clear src;

    cpsdVar.windowLen = round(picInfo.picnum/4);
    cpsdVar.winOverLap = round(cpsdVar.windowLen * 0.8);
    cpsdVar.f = 400;%点数为f/2

%     world.crossShoreRange = 180;
%     world.longShoreRange = 135;

    % if picInfo.idx == '1' || picInfo.idx == '9'
    %     %进行频率估计所需要的结构体
    %     cpsdVar.Fs = 2;%采样频率，单位hz
    %     picInfo.timeInterval = 1/cpsdVar.Fs; %单位s 
    %     picInfo.pixel2Distance = 0.5; %单位米
    % elseif picInfo.idx == '2'
    %     cpsdVar.Fs = 6;%采样频率，单位hz
    %     picInfo.timeInterval = 1/cpsdVar.Fs; %单位s 
    %     picInfo.pixel2Distance = 0.2; %单位米
    % else
    %     cpsdVar.Fs = 6;%采样频率，单位hz
    %     picInfo.timeInterval = 1/cpsdVar.Fs; %单位s 
    %     picInfo.pixel2Distance = 0.5; %单位米
    %     if picInfo.idx == '4'
    %         world.crossShoreRange = 180;
    %         world.longShoreRange = 100;
    %     elseif picInfo.idx == '5'|| picInfo.idx == '6'
    %         world.crossShoreRange = 215;
    %         world.longShoreRange = 115;
    %     end
    % end


    % 频率选择的区间影响很大
    cpsdVar.waveLow  = 0.05;
    cpsdVar.waveHigh = 0.2;


    %画图所需世界坐标信息，之前用的范围
    %     world.crossShoreRange = 200;
    %     world.longShoreRange = 90;



        %对于组别不同的取值范围，明确为：

        % 后两次的数据范围
    cpsdVar.Fs = 2;%采样频率，单位hz
    picInfo.timeInterval = 1/cpsdVar.Fs; %单位s 
    picInfo.pixel2Distance = 0.5; %单位米


%     world.crossShoreRange = 200;
%     world.longShoreRange = 100;

%     world.x = 0:picInfo.pixel2Distance:world.longShoreRange;
%     world.y = 0:picInfo.pixel2Distance:world.crossShoreRange;

    %% 直接读存储好的数据
    % 之前版本的数据来源
    % data = load("./someRes/afterFilter1_1000.mat");
    % picInfo.afterFilter = data.afterFilter;


    % 用timeStack系列获取的数据来源
    % load("./timeStackOperation/data_cell_normalized.mat");
    load("F:\workSpace\matlabWork\dispersion\selectPic\afterPer\双月湾第二组变换后\变换后图片"+picInfo.idx+"相关处理\最终元胞数据\data_cell_det&nor.mat");
    picInfo.afterFilter = usefulData;



    % 用不滤波版本的timeStack系列获取的数据来源 600个点 300s(400-1000)
    % data = load("./timeStackOperation/data_cell_detrend_normalized3.mat");
    % picInfo.afterFilter = data.usefulData;



    clear data;
    clear usefulData;





    %% main 获取每个像素点的时间序列

    % Time = zeros(1,picInfo.picnum);
    % for i = 1:picInfo.picnum
    %     Time(i)=i*picInfo.timeInterval;
    % end



    %% 图片预处理（带通滤波）（在我理解来是对每个像素点的时间序列进行滤波）,保存下来了建议直接load
    % PixelSeries = readData(picInfo);
    % afterFilter = cell(picInfo.row,picInfo.col);
    % load('testLp2_0.5_0.6.mat');
    % % load('bpFilter0.05_0.5Fs2.mat');
    % filter_len = size(test,2);
    % for i = 1 : picInfo.col
    %     for j = 1 : picInfo.row
    %     beforeFilterData = createSignal(PixelSeries,j,i);
    %     beforeFilterData = [beforeFilterData,zeros(1,filter_len)];
    %     afterFilter{j,i} = filter(test,1,beforeFilterData); 
    %     afterFilter{j,i} = afterFilter{j,i}(filter_len/2+1:picInfo.picnum+filter_len/2);
    %     afterFilter{j,i} = detrend(afterFilter{j,i}./255);
    %     afterFilter{j,i} = afterFilter{j,i}(1:1000); %发现取1000个点是比较好的
    %     end
    % end
    % picInfo.afterFilter = afterFilter;



    %% 这一段程序放在了getFullPixelSeries中，在main里直接load（DetrendAndNormalize.mat）即可
    % % 不滤波直接计算
    % % 没有滤波的元胞
    % DetrendAndNormalize = cell(height,width);
    % PixelSeries = readData(file_path,allPic,picnum,height,width);  %读取时间序列的函数可能存在可以改进的地方，利用列向量整列计算
    % for i = 1 : width
    %     for j = 1 : height
    %     DetrendAndNormalize{j,i} = createSignal(PixelSeries,j,i);
    %     DetrendAndNormalize{j,i} = detrend(DetrendAndNormalize{j,i})/255;
    %     end
    % end

    %% 删一些临时变量
    %     clear src;
    %     clear data;
end