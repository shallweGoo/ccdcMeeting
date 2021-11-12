
file_path =  "F:\workSpace\matlabWork\dispersion\selectPic\afterPer\双月湾第二组变换后\变换后图片\";
pic_path = string(ls(file_path));
pic_path = pic_path(3:end);
src = imread(file_path+pic_path(1));
pic_num = size(pic_path,1);
testLength = 1000;

TimeStack = zeros(size(src,1),testLength);
TimeStack_3s = zeros(size(src,1),testLength);
for i = 1: testLength
    src = imread(file_path+pic_path(i));
    TimeStack(:,i) = src(:,200);
    if i>=7
        TimeStack_3s(:,i-6)= src(:,200);
    end
end

for i = testLength+1:testLength+6
    src = imread(file_path+pic_path(i));
    TimeStack_3s(:,i-6) = src(:,200);
end


    
    TimeStack = uint8(TimeStack);
    TimeStack_3s = uint8(TimeStack_3s);
%     imshow(TimeStack);
        
    myFilter = load('testLp2_0.5_0.6.mat');
    
    %% 测试滤波程序
   
    
%     test_signal1 = TimeStack(300,:);
%     test_signal1 = [test_signal1,zeros(1,101)];
%     test_signal1 = filter(myFilter.test,1,test_signal1);
%     test_signal1 = test_signal1(52:pic_num+51);
%     test_signal1 = detrend(double(test_signal1)/255);
% %     test_signal1 = test_signal1(100:1100);
%     
%     test_signal2 = TimeStack(200,:);
%     test_signal2 = [test_signal2,zeros(1,101)];
%     test_signal2 = filter(myFilter.test,1,test_signal2);  
%     test_signal2 = test_signal2(52:pic_num+51);
%     test_signal2 = detrend(double(test_signal2)/255);
% %     test_signal2 = test_signal2(100:1100);
%     
%     [~,timelag]=correlationCalc(test_signal1,test_signal2,0.5);
    
    %滤完波之后，信号堆栈就很相似，想想怎么提取信号会计算出时滞，目前按照这种方式无法计算出时滞
    
    
    %%
    ref = 360; % 参考点的距离设置
    
    
    test_signal3 = TimeStack(ref,:);
    test_signal3 = [test_signal3,zeros(1,101)];
    test_signal3 = filter(myFilter.test,1,test_signal3);
    test_signal3 = test_signal3(52:testLength+51);
    
    
   %在固定时间来计算互相关矩阵时不使用detrend效果好像更好一点
    test_signal3 = detrend(double(test_signal3)/255);
%       test_signal3 = double(test_signal3)/255;
%     test_signal3 = test_signal3(100:1000);

    cor_val = zeros(1,ref-1);
    
    for i = ref-1:-1:1
        test_signal4 = TimeStack_3s(i,:);
        test_signal4 = [test_signal4,zeros(1,101)];
        test_signal4 = filter(myFilter.test,1,test_signal4);
        test_signal4 = test_signal4(52:testLength+51);
        
        test_signal4 = detrend(double(test_signal4)/255);
%         test_signal4 = double(test_signal4)/255;
        
        
%         test_signal4 = test_signal4(100:1000);
%         [cor_val(1,300-i),~]  = correlationCalc(test_signal3,test_signal4,0.5);
         cor_val(1,ref-i) = corr(test_signal3',test_signal4','type','Pearson');
         
    end
%     cor_val = cor_val./max(cor_val);
    plot(cor_val);
    [~,n]= max(cor_val)
    
    