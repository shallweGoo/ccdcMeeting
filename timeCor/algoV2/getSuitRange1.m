function id = getSuitRange1(ref, ref_id, data_set, params)
for i = 1 : size(data_set, 2) % 有n个信号
    cor_coff(:, i) = corr(ref, data_set(:, i), 'type', 'Pearson'); %获取互相关系数
end

if params.DEBUG == 1
    figure(2);  % 2号窗口用于debug
    plot(cor_coff, 'r'); 
end

range_end = max(1, ref_id - 10);
range_begin = max(1, ref_id - 40);
[~, id] = max(cor_coff(:, range_begin : range_end));
id = id + range_begin - 1;
end