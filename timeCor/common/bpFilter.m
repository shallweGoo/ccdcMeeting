%% 该程序为对时间信号进行滤波的程序

% myBpFilter = load('testLp2_0.5_0.6.mat');
afterPic = zeros(height,width);
for i = 1:height
    for j = 1:width
        afterPic(i,j) = afterFilter{i,j}(1);
    end
end
afterPic = uint8(afterPic);
% imwrite(afterPic,"./afterPic1.jpg");

%% 低通滤波的方法
contrastPic=imread(strcat(file_path,'1.jpg'));
img_f=fftshift(fft2(double(contrastPic)));  %傅里叶变换得到频谱
d0=50;
height_mid=fix(height/2);  %是不是可以有其他取整方式？
width_mid=fix(width/2);  
img_lpf=zeros(height,width);
h = zeros(height,width);
for i=1:height
    for j=1:width
        d=sqrt((i-height_mid)^2+(j-width_mid)^2);   %理想低通滤波，求距离
        if d<=d0
            h(i,j)=1;
        else
            h(i,j)=0;
        end
        img_lpf(i,j)=h(i,j)*img_f(i,j);  
    end
end
img_lpf=ifftshift(img_lpf);    %反傅里叶变换
img_lpf=uint8(real(ifft2(img_lpf)));  %取实数部分
%%
figure(1);
imshow(afterPic);
% contrastPic=imread(strcat(file_path,'1.jpg'));
figure(2);
imshow(contrastPic);

figure(3)
imshow(img_lpf);
%%
file_path =  'F:\workSpace\matlabWork\dispersion\selectPic\4hzSample\';% 图像文件夹路径
contrastPic=imread(strcat(file_path,'1.jpg'));
afterPic = imread(".\afterPic1.jpg");
figure(4);
plot(contrastPic(:,1),'r');
hold on;
plot(afterPic(:,1),'b');
hold on;
cvFilter = imread('C:/Users/49425/Desktop/GsFilter1.jpg');
plot(cvFilter(:,1),'black');

% plot(img_lpf(:,1),'black')