function [k,kh] = dispsol(h, f, flag)
%   计算k和kh,都是估计值，估计出f可能的h和k
%   使用迭代最小化技术返回色散方程的解
%   根据h和f计算k和kh. kh的意思是k*h

%	k = dispsol(h, f) returns the solution to the dispersion
%	equation using a iterative minimization technique [SLOW]
%	[k,kh] = dispSol(h, f, 0) returns approximate solution to
%	dispersion equation following Hunt 1979 JWPCOD, v. 105 no. WW4
%	See also Dean & Dalrymple p. 72
%	k is radial wavenumber
%	Either h or f can be a vector, but not both unless length(f) == 
%	length(h), 
%   h和f可以是向量，但是不都是，除非f的数量和h的数量一一对应
%   otherwise only first f will be used if both f and h are unequal
%   length vectors.
%   否则只使用第一个f值对k的值进行计算估计，第一个f为相关值最大的频率

%  modified 08/01 by Holman to accept both f vectors of h vectors
%  but not both and to return only k (returning k as the second 
%  of two argument caused lots of accidental errors

% modified by KTHolland to handle both f and h vectors.

h = h(:);
f = f(:);

switch nargin
case 2 		% range is infinite wavelength to about 0.25 m
    if length(h)==1
        for i = 1:length(f)
            k(i) =fminbnd('dispEqnK',0,20, ...
                optimset('TolX',1e-5,'Display','off'),h,f(i));   % fminbnd返回一个值 x，该值是 fun 中描述的标量值函数在区间  x1?<?x?<?x2 中的局部最小值
                                                                 % x = fminbnd(fun,x1,x2,options)
                                                                 % x 为横坐标
        end                                                      % 不知道多了两个参数是什么意思，可变参数数量，查看fminbnd.m
   elseif length(h) == length(f) % assume 2 vectors of h,f pairs
        for i = 1:length(f)
            k(i) = fminbnd('dispEqnK',0,20, ...
                optimset('TolX',1e-5,'Display','off'),h(i),f(i));
        end
   else
        for i = 1: length(h)
            k(i) = fminbnd('dispEqnK',0,20, ...
                optimset('TolX',1e-5,'Display','off'),h(i),f(1)); %TolX为步长
        end
    end
    k = k(:);
    kh = k.*h;
    
case 3
    if length(h)==1    %如果深度信息只有一个，那么寻找所有f中与之适配的的深度
        sigsq = (2*pi*f).^2;
        x = (sigsq*h)/9.82;  
    elseif length(h) == length(f) % assume 2 vectors of h,f pairs
        sigsq = (2*pi*f).^2;
        x = (sigsq.*h)/9.82;
    else
        sigsq = (2*pi*f(1))^2; %如果深度信息和f信息不对应，那么寻找中对于每个h假设f不变，进行波数k的估计
        x = sigsq*h/9.82;  %x=w^2*h/g;维度和h相同
    end
    d1 = 0.6666666666;
    d2 = 0.3555555555;
    d3 = 0.1608465608;
    d4 = 0.0632098765;
    d5 = 0.0217540484;
    d6 = 0.0065407983;
    kh = sqrt(x.^2 + x ./ (1 + d1*x + d2*x.^2 + d3*x.^3 ...
        + d4*x.^4 + d5*x.^5 + d6*x.^6)); %见 代码公式解释.md
    kh = kh(:);
    if length(h)==1
        k = kh/h;
    else
        k = kh./h;  %得到可能的波数
    end
otherwise
    error('Incorrect call to dispsol.  Must use either 2 or 3 inputs')
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

