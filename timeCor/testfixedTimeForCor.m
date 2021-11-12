function res = testfixedTimeForCor(timeStack_org,timeStack_fixedTime,i)
% 该程序为fixedTimeForCor的测试版，可以选择单一的timeStack进行计算，i是所在的位置
%     noNeedDistance = 50; %按照这个像素值就差不多是岸上了，实际上就算是岸上的点也会有互相关，我不知道哪里出问题
    PredictRange = 200; %在PredictRange个点之间预测互相关最大值
    row = size(timeStack_org,1);
    cor_val = NaN(1,PredictRange);
    res = NaN(row,PredictRange);
        for j = i:-1:i-PredictRange+1 %从本身开始这个像素开始计算相似程度
%         for j = i:-1:1 %从本身开始这个像素开始计算相似程度  
            cor_val(i-j+1) = corr(timeStack_org(i,:)',timeStack_fixedTime(j,:)','type','Pearson'); %用这个信号计算互相关
        end
            plot(cor_val);
            res(i,:) = cor_val;
end
