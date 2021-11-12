function [xInd, yInd] = findGoodTransects(xyz, params)
%
%   [xInd, yInd] = findGoodTransects(xyz, params)
%
%  pick out the indices of a representative x and y transect from a
%  matrix set of pixel locations, xyz.  Used for plotting
%  cross-spectra for BWLite.

%得到横断面周围的x,y索引


medX = median(xyz(:,1)); medY = median(xyz(:,2)); %计算中位数，其实是取x,y坐标中点的意思，默认值取中点

if( nargin < 2 )
       params.debug.frank = 0;
end

if( isfield( params.debug, 'TRANSECTX' ) ) %如果已经指定了x的横断面，就用这个值
    medX = params.debug.TRANSECTX;
end
if( isfield( params.debug, 'TRANSECTY' ) ) %同上
    medY = params.debug.TRANSECTY;
end

delx = sqrt(prod(max(xyz(:,1:2)) - min(xyz(:,1:2)))/(2*size(xyz,1))); %计算乘积再开方,最大的x和y值-最小的x和y值
dely = 2*delx;      % default 2:1 y:x spacing. %默认dy = 2*dx

% get representative x-profile
% 得到y轴横断面x的位置索引信息
dY = xyz(:,2)-medY; %得到每个y和中位数的差距
idy = find(abs(dY)<dely); %小于dely的y索引，有序
[sortx, xsortid] = sort(xyz(idy,1)); %按idy的顺序排x
idy = idy(xsortid);
diffx = diff(xyz(idy,1)); bad = find(diffx<0.4*delx); %坏点
while any(bad)
    for i = 1: length(bad)
        [foo,bar] = max(abs(dY(idy([bad(i) bad(i)+1]))));
        toss(i) = bar+bad(i)-1;
    end
    idy = setdiff(idy, idy(toss));
    [sortx, xsortid] = sort(xyz(idy,1));
    idy = idy(xsortid);
    diffx = diff(xyz(idy,1)); bad = find(diffx<0.4*delx);
    clear toss
end
xInd = idy;

% get representative y-profile
clear toss;
dX = xyz(:,1)-medX;
idy = find(abs(dX)<delx);
[sortx, xsortid] = sort(xyz(idy,2));
idy = idy(xsortid);
diffy = diff(xyz(idy,2)); bad = find(abs(diffy)<0.4*dely);
while any(bad)
    for i = 1: length(bad)
        [foo,bar] = max(abs(dX(idy([bad(i) bad(i)+1]))));
        toss(i) = bar+bad(i)-1;
    end
    idy = setdiff(idy, idy(toss));
    [sortx, xsortid] = sort(xyz(idy,2));
    idy = idy(xsortid);
    diffy = diff(xyz(idy,2)); bad = find(abs(diffy)<0.4*dely);
    clear toss
end
yInd = idy;

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

