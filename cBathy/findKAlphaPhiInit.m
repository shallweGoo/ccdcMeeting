%该函数的作用是根据xy和互功率谱最大特征值的特征向量v，对波数k,波角alpha,相位phi的初始值进行估计。详细的式子是3
function kAlphaPhiInit = findKAlphaPhiInit(v, xy, LB_UB, params)
%
%   kALphaPhiInit = findKAlphaInitPhi(v, xy, LB_UB, params);
%
%  find appropriate wavenumber and direction estimates, k and alpha
%  根据空间结构EOF求解合适的波数和方向。
%  based on the phase structure of the first EOF, v, at locations, xy.  
%  The estimate is done by modeling phase difference versus x and y
%  difference. dTheta = kx*dx + ky*dy.  This is done by extracting an x and 
%  y transect of phase and finding the median dPhasedx etc to remove phase
%  jumps.  This is done at multiple transects, taking the median of the
%  results. 

sliceFract = 0.1;   % define slices a this fraction nearest location
N = size(xy,1); %N是区域内的点数
n = floor(sliceFract*N);    %n为0.1N,进行估计，在y的尺度上分块（距离）对k进行估计

[~, ind] = sort(xy(:,2));       % sort everything in order of y  对y进行排序，默认从小到大排序,ind为从小到大的原数组的索引,可以理解为是一条条transect
x = xy(ind,1); %x按照y从小到大的顺序排列 
phase = angle(v(ind)); %相角由angle函数求出,同样是经过排序的顺序，y坐标从小到大

% find kx estimate at n longshore locations then find median
% 找出波数在x方向上的波数k,这是一个区域内的，所以增加一些
% 在一个xm,ym的区域内也要进行分块，增加鲁棒性，分块为10等分左右
for i = 1: floor(N/n) %i从1到每个块，N/n = 10左右
    pick = [(i-1)*n+1: i*n];
    [xp, xpInd] = sort(x(pick)); %对已经按y顺序排好的x进行排序
    phz = phase(pick(xpInd)); 
    kx(i) = median(diff(phz(:))./diff(xp(:))); %见师姐论文（3-22）解释：x方向的波数分量可以转化为相位在该方向的梯度来计算，具体是某个论文直接得出的结论，不知道是哪个论文。
end
kx = median(kx); % kx取向量的中位数,为了remove phase jumps.

% now find ky estimate at n cross-shore locations then find median
% 固定x对y进行排序，等于在沿岸距离的方向上进行估计
[~, ind] = sort(xy(:,1));       % sort everything in order of x
y = xy(ind,2);
phase = angle(v(ind));
for i = 1: floor(N/n)
    pick = [(i-1)*n+1: i*n];
    [yp, ypInd] = sort(y(pick));
    phz = phase(pick(ypInd));
    ky(i) = median(diff(phz(:)) ./ diff(yp(:)));
end
ky = median(ky);%ditto 同上 

kVec = kx+1i*ky;
k = abs(kVec);   %k也是从kx方向和ky方向进行叠加的
alpha = angle(kVec)-pi;     % switch by pi for 'coming from' angle (alpha的值(wave direction) = k的角度-pi)
%此时phase还在用 sort everything in order of x的排序使用
phi = mean(rem(phase - kx*xy(:,1) - ky*xy(:,2), 2*pi));  %phi 是appropriate phase shift，为了(3)的那个等式  rem是取余mod的意思，但是怎么来的不是很理解

%如果不在期望的范围内
if ((k<LB_UB(1,1)) || (k>LB_UB(2,1)))    % if not in expected range 
    k = dispsol(3.0, 0.1, 0);            % just guess a 0.1 Hz, h=3m value. （k超过范围了，默认值就为这个）
end

kAlphaPhiInit = [k alpha phi]; % 是论文中(3)中的三个参数


% Copyright by Oregon State University, 2017
% Developed through collaborative effort of the Argus Users Group
% For official use by the Argus Users Group or other licensed activities.
%
% $Id: findKAlphaPhiInit.m 4 2016-02-11 00:35:38Z  $
%
% $Log: findKAlphaPhiInit.m,v $
% Revision 1.1  2012/09/24 23:20:22  stanley
% Initial revision
%
% Revision 1.1  2011/08/08 00:28:51  stanley
% Initial revision
%
%
%key whatever is right, do it
%comment  
%
