%用于发现波长或近似波长，用于确定估计范围
%论文中提到固定时间为3s可以对应一个适合的时间
%输入为一个结构体，里面必须要含有两个元胞数组，一个是0~end-3s的信号，一个是3s~end的信号，信号长度一致

function  WaveLengthInfo = findWaveLength(picInfo)
    WaveLengthInfo = nan(picInfo.row,picInfo.col);

    for i = 1:picInfo.col
        source = squeeze(picInfo.timelag_before(:,i,:))'; % 将一列的元素变成列向量，方便计算互相关
        cmp = squeeze(picInfo.timelag_after(:,i,:))';
       
        CorMatrix = corr(source,cmp,'type','Pearson'); %得到一列的最大互相关
        [~,index] = max(CorMatrix,[],2);%获取每行的最大值以及索引
        
        %debug相关
%         figure(98);
%         title("3s时滞最大相关");
%         plot(CorMaxtrix(end,:));%最后一行的互相关值
%         legend('3s时滞相关度','Location','northeast');
        
        WaveLengthInfo(:,i) = index';
    end

    
end

