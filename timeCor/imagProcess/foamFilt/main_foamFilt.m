
clear ;
img = imread("foam_area.jpg");
[height,width] = size(img);


% 
D0 = 10;
H = gaussfilter(width,height,D0);
% H = elliptic_lp_filter(height,width,60,20,20,3);

mesh(1:height,1:width,H);

[H_fs,H_ps]=fft2Analysis(H);

figure(1);
subplot(2,1,1);imshow(H_fs,[]);title('傅里叶变换频谱图');
subplot(2,1,2);imshow(H_ps,[]),title('功率谱');

aft_img = imagFiltUseDiffFilter(img,H);

[aft_img_fs,~]=fft2Analysis(aft_img);
[img_fs,~] = fft2Analysis(img);


figure(2);
subplot(2,1,1);imshow(img_fs,[]),title('原图傅里叶变换频谱图');
subplot(2,1,2);imshow(aft_img_fs,[]);title('变换后图片傅里叶变换频谱图');


figure(3);
subplot(2,1,1);imshow(img);title('原图');
subplot(2,1,2);imshow(aft_img),title('滤波后的图');