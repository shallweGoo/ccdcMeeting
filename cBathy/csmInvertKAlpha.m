% 输入的f和G和xyz都是相对于(xm,ym)所得到区域，输入到这个函数中的都只有一个(xm,ym)
function fDependent = ...
    csmInvertKAlpha(f, G, xyz, xm, ym, params, kappa)
%


% fCombined = ...
%   csmInvertKAlpha(f, G, xyz, xm, ym, params, kappa)
%
% estimate wavennumber components from cross spectral matrix CSM
% using local nolinear model for any provided subset of Fourier values
% at any location, xm, ym.    
%
% Input
%   f   frequencies of input Fourier coefficients, Nf x 1
%   G, Fourier coeffients from a tiles worth of pixels, Nxy x 1 (complex)
%   xyz, pixel locations (Nxy of them; z column is not required
%   xm, ym, single location for this analysis
%   params, parameters structure for analysis (from SETTINGS files)
%   kappa, spatially-variable samping domain scaling
% Outputs:
%   fDependent: small structure of results with the following fields, each
%   of length nKeep (one for each frequency)
%       - fB,       - analysed frequencies
%       - k a h,    - wavenumber, alpha, depth
%       - kEst aEst hEst - errors in wavenumber, alpha and depth
%       - skill dof, - skill and degrees of freedom

% 03/07/10 - Holman fix to catch edge error where a tomographic point
%   an extrapolation region can get poor estimates with low error
%   because only a very few pixels are fit well.  Fix is to require
%   nGood pixels (likely > 3) and to have max(deltax) and max(deltay)
%   at least wavelengthFraction of the expected wavelength.
% 09/01/11 - Holman rewrite to finally get rid of tiling and analyze a
%   single location only
% 12/05/11 - Holman major change to base on EOFs rather than direct from CSM

%% %%  1. constants and parameters

clear fDependent
g=9.81;                         % 'g'
minNeededPixels = 6;            % to avoid edge anomalies，进行估计所需要最少的点，防止边界条件
minLFraction = 0.5;             % min fract of wavelength to span 最小波长跨度

OPTIONS = statset('nlinfit');   % fit options (拟合选项)，非线性拟合（最小二乘法）
OPTIONS.MaxIter = 50;  %最大迭代次数
OPTIONS.TolFun = 1e-6; %%%1e-6;  %预测值和实际（观测）值 <TolFun时停止迭代，停止条件，通过观测值去拟合一个波数和相位的函数

Nxy = size(xyz,1);   %tile里面的点数如果小于最少Nxy，就会报错
if Nxy<minNeededPixels          % too few points, bail out
    if( cBDebug( params ) )
        fprintf('Inadequate data to analyze tile, [x,y] = [%d, %d]\n', xm, ym)
    end
    fDependent.k = nan(1,params.nKeep);
    return
end

%汉宁滤波器的构造参数
ri = [0:0.01:1]';       % create a hanning filter for later interp，构造汉明滤波，详见论文,程序中解释是为了之后的插值
ai = (1 - cos( pi*(0.5 + 0.5*ri) ).^2); % pi/2~ pi ,汉明滤波器的数学表达式（个人感觉，往下看）
% 画图就知道ai长什么样子了
% figure(90);
% plot(ri,ai);
% close(90);
%% %% 2. find basic csm for all fB frequencies, sort by total coh^2 into preferred
%% %% order and keep only nKeep frequencies
%如何计算海浪最相关的主频率，这里用EOF(主频分析法)分几步
%1、计算特定频率范围的交叉谱，为矩阵形式，具体代码为  C(:,:,i) = G(id,:)'*G(id,:) / length(id)
%2、计算交叉谱矩阵的和，以和的大小来确定频率的权重，sum和权重成正比


fB = params.fB;
nKeep = params.nKeep;
for i = 1: length(fB)
    % find the f's that match  f的数量要大于fB，所以都可以找到匹配
   %寻找f在fB中的最佳匹配，实际上通过fft(或者说是fs频率采样)变换出来的f并没有和fB一一对应,
   %所以采用最近匹配，筛选所有满足的f点，f是实际采样得来的    
   
    id = find(abs(fB(i)-f) < (fB(2)-fB(1))/2);                                          
    % pull out the fft data and do the cross
    % spectrum,利用时间序列计算交叉谱，G是已经经过筛选的傅里叶变换,这个是傅里叶变换完协方差矩阵的表示方法
    % G(id,:)为id*区域像素点数量的一个矩阵，那么下面这个公式计算出来就是一个nums(区域像素点)*nums(区域像素点)的交叉谱矩阵，i的含义为第几个fB
    C(:,:,i) = G(id,:)'* G(id,:) / length(id);   % pos 2nd leads 1st.   选定特定频率f的所有点,进行交叉谱的计算. 这是关于各个频率间的互功率谱,
    
end

% create the coherence squared for all the potential frequence bands
% 为所有频段的平方相干排序，取前nKeep个最大值,保留其最大相干，互功率谱矩阵的值代表在该频率下的总能量
% C的意义在于特定频率下的交叉谱矩阵，第三层中每一层代表一个频率下的区域内所有点的交叉谱矩阵
% coh2的意思是将每个频率对应的互功率谱的值相加，最后squeeze成一个列向量。例如此时C为N*N*18;那么coh2最后值就是18*1的一个列向量，每行对应一个频率。
coh2 = squeeze(sum(sum(abs(C)))/(size(xyz,1)*(size(xyz,1)-1))); % sum(sum(abs(c)))为每个频率点f（即第三层）上的幅值相干总和，/N*(N-1),大概是什么公式，要除以后面这部分


[~, coh2Sortid] = sort(coh2, 1, 'descend');  % sort by coh2 按照列值降序排列,coh2Sortid储存了原数组中数值降序的索引，CEOF的原理吧
fs = fB(coh2Sortid(1:nKeep));         % keep only the nKeep most coherent，选nKeep个最相干的频率
fDependent.fB = fs;                   % 选择了fB中相干幅值最大的前nKeep频率
C = C(:,:,coh2Sortid(1:nKeep));       % ditto 同上，选择了最相关的一些频率

% report frequencies we keep
% formatStr = repmat('%.3f ', 1, nKeep);
% fprintf(['Frequencies [' formatStr '] Hertz\n'], fs);

%% %%  3. Find lags and weightings.  NOTE that we no longer rotate
%% coordinates to a user cross-shore orientation.  The user is now
%% responsible for providing cross-shore oriented coord system.

xy = xyz(:,1:2); %xy坐标  (xp,yp)的各点坐标,包括x_m,y_m
% find lags xym and pixels for weighting
dxmi = xy(:,1) - repmat(xm, Nxy, 1); %得到各个点与xm的距离
dymi = xy(:,2) - repmat(ym, Nxy, 1); %得到各个点与ym的距离
r = sqrt((dxmi/(params.Lx*kappa)).^2 + (dymi/(params.Ly*kappa)).^2);  %详细查看论文的那个函数,和距离有关
Wmi = interp1(ri,ai,r,'linear*',0);  % sample normalized weights ,   线性插值，得到了汉明权重函数，gamma，Wmi为函数值f(x),r为横坐标x ，[Wmi]是向量，记录了每个点的权重,和特征向量v加权的
%可以plot一下来看一下                                     
% plot(r,Wmi,'*');

% find span of data in x and y to determine if sufficient
maxDx = max(max(repmat(xy(:,1),1,Nxy) - repmat(xy(:,1)',Nxy,1))); %找出最大的x范围，来判断这个范围是否满足要求
maxDy = max(max(repmat(xy(:,2),1,Nxy) - repmat(xy(:,2)',Nxy,1))); %找出最大的y范围

% calculate the distance from every point to every other point

%% %%  4. loop through frequencies from most to least coherent.  For each
%% f, find the csm, then the first EOF.  If sufficiently coherent, fit to
%% find the k, alpha and scalar phase (no lasting value).
% 该段程序寻找f所对应的k，alpha和相位（论文第3个公式）


% starting search seed for alpha (should this be ZERO after rotation?)
% 旋转之后应该为0？
seedAlpha = params.offshoreRadCCWFromx; %波的传播方向吧，默认值为0，为了搜寻alpha的seed,和x轴的夹角，旋转之后默认为0了

for i = 1:nKeep         % frequency loop  进行相干性最大的n个频率的循环，寻找与之匹配的k Alpha Phi
    % prepare nlinfit params.  Note that k is radial wavenumber
    kmin = (2*pi*fs(i))^2/g; % smallest  and largest wavenumber   最小波数k = (2*pi*f)^2/g?? 就是适用深水的范围(w^2 = gk)
    kmax = 2*pi*fs(i)/sqrt(g*params.MINDEPTH);      %tanh的泰勒展开为这个数tanhx= x+o(x)，深度最小值是直接指定的,在argus02a.m这个配置文件里面
    LExpect = minLFraction*4*pi/(kmin+kmax);     % expected scale from mean k. 估计波长L的波动范围*L平均波长) = 0.5*L(平均波长)
    LB_UB = [kmin seedAlpha-pi/2;kmax seedAlpha+pi/2];
    % LB_UB = [kmin seedAlpha-pi/2   第二列参数为波角，和x轴的夹角吧,在-90~90之间
    %          kmax seedAlpha+pi/2]; //seedAlpha默认为0
    % 不知道这个矩阵有什么用
    OPTIONS.TolX = min([kmin/1000, pi/180/1000]); % min([kmin/1000,pi/180/1000]); 不知道这是在干嘛，设置最小步长，最小二乘的步长设置
    statset(OPTIONS);
    warning off stats:nlinfit:IterationLimitExceeded

    % info for depth subsequent h error estimation
    hiimax = g*(1/fs(i)^2)/(2*pi)/2;  % deepest allowable = L0/2   %L0 = g*T^2/(2*pi)同样也是利用色散关系的最大限制(tanh(kh) == 1)，可以得到最大深度
    hii = [params.MINDEPTH : .1 : hiimax]'; % find k for full range of h %枚举所有可能的h，
    
    %确定了水深的范围，然后再进行k的估计，此时只是大概的范围估计，后面进行匹配
    %维度跟各个估计的水深hii是相同的，跟每个水深对应
    kii = dispsol(hii, fs(i),0); %该函数的作用是枚举h，对f进行匹配，得到对应可能的k，此时k为向量

    % pull out csm
    %互功率谱矩阵中进行eof分析
    Cij = C(:,:,i); % C第三层的每一层对应的都是一个f
    [v,d] = eig(Cij); % 计算特征向量和特征值，d为特征值的对角, 48*48, v为对应的特征向量,列向量
    lam = real(diag(d));  % order eigenvalues and remove teeny imag component  (lam是特征值),取矩阵的对角线元素并取实部。此时lam为一个列向量
    [lam1, lamInd] = max(lam);  % 获得特征值最大值和特征值索引
    

    lam1Norm = lam1/sum(lam)*length(lam);  % as ratio to uniform eigenvalues  %length(返回最长的那个维度)
    
    v = v(:,lamInd);           % chose only dominant EOF,只选择了最大的那个特征向量对应的特征向量，主成分分析的知识，v是观测值的互谱矩阵的对应的特征值
    w = abs(v).*Wmi;           % final weights for fitting. 最终的权重函数，是特征向量的值*汉明窗函数
    
    % check if sufficient data quality and xy span
    % 这些数据都是估计值
    % 1、协方差矩阵的特征值要大于params.minLam
    % 2、区域的X范围要大于期望的波长值（在一个波长范围外进行估计）
    % 3、区域的Y范围要大于期望的波长值（在一个波长范围外进行估计）
    % 有一个不符合就直接进入第一个条件，都设置为nan
    if ~((lam1Norm>params.minLam) && (maxDx>LExpect) && (maxDy>LExpect))  
        kAlphaPhi = [nan nan nan];
        ex = kAlphaPhi;
        skill = nan;
    else
        try
            % do nonlinear fit on surviving data 
            %进行非线性拟合
            
            % v是功率谱矩阵最大特征值对应的特征向量
            % xy是以xm,ym为中点的区域点，第一列是x，第二列是y
            % LB_UB是规定好的一个合理波数范围，用于限制里面不合法的波数估计
            
            kAlphaPhiInit = findKAlphaPhiInit(v, xy, LB_UB, params);  %带入上面已经选好的v和xy和LB_UB进行k，Alpha，Phi这三个值的初始值设置，具体是算出kx,ky，alpha用kx,ky夹角算，phi用一个奇怪的公式算出来。
            
            
            % [xy w]是predictCSM模型（函数）的输入，xy为坐标，w =abs(v).*wmi，其中wmi是汉明滤波器权重
            % [real(v); imag(v)]是predictCSM模型（函数）的输出，分别为最大特征值对应的特征向量v的实部和虚部
            % predictCSM模型函数
            % kAlphaPhiInit 要拟合的三个参数k，Alpha，Phi的初始值
            % OPTIONS 是选项
            [kAlphaPhi,resid,jacob] = nlinfit([xy w], [real(v); imag(v)],...
                           'predictCSM', kAlphaPhiInit, OPTIONS);  % 用predictCSM函数去拟合这个数据，kAlphaPhiInit是初始值,predictCSM的返回值为q,也就是公式（3）的q
                                                                   % 用q的模型去拟合以[xy w]为横坐标,[real(v);imag(v)]为纵坐标的一组数据，所得到最佳拟合的k，Alpha和phi
            
            % check if outside acceptable limits
            % (这个判断是进行报错判断)，拟合出来的数据并不满足理论值的估计，所以就要throw
            if ((kAlphaPhi(1)<LB_UB(1,1)) || (kAlphaPhi(1)>LB_UB(2,1)) ...
                    || (kAlphaPhi(2)<LB_UB(1,2)) || (kAlphaPhi(2)>LB_UB(2,2)))
                error; 
            end
            
            % get predictions then skill
            % 用观测值和拟合出来的kAlphaPhi去得到一个预测值，此时权重并没有乘上汉宁滤波器
            vPred = predictCSM(kAlphaPhi, [xy abs(v)]);   % 得到拟合出kAlphaPhi,和没有经过汉宁滤波器w加权过的v，来得出一个预测值
            vPred = vPred(1:end/2) + sqrt(-1)*vPred(1+end/2:end); % 转化为复向量
            skill = 1 - norm(vPred-v)^2/norm(v-mean(v))^2; % can be neg. 拟合度，可正可负,简代码公式解释.md
            
            if( cBDebug( params, 'DOPLOTPHASETILE' ))
                figure(i); clf
                plotPhaseTile(xy,v,vPred) %画出以xy为横纵坐标，v为实际值（oberserve）,vPred为拟合值
                drawnow;
                fprintf('frequency %d of %d, normalized lambda %.1f\n  ', i, nKeep, lam1Norm)
            end

            % get confidence limits
            % 非线性模型的置信区间估计
            % 获得估计出来的参数的95%的置信区间，输入为拟合出来的参数，残差矩阵和雅戈比矩阵
            ex = nlparci(real(0 * kAlphaPhi), resid, jacob); % get limits not bounds  95% 的置信区间, 统计方面的, 详见论文, help nlparci 查看函数用法,
            ex = real(ex(:,2)); % get limit, not bounds
            
        catch   % nlinfit failed with fatal errors, adding bogus
            kAlphaPhi = [nan nan nan];
            ex = kAlphaPhi;
            skill = nan;
            lam1 = nan;
        end % try
    end

    % store results
    %储存结果
    fDependent.k(i) = kAlphaPhi(1); 
    fDependent.a(i) = kAlphaPhi(2);
    fDependent.dof(i) = sum(w/(eps+max(w)));  %自由度存下来,eps的作用是转化为浮点数精度，1+eps = 1.00
    fDependent.skill(i) = skill;
    fDependent.lam1(i) = lam1;
    fDependent.kErr(i) = ex(1);
    fDependent.aErr(i) = ex(2);
    
    % rough estimate of depth from linear dispersion
    if ~isnan(kAlphaPhi(1))  %如果k != nan,说明有值，那么就在以kii为横坐标，hii以其对应的值的地方插值
        fDependent.hTemp(i) = interp1(kii,hii, kAlphaPhi(1));   % h的初始值为kAlphaPhi(1)对应的h, h是插值插出来的
        dhiidkii = diff(hii)./diff(kii);
        fDependent.hTempErr(i) = ...
            sqrt((interp1(kii(2:end),dhiidkii, kAlphaPhi(1))).^2.* ...
                    (ex(1).^2));
    else
        fDependent.hTemp(i) = nan;
        fDependent.hTempErr(i) = nan;
    end
end  % frequency loop

if( cBDebug( params, 'DOPLOTPHASETILE' ))
    fDependent
    input('Hit enter to continue ');
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

