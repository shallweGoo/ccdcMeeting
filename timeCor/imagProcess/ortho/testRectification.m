%% 读取像素
src = rgb2gray(imread('C:\Users\49425\Desktop\cvtest\testRe_c\DJI_0013.JPG'));


%% 计算透视变换的矩阵
Rold =[0.9969982141132112, 0.07176715926050718, -0.02905229606665155;
 -0.04316140573852288, 0.8266985777497814, 0.5609871251652423;
 0.06427794419349442, -0.5580492239920827, 0.8273145771060076];

Rnew = eye(3);
cameraMatrix.mat = [3073.8 0 2000;
            0 3067.1 1125;
            0 0 1]; 
cameraMatrix.dist =[0.0986746953968013,-0.249452801912667,0,0,0];
resTest=orthoRectification(cameraMatrix,src,Rold,Rnew);
imshow(resTest);   





        
        