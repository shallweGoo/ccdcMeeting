function bathy = analyzeBathyCollect(xyz, epoch, data, cam, bathy)

%%
%
%  bathy = analyzeBathyCollect(xyz, epoch, data, cam, bathy);
%
%  cBathy main analysis routine.  Input data from a time
%  stack includes xyz, epoch and data as well as the initial fields
%  of the bathy structure.  In v1.2, cam is now an input, which is a vector 
%  containing a number for which camera each pixel stack came from. Returns an
%  augmented structure with new fields 'fDependent' that contains all
%  the frequency dependent results and fCombined that contains the
%  estimated bathymetry and errors. In v1.2, camUsed is also returned,
%  which is a matrix identifying which camera data came from.
%  bathy input is expected to have fields .epoch, .sName and .params.
%  All of the relevant analysis parameters are contained in params.
%  These are usually set in an m-file (or text file) BWLiteSettings or
%  something similar that is loaded in the wrapper routine
%
%  NOTE - we assume a coordinate system with x oriented offshore for
%  simplicity.  If you use a different system, rotate your data to this
%  system prior to analysis then un-rotate after.

%% prepare data for analysis
% ensure that epoch a) has magnitudes typical of epoch times, versus
% datenums, and b) is a column vector.  Note that epoch is sometimes a
% matrix with times for each camera.  We usually take just the first
% column.

%�����epoch����Ϊdatenum
if epoch(1) < 10^8      % looks like a datenum, convert����������ڸ�ʽ��t����Ҫת��
    epoch = matlab2Epoch(epoch(:));
end

if size(epoch,1)<size(epoch,2)     % looks rowlike   
    epoch = epoch(1,:)';            % take first row and transpose ��ʱ����Ϊ������������ת��Ϊ������
end

[f, G, bathy] = prepBathyInput( xyz, epoch, data, bathy );  %�õ����е�xm,ym���;���ɸѡ��f��G�������ж�data����ȥ���Ի��Ĳ���

if( cBDebug( bathy.params, 'DOPLOTSTACKANDPHASEMAPS' ) ) % ��ͼ���������п���Ƶ���µĸ���Ҷ�仯���ͼ
    plotStacksAndPhaseMaps( xyz, epoch, data, f, G, bathy.params ); 
    input('Hit return to continue ')
    close(10);
    close(11);
end


%% now loop through all x's and y's


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%���ﱻ��ע�͵��ˣ��ǵøĻ���%%%%%%%%%%%%%%%%%%%%%%%%%
if( cBDebug( bathy.params, 'DOSHOWPROGRESS' )) %��ʾ������̣���xm,ym����Χ�ܶ���������㣬��argus02a.m������������������DOSHOWPROGRESSֵ�ͻ����չʾ
    figure(21); clf
    plot(xyz(:,1), xyz(:,2), '.'); axis equal; axis tight
    xlabel('x (m)'); ylabel('y (m)')
    title('Analysis Progress'); drawnow;
    hold on
end


str = bathy.sName;
if cBDebug( bathy.params )
	hWait = waitbar(0, str);
end

