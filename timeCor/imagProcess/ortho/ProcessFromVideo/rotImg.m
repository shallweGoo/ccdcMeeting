function rotImg(pixelInst_path,savePath)
%ROTIMG 为了旋转pixelInst中的像素下采样图，得到海浪自下往上传播的效果图

    tmp1 = load(pixelInst_path);
    pixInst = tmp1.pixInst;
%     rectMeta = tmp1.rectMeta;
    t = tmp1.t;
    clear tmp1;
    
    [~,~,imgNum] = size(pixInst(1).Igray);
    for i = 1:imgNum
        img = rot90(pixInst(1).Igray(:,:,i),3);
        imwrite(img,[savePath 'finalOrth_'  num2str(round(((t(i)-datenum(1970,1,1))*24*3600)*1000)) '.jpg'],'jpg');
        disp([num2str(i/imgNum*100) '% completed']);
    end
    
    
    
end

