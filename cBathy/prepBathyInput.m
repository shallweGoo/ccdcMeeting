function [f, G, bathy] = prepBathyInput( xyz, epoch, data, bathy )

%% prepBathyInput
%
%  [f, G, bathy] = prepBathyInput( xyz, epoch, data, bathy )
%
%  take stack data from mBw bathy stacks and create the fftd intermediate
%   and a list of all x and y for analysis. Fill in empty bathy struct.
%
%  x and y are in bathy.xm, bathy.ym
%

%% 1.  Common Fourier calculations

% do the common tasks of Fourier transform, normalizing and getting
% rid of extraneous frequencies.  Keep memory use to a minimum.  Note
% that I get rid of all extraneous frequencies (including the upper
% reflected portion that are conjugates).  Note that the data are 
% detrended.

params = bathy.params;      % extract for ease of use.

% deal with epoch that is row vs. columns
if(size(epoch,2) > size(epoch,1))  %如果列数>行数，则翻转，便于计算吧，就是要将t转化为列向量
	epoch = epoch';
end

% fB are the center frequencies for potential analysis
% 要进行频率分析的候选频率
fB = params.fB; 
dfB = fB(2)-fB(1);%频率间隔


% detrend the columns (time series), fft (G is complex).
G = fft(detrend(double(data)));  %对每列去除线性趋势，因为波的形式为非线性，进行傅里叶变换,得到每一个点像素随时间变化的傅里叶变换,相当于对每个点的时间序列进行傅里叶变换

% dt is timestep 差分然后取平均mean([epoch(2)-epoch(1),...,epoch(n)-epoch(n-1)]);
dt = mean(diff(epoch(:,1))); %间隔时间为dt，0.5s(2hz) 

% frequencies of fft run from 0 1/(N-1) by 1/N   (fft之后的频率变化)
df = 1/(size(epoch,1)*dt);  %离散傅里叶变换中的：fs/N，每一个时间都为一个采样时间点n，与真实频率的对应关系为f=n*fs/N;
f = [0: df: 1/(2*dt)-df]; %傅里叶变换的有效频率为 n=[0:N/2-1],换成频率为f=n*fs/N=[0: df: 1/(2*dt)-df];

% find results of fft that are within the desired frequency limits

id = find((f >= (fB(1)-dfB/2)) & (f <= (fB(end)+dfB/2))); %从fft之后的G中选取想要的频率范围(1/18-dfB/2)~(1/4+dfB/2)
f = f(id); % 从fft提取想要的频率范围
G = G(id,:);   %选取这个频率内的fft,此时G是以f（也是点数N作为横坐标的）
G = G./abs(G);  % scale spectral results to 1. %归一化傅里叶变化的取值

%% %%   2.  Define the analysis domain. 

% 定义分析范围
% size of x and y intervals
dxm = params.dxm; 
dym = params.dym;

% span from the minimum X to maximum X in steps of dxm. Ditto Y.
%  round lower boundary.  If exists xyMinMax, let user set xm, ym.
if ~isempty(params.xyMinMax) %如果在.m(argus02a.m)文件中定义了xy的范围就直接取值
    
    xm = [params.xyMinMax(1): dxm: params.xyMinMax(2)]; %选择xm,ym的位置，直接确定为向量了
    ym = [params.xyMinMax(3): dym: params.xyMinMax(4)];
else
    xm = [ceil(min(xyz(:,1))/dxm)*dxm: dxm: max(xyz(:,1))]; %ceil向上取整，floor向下取整，bound为四舍五入
    ym = [ceil(min(xyz(:,2))/dym)*dym: dym: max(xyz(:,2))]; 
end

if (cBDebug(params, 'DOPLOTPHASETILE'))    % allow user to change array  允许用户选择自己感兴趣的区域进行xm，ym选择
    [xm,ym] = alterAnalysisArray(xm,ym);
end


bathy.tide.zt = nan; %潮位为nan
bathy.tide.e = 0;
bathy.tide.source = '';
bathy.xm = xm; %区域赋值
bathy.ym = ym;

% number of analysis points in x and y 需要分析的xm和ym点的长度
Nxm = length(xm); 
Nym = length(ym); 

nanArray = nan(Nym, Nxm);
fNanArray = nan([Nym, Nxm, params.nKeep]);

bathy.camUsed = nanArray;
bathy.fDependent.fB = fNanArray;
bathy.fDependent.k = fNanArray;
bathy.fDependent.a = fNanArray;
bathy.fDependent.hTemp = fNanArray;
bathy.fDependent.kErr = fNanArray;
bathy.fDependent.aErr = fNanArray;
bathy.fDependent.hTempErr = fNanArray;
bathy.fDependent.skill = fNanArray;
bathy.fDependent.dof = fNanArray;
bathy.fDependent.lam1 = fNanArray;
bathy.fCombined.h = nanArray;
bathy.fCombined.hErr = nanArray;
bathy.fCombined.J = nanArray;
bathy.runningAverage.h = nanArray;
bathy.runningAverage.hErr = nanArray;
bathy.runningAverage.P = nanArray;
bathy.runningAverage.Q = nanArray;


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
% key cBathy
%

