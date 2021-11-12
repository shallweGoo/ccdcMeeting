%该函数的功能是对世界坐标上的点在原图中进行下采样
%保证了每个像素点之间的距离是相同的
%输入参数为跨岸的坐标范围crossShoreRange以及沿岸的坐标范围longShoreRange，坐标范围自己选定,坐标也是自己选定的,
function downSampleImage= downSample(src,crossShoreRange,longShoreRange,crossShoreInterval,longShoreInterval,cameraMatrix,Re_c,T)
    crossPoint = crossShoreRange(1):crossShoreInterval:crossShoreRange(2);
    longPoint = longShoreRange(1):longShoreInterval:longShoreRange(2);
    downSampleImage = zeros(size(crossPoint,2),size(longPoint,2));
    wc = 1;
    for i = longShoreRange(1):longShoreInterval:longShoreRange(2)
        hc = 1;
        for j = crossShoreRange(1):crossShoreInterval:crossShoreRange(2)
            samplePointWorldCor = world2image(cameraMatrix,Re_c,T,[j;i;0]);
            if(samplePointWorldCor(1)>size(src,2) || samplePointWorldCor(1)<1 || samplePointWorldCor(2)>size(src,1) || samplePointWorldCor(2)<1)
            pixelValue = 0;
         else
            pixelValue = src(samplePointWorldCor(2),samplePointWorldCor(1));
            end
            downSampleImage(hc,wc) = pixelValue; 
            hc = hc+1;
        end
        wc = wc+1;
    end    
    downSampleImage = uint8(downSampleImage);
end

