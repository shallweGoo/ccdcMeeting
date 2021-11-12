% 生成一个信号
function signal = createSignal(TimeSeries,Height,Width)
    signalLen = length(TimeSeries(Height,Width,:));
    signal = zeros(1,signalLen);
    for i = 1:signalLen
        signal(i) = TimeSeries(Height,Width,i);
    end
end