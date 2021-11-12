% 对信号进行低通滤波

function filter_data = lowPassFliter(ori_data, params)
% bp_filter信息
bp_filter = load(['F:\workSpace\matlabWork\seaBathymetry\filter_mat\bpfilter0.05_0.5Fs' num2str(params.fs) '.mat']); %注意修改对应的滤波器
bpfilter = bp_filter.bpfilter;
filter_len = length(bpfilter);
data = detrend(double(ori_data)); % 去线性化
filter_mid =  floor(filter_len / 2);
f_start = filter_mid + 1;
for point_id = 1: length(ori_data)  
    one_data = [data(:, point_id) ; zeros(filter_len , 1)]; %滤波过程
    one_data = filter(bpfilter, 1, one_data); 
    filter_data(:, point_id) = one_data(f_start : size(ori_data, 1) + filter_mid);
end

end