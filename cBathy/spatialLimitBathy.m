function [subG, subXYZ, camUsed] = spatialLimitBathy(G, xyz, cam, xm, ym, params, kappa )

% spatialLimitBathy -- extract appropriate data from stack for 
%   processing in the vicinity of xm, ym. 
% 该函数的作用是从xm,ym提取合适的数据出来进行计算，
% 包括从G中得到subG,
% xyz中得到subXYZ，和cam中得到camUsed.
% 其中xm、ym都为向量。
% 确定（xp,yp）的情况

%
% [subG, subXYZ, camUsed] = spatialLimitBathy( G, xyz, cam, xm, ym, params, kappa )
%

% these are the indices of xy data that are within our box 
% 提取（xm+-Lx,ym+-Ly）这个区域的点，xm,ym是向量
idUse = find( (xyz(:,1) >= xm-params.Lx*kappa) ...
	 &    (xyz(:,1) <= xm+params.Lx*kappa) ...
	 &    (xyz(:,2) >= ym-params.Ly*kappa) ...
	 &    (xyz(:,2) <= ym+params.Ly*kappa) );

% first decimate to maxNPix per tile, then drop minority cameras at seams.
% Otherwise you end up limited only by maxNPix and the weightings get funny
% for tiles with partial coverage.

del = max(1, length(idUse)/params.maxNPix); % del = 所使用区域中的像素点/最大允许的像素点 （是最大像素点的几倍）
idUse = idUse(round(1: del: length(idUse))); %进行提取（缩放像素点的数量），再减少一些像素点
subG = G(:,idUse); %提取这个区域的点的傅里叶变换
subXYZ = xyz(idUse,:);%提取出这个区域的xyz
cams = cam(idUse);%cams为监控的点的摄像头使用信息


% if on seam, limit to the dominant camera bypixel count
uniqueCams = unique(cams);  %返回不包含重复项的cams值
for i = 1: length(uniqueCams)
    N(i) = length(find(cams==uniqueCams(i))); %这个摄像头的值有几个
end

pick = [];
camUsed = -1;

if exist('N') %检查变量区是否有N这个变量
    [~,pickCam] = max(N); %返回最大的N值，也就是所有的xyz点里面最多用了几个摄像头，返回这个最多使用的摄像头数量的下标索引
    pick = find(cams==uniqueCams(pickCam)); %返回最多摄像头数量对应的索引
    camUsed = uniqueCams(pickCam);% camUsed就是最大的摄像头使用情况
end
subG = subG(:,pick);   % keep only those for the majority camera ,数量最多的摄像头为主要的点
subXYZ = subXYZ(pick,:);    % 选取主摄像机的点


% problem: we've started getting subG's that came from missing data.
%  they are Inf because of the normalization in prepBathyInput, and they
%  mess up the EIG function in csmInvertKAlpha. Let's throw those columns
%  away. We may have no data (handled in subBathyProcess, or too little
%  data (handled in csmInvertKAlpha). 

% first, do we still have any data? 

if ~isempty(subG) %subG不为空不为空
    
    [ugly, bad] = find(isnan(subG)); %找出subG里面可能有nan值的索引
    all = 1:size(subG,2); %subG的列数
    good = setxor( all, unique(bad) ); %从subG所有列中剔除出现nan值的bad列
    
    subG = subG(:,good);
    subXYZ = subXYZ(good,:);
    
end

%
%   Copyright (C) 2017  Coastal Imaging Research Network
%                       and Oregon State University

%    This program is free software: you can redistribute it and/or  
%    modify it under the terms of the GNU General Public License as 
%    published by the Free Software Foundation, version 3 of the 
%    License.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see
%                                <http://www.gnu.org/licenses/>.

% CIRN: https://coastal-imaging-research-network.github.io/
% CIL:  http://cil-www.coas.oregonstate.edu
%
%key cBathy
%

