function [mat_fs,ps] = fft2Analysis(mat)
%FFT2ANALYSIS 用于2维数组的fft分析，绘制出频谱图和功率谱图
%   此处显示详细说明
    F=fft2(mat);
    Fs=fftshift(F);      %将频谱图中零频率成分移动至频谱图中心
    mat_fs=log(abs(Fs)+1);    %取模并进行缩放
%     subplot(2,1,1);imshow(mat_fs,[]);title('傅里叶变换频谱图');
    ps=log(abs(Fs).^2+1);   %功率谱
%     subplot(2,1,2);imshow(ps,[]),title('功率谱');
end

