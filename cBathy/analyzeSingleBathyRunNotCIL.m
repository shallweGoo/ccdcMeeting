function bathy = analyzeSingleBathyRunNotCIL(stackPnStr, stationStr)
%
%  bathy = analyzeSingleBathyRunNotCIL(stackPnStr, stationStr)
%
%  simple run of analyzeBathyCollect for a single stack.  Useful for
%  debugging.  Assumes stackPnStr is a loadable file which contains
%  variables 
%       epoch   - epoch times for each row in stack, Nt by 1
%       xyz     - xyz locations for each column in stack, Nxyz by 1
%       data    - Nt by Nxyz matrix of cBathy stack data
%       cam     - Nt array of camera number for associated data column.
%                 used to differentiate between data in multi-camera
%                 stacks to help with camera seams.
%
%   stationStr is the name of the station, for example 'argus02b' or
%   whatever naming convention you chose.  This name MUST correspond to a
%   callable m-file that creates the params structure that contains all of
%   the processing inputs.

eval(stationStr)        % creates the params structure. %载入argus02a.m中的数据
load(stackPnStr)           % load xyz, t, data %载入图片和距离信息

%data每一列里面是一个点的完整时间序列信号

% need an array with camera number for data
% if your stack data doesn't have it, then we have to create a dummy
%  one. 
% 每个数据对应多少台摄像头
if exist( 'cam', 'var' ) == 0
    cam = ones( size(xyz,1) , 1);
end

bathy.epoch = num2str(t(1)); %步长
bathy.sName = stackPnStr; %sName存了数据的名字
bathy.params = params;% argus02 这个固定摄像头系统的参数
bathy = analyzeBathyCollect(xyz, t, data, cam, bathy);

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

