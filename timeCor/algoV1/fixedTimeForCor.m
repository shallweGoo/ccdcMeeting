%该函数的目的是为了在固定一个时间，计算互相关最大的点,
%固定图片的每一列来计算（271），接着按照时间堆栈的每行来计算,直到计算到图片的每一个点

%timeStack得到的只是一列的时间堆栈，所以要得到整张图片就会很麻烦
function res = fixedTimeForCor(timeStack_org,timeStack_fixedTime)
    noNeedDistance = 100; %按照这个像素值就差不多是岸上了，实际上就算是岸上的点也会有互相关，我不知道哪里出问题
    PredictRange = 80; %在PredictRange个点之间预测互相关最大值
    row = size(timeStack_org,1);
    cor_val =NaN(1,PredictRange);
    res = NaN(row,PredictRange);
    for i = row:-1:noNeedDistance
        for j = i-1:-1:i-PredictRange+1 %从本身开始这个像素开始计算相似程度
            cor_val(i-j+1) = corr(timeStack_org(i,:)',timeStack_fixedTime(j,:)','type','Pearson'); %用这个信号计算互相关
        end
        plot(cor_val);
        res(i,:) = cor_val;
    end

end