for xind = 1:length(bathy.xm)   %һ��forѭ��
    if cBDebug( bathy.params )
	    waitbar(xind/length(bathy.xm), hWait)
    end
    fDep = {};  %% local array of fDependent returns
    % kappa increases domain scale with cross-shore distance
    % �밶ԽԶscale����Խ��,kappa���������е�Сk���밶ԽԶ����ѡ�������Խ��,������xԽ�����������
    kappa = 1 + (bathy.params.kappa0-1)*(bathy.xm(xind) - min(xyz(:,1)))/ ...
        (max(xyz(:,1)) - min(xyz(:,1)));  %kappa<= kappa0 ���������㹫ʽ����ʼֵΪ2
    
    if( cBDebug( bathy.params, 'DOSHOWPROGRESS' ))  %  ���Ҫչ���������(doshowProgress)������for���޷�����
        for yind = 1:length(bathy.ym)
            %�������˵����
            %1 f:��Ԥ�����õ��ĺ�fB����ļ���Ƶ��
            %2 G:ʱ�����е�fft
            %3 xyz:���������������
            %4 cam������ͷ����
            %5 ... ������䣬̫��д��������һ������
            %6 bathy.xm(xind)��������ȹ��Ƶĵ��x���꣨xm��
            %7 bathy.ym(yind):������ȹ��Ƶĵ��y���꣨ym��
            %8 bathy.params�����û������.m�ļ��Ĳ�������(argus02.m)
            %9 kappa:����������Ӧ����
            % ����ֵ˵��;
            %1 fDep{yind}:��yind�������µ�Ƶ��f
            %2 camUsed{yind}����yind�������µ����ʹ�ø���
             [fDep{yind},camUsed(yind)] = subBathyProcess( f, G, xyz, cam, ...
                bathy.xm(xind), bathy.ym(yind), bathy.params, kappa ); 
        end
    else  
        parfor yind = 1:length(bathy.ym) %��parfor���ټ��㣬���߳�
            [fDep{yind},camUsed(yind)] = subBathyProcess( f, G, xyz, cam, ...    %�ú���ʵ��f_depend�ṹ��Ĺ���������f_depend�Ĳ���k������Alpha�Ȳ���
                bathy.xm(xind), bathy.ym(yind), bathy.params, kappa );           %��Щ�����Ǹ��ݸ���f���ó�����
        end  %% parfor yind
    end
    
    % stuff fDependent data back into bathy (outside parfor)
    % ������ݷŻ�bathy�ṹ����
    for ind = 1:length(bathy.ym)

	bathy.camUsed(ind,xind) = camUsed(ind);
        
        if( any( ~isnan( fDep{ind}.k) ) )  % not NaN, valid data. �Ƿ������Ч����
            bathy.fDependent.fB(ind, xind, :) = fDep{ind}.fB(:);
            bathy.fDependent.k(ind,xind,:) = fDep{ind}.k(:);
            bathy.fDependent.a(ind,xind,:) = fDep{ind}.a(:);
            bathy.fDependent.dof(ind,xind,:) = fDep{ind}.dof(:);
            bathy.fDependent.skill(ind,xind,:) = fDep{ind}.skill(:);
            bathy.fDependent.lam1(ind,xind,:) = fDep{ind}.lam1(:);
            bathy.fDependent.kErr(ind,xind,:) = fDep{ind}.kErr(:);
            bathy.fDependent.aErr(ind,xind,:) = fDep{ind}.aErr(:);
            bathy.fDependent.hTemp(ind,xind,:) = fDep{ind}.hTemp(:);
            bathy.fDependent.hTempErr(ind,xind,:) = fDep{ind}.hTempErr(:);
        end
        
    end
    
%     if( cBDebug( bathy.params, 'DOSHOWPROGRESS' ))
%         figure(21);
%         imagesc( bathy.xm, bathy.ym, bathy.fDependent.hTemp(:,:,1));
%     end
    
end % xind
if cBDebug( bathy.params )
	delete(hWait);
end

%% Find estimated depths and tide correct, if tide data are available.
% ��f,k������Եģ���һ����ʼѡһ����ѵ�(f,k)�ԣ�ÿ��������nKeep�ԣ�f��k��


bathy = bathyFromKAlpha(bathy); %����ƥ����ѵ�(fB_k)��

bathy = fixBathyTide(bathy); %������λ

bathy.version = cBathyVersion();

%if ((exist(bathy.params.tideFunction) == 2))   % existing function
%    try
%        foo = parseFilename(bathy.sName);
%        eval(['tide = ' bathy.params.tideFunction '(''' ...
%            foo.station ''',' bathy.epoch ');'])
%        
%        bathy.tide = tide;
%        if( ~isnan( tide.zt ) ) 
%            bathy.fDependent.hTemp = bathy.fDependent.hTemp - tide.zt;
%            bathy.fCombined.h = bathy.fCombined.h - tide.zt;
%        end
%    end
%end

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
