function imag = imagFiltUseDiffFilter(imag_org,filter)
%使用不同滤波器的滤波过程
    if (ndims(imag_org) == 3)
        image_2zhi = rgb2gray(imag_org);
    else 
        image_2zhi = imag_org;
    end
    image_fft = fft2(image_2zhi);%用傅里叶变换将图象从空间域转换为频率域
    image_fftshift = fftshift(image_fft); %将零频率成分（坐标原点）变换到傅里叶频谱图中心

    [height,width] = size(image_2zhi);
    for i = 1:width
        for j =1:height
            image_fftshift(j,i)= filter(i,j)*image_fftshift(j,i);
        end
    end
    
    imag = ifftshift(image_fftshift);%将原点反变换回原始位置
    imag = uint8(real(ifft2(imag)));

end

