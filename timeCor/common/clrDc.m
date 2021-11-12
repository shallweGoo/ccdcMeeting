function signal = clrDc(signal,mode)
    if nargin<2
        mode = 2;
    end
    %目前有三种方法去除直流分量
    %1.detrend 去除最佳的线性拟合趋势并以返回
    %2.信号减去均值
    %3.在频域上令f=0Hz的分量为0
    
    switch mode
        case 1
            signal = detrend(signal);
            
        case 2
            signal = signal - mean(signal);
            
        case 3
            %先进行 fft变换
            fft_total = fft(signal);
            fft_total(1) = 0;
            signal = ifft(fft_total);
    end
    
end

