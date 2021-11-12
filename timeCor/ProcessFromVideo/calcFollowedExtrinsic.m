function  calcFollowedExtrinsic(step5)
% calcFollowedExtrinsic 用来稳定接下来的图像,用来计算每帧的外参，这个步骤可以用两种方法
% mode = 1，利用scp来计算外参
% mode = 3，利用模板来匹配gcp，进而计算外参
% mode = 2, 固定外参

    %scpInfo为scp信息结构体，输入应该为结构体
    %ieInfo应该为extrinsics和intrinsic和initialCam的结构体
    %unsovledExtrinsic_pic_path为待计算外参帧图片的路径
    %savePath为存储路径

    gcp_path = step5.gcp_path;
    rotateInfo_path = step5.rotateInfo_path;
    unsovledExtrinsic_pic_path = step5.unsovledExtrinsic_pic_path;
    savePath = step5.savePath;

    %如果没有使用模式的话，那么默认使用mode = 1
    if ~isfield(step5,'mode')
        mode = 1;
    else
        mode = step5.mode;
    end
    
    % 各种数据进行处理
    tmp2 = load(gcp_path);
    gcp = tmp2.gcp;
    
    tmp3 = load(rotateInfo_path);
    extrinsics = tmp3.extrinsics;
    intrinsics = tmp3.intrinsics;
    initialCamSolutionMeta = tmp3.initialCamSolutionMeta;
    
    clear tmp2;
    clear tmp3;
    %设置存放文件名
    saveName = 'extrinsicFullyInfo';
    
    %图片信息登录
    if mode == 1
        %记录scp信息
        scp_path = step5.scp_path;
        tmp1 = load(scp_path);
        scp = tmp1.scp;
        clear tmp1;
        %第一帧图像信息记录
        imagePath = char(scp(1).imagePath);
        ind =  find(imagePath == '/');
        firstFrame= imagePath((ind(end)+1):end); %第一帧图像路径
    else
        firstFrame = step5.ff_name;
    end
    
    %% 设置时间信息和图片数量信息

    %  每帧图像的存放路径，文件夹中必须只含有图片，并且命名格式若为数字应该为000001，000002这样的，建议使用绝对时间。
    %  因为之后会使用string(ls(3:end))这种形式去读，所以对命名格式有要求
    imageDirectory= unsovledExtrinsic_pic_path;
    %  Enter the dt in seconds of the collect. If not known, leave as {}. Under
    %  t, images will just be numbered 1,2,3,4.
    %  方便记录，如果不知道留成空，之后图片默认会被编号为1，2，3，4
    dts= 1/step5.fs; %Seconds 
    
    %  Enter the time of the initial image in MATLAB Datenum format; if unknown
    %  leave empty {}, to will be set to 0.
    
    to=datenum(2020,10,24,7,30,0); % 看注释不想改了，日期信息,不知道的话设置为空{}

    % 所有的图片列表
    L=string(ls(imageDirectory));
    % 找到所使用第一帧的图片位置
    chk=cellfun(@isempty,strfind(L,firstFrame));
    ffInd=find(chk==0);

    % 带矫正的图片索引
    ind=ffInd:length(chk);

    % Assign time vector, if dts is left empty, vector will just be image
    % number
    if isempty(dts)==0
        t=(dts./24./3600).*((1:length(ind))-1)+ to; %创建时间
    else
        t=(1:length(ind))-1;
    end

    if mode == 1  %模式1采用CRIN的方法进行计算
       %% Section 2: User Input:  Initial Frame information

        %  Enter the filename of the first image where IOEO is known. It should be
        %  the same image you did the initial solution for in
        %  C_singleExtrinsicsSolution (initialCamSolutionMeta.impath). It should be
        %  in the same directory as your other colleciton images imagesDirectory.
        % 第一列为scp的编号，第二列为scp在真实世界坐标系下的z估计值，坐标系应当和计算外参所使用的坐标系相同
        % initailCamSolutionMeta.worldCoordSys


        scpz=[ 1  0; % scp.num   z value
            2  0;
            3  0;
            4  0
            5  0];

        %  记录一下z值所使用的坐标系
        % (initailCamSolutionMeta.worldCoordSys)

        scpZcoord= initialCamSolutionMeta.worldCoordSys;


       %% Section 4: Load IOEO and SCP Info

        % Assign SCP Elevations to each SCP Point.
        for k=1:length(scp)
            i=find(scpz(:,1)==scp(k).num);
            scp(k).z=scpz(i,2);
        end

        % Put SCP in format for distUV2XYZ
        for k=1:length(scp)
            scpZ(k)=scp(k).z;
            scpUVd(:,k)=[scp(k).UVdo'];
        end


       %% Section 6: Initialize Extrinsic Values and Figures for Loop

        % Plot Initial Frame and SCP Locations
        In=imread(strcat(imageDirectory,'/', L(ffInd,:))); %展示一下第一帧信息
        f1 = figure; %图窗句柄，便于操作图窗
        imshow(In);
        hold on;
        for k=1:length(scp)
            plot(scp(k).UVdo(1),scp(k).UVdo(2),'ro','linewidth',2,'markersize',10)
        end

        if isempty(dts)==1
            title(['第一帧: ' num2str(t(1))])
        else
            title(['第一帧: ' datestr(t(1))])
        end


        % 输出化结构体
        extrinsicsVariable = nan(length(ind),length(extrinsics));
        extrinsicsVariable(1,:) = extrinsics; % First Value is first frame extrinsics.
        extrinsicsUncert(1,:)=initialCamSolutionMeta.extrinsicsUncert;


        %  Determine XYZ Values of SCP UVdo points
        %  We find the XYZ values of the first frame SCP UVdo points, assuming the
        %  z coordinate is the elevations we entered in Section 2. We find xyz,
        %  so when we find the corresponding SCP feature in our next images In,
        %  we can treat our SCPs as gcps, and solve for a new extrinsics_n for each
        %  iteration
        
        
        % 用一个估计的z值去计算scp的世界坐标，方便后计算，因为必须要已知一维的xyz信息才能计算，
        % 在这里已经用假设已经知道的z和较为精确的外参extrinsics进行UV->xyz的映射了,所以得到xyz的并不是scp真实的坐标，只是为了满足这个外参和假设的z进行
        % 的scp在自建坐标系下的坐标的估计
        [xyzo] = distUV2XYZ(intrinsics,extrinsics,scpUVd,'z',scpZ);


        % Initiate and rename initial image, Extrinsics, and SCPUVds for loop

        extrinsics_n=extrinsics;
        scpUVdn=scpUVd;





        %% Section 7: Start Solving Extrinsics for Each image.
        imCount=1;
        len = length(ind)+2;
        for k=ind(2:end)
            % Assign last Known Extrinsics and SCP UVd coords
            extrinsics_o=extrinsics_n;%利用上一帧的信息，进行校正
            scpUVdo=scpUVdn; %利用上一帧的scp信息进行校正
            %  Load the New Image
            In=imread(strcat(imageDirectory, L(k,:)));
            % Find the new UVd coordinate for each SCPs
            for j=1:length(scp)
               
                %用之前预设好的scp信息（搜索半径以及阈值去搜索）
                %在此可以用mode2 模板匹配去获取scp的坐标
                [ Udn, Vdn, ~, ~,~] = thresholdCenter(In,scpUVdo(1,j),scpUVdo(2,j),scp(j).R,scp(j).T,scp(j).brightFlag);
                % If the function errors here, most likely your threshold was too high or
                % your radius too small for  a scp. Look at scpUVdo to see if there is a
                % nan value, if so  you will have to redo E_scpSelection with bigger
                % tolerances.

                %Assingning New Coordinate Location
                scpUVdn(:,j)=[Udn; Vdn]; %每列储存一个scp点信息
            end


            % Solve For new Extrinsics using last frame extrinsics as initial guess and
            % scps as gcps
            extrinsicsInitialGuess=extrinsics_o; %用之前的外参作为初始值，进行进一步计算
            extrinsicsKnownsFlag=[0 0 0 0 0 0];
            [extrinsics_n,extrinsicsError]= extrinsicsSolver(extrinsicsInitialGuess,extrinsicsKnownsFlag,intrinsics,scpUVdo',xyzo);


            % Save Extrinsics in Matrix
            imCount=imCount+1;
            extrinsicsVariable(imCount,:)=extrinsics_n; %把外参存在extrinsicsVariable中
            extrinsicsUncert(imCount,:)=extrinsicsError;


            % Plot new Image and new UV coordinates, found by threshold and reprojected
            cla
            imshow(In);
            hold on

            % Plot Newly Found UVdn by Threshold
            plot(scpUVdn(1,:),scpUVdn(2,:),'ro','linewidth',2,'markersize',10);
            
            % Plot Reprojected UVd using new Extrinsics and original xyzo coordinates
            % 黄色的圈是计算出来的外参到
            [UVd] = xyz2DistUV(intrinsics,extrinsics_n,xyzo);
            uvchk = reshape(UVd,[],2);
            plot(uvchk(:,1),uvchk(:,2),'yo','linewidth',2,'markersize',10);

            % Plotting Clean-up
            if isempty(dts)==1
                title(['Frame: ' num2str(t(imCount))]);
            else
                title(['Frame ' num2str(imCount) ': ' datestr(t(imCount))]);
            end
            legend('上一帧SCP','本帧SCP');
            
            disp([ num2str( k./len*100) '% Fix Complete'])
            pause(.05)
        end


        


       %% Section 8: Plot Change in Extrinsics from Initial Frame

        f2 = figure;

        % XCoordinate
        subplot(6,1,1)
        plot(t,extrinsicsVariable(:,1)-extrinsicsVariable(1,1))
        ylabel('\Delta x')
%         title('Change in Extrinsics over Collection')
        title('外参变化曲线')
        
        
        % YCoordinate
        subplot(6,1,2)
        plot(t,extrinsicsVariable(:,2)-extrinsicsVariable(1,2))
        ylabel('\Delta y')

        % ZCoordinate
        subplot(6,1,3)
        plot(t,extrinsicsVariable(:,3)-extrinsicsVariable(1,3))
        ylabel('\Delta z')

        % roll
        subplot(6,1,4)
        plot(t,rad2deg(extrinsicsVariable(:,4)-extrinsicsVariable(1,4)))
        ylabel('\Delta roll [^o]')

        % pitch
        subplot(6,1,5)
        plot(t,rad2deg(extrinsicsVariable(:,5)-extrinsicsVariable(1,5)))
        ylabel('\Delta pitch [^o]')

        % yaw
        subplot(6,1,6)
        plot(t,rad2deg(extrinsicsVariable(:,6)-extrinsicsVariable(1,6)))
        ylabel('\Delta yaw [^o]')


        % Set grid and datetick if time is provided
        for k=1:6
            subplot(6,1,k)
            grid on

            if isempty(dts)==0
                datetick
            end
        end





       %% Section 9: Saving Extrinsics and Metadata
        %  Saving Extrinsics and corresponding image names
        extrinsics=extrinsicsVariable;
        imageNames=L(ind);


        % Saving MetaData
        variableCamSolutionMeta.scpPath=scp_path;
        variableCamSolutionMeta.scpo=scp;
        variableCamSolutionMeta.scpZcoord=scpZcoord;
        variableCamSolutionMeta.ioeopath=rotateInfo_path;
        variableCamSolutionMeta.imageDirectory=imageDirectory;
        variableCamSolutionMeta.dts=dts;
        variableCamSolutionMeta.to=to;


        % Calculate Some Statsitics
        variableCamSolutionMeta.solutionSTD= sqrt(var(extrinsics));

        %  Save File
        save([savePath saveName ],'extrinsics','variableCamSolutionMeta','imageNames','t','intrinsics');

        %  Display
        disp(' ')
        disp(['Extrinsics for ' num2str(length(L)) ' frames calculated.'])
        disp(' ')
        disp(['X Standard Dev: ' num2str(variableCamSolutionMeta.solutionSTD(1))])
        disp(['Y Standard Dev: ' num2str(variableCamSolutionMeta.solutionSTD(2))])
        disp(['Z Standard Dev: ' num2str(variableCamSolutionMeta.solutionSTD(3))])
        disp(['roll Standard Dev: ' num2str(rad2deg(variableCamSolutionMeta.solutionSTD(4))) ' deg'])
        disp(['pitch Standard Dev: ' num2str(rad2deg(variableCamSolutionMeta.solutionSTD(5))) ' deg'])
        disp(['yaw Standard Dev: ' num2str(rad2deg(variableCamSolutionMeta.solutionSTD(6))) ' deg'])
    
    
    
    %% 固定外参计算方式
    elseif mode == 2
        %直接存外参就完事了
        %日志为0.1s间隔的，如果一开始的视频是从0s开始的，fs为2hz，说明间隔是5行取1行记录
        XYZ = load_txt_for_extrinsic(step5.extrinsic_info.o_llh,step5.extrinsic_info.file_name);
        
        begin_time = step5.extrinsic_info.videoRange(1);
        end_time = step5.extrinsic_info.videoRange(2);
        
        %第一帧图片所在的数据行
        begin_row = begin_time*10+1; 
        
        %最后一帧图片所在的数据行
        end_row = end_time*10; 
        
        %对应图片相机所在的NED坐标，也是外参的前3位
        useful_row = begin_row:5:end_row;
        
        
        %循环存外参
        imCount=1;
        for k=1:length(ind)
            extrinsics_id = [XYZ(useful_row(imCount),1),XYZ(useful_row(imCount),2),XYZ(useful_row(imCount),3),extrinsics(4),extrinsics(5),extrinsics(6)];
            extrinsicsVariable(imCount,:)=extrinsics_id; %把外参存在extrinsicsVariable中
            imCount=imCount+1;
        end
        extrinsics = extrinsicsVariable;

        %存放外参
        save([savePath saveName ],'extrinsics','t','intrinsics');
    end
end


