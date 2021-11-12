dbstop if all error  % 方便调试
station_str = 'phantom4';
% 执行参数注入
addpath('algoV2');
addpath('common'); % 通用函数
eval(station_str);
load('data_final');
load('data_struct');
% params.DEBUG = 0;
% 进行滤波之后的信号提取

x = xyz(:, 1);
y = xyz(:, 2);
z = xyz(:, 3);
bathy.h = nan((max(x) - min(x)) / params.dist + 1, (max(y) - min(y)) / params.dist + 1); % 行 * 列
bathy.speed = bathy.h;
bathy.f = bathy.h;

for longshore = min(y) : params.dist : max(y)
    one_long_shore_id = find(y == longshore);
    cross_shore_x = x(one_long_shore_id, :);
    one_long_shore_data = data_final(:, one_long_shore_id);
    for cross_shore = min(cross_shore_x) : params.dist : max(cross_shore_x)
        
        ref_id = find(cross_shore_x == cross_shore); % 找到所在的索引
        ref = one_long_shore_data(:, ref_id);
        data_set = one_long_shore_data(:, 1 : (ref_id - 1));
        
%         range_id = getSuitRange1(ref, ref_id, data_set, params); % version1：获取互相关最大的那个值的索引，称为range_id，没有对信号进行筛选而得到的
        [range_id, ~] = getSuitRange2(ref(1: end - params.fix_time / params.dt), data_set(1 + params.fix_time / params.dt : end, :), params);
        [mid_id, speed, f] = getMidSpeedFreq(ref, ref_id, data_set, params, range_id);% 获取最相关的一个
        if isinf(speed) 
            speed = (ref_id - range_id) * params.dist ./ params.fix_time; % 如果拟合失败，则采用第二种方案，固定时间计算, speed = dx / dt;
        end
        
        col = (longshore - min(y)) / params.dist + 1;
        if isnan(mid_id) % 筛选机制
            continue
        end
        bathy.speed(mid_id, col) = speed;
        bathy.f(mid_id, col) = f;
        h_max = 9.82*(1/f^2)/(2*pi)/2; % 参考cBathy的理论
        
            
        if isnan(bathy.h(mid_id, col))
            bathy.h(mid_id, col) = abs(calDepth(speed, f));
        else 
            bathy.h(mid_id, col) = (bathy.h(mid_id, col) + abs(calDepth(speed, f))) / 2;
        end
        
        if bathy.h(mid_id, col) > h_max 
            bathy.h(mid_id, col) = nan;
        end
    end
    
    disp(['progress:' num2str((longshore - min(y)) / (max(y) - min(y)) * 100) '% completed']);
    
end
disp('反演结束！');

%% test
ref_id = 200;
longshore = 1;
params.DEBUG = 1;
one_long_shore_id = find(y == longshore);
cross_shore_x = x(one_long_shore_id, :);
one_long_shore_data = data_final(:, one_long_shore_id);
ref = one_long_shore_data(:, ref_id);
data_set = one_long_shore_data(:, 1 : (ref_id - 1));
range_id = getSuitRange2(ref(1: end - params.fix_time / params.dt), data_set(1 + params.fix_time / params.dt : end, :), params);
[mid_id, speed, f] = getMidSpeedFreq(ref, ref_id, data_set, params, range_id); % 获取最相关的一个


