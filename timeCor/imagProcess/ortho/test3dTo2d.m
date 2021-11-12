%运行前先要运行OrthoMain获取objectPoints的坐标，之后可以改进
addpath('E:/Program Files (x86)/mexopencv-master');
addpath('E:/Program Files (x86)/mexopencv-master/opencv_contrib');
addpath('./coordination transformation')
addpath(genpath('./ProcessFromVideo/'))
%% gcp的真实世界坐标（以自己建的坐标系）和像素坐标
gcp_llh =[
[22.5948224,114.8764800,7.41-5.09];
[22.5952560,114.8767744,7.53-5.09];
[22.5956768,114.8767360,5.09-5.09];
[22.5958368,114.8764544,5.14-5.09];
[22.5960064,114.8761216,5.11-5.09];

];


o_llh = [22.5952560,114.8767744,7.53-5.09];


objectPoints = gcpllh2NED(o_llh,gcp_llh);
objectPoints = objectPoints';
% 相机畸变参数和内参（1920*1080）
imagePoints = [[258,389];[287,725];[814,1015];[1286,866];[1696,710]];
cameraMatrix.mat = [1585.04404476623,0,960;0,1586.39568988226,540;0,0,1];
cameraMatrix.dist = [0.157285324524228,-0.493792014006428,0,0,0];

picNum = 500;
%% 计算Re_c

% Rnew = eye(3); %根据变换来修改
% Rnew = Euler2Rotate(123,0,0);
% Rnew = Rnew';


%%
src = imread(".\1.jpg");
tmp = src;
Rotate_ned2cs = Euler2Rotate(-148.5,0,0); %之前是148,
Rotate_ned2cs = Rotate_ned2cs';
objectPointsInCs = Rotate_ned2cs*objectPoints';
objectPointsInCs = objectPointsInCs';


[Re_c, tvec] = gcpForCamExtrinsic(cameraMatrix,objectPointsInCs,imagePoints);


%% 和Re_c对比用

