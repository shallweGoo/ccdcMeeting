img=imread('F:\workSpace\matlabWork\dispersion\selectPic\afterPer\双月湾第二组变换后\变换后图片\uasDemo_1603582140501.jpg');

subplot(2,3,1);imshow(img);title('原图');
% f=rgb2gray(img);
f = img;
F=fft2(f);
F1=log(abs(F)+1);   %取模并进行缩放
subplot(2,3,2);imshow(F1,[]);title('傅里叶变换频谱图');
Fs=fftshift(F);      %将频谱图中零频率成分移动至频谱图中心
S=log(abs(Fs)+1);    %取模并进行缩放
subplot(2,3,3);imshow(S,[]);title('频移后的频谱图');
fr=real(ifft2(ifftshift(Fs)));  %频率域反变换到空间域，并取实部
% ret=im2uint8(mat2gray(fr));    %更改图像类型
ret=im2uint8(mat2gray(fr)); 
subplot(2,3,4);imshow(ret),title('逆傅里叶变换');
F2=log(abs(Fs).^2+1);   %功率谱
subplot(2,3,5);imshow(F2,[]),title('功率谱');