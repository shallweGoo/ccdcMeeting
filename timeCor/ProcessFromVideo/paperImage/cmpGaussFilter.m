function cmpGaussFilter(step) 

%GETPIXELIMAGE 该函数获取经过chooseRoi函数所选择的区域、像素分辨率等得出的结果（mat文件）进行像素图片提取
% 使用前记得加上addpath(genpath('CoreFunctions')),可以在主函数中添加
% inputStruct为输入的结构体，应当包含roi_x,roi_y,dx,dy,x_dx,x_oy,x_rag,y_dy,y_ox,y_rag,localFlag
% localFlag = 0 为世界坐标系， = 1 为当地坐标系
% roi_x,roi_y：需要进行转换的区域，在local坐标系或者在world坐标系中都可以,不过要设置标志位localFlag
% dx,dy：为roi_x,roi_y的像素分辨率，单位为m
% x_dx：为 x_transect(Alongshore)方向上的像素分辨率，单位为m
% x_oy：为x_transect起点的y值
% x_rag:x_transect的范围，x的范围
% y_dy,y_ox,y_rag 同上解释

    roi_path = step.roi_path;
    extrinsicFullyInfo_path = step.extrinsicFullyInfo_path;
    unsolvedPic_path = step.unsolvedPic_path;
    savePath = step.savePath;
    inputStruct = step.inputStruct;
    





    %无人机系统得到的图片或者不需要的时候，留为空就行了，在后面载入的extrinsicFullyInfo会记录数据
    t={};
    
    % 如果是无人机系统得到图片或是不需要，那么留为空即可
    zFixedCam={}; 

    
    %用于接收grid结构体变量
    gridPath = roi_path;
    tmp1 = load(gridPath);
    X = tmp1.X; %用之前得到的roi_path只是为了得到可供插值的X,Y,Z数据
    Y = tmp1.Y;
    Z = tmp1.Z;
    localAngle = tmp1.localAngle;
    localOrigin = tmp1.localOrigin;
    localX = tmp1.localX;
    localY = tmp1.localY;
    localZ = tmp1.localZ;
    worldCoord = tmp1.worldCoord; 
    clear tmp1;
    
    %内外参 参数接收 单相机 ,该参数
    ioeopath{1} = extrinsicFullyInfo_path;
    tmp2 = load(ioeopath{1});
    extrinsics = tmp2.extrinsics;
    intrinsics = tmp2.intrinsics;
    t = tmp2.t; %时间感觉还是很重要的