% load('./ProcessFromVideo/gcpInfo_world.mat');
% load('./ProcessFromVideo/gcpInfo_firstFrame.mat');
% load('intrinsicMat.mat');
% 
% for i = 1:size(gcpInfo_world,1)
%     new_gcp(i).UVd = world2image(cameraMatrix,Re_c,tvec,gcpInfo_world(i,:)');
% end
% 
% imshow('./1.jpg');
% hold on;
% for k=1:length(gcp)
%     % Clicked Values
%     h1=plot(gcp(k).UVd(1),gcp(k).UVd(2),'ro','markersize',10,'linewidth',3);
%     text(gcp(k).UVd(1)+30,gcp(k).UVd(2),num2str(gcp(k).num),'color','r','fontweight','bold','fontsize',15)
% 
%     % New Reprojected Values
%     h2=plot(new_gcp(k).UVd(1),new_gcp(k).UVd(2),'yo','markersize',10,'linewidth',3);
%     text(new_gcp(k).UVd(1)+30,new_gcp(k).UVd(2),num2str(gcp(k).num),'color','y','fontweight','bold','fontsize',15)
% end



% for k =1:length(gcp)
% 
%     % Assumes Z is the known value; Reproject World XYZ from Clicked UVd
%     [xyzReproj(k,:)] = distUV2XYZ(intrinsics,extrinsics,[gcp(k).UVd(1); gcp(k).UVd(2)],'z',gcp(k).z);
% 
%     % Calculate Difference from Surveyd GCP World Coordinates
%     gcp(k).xReprojError=xyzCheck(k,1)-xyzReproj(k,1);
%     gcp(k).yReprojError=xyzCheck(k,2)-xyzReproj(k,2);
% 
% end

% rms=sqrt(nanmean((xyzCheck-xyzReproj).^2));
% 
% % Display the results
% disp(' ')
% disp('Horizontal GCP Reprojection Error')
% disp( ('GCP Num / X Err /  YErr'))
% 
% for k=1:length(gcp)
%     disp( ([num2str(gcp(k).num) '/' num2str(gcp(k).xReprojError) '/' num2str(gcp(k).yReprojError) ]));
% end

%%



crossRange =[0,100]; 
longRange =[0,73];
seaLevel = 0;
pixelInterval = 0.5;


testWorldCor1 = [crossRange(1);longRange(1);seaLevel];
testWorldCor2 = [crossRange(2);longRange(1);seaLevel];
testWorldCor3 = [crossRange(2);longRange(2);seaLevel];
testWorldCor4 = [crossRange(1);longRange(2);seaLevel];

% testWorldCor5 = [75;0;0];
% testWorldCor6 = [150;40;0];
% testWorldCor7 = [75;80;0];
% testWorldCor8 = [0;40;0];

testImageCor1 = world2image(cameraMatrix,Re_c,tvec,testWorldCor1);
testImageCor2 = world2image(cameraMatrix,Re_c,tvec,testWorldCor2);
testImageCor3 = world2image(cameraMatrix,Re_c,tvec,testWorldCor3);
testImageCor4 = world2image(cameraMatrix,Re_c,tvec,testWorldCor4);





% testImageCor5 = world2image(cameraMatrix,Re_c,tvec,testWorldCor5);
% testImageCor6 = world2image(cameraMatrix,Re_c,tvec,testWorldCor6);
% testImageCor7 = world2image(cameraMatrix,Re_c,tvec,testWorldCor7);
% testImageCor8 = world2image(cameraMatrix,Re_c,tvec,testWorldCor8);


tmp = insertShape(tmp,'Line',[testImageCor1(1) testImageCor1(2) testImageCor2(1) testImageCor2(2)],'LineWidth',2,'Color','blue');
tmp = insertShape(tmp,'Line',[testImageCor2(1) testImageCor2(2) testImageCor3(1) testImageCor3(2)],'LineWidth',2,'Color','blue');
tmp = insertShape(tmp,'Line',[testImageCor3(1) testImageCor3(2) testImageCor4(1) testImageCor4(2)],'LineWidth',2,'Color','blue');
tmp = insertShape(tmp,'Line',[testImageCor4(1) testImageCor4(2) testImageCor1(1) testImageCor1(2)],'LineWidth',2,'Color','blue');

% tmp = insertShape(tmp,'circle',[testImageCor5(1) testImageCor5(2) 20],'LineWidth',2,'Color','red');
% tmp = insertShape(tmp,'circle',[testImageCor6(1) testImageCor6(2) 20],'LineWidth',2,'Color','red');
% tmp = insertShape(tmp,'circle',[testImageCor7(1) testImageCor7(2) 20],'LineWidth',2,'Color','red');
% tmp = insertShape(tmp,'circle',[testImageCor8(1) testImageCor8(2) 20],'LineWidth',2,'Color','red');

% tmp = insertShape(tmp,'circle',[258 389 20],'LineWidth',2,'Color','green');
% tmp = insertShape(tmp,'circle',[287 725 20],'LineWidth',2,'Color','green');

figure(1);
imshow(tmp);

% sampleHeight = 0:0.4:200;
% sampleWidth = 0:0.4:100; %相隔0.5m采样
% resImage = zeros(size(sampleHeight,2),size(sampleWidth,2));
% wc = 1;
% for i = 0:0.4:100
%     hc = 1;
%     for j = 0:0.4:200
%         samplePointWorldCor = world2image(cameraMatrix,Re_c,tvec,[j;i;0]);
%         if(samplePointWorldCor(1)>size(src,2) || samplePointWorldCor(1)<1 || samplePointWorldCor(2)>size(src,1) || samplePointWorldCor(2)<1)
%             pixelValue = 0;
%         else
%             pixelValue = src(samplePointWorldCor(2),samplePointWorldCor(1));
%         end
%         resImage(hc,wc) = pixelValue; 
%         hc = hc+1;
%     end
%     wc = wc+1;
% end    
% resImage = uint8(resImage);


resImage = downSample(src,crossRange,longRange,pixelInterval,pixelInterval,cameraMatrix,Re_c,tvec); %下采样函数
figure(2);
imshow(resImage);

