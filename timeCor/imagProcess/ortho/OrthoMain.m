%该程序为透视变换的主程序
% addpath('E:/Program Files (x86)/mexopencv-master');
% addpath('E:/Program Files (x86)/mexopencv-master/opencv_contrib');
% addpath('F:/workSpace/matlabWork/dispersion/imagProcess/ortho/coordination transformation')

%% gcp的真实世界坐标（以自己建的坐标系）和像素坐标
gcp_llh =[[22.5948224,114.8764800,7.41];
[22.5952560,114.8767744,7.53];
[22.5956768,114.8767360,5.09];
[22.5958368,114.8764544,5.14];
[22.5960064,114.8761216,5.11]];

% o_llh = [22.5957696,114.8766464,5.23];
o_llh = [22.5956768,114.8767360,5.09];

objectPoints = gcpllh2NED(o_llh,gcp_llh);
objectPoints = objectPoints';
imagePoints = [[258,389];[287,725];[814,1015];[1286,866];[1696,710]];
% % 相机畸变参数和内参（4000*1250）
% cameraMatrix.mat = [3073.8 0 2000;
%                 0 3067.1 1125;
%                 0 0 1]; 
% cameraMatrix.dist =[0.0986746953968013,-0.249452801912667,0,0,0];

% 相机畸变参数和内参（1920*1080）
cameraMatrix.mat = [1585.04404476623,0,960;0,1586.39568988226,540;0,0,1];
cameraMatrix.dist = [0.157285324524228,-0.493792014006428,0,0,0];

picNum = 500;
file_path = ".\1.jpg";
save_path =".\";
save_name ="沿岸与跨岸变化_Per";
%% 计算Re_c
[Re_c, tvec] = gcpForCamExtrinsic(cameraMatrix,objectPoints,imagePoints);

% Rnew = eye(3); %根据变换来修改
Rnew = Euler2Rotate(148,0,0);
Rnew = Rnew';

%% 进行变换 直接计算整张图的变换（利用单应性矩阵）后来发现没有必要进行整张图的采样
src = imread(file_path);
if ndims(src) == 3
    src = rgb2gray(src);
end
res = orthoRectification(cameraMatrix,src,Re_c,Rnew);
% imwrite(res,save_path+save_name+'.jpg');


%% 循环进行批量修改
% for i = 1:picNum
%     src = rgb2gray(imread(file_path+num2str(i)+'.jpg'));
%     res = orthoRectification(cameraMatrix.mat,src,Re_c,Rnew);
%     imwrite(res,save_path+num2str(i)+'.jpg');
% end
    