
%获取泡沫区域

foam_area = imread("F:\workSpace\matlabWork\dispersion\selectPic\afterPer\双月湾第二组变换后\变换后图片3\uasDemo_1603582140167.jpg");
foam_area = foam_area(20:100,20:80);
imshow(foam_area);
imwrite(foam_area,"foam_area.jpg");
