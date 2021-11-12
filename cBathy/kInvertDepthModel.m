function k = kInvertDepthModel(depth, fw)

% return wavenumber given depth and frequency
% 根据h,和f以及权重w，得到波数k


% include a weight too

w = fw(:,2);
% 该函数的作用是用深度h和f得到k,原理用的是一个论文结论，简单来说套公式
k = dispsol(depth, fw(:,1), 0);

k = k.*w;



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

