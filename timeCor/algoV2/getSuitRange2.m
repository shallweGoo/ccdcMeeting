% 版本2，获取互相关最大的那个点,采用时滞信号，默认3s
function [id, cor_val] = getSuitRange2(ref, data_set, params)
num = 60;
cor_val = nan(num, 1);
id = nan;
if isempty(data_set)
   return;
end
for i = 1 : size(data_set, 2) % 有n个信号
    cor_coff(:, i) = corr(ref, data_set(:, i), 'type', 'Pearson'); %获取互相关系数
end

if params.DEBUG == 1
    figure(2);  % 2号窗口用于debug
    plot(cor_coff, 'r'); 
end

[~, id] = max(cor_coff);

tmp = cor_coff(max(end - num + 1, 1) : end)'; % 长度为50的互相关性值

if length(tmp) ~= num
    cor_val(1 : length(tmp), 1) = tmp;
    cor_val = flipud(cor_val);
else 
    cor_val = tmp;
end
    
end