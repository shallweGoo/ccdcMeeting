%由于波长不是先验已知的，那么就要选取一个范围，选取的原则在于这个信号和另一个信号互相关的值最大
%获得波长之后进行速度和频率的估计
%需要改进!
function [range,speed,f] = selectRangeAndMidSpeedAndFrequence(picInfo,posReference,cpsdVar)%posRef为参考点,根据位置选取目标点，位置信息实际上包含了x和y信息，x为longShore方向,y为crossShore方向
%% 该版本考虑固定波长（40m），每次5米进行分析   
    %预分配内存
    %要计算几个像素点就分配几个内存
    
    PixelNum = 8;
    corVal = zeros(1,PixelNum+1);%用于储存从s1到向岸传播每个像素点的互相关最大值
    timeLag = zeros(1,PixelNum+1);%用于储存时间信息
    shoreDistance = zeros(1,PixelNum+1);%用于储存距离信息
    count = 2;
    
    pixelInterval = 5;  %每次隔几个像素点
    if(posReference.y-PixelNum*pixelInterval>=1)
        for i = posReference.y-pixelInterval:-pixelInterval:posReference.y-PixelNum*pixelInterval %中间的间隔用于观察隔几个像素点进行一次统计(5m),4个点，对应0.5s
            posTarget = getSignalAndSetInfo(picInfo,i,posReference.x);
            [corVal(count),timeLag(count)]=correlationCalc(posReference.signal,posTarget.signal,picInfo.timeInterval);
            count = count+1;
        end
    else 
        range = nan;
        speed = nan;
        f = nan;
        return;
    end

    %进行代表频率f_ref的计算
    f = ForMidPoint_f(posReference.signal,posTarget.signal,cpsdVar);

    
%   直接默认波长进行计算
    range  = 0;
   
    shoreDistance(2:PixelNum+1) = (1:PixelNum)*picInfo.pixel2Distance*pixelInterval; %用于距离的估算
    plot(abs(timeLag),shoreDistance,'r.');
    speed = polyfit(abs(timeLag),shoreDistance,1); % 拟合进行中点处速度的计算 abs()可以考虑在互相关计算函数中加 
 %% 以下为论文方法寻找最大互相关的范围，然后进行估计
 
%         corVal = zeros(1,posReference.y - 1);%用于储存从s1到向岸传播每个像素点的互相关最大值
%         timeLag = zeros(1,posReference.y - 1);%用于储存时间信息
    


    %按照论文的方法选择互相关最大值作为估计,但是与该点像素强度波动互相关最大值永远是离该点最近的下一个点，做不到论文中那种直接可以确定波长的效果
    %现考虑假设固定波长来估算
    
%     for i = posReference.y-1:-10:1 
%         posTarget = getSignalAndSetInfo(picInfo.afterFilter,i,posReference.x);
%         %如果程序正确的话,covVal存放着最大的互相关值
%         %timeLag存了互相关最大值对应的时间时间
%         [corVal(posReference.y-posTarget.y),timeLag(posReference.y-posTarget.y)]=correlationCalc(posReference.signal,posTarget.signal,picInfo.timeInterval);
%     end

% %     以下这部分是按照论文中选择一波波长范围进行估计的代码，现将其注释
%     
%     %进行代表频率f_ref的计算
%     f = ForMidPoint_f(posReference.signal,posTarget.signal,cpsdVar);
%     [~,Position] = max(corVal);%这Positon是离参考位置的距离
%     range = posReference.y-Position;%这range是目标点的像素坐标
%     shoreDistance = (1:Position)*picInfo.pixel2Distance; %用于距离的估算
%     speed = polyfit(timeLag(1:Position),shoreDistance,1); % 拟合进行中点处速度的计算  
    
   



end
    

%假设有波长为100个像素点~50m间隔，

