%用于互相关法水深计算
function depth = correlationProcess(picInfo,cpsdVar)

    depth = nan(picInfo.row,picInfo.col);%水深函数
    f = nan(picInfo.row,picInfo.col); %频率
    speed = nan(picInfo.row,picInfo.col); %波速

    pix_dist = picInfo.dist/picInfo.pixelResolution;
    
    for i = 1:picInfo.col
        
        for source_id = picInfo.row:-1:1

            wave_id = picInfo.waveLengthInfo(source_id,1);%互相关系数最大的那个点
            
            if wave_id > source_id %出现了偏差
                
                continue;
                
            end
            
            target_id = source_id:-pix_dist:wave_id; % 与source信号估计的索引
            
            source = squeeze(picInfo.afterFilter(source_id,i,:)); % 列向量形式
            
            target = squeeze(picInfo.afterFilter(target_id,i,:))'; %改成列向量的形式
            
            if size(target,1) < size(target,2) % 如果是行向量
                
                target = target';
                
            end
                
            mid = round((source_id+wave_id)/2);% 中点索引
            
            %计算互相关时滞
            [MaxCor, TimeLag]= correlationCalc(source,target,picInfo.timeInterval); %返回和source信号相关的所有时滞
            
            TimeLag = abs(TimeLag);

            PointDist = [0:length(TimeLag)-1]'*picInfo.dist;
            
            clear invalid_id; %清除索引记录
            clear invalid_cur;
            
            invalid_cur = 1;%用于记录无效时间索引
            for cur = 2:length(TimeLag)-1
                
                if abs(TimeLag(cur)-TimeLag(cur-1)) >= 2
                    TimeLag(cur) = TimeLag(cur-1);
                    invalid_id(invalid_cur) = cur;
                    invalid_cur = invalid_cur+1;
                end
                
            end
            
            if exist('invalid_id','var') == 1
                TimeLag(invalid_id) = nan;
                PointDist(invalid_id) = nan;
            end
            
            if length(TimeLag) > 1 && length(TimeLag) - (invalid_cur-1) >1 %如果时滞大于长度且非nan值个数要>=2
                
                linearCurve = polyfit(TimeLag,PointDist,1); % 一阶多项式拟合，为了得到斜率
                
                
                % 速度估计
                if isnan(speed(mid,i))
                    speed(mid,i) = linearCurve(1);
                else
                    speed(mid,i) = (linearCurve(1)+speed(mid,i))/2;
                end
                
                target_f = squeeze(picInfo.afterFilter(wave_id,i,:));

                % 频率估计
                if isnan(f(mid,i))
                    f(mid,i) = ForMidPoint_f(source,target_f,cpsdVar);% 计算f_ref,当成中点的频率
                else
                    f(mid,i) = ( ForMidPoint_f(source,target_f,cpsdVar) + f(mid,i) )/2;
                end
                
            end

            % debug相关
%             clf;
%             figure(90);% 图窗号为90
%             plot(TimeLag,PointDist,'k.');
%             hold on;
%             tmp_y = polyval(linearCurve,TimeLag);
%             plot(TimeLag,tmp_y,'b');

            
            

            
            
            
            
        end
        
        depth(:,i) = calDepth(speed(:,i),f(:,i));
        
        disp("correlation process "+ num2str(i/picInfo.col*100)+ "% completed");
        
        
    end
     

end


%         [point.f(:,i),point.speed(:,i)] = corForFandC(picInfo,i,cpsdVar);
%         seaDepth(:,i) = calDepth(point.speed(:,i),point.f(:,i));
%         disp(['process:' num2str(i/picInfo.col*100) '% completed']);
    %     run_time = cputime-t1;