addpath(genpath('./ProcessFromVideo/CoreFunctions/'));
% rootPath = 'F:/workSpace/matlabWork/imgResult/';
rootPath = 'H:/imgResult/';
foldName = ["downSample/" "filt/" "resMat/" "orthImg/" "gaussFilt/"];
ds_image_savePath =  [rootPath char(foldName(1))];
filter_image_savePath = [rootPath char(foldName(2))];
mat_savePath = [rootPath char(foldName(3))];
% intrinsics_name = 'intrinsicMat_phantom4rtk.mat';
intrinsics_name = 'intrinsicMat_mavir_pro_1080.mat';
fs = 4;
%% step1
% videoPath ： 视频的绝对路径
% savePath ： 存放结果图片的绝对路径
% fs ： 采样频率
% videoRange ： 为一个1*2数组，videoRange(1)为截取视频的开始时间，videoRange(2)为视频结束时间，单位为秒
step1.videoPath = 'E:/海浪原始数据/2021.01.21双月湾/2021_01_21晚/DJI_0183.MOV'; % 
step1.savePath = ds_image_savePath;
step1.filterPath = filter_image_savePath;
step1.fs = fs;
step1.d0 = 50;
step1.videoRange = [300, 600]; %5分钟的截取时长,一共有（end-begin）*fs张采样图片

%% step2
% 输入参数：
% gcp_llh ： gcp的经纬高，gps得出
% o_llh ： local坐标系原点的经纬高，gps得出
% euler_ned2new ： ned坐标系转local坐标系的欧拉角，一般只和偏航有关 1*3矩阵,对应yaw,pitch,roll
% savePath ： 存放数组的绝对路径
step2.world.savePath = mat_savePath;
step2.world.gcp_llh = [
    [22.5960988,114.8759359,0];
    [22.5959546,114.8762086,0];
    [22.5958634,114.8765426,0.1];
    [22.5952071,114.8767393,2.2];
    [22.5948237,114.8764282,2.1];
];
step2.world.o_llh = [22.5958634,114.8765426,0.1];
step2.world.euler_ned2new = [-148.5, 0, 0];
step2.world.uav_llh = [22.596833 114.877683 88];

%   fs ： 采样频率
%   mode ： 模式1：获取gcp在函数内定义的信息。模式2：获取除了之前的信息之外，令加入了gcp模板
ff_name = string(ls(ds_image_savePath));
ff_name = ff_name(3);%为第一帧的图片名称
ff_name = char(ff_name);
step2.UV.imagePath = [ds_image_savePath ff_name];
step2.UV.gcpSavePath = mat_savePath;
step2.UV.fs = fs;
getGcpInfo_UV(step2, 1);


%% step3
% 第三步 以第一帧获取整合gcp数据（将UV数据和World数据结合）,以及第一帧的外参
% 函数原型 matchGcp(gcpInfo_UV_path,gcpInfo_world_path,intrinsic_path,savePath,mode)
% 输入参数：
% gcpInfo_UV_path：gcp_UV信息mat格式数据的绝对路径
% gcpInfo_world_path：gcp_world信息mat格式数据的绝对路径
% intrinsic_path：1*11的结构体，相机内参
% savePath：gcp全部信息整合的结构体与第一帧图片相机外参存放的绝对路径

step3.gcpInfo_UV_path = [mat_savePath 'gcpInfo_firstFrame.mat'];
step3.gcpInfo_world_path = [mat_savePath 'gcpInfo_world.mat'];
step3.intrinsic_path = ['./neededData/',intrinsics_name];
step3.savePath = mat_savePath;

% mode = 1： 非线性拟合计算外参
% mode = 2：利用姿态角直接计算外参
step3.mode = 1; 
%非线性拟合的初始值。

% 前三为相机在NED坐标系下的坐标
% 后三为相机的roll, yaw, pitch
% rtk版本
% step3.extrinsicsInitialGuess = [50  50  -90 deg2rad(-26.7) deg2rad(0) deg2rad(-100)];
% mavoc
step3.extrinsicsInitialGuess = [110  120  -87 deg2rad(-16) deg2rad(0) deg2rad(-114)];
step3.extrinsicsKnownsFlag = [0,0,0,0,0,0];

%% step4
% gcp_path ： 由step3所得到的gcp的全部信息的mat格式数据的绝对路径
% savePath ： 最终得到的scp信息的存放路径
% fs ：采样频率
% brightFlag：颜色映射选项，可选为'bright'和'dark' 分别对应 白色为高像素值映射与黑色为高像素值映射
step4.gcp_path = [mat_savePath 'gcpFullyInfo.mat'];
step4.savePath = mat_savePath;
step4.fs = fs;
step4.brightFlag = 'bright'; 

