%该函数用于像素坐标向世界坐标转换，但是深度信息可能存在较大偏差
function worldCor = image2world(cameraMatrix,Re_c,T,imageCor,seaLevelHeight)
    M1 = inv(Re_c) * inv(cameraMatrix.mat) * imageCor;
    M2 = Re_c\T;
    Zc = (seaLevelHeight+M2(3))/M1(3);
    worldCor =  Re_c'* (cameraMatrix.mat\imageCor*Zc - T);
end

