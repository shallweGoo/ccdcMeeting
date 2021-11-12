function guassfilterForOrthoImg(step)


    imgInfo.path = step.path;
    imgInfo.save_path = step.save_path;


    allFile = string(ls(imgInfo.path));
    allFile = allFile(3:end);


    for i = 1:length(allFile)
        org_pic = imread((imgInfo.path+allFile(i)));
        res = gaussfilter(org_pic,50);
        imwrite(res,(imgInfo.save_path+allFile(i)));

    end



    pi1 = org_pic(:,90);
    res = gaussfilter(org_pic,50);
    pi2 = res(:,90);
    figure(1);plot((1:size(pi1,1)),pi1,'r',(1:size(pi1,1)),pi2,'black');
    figure(2);imshow(res);

end



function [image_result] =gaussfilter(image_orign,D0)

    %GULS 高斯低通滤波器

    % D0为截至频率的（相当于设置在傅里叶谱图的半径值）

    if (ndims(image_orign) == 3)

    %判断读入的图片是否为灰度图，如果不是则转换为灰度图，如果是则不做操作

    image_2zhi = rgb2gray(image_orign);

    else 

    image_2zhi = image_orign;

    end

    image_fft = fft2(image_2zhi);%用傅里叶变换将图象从空间域转换为频率域

    image_fftshift = fftshift(image_fft);

    %将零频率成分（坐标原点）变换到傅里叶频谱图中心

    [width,high] = size(image_2zhi);

    D = zeros(width,high);

    %创建一个width行，high列数组，用于保存各像素点到傅里叶变换中心的距离

    for i=1:width

    for j=1:high

        D(i,j) = sqrt((i-width/2)^2+(j-high/2)^2);

    %像素点（i,j）到傅里叶变换中心的距离

        H(i,j) = exp(-1/2*(D(i,j).^2)/(D0*D0));

    %高斯低通滤波函数

        image_fftshift(i,j)= H(i,j)*image_fftshift(i,j);

    %将滤波器处理后的像素点保存到对应矩阵

    end

    end

    image_result = ifftshift(image_fftshift);%将原点反变换回原始位置

    image_result = uint8(real(ifft2(image_result)));

%real函数用于取复数的实部；

%uint8函数用于将像素点数值转换为无符号8位整数；ifft函数反傅里叶变换
end