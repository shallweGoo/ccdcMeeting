
% 该函数的作用是找到和reference信号互相关系数最大的那个点
% 输入参数： 
% 1、ref ： 参考信号
% 2、data_set ： 信号集
% 3、ref_id ： 

function [mid_id , speed, freq] = getMidSpeedFreq(ref, ref_id, data_set, params, range_id)
if isempty(data_set) || isnan(range_id) 
    mid_id = nan;
    speed = nan;
    freq = nan;
    return;
end
freq = getFreq(ref, ref, params);
data_range = data_set(:, range_id : end);
timelag = getTimelag(ref, data_range, params);
timelag = flipud(timelag);
for time_id = 2 : length(timelag)      % 由于信号的种种原因，时间并不会展现递增的规律，或出现跳变，所以此时需要筛选时间信号
     if timelag(time_id) < timelag(time_id - 1) || timelag(time_id) > timelag(time_id - 1) + 2
            break;
     end
end
timelag = [0; timelag(1 : time_id - 1, :)];
position = [0 : length(timelag) - 1]' .* params.dist;


% 处理时滞应该不大于10
time_id = find(timelag < 10);
timelag = timelag(time_id);
position = position(time_id);


% timelag = [0; timelag(1 : time_id - 1, :)];

% position = [0 : length(timelag) - 1]' .* params.dist;



linear_curve = polyfit(timelag, position, 1);   % 拟合
speed = linear_curve(1);
if params.DEBUG == 1
    clf;
    figure(3);
    plot(timelag, position, 'k*');  % 画出timelag和position的关系
    hold on;
    tmp_y = polyval(linear_curve, timelag);
    plot(timelag, tmp_y, 'color','r', 'LineWidth',3);
%     title('wave celerity fitting');
    xlabel('time lag(s)');
    ylabel('distance(m)');
    
end



mid_id = round((range_id + ref_id) / 2);

end


% 找到互相关最大的那个点的id， 和互相关值
function timelag = getTimelag(ref, data, params) 
timelag = zeros(size(data, 2), 1);
max_cor_val_set = timelag;
for i = 1 : size(data, 2) % 有n个信号
    [cor_mag, series_num] = xcorr(ref, data(:, i), 15, 'coeff'); %'coeff'参数为归一化互相关曲线所得到的
    [max_cor, max_id] = max(cor_mag); % 互相关最大的值
    timelag(i, :) = abs(series_num(max_id) * params.dt); % 最大值对应的时间点
    max_cor_val_set(i, :) = max_cor;
    if params.DEBUG == 1
        figure(32);%  互相关图窗编号32
        plot(series_num, cor_mag);
    end
end

end

% 获取合适的估计范围
% 选取的原则


% 获取该信号的互功率谱矩阵
function freq = getFreq(s1, s2, params)
    [Pxy, F] = cpsd(s1, s2,[], [], [], params.fs);
%     Pxy(Cxy<0.1) =0;
    mag = abs(Pxy);
    
    
    if params.DEBUG == 1
        figure(33);%  互相关图窗编号32
        plot(F, mag);
        title('互功率谱');
    end
    id = find(F >= min(params.fB) ...
             & F <= max(params.fB));
    
    validMag = mag(id, :);
    validF = F(id, 1);
    freq = validMag'* validF / sum(validMag);
end





