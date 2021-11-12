function bathy = analyzeBathyCollect(xyz, epoch, data, cam, bathy)

%%
%
%  bathy = analyzeBathyCollect(xyz, epoch, data, cam, bathy);
%
%  cBathy main analysis routine.  Input data from a time
%  stack includes xyz, epoch and data as well as the initial fields
%  of the bathy structure.  In v1.2, cam is now an input, which is a vector 
%  containing a number for which camera each pixel stack came from. Returns an
%  augmented structure with new fields 'fDependent' that contains all
%  the frequency dependent results and fCombined that contains the
%  estimated bathymetry and errors. In v1.2, camUsed is also returned,
%  which is a matrix identifying which camera data came from.
%  bathy input is expected to have fields .epoch, .sName and .params.
%  All of the relevant analysis parameters are contained in params.
%  These are usually set in an m-file (or text file) BWLiteSettings or
%  something similar that is loaded in the wrapper routine
%
%  NOTE - we assume a coordinate system with x oriented offshore for
%  simplicity.  If you use a different system, rotate your data to this
%  system prior to analysis then un-rotate after.

%% prepare data for analysis
% ensure that epoch a) has magnitudes typical of epoch times, versus
% datenums, and b) is a column vector.  Note that epoch is sometimes a
% matrix with times for each camera.  We usually take just the first
% column.

%这里的epoch输入为datenum
if epoch(1) < 10^8      % looks like a datenum, convert，如果是日期格式的t，就要转化
    epoch = matlab2Epoch(epoch(:));
end

if size(epoch,1)<size(epoch,2)     % looks rowlike   
    epoch = epoch(1,:)';            % take first row and transpose 将时间作为步长由行向量转化为列向量
end

[f, G, bathy] = prepBathyInput( xyz, epoch, data, bathy );  %得到所有的xm,ym，和经过筛选的f和G，里面有对data进行去线性化的操作

if( cBDebug( bathy.params, 'DOPLOTSTACKANDPHASEMAPS' ) ) % 画图，画出所有可能频率下的傅里叶变化相角图
    plotStacksAndPhaseMaps( xyz, epoch, data, f, G, bathy.params ); 
    input('Hit return to continue ')
    close(10);
    close(11);
end


%% now loop through all x's and y's


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%这里被我注释掉了，记得改回来%%%%%%%%%%%%%%%%%%%%%%%%%
if( cBDebug( bathy.params, 'DOSHOWPROGRESS' )) %显示计算过程，用xm,ym的周围很多个点来计算，（argus02a.m）里面如果设置了这个DOSHOWPROGRESS值就会进行展示
    figure(21); clf
    plot(xyz(:,1), xyz(:,2), '.'); axis equal; axis tight
    xlabel('x (m)'); ylabel('y (m)')
    title('Analysis Progress'); drawnow;
    hold on
end


str = bathy.sName;
if cBDebug( bathy.params )
	hWait = waitbar(0, str);
end

for xind = 1:length(bathy.xm)   %一个for循环
    if cBDebug( bathy.params )
	    waitbar(xind/length(bathy.xm), hWait)
    end
    fDep = {};  %% local array of fDependent returns
    % kappa increases domain scale with cross-shore distance
    % 离岸越远scale可以越大,kappa就是论文中的小k，离岸越远可以选的区域就越大,会随着x越大而缓慢增长
    kappa = 1 + (bathy.params.kappa0-1)*(bathy.xm(xind) - min(xyz(:,1)))/ ...
        (max(xyz(:,1)) - min(xyz(:,1)));  %kappa<= kappa0 ，步长计算公式，初始值为2
    
    if( cBDebug( bathy.params, 'DOSHOWPROGRESS' ))  %  如果要展现这个过程(doshowProgress)，则用for，无法加速
        for yind = 1:length(bathy.ym)
            %输入参数说明：
            %1 f:是预处理得到的和fB最近的几个频率
            %2 G:时间序列的fft
            %3 xyz:采样点的世界坐标
            %4 cam：摄像头数量
            %5 ... 连接语句，太长写不下连接一下两行
            %6 bathy.xm(xind)：进行深度估计的点的x坐标（xm）
            %7 bathy.ym(yind):进行深度估计的点的y坐标（ym）
            %8 bathy.params：由用户输入的.m文件的参数集合(argus02.m)
            %9 kappa:步长，自适应增长
            % 返回值说明;
            %1 fDep{yind}:在yind的索引下的频率f
            %2 camUsed{yind}：在yind的索引下的相机使用个数
             [fDep{yind},camUsed(yind)] = subBathyProcess( f, G, xyz, cam, ...
                bathy.xm(xind), bathy.ym(yind), bathy.params, kappa ); 
        end
    else  
        parfor yind = 1:length(bathy.ym) %用parfor加速计算，多线程
            [fDep{yind},camUsed(yind)] = subBathyProcess( f, G, xyz, cam, ...    %该函数实现f_depend结构体的构建，包括f_depend的波数k，波向Alpha等参数
                bathy.xm(xind), bathy.ym(yind), bathy.params, kappa );           %这些参数是根据给定f所得出来的
        end  %% parfor yind
    end
    
    % stuff fDependent data back into bathy (outside parfor)
    % 相关数据放回bathy结构体中
    for ind = 1:length(bathy.ym)

	bathy.camUsed(ind,xind) = camUsed(ind);
        
        if( any( ~isnan( fDep{ind}.k) ) )  % not NaN, valid data. 是否存在有效数据
            bathy.fDependent.fB(ind, xind, :) = fDep{ind}.fB(:);
            bathy.fDependent.k(ind,xind,:) = fDep{ind}.k(:);
            bathy.fDependent.a(ind,xind,:) = fDep{ind}.a(:);
            bathy.fDependent.dof(ind,xind,:) = fDep{ind}.dof(:);
            bathy.fDependent.skill(ind,xind,:) = fDep{ind}.skill(:);
            bathy.fDependent.lam1(ind,xind,:) = fDep{ind}.lam1(:);
            bathy.fDependent.kErr(ind,xind,:) = fDep{ind}.kErr(:);
            bathy.fDependent.aErr(ind,xind,:) = fDep{ind}.aErr(:);
            bathy.fDependent.hTemp(ind,xind,:) = fDep{ind}.hTemp(:);
            bathy.fDependent.hTempErr(ind,xind,:) = fDep{ind}.hTempErr(:);
        end
        
    end
    
%     if( cBDebug( bathy.params, 'DOSHOWPROGRESS' ))
%         figure(21);
%         imagesc( bathy.xm, bathy.ym, bathy.fDependent.hTemp(:,:,1));
%     end
    
end % xind
if cBDebug( bathy.params )
	delete(hWait);
end

%% Find estimated depths and tide correct, if tide data are available.
% （f,k）是配对的，这一步开始选一个最佳的(f,k)对，每个区域都有nKeep对（f，k）


bathy = bathyFromKAlpha(bathy); %用于匹配最佳的(fB_k)对

bathy = fixBathyTide(bathy); %修正潮位

bathy.version = cBathyVersion();

%if ((exist(bathy.params.tideFunction) == 2))   % existing function
%    try
%        foo = parseFilename(bathy.sName);
%        eval(['tide = ' bathy.params.tideFunction '(''' ...
%            foo.station ''',' bathy.epoch ');'])
%        
%        bathy.tide = tide;
%        if( ~isnan( tide.zt ) ) 
%            bathy.fDependent.hTemp = bathy.fDependent.hTemp - tide.zt;
%            bathy.fCombined.h = bathy.fCombined.h - tide.zt;
%        end
%    end
%end

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

