%%% 参数输入
params.station_str = 'phantom4';    % 素材来源平台名称

%%%%%
params.fs = 2;                      % 采样频率
params.N = 600;                     % 采样点
params.dxm = 0.5;                   % local坐标系 x轴距离分辨率
params.dym = 0.5;                   % local坐标系 y轴距离分辨率
params.prm = params.dxm;
params.dist = 1;                    % 距离限制
% params.pred_range = [10 40];      % 波长估计范围
% params.pred_k = 1;

params.xy_min_max = [0 180 0 135];  % local坐标系 xy轴的范围，12个元素是x轴，34是y轴

params.xy_range = params.xy_min_max;
params.xy_want = params.xy_min_max;

params.df = params.fs / params.N;          % fft里面每个横坐标点对应的频率间隔，简单来说就是fs/N;
params.dt = 1 / params.fs;          % delta t，这项不用设置
params.t = 0 : params.dt : (params.N - 1) * params.dt; % 这项也不用设置，自动计算
params.f = 0 : params.df : (1 / (2 * params.dt) - params.df );
% params.tideFunction = 'cBathyTide';  % 潮位校正的函数校正

%%%%%%%   算法参数   %%%%%%%
params.MINDEPTH = 0.25;             % 初始化最小深度作为初始值
params.minValsForBathyEst = 4;      % f_k对的个数

params.QTOL = 0.5;                  % 拟合度低于这个值说明不够拟合，要reject
params.minLam = 10;                 % min normalized eigenvalue to proceed 进行的最小归一化特征值
params.Lx = 3*params.dxm;           % 区域的选择,X轴上的
params.Ly = 3*params.dym;           % 区域的选择,Y轴上的
params.kappa0 = 2;                  % 增长因子，离岸越远区域就要越大
params.DECIMATE = 1;                % decimate pixels to reduce work load. 减少像素以减少工作量的标志位
params.maxNPix = 80;                % max num pixels per tile (decimate excess) 每块区域中最多存在80个像素点

% 选择要分析的频率范围
params.fB = [1/18: 1/50: 1/4];		% 枚举可能的频率值
params.nKeep = 4;                   % 保留主要频率的个数
params.dfB = mean(diff(params.fB)); % dfBs


% 是否开启debug功能
params.debug.production = 0;            % 1开启，0关闭
params.debug.DOPLOTSTACKANDPHASEMAPS = 1;  % 画出频率对应的相位图
params.debug.DOSHOWPROGRESS = 1;		  % 过程图展示
params.debug.DOPLOTPHASETILE = 1;		  % 每个像素点的eof结果
params.debug.TRANSECTX = 200;		  % 画图选项，画出x轴的截断面，这个为x坐标值
params.debug.TRANSECTY = 200;		  % 画图选项，画出y轴的截断面，这个为y坐标值

% default offshore wave angle.  For search seeds.
params.offshoreRadCCWFromx = 0;