%% step5
% 输入参数：
% scp_path ： scp信息的mat格式数据绝对路径
% gcp_path ： gcp信息的mat格式数据绝对路径
% rotateInfo_path ： 第一帧的旋转信息的mat格式数据绝对路径
% unsovledExtrinsic_pic_path ： 待计算外参图片的存放绝对路径
% savePath ： 全部的外参矩阵的以及相关信息的存放绝对路径，为输出路径
% mode ：模式1为利用scp信息，模式2为利用模板信息
step5.scp_path =[mat_savePath 'scpInfo_firstFrame.mat'];
step5.gcp_path = [mat_savePath 'gcpFullyInfo.mat'];
step5.rotateInfo_path = [mat_savePath 'RotateInfo_firstFrame.mat']; %这一个是matchGcp得到的第一帧的外参
step5.unsovledExtrinsic_pic_path = ds_image_savePath;
step5.savePath = mat_savePath;
step5.mode = 1;
step5.fs = fs;


%% step6
% 第六步，选择感兴趣的区域,主要是获取该区域的local_xyz信息
% 函数原型 chooseRoi(gcpInfo_path,rotateInfo_path,roi_x,roi_y,pixel_resolution,savePath)
% 输入参数：
% gcpInfo_path：gcp信息的mat格式数据绝对路径
% rotateInfo_path ： 第一帧的旋转信息的mat格式数据绝对路径
% roi_x,roi_y ：感兴趣区域的x轴y轴范围，都为1*2数组
% pixel_resolution ： 每个像素点相隔的距离
% savePath ： 区域信息的储存路径
step6.gcpInfo_path = [mat_savePath 'gcpFullyInfo.mat'];
step6.rotateInfo_path = [mat_savePath 'RotateInfo_firstFrame.mat'];
step6.roi_x = [0,300]; % 本来是300
step6.roi_y = [0,150];
%将NED->Local坐标系的参数放在这一步来实现
% step6.local_angle = -148.5; %GEO(NED)->Local(world)的偏航角，右手定则定方向
step6.local_angle = -148.5;
step6.local_origin = [0,0]; %NED和world的原点偏置，一般都是0
step6.pixel_resolution = 0.5;
step6.savePath = mat_savePath;

step6.local_flag_input = 1;%输入的参数相对于world坐标系的。


%% step7
% 输入参数：
% roi_path ： roi息的mat格式数据绝对路径
% extrinsicFullyInfo_path ：所有图片外参的mat格式数据的绝对路径
% unsolvedPic_path ： 待解决图片的存放绝对路径
% savePath ： 输出路径，输出像素点图片

% inputStruct ： 输入的结构体，应当包含roi_x,roi_y,dx,dy,x_dx,x_oy,x_rag,y_dy,y_ox,y_rag,localFlag
% localFlag = 0 为世界坐标系， = 1 为当地坐标系
% roi_x,roi_y：需要进行转换的区域，在local坐标系或者在world坐标系中都可以,不过要设置标志位localFlag
% dx,dy：为roi_x,roi_y的像素分辨率，单位为m
% x_dx：为 x_transect(Alongshore)方向上的像素分辨率，单位为m
% x_oy：为x_transect起点的y值
% x_rag:x_transect的范围，x的范围
% y_dy,y_ox,y_rag 同上解释
step7.roi_path = [mat_savePath 'GRID_roiInfo.mat'];
step7.extrinsicFullyInfo_path = [mat_savePath 'extrinsicFullyInfo.mat'];
step7.unsolvedPic_path = filter_image_savePath;
step7.savePath = mat_savePath;


step7.inputStruct.roi_x = [0,300];
step7.inputStruct.roi_y = [0,100];
step7.inputStruct.dx = 0.5;
step7.inputStruct.dy = 0.5;

step7.inputStruct.x_dx = 0.5;
step7.inputStruct.x_oy = 0;
step7.inputStruct.x_rag = [0,300];

step7.inputStruct.y_dy = 0.5;
step7.inputStruct.y_ox = 0;
step7.inputStruct.y_rag = [0,100];
%% step8

% pixelInst_path ： 像素信息的结构的绝对路径
% savePath ： 储存信息
step8.pixelInst_path = [mat_savePath 'pixelImg.mat'];
step8.savePath = [rootPath char(foldName(4))];


