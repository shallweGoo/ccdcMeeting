%%% Site-specific Inputs
params.stationStr = 'mavic_pro';
params.dxm = 3;                    % analysis domain spacing in x
params.dym = 3;                    % analysis domain spacing in y
params.xyMinMax = [0 300 50 150];   % min, max of x, then y  
                                    % default to [] for cBathy to choose  
                                    
params.tideFunction = 'cBathyTide';  % tide level function for evel 潮位

%%%%%%%   Power user settings from here down   %%%%%%%
params.MINDEPTH = 0.25;             % for initialization and final QC，初始化最小深度作为初始值
params.minValsForBathyEst = 4;      % min num f-k pairs for bathy est. 最小数量的(f-k)对

params.QTOL = 0.5;                  % reject skill below this in csm  低于这个值就要reject
params.minLam = 10;                 % min normalized eigenvalue to proceed 进行的最小归一化特征值
params.Lx = 3*params.dxm;           % tomographic domain smoothing 区域的选择,X轴上的
params.Ly = 3*params.dym;           % 区域的选择,Y轴上的
params.kappa0 = 2;                  % increase in smoothing at outer xm ,增长因子吧，随着x的增加，要估计的区域要增大，
params.DECIMATE = 1;                % decimate pixels to reduce work load. 减少像素以减少工作量的标志位
params.maxNPix = 80;                % max num pixels per tile (decimate excess) 每块区域中最多存在80个像素点

% f-domain etc.
params.fB = [1/18: 1/50: 1/4];		% frequencies for analysis (~40 dof) 10个频率值备选
params.nKeep = 4;                   % number of frequencies to keep  要维护nKeep个频率作为备选

% debugging options  debug选项
params.debug.production = 0;            %这个应该是总开关，为1不debug
params.debug.DOPLOTSTACKANDPHASEMAPS = 1;  % top level debug of phase %画出频率对应的相位图的开关
params.debug.DOSHOWPROGRESS = 0;		  % show progress of tiles
params.debug.DOPLOTPHASETILE = 0;		  % observed and EOF results per pt
params.debug.TRANSECTX = 100;		  % for plotStacksAndPhaseMaps 画图选项
params.debug.TRANSECTY = 50;		  % for plotStacksAndPhaseMaps

% default offshore wave angle.  For search seeds.
params.offshoreRadCCWFromx = 0;



