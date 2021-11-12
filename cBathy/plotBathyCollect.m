function f = plotBathyCollect(bathy, figNum)

%
%   plotBathyCollect(bathy, {figNum})
%
%  plots a bathymetry result showing the bathymetry and error.  Allows
%  optional choice of figure number, otherwise defaults to the current
%  figure.

% set up the figure
if nargin<2
    figNum = gcf;
end
set(figNum,'RendererMode','manual','Renderer','painters');
cmap = colormap( 'jet' ); %默认颜色属性'jet'
colormap( flipud( cmap ) ); %flipud的作用是翻转矩阵

% plot the fCombined bathymetry
clf; %清除图像上的内容clear figure
subplot(121);
pcolor(bathy.xm, bathy.ym, bathy.fCombined.h); %着色,xm对应h中的列，ym对应h中的行，色彩设置默认为
shading flat %去网格
caxis([0 6]);
set(gca, 'ydir', 'nor');
axis equal;
axis tight;
xlabel('x (m)');
ylabel('y (m)');
titstr = datestr( epoch2Matlab(str2num(bathy.epoch)), ...
    'mmm dd yyyy, HH:MM' );
title( titstr );
h=colorbar('peer', gca);
set(h, 'ydir', 'rev');
set(get(h,'title'),'string', 'h (m)')

subplot(122);
pcolor(bathy.xm, bathy.ym, abs(bathy.fCombined.hErr));
shading flat
caxis([0 2]);
set(gca, 'ydir', 'nor');
axis equal;
    axis tight;
xlabel('x (m)');
ylabel('y (m)');
h=colorbar('peer', gca);
set( h, 'ydir', 'rev' ); 
foo = get( h, 'yticklabel' );
foo = cellstr(foo);
for ll=1:length(foo)
foo{ll} = num2str( abs(str2num(foo{ll})), '%.1f' );
end
set( h, 'yticklabel', foo );
set( get(h,'title'), 'string', 'hErr (m)' );

return


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