%     variableCamSolutionMeta = tmp2.variableCamSolutionMeta;
    clear tmp2;
    
    
    
    imageDirectory{1} = unsolvedPic_path; %待解决图片路径,只有一个路径就写个1就可以了
     
    saveName = 'pixelImg';




    %  If a Fixed station, most likely images will span times where Z is no
    %  longer constant. We have to account for this in our Z grid. To do this,
    %  enter a z vector below that is the same length as t. For each frame, the
    %  entire z grid will be assigned to this value.  It is assumed elevation
    %  is constant during a short
    %  collect. If you would like to enter a z grid that is variable in space
    %  and time, the user would have to alter the code to assign a unique Z in
    %  every loop iteration. See section 3 of D_gridGenExampleRect for more
    %  information. If UAS or not desired, leave empty.
    


    



    %% Section 4: User Input: Instrument Information



    % 使用自建坐标系，将此标志位设为1。使用已有规范的世界坐标系（NED,ENU...），则该标志位为0 
    % localAngle,localOrigin, and localX,Y,Z不能为空
    localFlag = 1;

    
    %  Instrument Entries
    %  Enter the parameters for the isntruments below. If more than one insturment
    %  is desired copy and paste the entry with a second entry in the structure.
    %  Note, the coordinate system
    %  should be the same as specified above, if localFlag==1 the specified
    %  parameters should be in local coordinates and same units.

    %  Note: To reduce clutter in the code, pixel instruments were input in
    %  local coordinates so it could be used for both mulit and Uas demos. The
    %  entered coordinates are optimized for the UASDemo and may not be
    %  optmized for the multi-camera demo.



    %  grid网格也就是采样点的参数设置，dx,dy可以不相同，取决于需求
    pixInst(1).type='Grid';
    pixInst(1). dx =inputStruct.dx;  % x轴像素分辨率，即每个像素的间隔
    pixInst(1). dy =inputStruct.dy;
    pixInst(1). xlim =inputStruct.x_rag;
    pixInst(1). ylim =inputStruct.y_rag;
    pixInst(1).z={}; % Leave empty if you would like it interpolated from input
    % Z grid or zFixedCam. If entered here it is assumed constant
    % across domain and in time.

   



    %  在y轴上采点，称为yTransect，y轴为Along shore方向，以下设置相关参数
    pixInst(2).type = 'yTransect';
    pixInst(2).x= inputStruct.y_ox; % y轴所对应x的初始位置
    pixInst(2).ylim=inputStruct.y_rag;
    pixInst(2).dy =inputStruct.y_dy; %像素分辨率
    pixInst(2).z ={};  %实际上是z坐标，在海面上可以估计为0，为空说明可通过输入的Z值进行插值，
    % 如果不为空说明为固定值

    %
    %
    %  Runup (Cross-shore Transects)
    %  同上，x轴上采点，Cross-shore方向，以下设置相关参数

    pixInst(3).type = 'xTransect';
    pixInst(3).y= inputStruct.x_oy;
    pixInst(3).xlim=inputStruct.x_rag;
    pixInst(3).dx =inputStruct.x_dx;
    pixInst(3).z ={};  % 该参数不为空说明z轴为常值，为空可通过输入的Z值进行插值,可以直接设为空

    %% Section 5: Load Files

    % Load Grid File And Check if local is desired
    % 选择local坐标系进行计算
    
    if localFlag==1
        X=localX;
        Y=localY;
        Z=localZ;
    end

    % 载入内外参和目标图片路径

    %  Determine Number of Cameras
    camnum=length(ioeopath);

    for k=1:camnum
        % Load List of Collection Images
        L{k}=string(ls(imageDirectory{k}));
        L{k}=L{k}(3:end); % 前两个为当前目录.和上级目录..

        % Check if fixed or variable. If fixed (length(extrinsics(:,1))==1), make
        % an extrinsic matrix the same length as L, just with initial extrinsics
        % repeated.
        if length(extrinsics(:,1))==1 %如果外参为固定值，输入的外参只有一组，1*6，那么有几张图片就复制几份即可，为了程序的泛化性
            extrinsics=repmat(extrinsics,length(L{k}(:)),1);
        end
        if localFlag==1     %世界标准坐标(ned)->自定义坐标(local),CRIN用的是东北天（ENU）
            extrinsics = localTransformExtrinsics(localOrigin,localAngle,1,extrinsics);
        end

        % 整合数据便于后续储存
        Extrinsics{k}=extrinsics;
        Intrinsics{k}=intrinsics;

        clear extrinsics;
        clear intrinsics;
    end






    %% Section 6: Initialize Pixel Instruments

    % Make XYZ Grids/Vectors from Specifications.
    [pixInst]=pixInstPrepXYZ(pixInst); %拼接pixInst结构体

    % Assign Z Elevations Depending on provided parameters.
    % If pixInst.z is left empty, assign it correct elevation
    for p=1:length(pixInst)
        if isempty(pixInst(p).z)==1
            if isempty(zFixedCam)==1 % If a Time-varying z is not specified 
                pixInst(p).Z=interp2(X,Y,Z,pixInst(p).X,pixInst(p).Y); % 依靠输入的z值对选择的区域进行插值
            end

            if isempty(zFixedCam)==0 % If a time varying z is specified
                pixInst(p).Z=pixInst(p).X.*0+zFixedCam(1); % 如果明确z值那后来的都为定值
            end
            
        end
    end





    %% Section 7: Plot Pixel Instruments

    for k=1:camnum
        % Load and Display initial Oblique Distorted Image
        I=imread(strcat(imageDirectory{k}, L{k}(1)));
        figure;
        hold on;

        imshow(I);
        hold on;
