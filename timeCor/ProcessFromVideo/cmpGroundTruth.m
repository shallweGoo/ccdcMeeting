%�ó������ڱȽϽ��мƽ���ʵ����
%��Ҫ�Ĳ���
%1������ת��
%2����ͼ�ϵĽ�����Ӧ

dbstop if all error  % �������

addpath(genpath('F:/workSpace/matlabWork/seaBathymetry/'));
addpath(genpath('F:/workSpace/matlabWork/seaBathymetry/ProcessFromVideo/CoreFunctions/'));
mat_savePath = 'H:/imgResult/resMat/';
ds_image_savePath =  'H:/imgResult/downSample/';
fs = 4;

world.crossShoreRange = 300;
world.longShoreRange = 100;

world.x = 0 : 1 : world.longShoreRange;
world.y = 0 : 1 : world.crossShoreRange;
%% 1����ȡtxt�ļ���������ת��
data = load('F:/workSpace/matlabWork/����/excel/total.txt');
% o_llh2 = [22.5952560,114.8767744,7.53-5.09];
% op2 = gcpllh2NED(o_llh, o_llh2);
% op2 = op2';
% other_origin = (Rotate_ned2cs*op2')';

o_llh = [22.5958634,114.8765426, 0.1];
% o_llh = [22.59567364 114.87665961 0];
%{
        world.gcp_llh = [
        [22.5948224,114.8764800,7.41-5.09];
        [22.5952560,114.8767744,7.53-5.09];
        [22.5956768,114.8767360,5.09-5.09];
        [22.5958368,114.8764544,5.14-5.09];
        [22.5960064,114.8761216,5.11-5.09];
        ]
%}


objectPoints = gcpllh2NED(o_llh, data);
objectPoints = objectPoints';



Rotate_ned2cs = Euler2Rotate(-148.5,0,0); %֮ǰ��148,
Rotate_ned2cs = Rotate_ned2cs';
objectPointsInCs = Rotate_ned2cs*objectPoints';
objectPointsInCs = objectPointsInCs'; %��һ��ת��Ϊ�Խ�����ϵ�µ�����


%% 2����ͼ�ϵ������Ӧ����
% ����ת��Ϊ����

% Load and Display initial Oblique Distorted Image

step7.roi_path = [mat_savePath 'GRID_roiInfo.mat'];
step7.extrinsicFullyInfo_path = [mat_savePath 'extrinsicFullyInfo.mat'];

step7.L=string(ls(ds_image_savePath));
step7.L=step7.L(3:end); % ǰ����Ϊ��ǰĿ¼.���ϼ�Ŀ¼..
I=imread(strcat(ds_image_savePath, step7.L(1)));
figure;
hold on;

imshow(I);
hold on;
title('Pixel Instruments');
load(step7.roi_path);
load(step7.extrinsicFullyInfo_path);

step7.Extrinsics=localTransformExtrinsics([0,0], -148.5 ,1, extrinsics);
step7.extrinsics_ff=step7.Extrinsics(1,:);
% Determine UVd Points from intrinsics and initial extrinsics
[step7.UVd] = xyz2DistUV(intrinsics, step7.extrinsics_ff, objectPointsInCs); %����chooseRoi��ѡ�������������е�xyz��Ϣ��ֵ��õ�z�����ø�ֵ����uv����

% Make A size Suitable for Plotting
step7.UVd = reshape(step7.UVd, [], 2);
plot(step7.UVd(:,1), step7.UVd(:,2), '*');
xlim([0 intrinsics(1)]);
ylim([0 intrinsics(2)]);

% Allows for the instruments to be plotted before processing


%����ԭ��
% [UVo] = xyz2DistUV(intrinsics,extrinsics_ff, other_origin); %����chooseRoi��ѡ�������������е�xyz��Ϣ��ֵ��õ�z�����ø�ֵ����uv����
% 
% % Make A size Suitable for Plotting
% UVo = reshape(UVo, [], 2);
% plot(UVo(:,1), UVo(:,2),'r*');
% xlim([0 intrinsics(1)]);
% ylim([0  intrinsics(2)]);
    
    

pause(1)






%% seaDepth;
load('F:/workSpace/matlabWork/seaBathymetry/data_struct.mat');
load('F:/workSpace/matlabWork/seaBathymetry/bathy.mat');

r = size(xyz, 1);
c = size(xyz, 2);
% load('F:\workSpace\matlabWork\dispersion\selectPic\afterPer\˫����ڶ���任��\�任��ͼƬ14��ش���\���ս��\afterInsert_t_cor_det&cor(50_550)_psd(0.05_0.2).mat');


realDepth = load('F:/workSpace/matlabWork/����/excel/totalDEPTH.txt');



%%
closest_point_idx = -1;
seaDepth = bathy.h_final;

depth = reshape(seaDepth,[], 1);
groundTruth = nan(size(depth,1), 1);
for i = 1 : r
    if xyz(i, 1) <= 70 % x>90��ȥ����
        continue;
    end
    ground_idx = -1;
    dis = 1e9;
    for j = 1 : size(objectPointsInCs, 1) %�м�����ʵ����data��
            ground_idx = i;
            every_dis = sqrt(abs(xyz(i,1)-objectPointsInCs(j,1))^2+abs(xyz(i,2) + 50 -objectPointsInCs(j,2))^2); %yΪ50-150����Ҫ��50
            if(every_dis<dis) %���С�������
                closest_point_idx = j;
                dis = every_dis;
            end
    end
    if ground_idx ~= -1
        groundTruth(ground_idx) = realDepth(closest_point_idx);
    end
        
end

groundTruth_mat = reshape(groundTruth, size(seaDepth, 2), size(seaDepth,1));
groundTruth_mat = rot90(groundTruth_mat,3);

ground_truth_tidy = tidyFix(groundTruth_mat, 0.4);


%% �ֿ���ͼ, ���㷨�ı�ʾ
close all;
seaDepth(1:50, :) = nan;
subplotBathy(world, ground_truth_tidy, seaDepth);
figure;
target_col = 100;
subplot(3, 1, 1)
plot(-ground_truth_tidy(:, target_col), 'k');
hold on;
plot(-seaDepth(:, target_col),'color','r','linewidth',2);

legend('ground truth ','bathymetry');
axis tight;
xlabel('cross shore(m)');
ylabel('water depth(m)');
title(['transect depth in longshore ' num2str(target_col) 'm']);
hold on;

err_100m = abs(ground_truth_tidy(:, target_col) - seaDepth(:, target_col));
err_id = find(~isnan(err_100m));
err_real = err_100m(err_id);
err = sqrt(sum(err_real) / length(err_real))


target_col = 75;
subplot(3, 1, 2)
plot(-ground_truth_tidy(:, target_col), 'k');
hold on;
plot(-seaDepth(:, target_col),'color','r','linewidth',2);

legend('ground truth ','bathymetry');
axis tight;
xlabel('cross shore(m)');
ylabel('water depth(m)');
title(['transect depth in longshore ' num2str(target_col) 'm']);

err_100m = abs(ground_truth_tidy(:, target_col) - seaDepth(:, target_col));
err_id = find(~isnan(err_100m));
err_real = err_100m(err_id);
err = sqrt(sum(err_real) / length(err_real))


target_col = 10;
subplot(3, 1, 3)
plot(-ground_truth_tidy(:, target_col), 'k');
hold on;
plot(-seaDepth(:, target_col),'color','r','linewidth',2);

legend('ground truth ','bathymetry');
axis tight;
xlabel('cross shore(m)');
ylabel('water depth(m)');
title(['transect depth in longshore ' num2str(target_col) 'm']);

err_100m = abs(ground_truth_tidy(:, target_col) - seaDepth(:, target_col));
err_id = find(~isnan(err_100m));
err_real = err_100m(err_id);
err = sqrt(sum(err_real) / length(err_real))

%% ����cBathy֮���������


close all;
load('cBathy.mat');
seaDepth = bathy.fCombined.h';
seaDepth(1:50, :) = nan;
subplotBathy(world, ground_truth_tidy, seaDepth);
figure;
target_col = 100;
subplot(3, 1, 1)
plot(-ground_truth_tidy(:, target_col), 'k');
hold on;
plot(-seaDepth(:, target_col),'color','r','linewidth',2);

legend('ground truth ','cBathy');
axis tight;
xlabel('cross shore(m)');
ylabel('water depth(m)');
title(['transect depth in longshore ' num2str(target_col) 'm']);
hold on;

err_100m = abs(ground_truth_tidy(:, target_col) - seaDepth(:, target_col));
err_id = find(~isnan(err_100m));
err_real = err_100m(err_id);
err = sqrt(sum(err_real) / length(err_real))


target_col = 75;
subplot(3, 1, 2)
plot(-ground_truth_tidy(:, target_col), 'k');
hold on;
plot(-seaDepth(:, target_col),'color','r','linewidth',2);

legend('ground truth ','cBathy');
axis tight;
xlabel('cross shore(m)');
ylabel('water depth(m)');
title(['transect depth in longshore ' num2str(target_col) 'm']);

err_100m = abs(ground_truth_tidy(:, target_col) - seaDepth(:, target_col));
err_id = find(~isnan(err_100m));
err_real = err_100m(err_id);
err = sqrt(sum(err_real) / length(err_real))


target_col = 10;
subplot(3, 1, 3)
plot(-ground_truth_tidy(:, target_col), 'k');
hold on;
plot(-seaDepth(:, target_col),'color','r','linewidth',2);

legend('ground truth ','cBathy');
axis tight;
xlabel('cross shore(m)');
ylabel('water depth(m)');
title(['transect depth in longshore ' num2str(target_col) 'm']);

err_100m = abs(ground_truth_tidy(:, target_col) - seaDepth(:, target_col));
err_id = find(~isnan(err_100m));
err_real = err_100m(err_id);
err = sqrt(sum(err_real) / length(err_real))




%% ������

% err_100m = abs(ground_truth_tidy(:, target_col) - seaDepth(:, target_col));
% err_id = find(~isnan(err_100m));
% err_real = err_100m(err_id);
% err = sqrt(sum(err_real) / length(err_real))

%%

figure(1);
plotBathy(world, groundTruth_mat);

figure(2);
plotBathy(world, seaDepth);




%%





%% 




%% 
% gt_grid = load('F:\workSpace\matlabWork\gt_grid.mat');
% al_grid = load('F:\workSpace\matlabWork\al_grid.mat');

err_grid= abs(groundTruth_mat - seaDepth);

cmap = colormap( 'jet' );
colormap( flipud( cmap ) );  % ������ɫ

row = size(err_grid,1);
col = size(err_grid,2);

% shading flat;

pcolor(1:col,1:row,err_grid);
caxis([0 2]); %������ȵ���ʾ��Χ
set(gca, 'ydir', 'nor');
axis equal;
axis tight;
h = colorbar('peer', gca);
set(h, 'ydir', 'rev');
set(get(h,'title'),'string', 'err\_h (m)');
set(gca,'ydir','reverse');
% set(gca,'XTick',1:col,'YTick',1:row);  % ��������
% axis image xy;  % ��ÿ��������ʹ����ͬ�����ݵ�λ������һ��

shading flat;
title('���׵���ͼ���ֵ');

% plot(err_grid(:, 100));


%% 
err_2m = 0;
    for i = 1:c
        for j = 1:r
            if groundTruth_mat(j,i)>=3
                err_2m = err_2m + abs(groundTruth_mat(j,i)-seaDepth(j,i));
                break;
            end
        end
    end
err_2m = err_2m/c



%% 
% load('F:\workSpace\matlabWork\dispersion\selectPic\afterPer\˫����ڶ���任��\�任��ͼƬ14��ش���\���ս��\afterInsert_t_cor_det&cor(50_550)_psd(0.05_0.2).mat');
% depth = interpolation.seaDepth;
load('F:/workSpace/matlabWork/gt.mat');
depth = groundTruth_mat;


row_idx = 1;
col_idx = 1;
for i = 1:2:picInfo.row
    col_idx = 1;
    for j = 1:2:picInfo.col
        om_sum = 0;
        cnt1 = 0;
        cnt2 = 0;
        for l = i:i+2
            for k = j:j+2
                if l <= picInfo.row
                    if k <= picInfo.col
                        if isnan(depth(l,k))
                            cnt2 = cnt2 + 1;
                        else
                            om_sum = om_sum + depth(l,k);
                        end
                        cnt1 = cnt1 + 1;
                    end
                end
            end
        end
        if cnt1 <= 2*cnt2 %�����Чֵ���ֳ���һ�룬��ô���������Ϊ��Чֵ
            om_sum = nan;
        else 
            om_sum = om_sum / cnt1;
        end
        om_grid(row_idx,col_idx) = om_sum;
        col_idx = col_idx + 1;
    end
    row_idx = row_idx + 1;
end

clear depth;

gridPlot(om_grid);


%% 
figure;
s = load('C:\Users\49425\Desktop\S.mat');
subplot(1,3,1);
gridPlot(s.om_grid);
title("����ͧ�������",'fontsize',30,'color','b');
v = load('C:\Users\49425\Desktop\V.mat');
subplot(1,3,2);
gridPlot(v.om_grid);
title("�㷨��������",'fontsize',30,'color','b');
subplot(1,3,3);
err_grid= abs(s.om_grid-v.om_grid);
gridPlot(err_grid);
title('���ֵ','fontsize',30,'color','r');

%
figure;
tmp = imread("F:/workSpace/matlabWork/imgResult/orthImg/finalOrth_1603524600000.jpg");
tmp = insertShape(tmp,'Line',[20 1 20 401],'LineWidth',1,'Color','r');
tmp = insertShape(tmp,'Line',[120 1 120 401],'LineWidth',1,'Color','r');

subplot(1,3,1);
imshow(tmp);


cs_dis = length(seaDepth);
r = size(groundTruth_mat,1);
c = size(groundTruth_mat,2);



cmp_col = 20;
subplot(1,3,2);
plot((1:cs_dis)*0.5,seaDepth(:,cmp_col),'r');
hold on;
plot((1:cs_dis)*0.5,groundTruth_mat(:,cmp_col),'b');
legend('��������',"��ʵ����");
xlim([90, 180]);
ylim([0, 5]);
xlabel('�簶����(m)');
ylabel('��ˮ���(m)');
title('�ذ�����(10m)','fontsize', 30, 'color', 'b');


subplot(1,3,3);
cmp_col = 120;

plot((1:cs_dis)*0.5,seaDepth(:,cmp_col),'r');
hold on;
plot((1:cs_dis)*0.5,groundTruth_mat(:,cmp_col),'b');
legend('��������',"��ʵ����");
xlim([90, 180]);
ylim([0, 5]);
xlabel('�簶����(m)');
ylabel('��ˮ���(m)');
title('�ذ�����(60m)','fontsize',30,'color','b');

