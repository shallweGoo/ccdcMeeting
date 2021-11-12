%该函数用于对信号进行fft分析,只用于观察频谱图
% 包含画图步骤
function fft_M = fftAnalysis(signal, fs)
    fft_total = fft(signal);
    fft_M = abs(fft_total);
    N = length(fft_total);
    frequence = (0:N/2-1)*fs / N;
    fft_M = fft_M/N;
    fft_M(2:end) = 2*fft_M(2:end);
    figure;
    plot(frequence,fft_M(1:length(frequence)));
end

