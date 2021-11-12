%用于测试同一列不同行时间堆栈的互相关最大值，为corForFandC的测试版,pos为信号所在的行数
function [f,c] = testcorForFandC(picInfo,pos,currentCol,cpsdVar)
%     aRange = 50;%一个范围，离岸点这么近的时候就不估计了，因为图像中有岸
    
    %temp_变量为了节省用parfor下系统的开销
    temp_data = picInfo.afterFilter;
    temp_timeInterval = picInfo.timeInterval;
    
    f = nan(picInfo.row,1);
    c = nan(picInfo.row,1);
    
    
    % 设置互相关估计的距离限制，目前想的是在20个之外（10m）之外进行相关系数最大的选取
    ov_range = 50; % 想要忽视的距离
    
    
    
      i = pos ;%从第最后一行开始向前计算

%     for i = aRange:picInfo.row %从第一行开始向后计算

        ref = temp_data{i,currentCol};
%         maxCorVal = nan(1,i-1);%记录每个点和参考点(也就是下一个点)的最大互相关值
%         timeLag = nan(1,i-1);%记录每个点和参考点最大互相关值所对应的时滞
        
        %计算互相关
%         cor_cof = nan(1,i-1); % 用来记录两个信号的相关系数
        
%         parfor j = 1:i-1
%             target = temp_data{j,currentCol};
%             cor_cof(j) = corr(ref',target','type','Pearson');
%             [~,timeLag(j)]= correlationCalc(ref,target,temp_timeInterval); %得到每个最大值和所对应的时滞
%         end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%  修改上面那个并行计算结构(parfor)版本 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        target = cell2mat(temp_data(1:i-1,currentCol)); 
        
        
        
        cor_cof = corr(ref',target','type','Pearson'); %获取互相关系数
        
        [~,mostSim] = max(cor_cof(round(length(cor_cof)*0.6):end-ov_range));% 这里会出现bug，就是end-ov_range 会小于round(length(cor_cof)*0.6),则出现bug 
        
        mostSim = mostSim+round(length(cor_cof)*0.6)-1;
      %计算时滞还是要多进行一次循环,xcorr不支持多行计算        
  
        %尝试每隔2m来进行一次估算
        dst_itv = 4;%所隔像素点
        t_lag_idx = mostSim:dst_itv:i-1; %并行运算
        timeLag = nan(1,size(t_lag_idx,2));
        
%         并行运算版本（每个点都进行计算的话很慢)        
%         parfor j =  mostSim:i-1
%             [~,timeLag(j)]= correlationCalc(ref,target(j,:),temp_timeInterval);
%         end
        sup_count = 1;
        for j = t_lag_idx
            [~,timeLag(sup_count)]= correlationCalc(ref,target(j,:),temp_timeInterval);
            sup_count = sup_count+1;
        end
          
%%%%%%%%%%%%%%%%%%%
        
        
        
        
        
%         figure(1);
%         plot(maxCorVal,'b');
        figure(2);
        plot(cor_cof,'r');
        
%         [~,mostSim] = max(cor_cof(1:end-ov_range));
        
        
        
        
        %用于速度估计的散点
        
%         shoreDistance = zeros(1,i-mostSim+1);
%         time_lag = zeros(1,i-mostSim+1); 
%         time_lag(2:end) = timeLag(end:-1:mostSim); %这里的关系需要好好理清一下
        



%         shoreDistance = [0,(1:i-mostSim)*picInfo.pixel2Distance]; %用于距离的估算
%         timeLag = [0,flip(abs(timeLag(1,mostSim:i-1)))]; %时滞计算
      
        
        timeLag = flip(abs(timeLag)); %时滞计算
        
        for idx = 2:size(timeLag,2)      %由于信号的种种原因，时间并不会展现递增的规律，或出现跳变，所以此时需要筛选时间信号
             if timeLag(idx)<timeLag(idx-1) || timeLag(idx)>timeLag(idx-1)+20
                    break;
             end
        end
        
        timeLag = [0,timeLag(1:idx-1)];
        
        shoreDistance = [0,(1:idx-1)*picInfo.pixel2Distance*dst_itv]; %用于距离的估算

        midPoint = round((i+mostSim)/2); %中点处的坐标
        
        linearCurve = polyfit(timeLag,shoreDistance,1); % 拟合进行中点处速度的计算（在选取了最大相关的信号之后不用再选取范围）
        %         linearCurve = polyfit(abs(time_lag),shoreDistance,1); % 拟合进行中点处速度的计算 
        
        % 取平均值操作
        if(isnan(c(midPoint)))
            c(midPoint) = linearCurve(1);
        else
            c(midPoint) = (linearCurve(1)+c(midPoint))/2;
        end
        
        
        % 取平均值操作
        if(isnan(f(midPoint)))
            f(midPoint) = ForMidPoint_f(ref,temp_data{mostSim,currentCol},cpsdVar);% 计算f_ref,当成中点的频率
        else
            temp_f = ForMidPoint_f(ref,temp_data{mostSim,currentCol},cpsdVar);
            f(midPoint) = (temp_f+f(midPoint))/2;
        end
        

        
    end



































% %     aRange = 50;%一个范围，离岸点这么近的时候就不估计了，因为图像中有岸
%     f = nan(picInfo.row,1);
%     c = nan(picInfo.row,1);
%     
%     
%     temp_data = picInfo.afterFilter;
%     temp_timeInterval = picInfo.timeInterval;
%     
%         i =  pos;
%         ref = temp_data{i,currentCol};
%         maxCorVal = nan(i-1,1);%记录每个点和参考点(也就是下一个点)的最大互相关值
%         timeLag = nan(i-1,1);%记录每个点和参考点最大互相关值所对应的时滞
%         for j = 1:i-1
%             target = temp_data{j,currentCol};
%             [maxCorVal(j),timeLag(j)]= correlationCalc(ref,target, temp_timeInterval); %得到每个最大值和所对应的时滞
%         end
%         plot(maxCorVal);
%         [~,maxValueIdx] = max(maxCorVal); % 得到最大互相关的值所在的图像位置索引
%         %用于速度估计的散点
%         shoreDistance = zeros(i-maxValueIdx+1,1);
%         time_lag = zeros(i-maxValueIdx+1,1); 
%         time_lag(2:end) = timeLag(end:-1:maxValueIdx); %这里的关系需要好好理清一下
%         shoreDistance(2:end) = (1:i-maxValueIdx)*picInfo.pixel2Distance; %用于距离的估算
%         %进行速度的计算
%         midPoint = round((i+maxValueIdx)/2);
%         f(midPoint) = ForMidPoint_f(ref,picInfo.afterFilter{maxValueIdx,currentCol},cpsdVar);% 计算f_ref,当成中点的频率
%         linearCurve = polyfit(abs(time_lag),shoreDistance,1); % 拟合进行中点处速度的计算 
%         c(midPoint) = linearCurve(1);
% end

