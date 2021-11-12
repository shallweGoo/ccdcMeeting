%% 读取像素
% src.pixel = rgb2gray(imread('C:\Users\49425\Desktop\cvtest\testRe_c\DJI_0046.JPG'));
% [src.row,src.col] = size(src.pixel);
src =rgb2gray(imread('C:\Users\49425\Desktop\cvtest\testRe_c\DJI_0046.JPG'));

%% 计算透视变换的矩阵
Re_c =[0.3988512556915239, 0.9156013978303278, -0.05090929310493908;
 -0.5823276196894563, 0.2957756709212429, 0.7572392593083778;
 0.7083870546389922, -0.2723799419601939, 0.6511504803328143];

Rnew = Euler2Rotate(90,0,0);
Rnew = Rnew';
% Rnew = eye(3);

cameraMatrix.mat = [3073.8 0 2000;
            0 3067.1 1125;
            0 0 1]; 
cameraMatrix.dist =[0.0986746953968013,-0.249452801912667,0,0,0];        
% H = cameraMatrix*Rnew*Rold'*inv(cameraMatrix);

%% remap变换完的图像大小
% x_min = 1e9;
% x_max = -1e9;
% y_min = 1e9;
% y_max = -1e9;
% 
% for i = 1:src.row
%     for j = 1:src.col
%          temp = H*[j,i,1]';
%          temp(1) = round(temp(1)/temp(3)); % 四舍五入
%          temp(2) = round(temp(2)/temp(3)); % 四舍五入
%          x_min = min(temp(1),x_min);
%          x_max = max(temp(1),x_max);
%          y_min = min(temp(2),y_min);
%          y_max = max(temp(2),y_max);
%     end
% end

%% 目标图像的大小
% dst.row = y_max - y_min + 1; %目标图像所具有的行数
% dst.col = x_max - x_min + 1; %目标图像所具有的列数
% dst.pixel = zeros(dst.row,dst.col); %目标图像的大小

% 从原图像变换过去，然后分配像素点，会出现黑点，因为无法保证一一对应
% for i = 1:src.row
%     for j = 1:src.col
%          temp = H*[j,i,1]';
%          temp(1) = round(temp(1)/temp(3)); % 四舍五入
%          temp(2) = round(temp(2)/temp(3)); % 四舍五入
%          dst.pixel(temp(2)-y_min+1,temp(1)-x_min+1) = src.pixel(i,j);
%     end
% end

% inv_H = inv(H);
% 
% % 从目标图像变换过去
%   for i = 1+y_min:dst.row+y_min
%       for j = 1+x_min:dst.col+x_min
%           dst2src = inv_H*[j,i,1]';
%           dst2src(1) = round(dst2src(1)/dst2src(3)); % 四舍五入
%           dst2src(2) = round(dst2src(2)/dst2src(3)); % 四舍五入
%           if(dst2src(1)>=1 && dst2src(2)>=1 && dst2src(2)<= src.row && dst2src(1)<= src.col)
%             dst.pixel(i-y_min,j-x_min) = src.pixel(dst2src(2),dst2src(1));
%           end
%       end
%   end
%% imshow
% res = uint8(dst.pixel);
% imshow(res);


res=orthoRectification(cameraMatrix,src,Re_c,Rnew);
imshow(res);
% name = 'DJ046Per';
% imwrite(res,'C:\Users\49425\Desktop\DJ046Per.JPG');





        
        