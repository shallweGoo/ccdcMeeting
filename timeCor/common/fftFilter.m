%% 去除信号中的特定频率的信号
% 输入参数：
% ori_singal: 源信号
% ff 需要滤去的频率，为一个数组
% params 其他参数

% 输出： 经过滤波之后的信号
function filter_signal = fftFilter(ori_singal, ff, params)
 
% 由输入参数params得到的一些
    fs = params.fs;
    N = length(ori_singal); % 采样点个数
    n = 0 : N - 1;          % 用于时间的估算
    t = n / fs;             % 采样时间
%
    df = fs / N;            % df
    dt = 1 / fs;            % dt

    G = fft(detrend(double(ori_singal)));   %去直流
%     figure(1)
%     plot(n*df, abs(G), 'r');
%     hold on;
    filter_mid = N / 2 + 1;
    for i = 1 : length(ff)
        need_filter_f = ff(i);
        need_filter_pos = uint32(need_filter_f / df + 1);
        G(need_filter_pos, :) = 0;
        G(2 * filter_mid - need_filter_pos, :) = 0;
%         plot(n * df, abs(G), 'b');
    end
    filter_signal = ifft(G);

%     figure(100)
%     plot(t, filter_signal, 'r');
%     hold on;
%     plot(t, signal_filter, 'b');

end

