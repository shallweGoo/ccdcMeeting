% 输入参数：
% 1、signal1:第一个时序信号
% 2、signal2:第二个时序信号
% 3、目标频率点
function f = getRepresentativeFrequency(signal1,signal2,source_f,Fs)
    %计算互功率谱
    [Pxy,F] = cpsd(signal1,signal2,[],[],[],Fs);
    mag = abs(Pxy);
    figure(33); % 功率谱图窗编号
    plot(F,mag);
    
    id = find_target_f_point(source_f,F,mag); %获取频率

    f = F(id)'*mag(id)/sum(mag(id));
    
end


%求目标频率点
function target_id = find_target_f_point(source_f,total_f,cpsd_val)
    target_val = zeros(1,length(source_f));
    for i = 1:length(source_f)
        id = find(abs(source_f(i)-total_f)<0.01);%索引
        for j = 1:length(id)
            if target_val(i) < cpsd_val(id(j))
                target_val(i) = cpsd_val(id(j));
                target_id(i) = id(j);
            end
        end
    end
end