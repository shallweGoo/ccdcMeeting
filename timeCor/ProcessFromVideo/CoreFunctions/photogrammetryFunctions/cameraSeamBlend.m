%% cameraSeamBlend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function takes rectifications from different cameras (but same grid)
%  and merges them together into a single rectification. To do this, the function
%  performs a weighted average where pixels closest to the seams are not
%  represented as strongly as those closest to the center of the camera
%  rectification.


%  Input:
%  IrIndv= A NxMxCxK matrix where N and M are the grid lengths for the
%  rectified image. C is the number of color channels (3 for rgb, 1 for bw)
%  and K is the number of cameras. Even if using bw images, the matrix must
%  be four dimensions with C=1; Each k entry is a rectified image of a
%  camera.


%  Output:
%  Ir= A NxMxC uint8 matrix of the merged rectified image. N and M are the grid lengths for the
%  rectified image. C is the number of color channels (3 for rgb, 1 for bw)
%  and K is the number of cameras. Even if using bw images, the matrix must
%  be four dimensions with C=1;


%  Required CIRN Functions:
%  None

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%该函数的作用为多个相机视野对同一个视野进行校正


function [Ir] =cameraSeamBlend(IrIndv)

%% Section 1:  Weighting Functions

% Intialize Weighting Functions For seams
[m,n,c,camnum]=size(IrIndv(:,:,:,:)); % 参数说明如上m*n的区域，c = 1为灰度图，=3为rgb，camnum 为相机数
IrIndvW = zeros([m n c camnum]);%初始化一个结构体用于存放结果
indvW = IrIndvW ;
IrIndv=double(IrIndv);




%% Section 2: Determine Weighting Function for Each Camera
for k=1:camnum
    
    % Pull Individual Rectification
    ir=((IrIndv(:,:,:,k)));
    
    % Find Points that Are [0 0 0] rgb and turn them to nan; Assuming if
    % one channel has exactly 0, they all will.
    bind=find(ir(:)==0);
    ir(bind)=nan;
    % Turn image into binary image (1 for nan, 0 for nonnan).
    binI=isnan(ir(:,:,1));
    
    % For each pixel that =0 (non-nan pixels), find shortest distance to pixel that =1 (nan pixels, edges). For
    % pixels that ==1 (nan pixels), the distance is 0. Valid non-nan pixels
    % near the edges will have smaller D than those in the center of the
    % rectified image.
    D = bwdist(binI);%计算非nan像素点和nan像素点的最短欧式距离
    
    % Weight all Pixels Equally if all are non-zero (W is inf, No edges or nanned areas).
    if( isinf(max(D(:))) )
        W = ones(size(D));%这种情况所选的区域都是可用点，没有超过图片或是其他范围，选到的点都有像素值
    else
        
        % Normalize Distances by max Distance to create Weighting Function for pixels.
        % Pixels furthest away from the edges (Largest D) will have maximum
        % weights near 1. Pixels near edges(smallest D), weighed less.
        W = D ./ max(D(:));%归一化距离
    end
    
    % Replicate the Weighting Function for Each Color Channel, Remove any
    % nans
    W = repmat(W, [1 1 c]);%归一化之后的每一层都是同一个矩阵
    W(isnan(W(:))) = 0; % W就是一个权重函数，用距离当作权重因子
    
    % Apply Weight to OrthoPhoto and save in Matrix
    IrIndvW(:,:,:,k)=ir.*(W); %经过权重计算的图像，不知道有什么意义
    % Save Weights to perform Weighted Average
    indvW(:,:,:,k)=W;
end





%% Section 3: Calculate Weighted Average

% Perform Weighted Average and format
Ir=uint8(nansum(IrIndvW,4)./nansum(indvW,4));
%加权方式减少多个相机视距造成的像素差


%82行乘，94行除
%若有多个相机，那么这一步就是取多个相机经过加权的像素平均值,若只有一个，那么输出值与输入值相同，神奇
end