%%
    bathy.h(bathy.h == inf) = nan;
    world_info.x = 0 : params.dist : (params.xy_range(4) - params.xy_range(3));
    world_info.y = 0 : params.dist : (params.xy_range(2) - params.xy_range(1));
    plotBathy(world_info, abs(bathy.h));
    
    
 %% 插值操作
    itp.h = bathy.h;
    for i = 1 : size(bathy.h, 2) % 按列插值
        itp.tmp = bathy.h( : , i);
        itp.need_points = 1 : size(bathy.h, 1);
        itp.ins_id = find(isnan(itp.tmp));  %需要插值的id
        itp.ins_x = itp.need_points(itp.ins_id);
        itp.src_id = find(~isnan(itp.tmp));    % 发现原始数据
        itp.src_x = itp.need_points(itp.src_id);
        itp.src_y = itp.tmp(itp.src_id);
        itp.ins_y = interp1(itp.src_x, itp.src_y', itp.ins_x, 'linear');
        itp.tmp(itp.ins_id) = itp.ins_y;
        itp.h(:, i) = itp.tmp;
    end
    bathy.h1 = itp.h;
    plotBathy(world_info, bathy.h1);
    %% 加一些数据处理，如果产生突变深度一般理解为是反演错误，需要删除重新插值
    % 第一次处理
    err_threshold = 0.5; % 产生突变的阈值设置为0.5m
    for i = 1 : size(bathy.h1, 2)
        err_process.tmp = bathy.h1(:, i);
        err_process.dif = abs(diff(err_process.tmp)); % 差分
        err_id = 1;
        vanish_id = [];
        for j = 1 : length(err_process.dif) - 1
            if isnan(err_process.dif)   %如果以及有nan值了
                continue;
            end
            if err_process.dif(j) > err_threshold  % 如果有个大差值
                if ~ismember(j, vanish_id)
                    vanish_id(err_id, 1) = j + 1;
                    err_id = err_id + 1;
                else
                    dd = 0;
                    for k = j : -1 : 1  %向前找到一个不在vanish_id里面（即认为是正常的）的值
                        dd = dd + 0.1;
                        if ismember(k, vanish_id)
                            continue;
                        end

                        if abs(err_process.tmp(j + 1) -  err_process.tmp(k)) > err_threshold + dd 
                            vanish_id(err_id, 1) = j + 1;
                            err_id = err_id + 1;
                        else
                            break;
                        end
                    end
                end
            end
        end
        err_process.tmp(vanish_id) = nan;
        err_process.h(:, i) = err_process.tmp;
    end
    for i = 1 : size(err_process.h, 2) % 按列插值
        itp.tmp = err_process.h( : , i);
        itp.need_points = 1 : size(err_process.h, 1);
        itp.ins_id = find(isnan(itp.tmp));  %需要插值的id
        itp.ins_x = itp.need_points(itp.ins_id);
        itp.src_id = find(~isnan(itp.tmp));    % 发现原始数据
        itp.src_x = itp.need_points(itp.src_id);
        itp.src_y = itp.tmp(itp.src_id);
        itp.ins_y = interp1(itp.src_x, itp.src_y', itp.ins_x, 'linear');
        itp.tmp(itp.ins_id) = itp.ins_y;
        itp.h(:, i) = itp.tmp;
    end
    bathy.h2 = itp.h;
% 第二次处理

    for i = 1 : size(itp.h, 2)
        err_process.tmp = itp.h(:, i);
        err_process.dif = abs(diff(err_process.tmp)); % 差分
        err_id = 1;
        vanish_id = [];
        for j = 1 : length(err_process.dif) - 1
            if isnan(err_process.dif)   %如果以及有nan值了
                continue;
            end
            if err_process.dif(j) > err_threshold  % 如果有个大差值且这个数的索引不在坏点的范围内,大差值
                if ~ismember(j, vanish_id)
                    vanish_id(err_id, 1) = j + 1;
                    err_id = err_id + 1;
                else
                    dd = 0;
                    for k = j : -1 : 1  %向前找到一个不在vanish_id里面（即认为是正常的）的值
                        dd = dd + 0.1;
                        if ismember(k, vanish_id) % 如果是坏点，那么向前找，直到找到到一个不是坏点的，和这个点作比较
                            continue;
                        end
                        
                        if abs(err_process.tmp(j + 1) -  err_process.tmp(k)) > err_threshold + dd 
                            vanish_id(err_id, 1) = j + 1;
                            err_id = err_id + 1;
                        else
                            break;
                        end
                    end
                end
            end
        end
        err_process.tmp(vanish_id) = nan;
        
        err_process.h(:, i) = err_process.tmp;
    end
    
    
   
    for i = 1 : size(err_process.h, 2) % 按列插值
        itp2.tmp = err_process.h( : , i);
        itp2.need_points = 1 : size(err_process.h, 1);
        itp2.ins_id = find(isnan(itp2.tmp));  %需要插值的id
        itp2.ins_x = itp2.need_points(itp2.ins_id);
        itp2.src_id = find(~isnan(itp2.tmp));    % 发现原始数据
        itp2.src_x = itp2.need_points(itp2.src_id);
        itp2.src_y = itp2.tmp(itp2.src_id);
        itp2.ins_y = interp1(itp2.src_x, itp2.src_y', itp2.ins_x, 'linear');
        itp2.tmp(itp2.ins_id) = itp2.ins_y;
        itp2.h(:, i) = itp2.tmp;
    end
    
    bathy.h3 = itp2.h;
    subplotBathy(world_info, abs(itp.h), abs(bathy.h3));
    
    %% 再取一个均值 
    for i = 1 : size(bathy.h3, 2) % 按列取均值，改成2m的像素分辨率
        avg.tmp = bathy.h3(:, i);
        for j = 1 : length(avg.tmp)
            if isnan(avg.tmp(j))
                continue;
            end
            avg.sum = avg.tmp(j);
            avg.cnt = 1;
            if j - 1 >= 1 && ~isnan(avg.tmp(j - 1))
                avg.sum = avg.sum + avg.tmp(j - 1);
                avg.cnt = avg.cnt + 1;
            end
            if j + 1 <= length(avg.tmp) && ~isnan(avg.tmp(j - 1))
                avg.sum = avg.sum + avg.tmp(j + 1);
                avg.cnt = avg.cnt + 1;
            end
            avg.tmp(j) = avg.sum / avg.cnt;
        end
        avg.h(:, i) = avg.tmp;
    end
    bathy.h_final = avg.h;
    bathy.h_final(1:50, :) = nan;
    plotBathy(world_info, abs(bathy.h_final));
    %%
    figure(99);
    itv = 0;
    target_col = 70;
    plot(err_process.h(1: end - itv, target_col), 'g');
    hold on;
    plot(bathy.h2(1: end - itv, target_col), 'r');
    hold on;
    plot(bathy.h_final(1: end - itv, target_col), 'b');
    
    %%
    close all;
    figure;
    plotBathy(world_info, abs(bathy.h_final));
    
    %%
    plot(bathy.h(:, 1), 'r');
    hold on;
    plot(err_process.h(:, 1), 'g');
    hold on;
    plot(bathy.h_final(:, 1), 'b');
    %% save bathy结构体
    save('bathy.mat', 'bathy');
    disp('保存完成');