%         title('Pixel Instruments');

        % For Each Instrument, Determin UVd points and plot on image
        for p= 1 : length(pixInst)

            % Put in Format xyz for xyz2distUVd
            xyz=cat(2,pixInst(p).X(:),pixInst(p).Y(:),pixInst(p).Z(:));
            

            %Pull Correct Extrinsics out, Corresponding In time

            extrinsics=Extrinsics{k}(1,:);
            intrinsics=Intrinsics{k};
            
            [UVd] = xyz2DistUV(intrinsics,extrinsics,xyz); %利用chooseRoi中选定的区域所具有的xyz信息插值后得到z，并用该值计算uv坐标
            
            % Make A size Suitable for Plotting
            UVd = reshape(UVd,[],2);
            plot(UVd(:,1),UVd(:,2),'*');
            xlim([0 intrinsics(1)]);
            ylim([0  intrinsics(2)]);

            % Make legend
            le{p}= [num2str(p) ' ' pixInst(p).type ];
        end
        legend(le)
        clear I;
        clear extrinsics;
        clear intrinsics;
    end

    % Allows for the instruments to be plotted before processing
    pause(1)




    %% Section 7:  Loop for Collecting Pixel Instrument Data.

    for j=1:1

        % For Each Camera
        for k=1:camnum
            % Load Image
            I{k}=imread(strcat(imageDirectory{k}, L{k}(j)));
        end

        %  Loop for Each Pixel Instrument
        for p=1:length(pixInst)

            % Check if a time varying Z was specified. If not, wil just use constant Z
            % specified or interpolated from grid in Section 4 and 6 respectively.
            if isempty(pixInst(p).z)==1  % 如果此时的z值还为空时
                if isempty(zFixedCam)==0 % 如果时固定相机的话z存在固定值，就用这个固定值计算
                    pixInst(p).Z=pixInst(p).X.*0+zFixedCam(j); % Assign First Value for First Image, spatially constant elevation
                end
            end

            %Pull Correct Extrinsics out, Corresponding In time
            for k=1:camnum
                extrinsics{k}=Extrinsics{k}(j,:);%及时更新外参，感觉有点画蛇添足了
            end
            intrinsics=Intrinsics;

            % 获取区域或横断面的rgb图
            [Irgb]= imageRectifier(I,intrinsics,extrinsics,pixInst(p).X,pixInst(p).Y,pixInst(p).Z,0); 
            % 最后一个参数0为教学模式
            % 可以展示跟chooseRoi一样的区域
            
            
            % 转化为灰度图
            [Igray]=rgb2gray(Irgb);




            % If First frame, initialize pixInst structure entries
            if j==1
                pixInst(p).Igray=Igray;
                pixInst(p).Irgb=Irgb;
                
            end

            % If not First frame, tack on as last dimension (time).
            if j~=1
                s=size(Igray);
                nDim= length(find(s~=1)); % 如果是区域图，则Igray为2维；如果是横断面，则Igray为1维。
                
                % For Gray Scale it is straight forward
                pixInst(p).Igray=cat(nDim+1,pixInst(p).Igray,Igray); % 拼接数据，本身是1维的横断面数据就拼在第2维（列），2维区域数据就拼在第3维

                % For RGB it is trickier since MATLAB always likes rgb values in
                % third dimension.
                % If a GridGrid Add in the fourth dimension
                if nDim==2
                    pixInst(p).Irgb=cat(nDim+2,pixInst(p).Irgb,Irgb); % rgb图片永远拼在第4维
                end
                % 横断面数据拼在第2维
                if nDim==1
                    pixInst(p).Irgb=cat(nDim+1,pixInst(p).Irgb, Irgb);
                end

            end
        end

        % Display progress
        disp([ 'Frame ' num2str(j) ' out of ' num2str(length(L{k}(:))) ' completed. ' num2str(round(j/length(L{k}(:))*1000)/10) '%'])

    end


    %% Section 8: Plot Instrument Data
    % For Each Instrument Plot the Data, note, if Grid data only the first
    % frame will be plotted.

    %把grid,x_transect,y_transect都画出来
    
    for p=1:length(pixInst)

        %新建图窗窗口，并且用type当作标题
        figure;
        title([num2str(p) ' ' pixInst(p).type ])
        hold on

        % Grid画图,映射关系根据x和y的增加来映射
        if strcmp(pixInst(p).type,'Grid')==1
            rectificationPlotter(pixInst(p).Irgb(:,:,:,1),pixInst(p).X,pixInst(p).Y,1); % Plot First Frame RGB
        end
        
        % x_transect 画出timestack图
        if strcmp(pixInst(p).type,'xTransect') == 1
            stackPlotter(pixInst(p).Irgb,pixInst(p).X,t, 'x', 1)

            %如果有时间信息添加到坐标轴里面
            
            if isempty(t)==0
                datetick('y','keeplimits')
            end
        end
           
        % y_transect 画出timestack图
        if strcmp(pixInst(p).type,'yTransect')==1
            stackPlotter(pixInst(p).Irgb, pixInst(p).Y,t, 'y', 1)
            %If t non empty, add datetick to axis
            if isempty(t)==0
                datetick('x','keeplimits');
            end
        end

    


    end
    
        % Save metaData and Grid Data
    rectMeta.solutionPath=ioeopath;
    rectMeta.imageDirectory=imageDirectory;
    rectMeta.imageNames=L;
    rectMeta.t=t;
    rectMeta.worldCoord=worldCoord;

    % If A local Grid Add Information
    if localFlag==1
        rectMeta.localFlag=1;
        rectMeta.localAngle=localAngle;
        rectMeta.localOrigin=localOrigin;
    end


    save(strcat(savePath, saveName), 'pixInst','rectMeta', 't');



end