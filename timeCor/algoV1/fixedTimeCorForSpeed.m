
% 该函数的作用：
% 根据固定时间所得到的每一列互相关值，来进行速度的估计
% 就当成这个点的波速，频率为：跟这个距离互相关最大的那一点的两个信号的互功率谱所得到加权值

function speed = fixedTimeCorForSpeed(fixedTimeCorVal,picInfo)
    [maxVal,idx] = max(fixedTimeCorVal,[],2); %计算每行的故相关值
    
end