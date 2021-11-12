clear;

%% 
Fs = 2;
N = 600;
n = 0:N-1;
t = n/Fs;
dt = mean(diff(t));
df = 1/(N*dt); 
f = 0: df: 1/(2*dt)-df;
fB = [1/18:1/50:1/4];
dfB = fB(2)-fB(1);
nKeep = 4;
%%%%%%%%%%%读入文件设置%%%%%%%%
dir_ind = num2str(18);
col_num = num2str(100);

%timestack_foldPath = "F:\workSpace\matlabWork\corNeed_imgResult\"+"变换后图片"+dir_ind+"相关处理\"+"变换后图片"+dir_ind+"时间堆栈\";
timestack_foldPath = "F:\workSpace\matlabWork\corNeed_imgResult\"+"变换后图片"+dir_ind+"相关处理\"+"变换后图片"+dir_ind+"带通滤波\";
real_file = timestack_foldPath + "col" + col_num;
load(real_file);

% x1 = detrend(double(row_timestack(400,:))); 
% x2 = detrend(double(row_timestack(380,:)));

x1 = detrend(double(afterFilt(400,:))); 
x2 = detrend(double(afterFilt(380,:)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% y1 = detrend(smooth(x1,10));
% y2 = detrend(smooth(x2,10));

signal = [x1',x2'];


% figure(21);
% plot(t,y1,'r',t,y2,'b');


% figure(22);
% plot(t,detrend(x1),'r',t,detrend(x2),'b');
% corr(y1,y2,'type','Pearson')


%%
G = fft(signal);
init_G = G;
id = find((f >= (fB(1)-dfB/2)) & (f <= (fB(end)+dfB/2))); %从fft之后的G中选取想要的频率范围(1/18-dfB/2)~(1/4+dfB/2)
f = f(id); % 从fft提取想要的频率范围
G = G(id,:);   %选取这个频率内的fft,此时G是以f（也是点数N作为横坐标的）
G = G./abs(G);  % scale spectral results to 1. %归一化傅里叶变化的取值


%%
for i = 1: length(fB)
    % find the f's that match  f的数量要大于fB，所以都可以找到匹配
   %寻找f在fB中的最佳匹配，实际上通过fft(或者说是fs频率采样)变换出来的f并没有和fB一一对应,
   %所以采用最近匹配，筛选所有满足的f点，f是实际采样得来的    
   
    id = find(abs(fB(i)-f) < (fB(2)-fB(1))/2);                                          
    % pull out the fft data and do the cross spectrum
    % 利用时间序列计算交叉谱，G是已经经过筛选的傅里叶变换
    % G(id,:)为id*区域像素点数量的一个矩阵，那么下面这个公式计算出来就是一个nums(区域像素点)*nums(区域像素点)的交叉谱矩阵，i的含义为第几个fB
    C(:,:,i) = G(id,:)'*G(id,:) / length(id);   % pos 2nd leads 1st.   选定特定频率f的所有点,进行交叉谱的计算. 这是关于各个频率间的互功率谱,
    
end

%coh2 = squeeze(sum(sum(abs(C)))/(size(xyz,1)*(size(xyz,1)-1))); % sum(sum(abs(c)))为每个频率点f（即第三层）上的幅值相干总和，/N*(N-1),大概是什么公式，要除以后面这部分
coh2 = squeeze(sum(sum(abs(C)))/2);

[~, coh2Sortid] = sort(coh2, 1, 'descend');  % sort by coh2 按照行从大到小排列,coh2Sortid储存了原数组中数值从大到小的索引，CEOF的原理吧
f_coh = fB(coh2Sortid(1:nKeep));         % keep only the nKeep most coherent，选nKeep个最相干的频率
C = C(:,:,coh2Sortid(1:nKeep));       % ditto 同上，选择了最相关的一些频率


%用fs反算f_n
f_n = (round(f_coh*N/Fs)+1);


filter_G = zeros(size(init_G,1),size(init_G,2));
%过滤无关信号，都取成0;
for i = 1:nKeep
    
    filter_G(f_n,:) = init_G(f_n,:);
    filter_G(N-f_n+2,:)= init_G(N-f_n+2,:);
end

f_signal = ifft(filter_G);
f_x1 = f_signal(:,1);
f_x2 = f_signal(:,2);
figure(30);%滤波之后的信号
plot(t(1:100),f_x1(1:100),'r',t(1:100),f_x2(1:100),'b')

%% 计算互相关

[max_cor,delta_t] = correlationCalc(f_x1,f_x2,1/Fs)

%% 计算功率谱

f = getRepresentativeFrequency(f_x1,f_x2,f_coh,Fs)



%% 测试fft变换出来的信号消除特定频率

%  fs_test = 2;
%  n = 0:1000-1;
%  t = n/fs_test;
%  a = sin(2*pi*0.004*t)+2*sin(2*pi*0.2*t);
%  b = fft(a);
%  figure(1);
%  plot(abs(b));
%  b(2) = 0;
%  b(1000) = 0;
%  figure(2);
%  plot(abs(b));
%  f_a = ifft(b);
%  fftAnalysis(f_a,fs_test);
%  fftAnalysis(a,fs_test);



