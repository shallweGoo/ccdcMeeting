function gcpInfo =  getGcpInfo_UV(step_info,mode)
    %该函数计算外参 (内参已经由相机标定得出)
    %分步(可分为两种方法 1)存下第一帧的gcp坐标,并以此为标准 2)存在第一帧的gcp模板，用于后面的模板匹配 )
    %1.选择gcp在图像坐标系中的坐标(U,V) 
    %2.获取gcp在现实世界中的坐标(X,Y)
    %3.最小二乘法（非线性优化）得到外参（旋转矩阵、平移向量）
    %4.每张图片都需要计算一次外参

    %mode1 方法为获取控制点的坐标
    %mode2 方式为模板匹配 除了获取控制点的坐标之外还获取其模板

    imagePath = step_info.UV.imagePath;
    gcpSavePath = step_info.UV.gcpSavePath;
    
    if( isfield(step_info.UV,'fs'))
        fs = step_info.UV.fs;
    else
        fs = 2;
    end

%     if nargin < 3
%         fs = 2; % 默认频率为2Hz
%         mode = 1;  %默认模式为以第一帧的gcp坐标为匹配基准
%     end

    
    
    unvalid = -99;
    saveName = 'gcpInfo';
    
    %%

    if isempty(imagePath)==0

        % 新建一个窗口便于用户选择gcp
        f1=figure;

        I=imread(imagePath);
        [r,c,~]=size(I);
           
        colormap(gray); %映射为灰度值
        imagesc(1:c,1:r,I); %RGB图用这个函数，灰度图要加上上面那个映射为灰度值的colormap
        
        axis equal; % 均衡坐标轴刻度，展现真实比例
        xlim([0 c]);
        ylim([0 r]);
        xlabel({ 'U';'不想选了就点这里退出'});
        ylabel('V');
        hold on;

        % 初始化鼠标事件
        x=1;
        y=1;
        button = 1;
        UVclick=[];
        % mode2 设置去获取模板
        if mode == 2
            templatelength = 30; %30个像素点大小的模板，实际上是31.
%             gcpTemplate = cell(1,10); % 预设10个模板
%             for i = 1:10
%                 gcpTemplate{i} = unvalid; %初始化模板数据结构
%             end
        end 
        while x <= c && y <= r % 鼠标在x<=c 和 y<=r 为有效区域

            title('请按下任意键，进入选择模式');
            pause

            title('左键选择GCP,右键删除GCP');
            [x,y,button] = ginput(1); %以当前的坐标轴为参考


            % 鼠标左键事件,
            if button == 1  &&  x <= c && y <= r 

                % 在图片上用圆圈标注gcp
                plot(x,y,'ro','markersize',10,'linewidth',3);  

                title('请在命令行输入GCP的编号');

                num=input('请输入GCP的编号:');

                
                % 存下gcp信息
                UVclick=cat(1,UVclick, [num x y]);
                
                if mode == 2
                    
                    tp.x_up = round(x + templatelength/2);
                    tp.x_down = round(x - templatelength/2);
                    tp.y_up = round(y + templatelength/2);
                    tp.y_down = round(y - templatelength/2);
                    if  tp.x_up<= c &&  tp.x_down >= 0 && tp.y_up<=r && tp.y_down>= 0
                        gcpTemplate(num).tp = I(tp.y_down:tp.y_up,tp.x_down:tp.x_up);
                    else 
                        error('can not make this template because of its range!');
                    end
                    
                end
                
                
                % 图上标注gcp信息
                text(x+30,y,num2str(num),'color','r','fontweight','bold','fontsize',15);

                % 命令行输出gcp的值
                disp(['GCP ' num2str(num) ' [U V]= [' num2str(x) ' ' num2str(y) ']']);
                disp(' ');
                figure(f1);
                zoom out
            end

            % 右键鼠标事件删除离点击位置最近的gcp位置
            % 删除采用unvalid这个变量进行数据覆盖.
            if button==3 && x <= c && y <= r

                % 寻找离鼠标点击距离最近的gcp，获得其索引
                Idx = knnsearch(UVclick(:,2:3),[x y]);

                % 关闭在图上的标注
                N=length(UVclick(:,1,1))*2+1; % Total Figure Children (Image+ 1 Text + 1 Marker for each Click)
                f1.Children(1).Children(N-(Idx*2)).Visible='off';   % 关闭这个点的文字标注
                f1.Children(1).Children(N-(Idx*2-1)).Visible='off'; % 关闭这个点的圆圈标注
                
                %命令行打印删除信息
                disp(['删除 GCP ' num2str(UVclick(Idx,1))]);

                % 将这个索引所对应的值设置为无效值，便于后续处理
                UVclick(Idx,1)= unvalid;
                
                if mode == 2
                    gcpTemplate(Idx).tp= unvalid;
                end
                
                zoom out
            end



        end

        % 将无效数据删除
        IND=find(UVclick(:,1) ~= unvalid);
        
        UVsave=UVclick(IND,:);
        
         % 按照gcp索引排序
        [~,ic]=sort(UVsave(:,1)); %ic为排序完的UVsave行索引
        UVsave(:,:)=UVsave(ic,:);
        
        if mode == 2
            %对于结构体只好用循环来找
            cur = 1;
            for i = 1:length(gcpTemplate)
                if(gcpTemplate(i).tp ~= unvalid)
                    Tsave(cur).tp = gcpTemplate(i).tp;
                    Tsave(cur).num = i;
                    cur = cur+1;
                end
            end
            clear cur;
            
            [~,ic]=sort([Tsave.num]); %ic为排序完的UVsave行索引
            Tsave = Tsave(ic);
            
        end
        
         
        % 重新输入gcp格式
        for k=1:length(UVsave(:,1))
            gcp(k).UVd=UVsave(k,2:3);
            gcp(k).num=UVsave(k,1);
            gcp(k).Fs = fs;
            if mode == 2 
                gcp(k).template = Tsave(k).tp;
            end    
        end
    end
        
    
    
    
    %% 输出并储存gcp信息
    close all

    disp(['GCPs Entered for ' saveName ':'])
    disp(' ')

    % 命令行输出gcp信息
    for k=1:length(gcp)
        disp(['gcp(' num2str(k) ').num = ' num2str(gcp(k).num(1)) ] )
        disp(['gcp(' num2str(k) ').UVd = [' num2str(gcp(k).UVd(1)) ' ' num2str(gcp(k).UVd(2)) ']'])
    end

    % 确定每个gcp的图片来源路径（只是方便查看而已，没有实质的作用）
    for k=1:length(gcp)
        if isempty(imagePath)==0
            gcp(k).imagePath=imagePath;
%         else
%             gcp(k).imagePath=imagePath_noclick;
        end
    end

    
    

    %储存模板,存一份mat,存一份图像
    if mode == 2
%         save([gcpSavePath saveName '_template'],'Tsave'); %mat格式
%         该数据已经整合至gcp这个结构体中
        for i = 1:length(Tsave)
            imwrite(Tsave(i).tp,[gcpSavePath  saveName '_template' num2str(i) '.jpg'],'jpg');
        end
    end
    
    %储存gcp.mat的信息
    
    save([gcpSavePath  saveName '_firstFrame'],'gcp');
    
    %输出信息
    gcpInfo = gcp;
        
end
        
        
        


    
    
