%%%%%%%%  按照cBathy的方法获取xyz信息，data %%%
% 输入参数：
%
% save_info：
% save_path： 结果存放路径
% save_name： 结果存放命名

% params：
% 1、dist:也就是需要采样点的距离
% 2、fs:图片的分辨率
% 3、xy_range: xy轴的取值范围
% 4、xy_want: xy轴想要获得采样的采样范围
% 5、prm: 像素分辨率

% 


function [xyz, data, t, N] = makeTimeStack(img_path, save_info, time_info, params)


%  循环获取图片信息
%  xyz+data+t
fs  = params.fs;
save_name = save_info.name;
save_path = save_info.path;

img_name = string(ls(img_path));
img_name = img_name(3:end);
N = length(img_name);
%%
% 1.xyz获取
dist = params.dist;

% 图片起始x, y范围
img_x_begin = params.xy_range(1);
img_x_end = params.xy_range(2);
img_y_begin = params.xy_range(3);
img_y_end = params.xy_range(4);

% 想要采样的图片范围
x_begin = params.xy_want(1);
x_end = params.xy_want(2);
y_begin = params.xy_want(3);
y_end = params.xy_want(4);

row_id = 1;

for dx = x_begin : dist : x_end

    for dy = y_begin : dist : y_end
        
        xyz(row_id, 1) = dx;
        
        xyz(row_id, 2) = dy;
        
        xyz(row_id, 3) = 0;
        
        row_id = row_id + 1;
    end

end
    
disp('get xyz successfully!');
%%
% 2.data获取

sample_point_xyz(:,1) = xyz(:,1) - img_x_begin;
sample_point_xyz(:,2) = xyz(:,2) - img_y_begin;

% sample_point_xyz(:,1) = xyz(:,1);
% sample_point_xyz(:,2) = xyz(:,2);

sample_point_xyz = sample_point_xyz ./ params.prm + 1;

time_id = 1;

for img_id = 1:length(img_name)
    
    img_real_path = strcat(img_path, img_name(img_id));
    
    pixel_info = imread(img_real_path);
    
    pixel_info = fliplr(pixel_info);
    
    pixel_intensity_info = zeros(1, length(sample_point_xyz));
    
%     figure(22);
%     imshow(pixel_info);
%     hold on;
    
    for point_id = 1:length(sample_point_xyz)
        pixel_intensity_info(1, point_id) =  pixel_info(sample_point_xyz(point_id,1), sample_point_xyz(point_id,2));
%        画图
%        plot(sample_point_xyz(point_id,2),sample_point_xyz(point_id,1),'k.','markersize',5,'linewidth',3);
        
    end
        
    data(time_id,:) = pixel_intensity_info;
    
    time_id = time_id + 1;
    
end

disp('get data successfully!');

%% t 获取
if length(time_info) < 6
    for i = length(time_info) + 1 : 6
        time_info(i, :) = 0;
    end
end


year = time_info(1);
month = time_info(2);
day = time_info(3);
hour = time_info(4);
minute = time_info(5);
second = time_info(6);


t_begin = datenum(year, month, day, hour, minute, second);

time_id = size(data,1);


for time_cur = 1:time_id
    step_s = floor((second+ 1/fs)/60);
    second = mod((second+1/fs),60);
    step_m = floor((minute+step_s) / 60);
    minute = mod((minute+step_s), 60);
    step_h = floor((hour+step_m) / 24);
    hour = mod((hour+step_m), 24);
    t(time_cur) = datenum(year,month,day,hour,minute,second);
end
disp('get t successfully!');

%% 储存数据
% real_save = strcat(save_path, save_name);
% data_struct.xyz = xyz;
% data_struct.data = data;
% data_struct.t = t;

% data_lowpass = lowPassFliter(data, params);

save(save_name, 'xyz', 'data', 't');

disp('process done');


end




