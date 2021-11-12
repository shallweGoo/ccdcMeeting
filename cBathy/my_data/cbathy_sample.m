% 获取下采样之后的图像

clear;
% img_savePath =  "F:/workSpace/matlabWork/imgResult/orthImg/";
img_savePath =  "F:/workSpace/matlabWork/corNeed_imgResult/变换后图片18/";
% img_savePath = "F:/workSpace/matlabWork/dispersion/selectPic/afterPer/双月湾第二组变换后/变换后图片14/";
img_name = string(ls(img_savePath));
img_name = img_name(3:end);

%  循环获取图片信息
%  xyz+data+t
fs  = 2 ;
save_name = './2021_05_15_group1';
%%
% 1.xyz获取
row_id = 1;

dist = 1;

% 图片起始x,y范围
img_x_begin = 0;
img_x_end = 300;
img_y_begin = 50;
img_y_end = 150;

% 想要采样的图片范围
x_begin = 0;
x_end = 300;
y_begin = 50;
y_end = 150;


for dx = x_begin : dist : x_end
    
    for dy = y_begin : dist : y_end
        
        xyz(row_id,1) = dx;
        
        xyz(row_id,2) = dy;
        
        xyz(row_id,3) = 0;
        
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



sample_point_xyz = sample_point_xyz ./ 0.5 + 1; %分辨率是0.5m,那么就要找到对应的那个点,这一步是要将local坐标和像素位置对应起来

time_id = 1;

for img_id = 1:length(img_name)
    
    img_real_path = strcat(img_savePath, img_name(img_id));
    
    pixel_info = imread(img_real_path);
    
    pixel_info = fliplr(pixel_info);
    
    pixel_intensity_info = zeros(1, length(sample_point_xyz));
    
%     figure(22);
%     imshow(pixel_info);
%     hold on;
    
    for point_id = 1:length(sample_point_xyz)
        pixel_intensity_info(1, point_id) =  pixel_info(sample_point_xyz(point_id,1), sample_point_xyz(point_id,2));
%         画图
%        plot(sample_point_xyz(point_id,2),sample_point_xyz(point_id,1),'k.','markersize',5,'linewidth',3);
        
    end
        
    data(time_id, :) = pixel_intensity_info;
    
    time_id = time_id + 1;
    
end

disp('get data successfully!');

%% t 获取
year = 2021;
month = 5;
day = 15;
hour = 7;
minute = 0;
second = 0;


t_begin = datenum(year,month,day,hour,minute,second);

time_id = size(data,1);


for time_cur = 1:time_id
    step_s = floor((second+1/fs)/60);
    second = mod((second+1/fs),60);
    step_m = floor((minute+step_s)/60);
    minute = mod((minute+step_s),60);
    step_h = floor((hour+step_m)/24);
    hour = mod((hour+step_m), 24);
    t(time_cur) = datenum(year,month,day,hour,minute,second);
end
disp('get t successfully!');

%%
save(save_name,'xyz','data','t');

disp('process done');







