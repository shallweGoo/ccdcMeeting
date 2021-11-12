function bathy = bathyFromKAlpha(bathy)
%
%  bathy = bathyFromKAlpha(bathy);
%  
% final step in BWLite to take multi-frequency estimates of bathymetry
% and find a best solution for each tomographic location using skill
% and error weightings

%匹配最佳的（fB,k）对


% a global flag -- shudder -- to turn the deep water fix OFF
% easy so that this can be tested at some time TBD
global CBATHYDoNotDeepWater



OPTIONS = statset('nlinfit');   % nlinfit options
OPTIONS.MaxIter = 30; %最大迭代次数
OPTIONS.TolX = 1e-10; %%%1e-3;l
OPTIONS.Display = 'iter';
OPTIONS.Display = 'off';

g = 9.81; % gravity, it's the law!
ri = [0:0.01:1]';       % create a hanning filter for later interp
ai = (1 - cos( pi*(0.5 + 0.5*ri) ).^2);

if( CBATHYDoNotDeepWater ) %如果是浅水的标志位
else
    %%lines 18-24, create sensitivity vectors gammaiBar and mu
    % find the dispersion sensitivity, mu.  This will used to interp into
    % gammi, mu, below.
    gammai = [0.0: 0.01: 1]; %100个点
    gammaiBar = (gammai(1:end-1)+gammai(2:end))/2;
    foo = gammai.*atanh(gammai);
    dFoodGamma = diff(foo)./diff(gammai);
    mu = dFoodGamma./tanh(gammaiBar);
end

params = bathy.params;
nFreqs = size(bathy.fDependent.fB, 3); %第3维的数据的size，选了nkeep个fB，nkeep在argus02.m里面指定了，也就是需要在输入数据的.m文件里面弄好这些参数
x = bathy.xm;     % 所有要估计的点的x坐标
y = bathy.ym;     % for ease of writing
xMin = min(x);    
xMax = max(x);
X = repmat(x, [size(y,2), 1, nFreqs]);  %ym行xm列fB维的一个矩阵
Y = repmat(y', [1, size(x,2), nFreqs]); %ym行xm列fB维的一个矩阵，对应xy区域，这样想就可以了

% loop through all points, doing nlinfit solution for h.  Note that the init
% values of nan are returned unless solution is successful.


%对每个x轮询y
for ix = 1: length(x)
    for iy = 1: length(y)
        kappa = 1 + (bathy.params.kappa0-1)*(x(ix) - xMin)/ ...
             (xMax - xMin);
        % find range-based weights, Wmi to contribute to total weight
        dxmi = X - x(ix); %每一个元素都减去x(ix)
        dymi = Y - y(iy); %每一个元素都减去y(iy)
        r = sqrt((dxmi/(params.Lx*kappa)).^2 + (dymi/(params.Ly*kappa)).^2); %汉明参数
        Wmi = interp1(ri,ai,r,'linear*',0);  % sample normalized weights  得到汉明权重参数

        %找到汉明权重参数Wmi里面 > 0且 拟合值符合要求 且 hTemp不为nan的 索引
        id = find((Wmi > 0) & ...
                  (bathy.fDependent.skill>params.QTOL) & ...
                   (~isnan(bathy.fDependent.hTemp)));
        if(length(id)>params.minValsForBathyEst)  %这个值为4              % just need two
            f = bathy.fDependent.fB(id);
            k = bathy.fDependent.k(id);
            kErr = bathy.fDependent.kErr(id);
            s = bathy.fDependent.skill(id); % 拟合度
            l = bathy.fDependent.lam1(id); %特征值
%             % find dispersion sensitivity
             gamma = 4*pi*pi*f.*f./(g.*k);  %w^2/(gk) = tanh(gk) = gamma;
            if( CBATHYDoNotDeepWater )
                w = Wmi(id).*l.*s./(eps+k);    % weights depend on skill and variance (lam) % 权重是这样得来的，权重Wmi*特征值lambda*拟合度/波数k
            else
                wMu = 1./interp1(gammaiBar, mu, gamma);
                w = Wmi(id).*wMu.*l.*s./(eps+k);    % weights depend on skill and variance (lam)
            end

            hInit = bathy.fDependent.hTemp(id)'*s / sum(s);  %hInit = 根据fDependent.hTemp(id)得出来的
            [h,resid,jacob] =nlinfit([f, w], k.*w, ...
                'kInvertDepthModel',hInit, OPTIONS);  %h使用kInvertDepthModel这个函数拟合出来的
            if (~isnan(h))      % some value returned %如果拟合有结果的话，就要进行一些误差分析
                % 输出95%置信区间的误差
                hErr = bathyCI(resid,jacob, w);		 % get limits not bounds
                kModel = kInvertDepthModel(h, [f, w]);  %带权拟合出的kMode
                J = sqrt(sum(kModel.*k.*w)/(eps+sum(w.^2))); % skill 计算拟合度
                if ((J~=0) && (h>=params.MINDEPTH))
                    bathy.fCombined.h(iy,ix) = h;   %带权的最终h
                    bathy.fCombined.hErr(iy,ix) = hErr; %最终h误差
                    bathy.fCombined.J(iy,ix) = J;
                end
            end
        end  % default h, hErr to nan if no successful solution.
    end	%iy
end	% ix

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

