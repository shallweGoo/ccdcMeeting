% 找到频率最相关的几个点

function ff = findMostCorFreq(G, params) 
nKeep = params.nKeep;
% g = 9.82;   % 重力
f = params.f;   % 实际的频率范围
fB = params.fB; % 需要枚举的fB范围
for i = 1 : length(fB)
    f_id = find(abs(fB(i)-f) < (fB(2)-fB(1))/2);    %找到对应的频率范围
    C(:, :, i) = G(f_id, :)' * G(f_id,:) / length(f_id);    % 互功率谱矩阵
end

coh2 = squeeze(sum(sum(abs(C)))/(size(G, 2) * (size(G, 2)- 1))); % 互相干系数

[~, coh2Sortid] = sort(coh2, 1, 'descend');  % sort by coh2 按照列值降序排列,coh2Sortid储存了原数组中数值降序的索引，CEOF的原理吧
ff = fB(coh2Sortid(1:nKeep));         % keep only the nKeep most coherent，选nKeep个最相干的频率

end