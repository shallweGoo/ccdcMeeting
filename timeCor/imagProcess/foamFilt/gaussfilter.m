function H =gaussfilter(width,height,D0) 
%gauss 低通滤波
D = zeros(width,height);
H = zeros(width,height);
for i=1:width
    for j=1:height
        D(i,j) = sqrt((i-width/2)^2+(j-height/2)^2);
%像素点（i,j）到傅里叶变换中心的距离
        H(i,j) = exp(-1/2*(D(i,j).^2)/(D0*D0));
    end
end
