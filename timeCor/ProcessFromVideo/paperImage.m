%% 设置
rootPath = 'H:/imgResult/';
foldName = ["downSample/" "filt/" "resMat/" "orthImg/" "gaussFilt/"];
ds_image_savePath =  [rootPath char(foldName(1))];
filter_image_savePath = [rootPath char(foldName(2))];
mat_savePath = [rootPath char(foldName(3))];
% intrinsics_name = 'intrinsicMat_phantom4rtk.mat';
intrinsics_name = 'intrinsicMat_mavir_pro_1080.mat';
fs = 4;


%% 画x轴的横断面
step7.roi_path = [mat_savePath 'GRID_roiInfo.mat'];
step7.extrinsicFullyInfo_path = [mat_savePath 'extrinsicFullyInfo.mat'];
step7.unsolvedPic_path = filter_image_savePath;
step7.savePath = mat_savePath;


step7.inputStruct.roi_x = [0,300];
step7.inputStruct.roi_y = [50,150];
step7.inputStruct.dx = 0.5;
step7.inputStruct.dy = 0.5;

step7.inputStruct.x_dx = 0.5;
step7.inputStruct.x_oy = 0;
step7.inputStruct.x_rag = [0,300];

step7.inputStruct.y_dy = 0.5;
step7.inputStruct.y_ox = 0;
step7.inputStruct.y_rag = [50,150];

roiImage(step7);




%% 高斯低通滤波效果图

% 选取一个横断面，做一个滤波后的图

step7.roi_path = [mat_savePath 'GRID_roiInfo.mat'];
step7.extrinsicFullyInfo_path = [mat_savePath 'extrinsicFullyInfo.mat'];
step7.unsolvedPic_path = ds_image_savePath;
step7.savePath = './tmp_res/';
if ~isfolder(step7.savePath)
     mkdir(step7.savePath);
end


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

cmpGaussFilter(step7);

disp('-----------step7 finish--------------- ');

%%

disp('----------step8 start--------------- ');

step8.pixelInst_path =  './tmp_res/pixelImg.mat';
step8.savePath = './tmp_res/';

if ~isfolder(step8.savePath)
     mkdir(step8.savePath);
end


rotImg(step8.pixelInst_path,step8.savePath);

disp('----------step8 finish--------------- ');

disp('----------ALL STEP FINISH!!--------------- ');


%% 高斯滤波对比图

I1 = imread('./tmp_res/1.jpg');
I2 = imread('./tmp_res/2.jpg');

plot(I1(:, 100), 'k');
hold on;
plot(I2(:, 100), 'linewidth',5 ,'color','r');
axis equal;
axis tight;

set(gca,'XTick',[0:50:600]);
set(gca,'xticklabel',[0:50:600] .* 0.5);
set(gca,'FontSize',30);
legend('origin intensity ','Gauss filter intensity');

xlabel('cross-shore(m)','fontsize', 30);
ylabel('pixel intensity', 'fontsize', 30);






%% 结果图


% imagesc(I);
% colormap(gray)
% 
% set(gca,'XTick',[0:20:200]);
% set(gca,'YTick',[0:50:600]);
% % set(gca,'yticklabel',[0:100:600] .* 0.5);
% % set(gca,'xticklabel',[0:10:200] .* 0.5);
% xlabel('long shore (m)');
% ylabel('cross shore (m)');
% 
% 
% hold on;





h = bathy.h_final;
h(1:50, :) = nan;









set(gcf,'RendererMode','manual','Renderer','painters');
cmap = colormap( 'jet' );
colormap( flipud( cmap ) );

% clf;
world.x = 0 : 1 : world.longShoreRange;
world.y = 0 : 1 : world.crossShoreRange;
subplot(1,2,2)
pcolor(world.x, world.y, h);
shading flat
caxis([0 5]); %设置深度的显示范围
set(gca, 'ydir', 'nor');
axis equal;
axis tight;
xlabel('long shore (m)');
ylabel('cross shore (m)');
title( 'bathymetry result' );
h=colorbar('peer', gca);
set(h, 'ydir', 'rev');
set(get(h,'title'),'string', 'h (m)');
set(gca,'ydir','reverse');



I = imread('H:/imgResult/orthImg/finalOrth_1603524600000.jpg');
subplot(1,2,1);
imshow(I);