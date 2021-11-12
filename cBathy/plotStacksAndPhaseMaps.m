function plotStacksAndPhaseMaps(xyz,t,data,f,G, params)
%   plotStacksAndPhaseMaps(xyz,t,data,f,G)
%
%  debugging tool for cBathy to show stacks and phase maps for the full
%  stack. Example stacks will show up in Figure 10 and phase maps in Figure
%  11, to preserve figures 1:nfB for analysis point debug plots
%% 
% find representative transects in x and y. 找到代表性截断面所在的x索引和y索引，经过了坏点筛选
[xInd, yInd] = findGoodTransects(xyz, params);


%%

t = t(:,1);
tm = epoch2Matlab(t);  %换为从1970-01-01的秒数

% begin plots
figure(10); set(gcf, 'name', 'Intensity Transects'); clf;  colormap(gray)
subplot 221
plot(xyz(:,1),xyz(:,2),'b.',xyz(xInd,1),xyz(xInd,2),'r+')
xlabel('x (m)'); ylabel('y (m)'); title('cross-shore transect')

subplot 222
plot(xyz(:,1),xyz(:,2),'b.',xyz(yInd,1),xyz(yInd,2),'r+')
xlabel('x (m)'); ylabel('y (m)'); title('longshore transect')

subplot 223
imagesc(xyz(xInd,1),tm,data(:,xInd))
datetick('y')
xlabel('x (m)'); ylabel('time (s)'); title('x-transect')

subplot 224
imagesc(xyz(yInd,2),tm,data(:,yInd))    %放置图像，使其位于 x 轴上的xyz(yInd,2)之间及 y 轴上的tm之间,help imagesc查看一下
datetick('y')
xlabel('y (m)'); ylabel('time (s)'); title('y-transect')

% now do phase maps.  Leave in natural order of freqs for simplicity
%fb是之前选好的频率范围，预先采用的10个fB
fB = params.fB; 
nf = length(fB);
%图窗口数量
nCols = ceil(sqrt(nf));     % chose a reasonable number of rows and cols for display,频率数量开根号来作为列的数量,10的话这个为4,
nRows = ceil(nf / nCols);     % 行的取值，10的话这个值为3
figure(11); set(gcf, 'name', 'Phase Maps'); clf; colormap('jet');
for i = 1:nf
    ind = find(abs(f-fB(i)) == min(abs(f-fB(i)))); %寻找和实际频率对应最新的那个频率点的索引
    subplot(nRows, nCols, i,'FontSize',7); hold on
    %一个频率f下所有的点xyz的相角信息,以x当作横坐标，y当作纵坐标，相角信息当作颜色阈值，如果相同的相角会显示一样的颜色
    
%     一个信号的傅里叶变换，你可以这样理解：
%     对幅度谱，是对信号轮廓和形状的描述；
%     对相位谱，是对信号位置的描述。不同位置的同形状的信号，幅度谱一样，相位谱则不同。
    h=scatter(xyz(:,1),xyz(:,2),3,angle(G(ind,:)),'filled'); % 傅里叶变化的相位就是在这个频率下正弦波的相位
    xlabel('x (m)'); 
    ylabel('y (m)'); 
    axis equal;
    caxis([-pi pi]);
    axis ([ min(xyz(:,1)) max(xyz(:,1)) min(xyz(:,2)) max(xyz(:,2))]);
    view(2); 
    title(['f = ' num2str(fB(i),'%0.3g') ' Hz'],'FontWeight','normal','FontSize',9); 
    grid on
end

% figure(3); set(gcf,'name', 'Phase Transects'); clf;
% for i = 1: 3
%     subplot(3,2,2*i-1); hold on
%     plot(xyz(xInd,1),angle(G(sortInd(i),xInd)),'+-')
%     xlabel('x (m)'); ylabel('phase (rad)');
%     title(['freq = ' num2str(fs(i),'%0.3g') ' Hz']); grid on
%     subplot(3,2,2*i); hold on
%     plot(xyz(yInd,2),angle(G(sortInd(i),yInd)),'+-')
%     xlabel('y (m)'); ylabel('phase (rad)');
%     title(['freq = ' num2str(fs(i),'%0.3g') ' Hz']); grid on
% end

%
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

