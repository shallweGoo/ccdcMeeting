function scpInfo = getScpInfo(step4)
% GETSCPINFO 该函数获取关于scp（stable control point）的信息，用于后面的gcp的匹配，CRIN方法
% 选取的方法和选取gcp的方式一样，用鼠标点击的方式
% 利用颜色阈值，用均值计算中心的方法
% 2、利用模板匹配的方式

    gcp_path = step4.gcp_path;
    savePath = step4.savePath;
    fs = step4.fs;
    brightFlag = step4.brightFlag;

    
    tmp = load(gcp_path);
    gcp = tmp.gcp;
    clear tmp;
    
    imagePath = gcp.imagePath;
    saveName = 'scpInfo';
    
    if isempty(imagePath)==0

        % Display Image
        f1=figure;

        
        
        I=imread(imagePath);
        [r,c,~]=size(I);
        
        colormap(gray); %映射为灰度值,如果本身为彩色图那就不用这条语句了
        imagesc(1:c,1:r,I);
        axis equal;
        xlim([0 c]);
        ylim([0 r]);
        xlabel({ 'U';'不想选了就点这里退出'});
        ylabel('V');
        hold on;

        % 初始化鼠标事件
        x=1;
        y=1;
        button=1;
        UVclick=[];
        unvalid = -99;
        while x<=c && y<=r 

            title('请按下任意键，进入选择模式');
            pause

            title('左键选择SCP,右键删除SCP');
            [x,y,button] = ginput(1);


            % 左键事件
            if button==1  && x<=c && y<=r


                title('请在命令行输入SCP的参数')

                % 
                num=input('请输入SCP的编号:');
                % 画出scp位置
                text(x+30,y,num2str(num),'color','r','fontweight','bold','fontsize',15)

                % User Input for UVd Pixel Radius
                % Allows user to input various values and display until one
                % is satisfactory. (Its really a square width, not radius)
                Rn=75;
                h=rectangle('position',[x-Rn,y-Rn,2*Rn,2*Rn],'EdgeColor','r','linewidth',1);
                while isempty(Rn)==0
                    R=Rn;
                    disp(['请输入搜索半径，如果已经满足要求则不必输入（此时半径' num2str(Rn) '个像素):']);
                    Rn=input('');
                    if isempty(Rn) == 0 %不为空
                        h.Position=[x-Rn,y-Rn,2*Rn,2*Rn];
                    end
                end

                % 由用户自定义选择阈值

                % 新建一个窗口用于展示scp选的准不准
                Tn=100;%默认阈值，白~黑对应（0~255）dark~bright
                f2=figure;

                % 像素值映射图
                subplot(121);
                hold on;
                title(['SCP: ' num2str(num) '像素值映射图']);
                colorbar
                colormap jet
                axis equal


                % 阈值图映射图
                subplot(122)
                title(['SCP: ' num2str(num) '. 阈值:' num2str(Tn)]);
                hold on;
                hold on
                colormap jet
                axis equal


                % 用户输入阈值的过程，不为0就可以重新选择

                while isempty(Tn)==0
                    %Initiate Values
                    T=Tn;
                    % Calculate New Center of Area (Udn,Vdn) given Threshold T
                    [ Udn, Vdn, i, udi,vdi] = thresholdCenter(I,x,y,R,T,brightFlag);

                    % Plot Calculated Subset, Image, and new Centers of
                    % ROI in regular image
                    subplot(121)
                    imagesc(udi,vdi,i), set(gca,'ydir','reverse')
                    p1=plot(Udn,Vdn,'ko','markersize',10,'markerfacecolor','w');
                    p1.XData=Udn;
                    p1.YData=Vdn;
                    xlim([udi(1) udi(end)])
                    ylim([vdi(1) vdi(end)])
                    xlabel('Ud')
                    ylabel('Vd')
                    % Plot Calculated Subset, Image, and new Centers of ROI
                    % In Thresholded image
                    subplot(122)
                    if strcmp(brightFlag,'bright')==1
                        imagesc(udi,vdi,i>T), set(gca,'ydir','reverse')
                    end
                    if strcmp(brightFlag,'dark')==1
                        imagesc(udi,vdi,i<T), set(gca,'ydir','reverse')
                    end


                    title(['SCP: ' num2str(num) '. Threshold:' num2str(Tn)])
                    p2=plot(Udn,Vdn,'ko','markersize',10,'markerfacecolor','w');
                    p2.XData=Udn;
                    p2.YData=Vdn;
                    xlim([udi(1) udi(end)])
                    ylim([vdi(1) vdi(end)])
                    xlabel('Ud')
                    ylabel('Vd')
                    hh=colorbar;
                    cmap=jet(100);
                    cmap=cmap([1 100],:);
                    colormap(gca,cmap)
                    hh.Ticks=[0 1];
                    % Have user Enter New Value
                    disp(['请输入阈值，如果已经满足要求则不必输入（此时阈值为:' num2str(T) '):']);
                    Tn=input('');
                end
                % Close New Figure when user decides value
                close(f2)




                % Store Entered and Clicked Values
                UVclick=cat(1,UVclick, [num x y  R T Udn Vdn]);


                % Display Values
                disp(['SCP ' num2str(num) ' [Udo Vdo]= [' num2str(Udn) ' ' num2str(Vdn) ']'])
                disp(' ')

                % Make f1 current figure and in original view.
                figure(f1)
                zoom out
            end

            % 右键删除事件
            if button==3 && (x<=c && y<=r)
                % 找到最近的点
                Idx = knnsearch(UVclick(:,2:3),[x y]);

                % Turn the visual display off.
                N=length(UVclick(:,1,1))*2+1; % Total Figure Children (Image+ 1 Text + 1 Marker for each Click)
                f1.Children(1).Children(N-(Idx*2)).Visible='off';   % Turn off Text
                f1.Children(1).Children(N-(Idx*2-1)).Visible='off'; % Turn off Marker

                %打印删除信息
                disp(['删除 SCP ' num2str(UVclick(Idx,1))]);

                % 设置为无效值
                UVclick(Idx,1)=unvalid;
                zoom out
            end
        end

        % Filter out values that were to be deleted
        IND=find(UVclick(:,1) ~= unvalid);
        UVsave=UVclick(IND,:);

        % Sort so SCP Numbers are in order
        [~,ic]=sort(UVsave(:,1));
        UVsave(:,:)=UVsave(ic,:);

        % 构建scp结构体
        for k=1:length(UVsave(:,1))
            scp(k).UVdo=UVsave(k,6:7);
            scp(k).num=UVsave(k,1);
            scp(k).R=UVsave(k,4);
            scp(k).T=UVsave(k,5);
            scp(k).brightFlag=brightFlag;
        end


    end





    %% Section 4: Display Results
    disp(['SCPs Entered for ' saveName ':'])
    disp(' ')

    for k=1:length(scp)
        disp(['scp(' num2str(k) ').num = ' num2str(scp(k).num(1)) ] )
        disp(['scp(' num2str(k) ').UVdo = [' num2str(scp(k).UVdo(1)) ' ' num2str(scp(k).UVdo(2)) ']'])
        disp(['scp(' num2str(k) ').R = ' num2str(scp(k).R(1)) ] )
        disp(['scp(' num2str(k) ').T = ' num2str(scp(k).T(1)) ] )
        disp(' ')
    end





    %% Section 5: Save File

    % Incorporate imagePath in structure
    for k=1:length(scp)
        scp(k).imagePath=imagePath;
        scp(k).Fs = fs;
    end
    
    % 储存scp这个结构体
    save([savePath saveName '_firstFrame' ],'scp');
    scpInfo = scp;
    
end

