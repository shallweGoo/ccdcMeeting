%c0为上电时刻的相机坐标
%c为进行拍照时刻的相机坐标
% Rc0c 从上电时刻转到拍照时刻的相机坐标
% Rotate = Euler2Rotate(yaw,pitch,roll)
Rc0_c = Euler2Rotate(0,0,-90);
Rc0_c = Rc0_c';

%Rbc是机体b坐标系到上电相机坐标系c的旋转矩阵，输入的旋转角为b->c的角度
Rb_c = Euler2Rotate(90,0,90);
Rb_c = Rb_c';
%%
%P = Rc0_c*Rb_c*[1;0;0];
%%
%Rned_b 
Rned_b = Euler2Rotate(-5.1,5,-1.3);
Rned_b = Rned_b';

%Re_ned
Re_ned = Euler2Rotate(3,0,0);
Re_ned = Re_ned';

%total
Re_c = Rc0_c*Rb_c*Rned_b*Re_ned;

% [yaw,pitch,roll] = Rotate2Euler(Rc0c);
% Rcv_e_c
Rcv_e_c = [0.01768085450531172,0.9995008050096885,0.02618259286142196;
           -0.9995578333534292,0.01829587042830817, -0.02343925995139384;
           -0.02390659251671921, -0.02575658964722512,0.9993823457135835];
Rcalc_e_ned = Rned_b'*Rb_c'*Rc0_c'*Rcv_e_c;
[yaw,pitch,roll] = Rotate2Euler(Rcalc_e_ned);

%从cv得到的旋转矩阵：
T = [  -9.298077026385412;  5.613361443645831;  50.62898101162759];
Zc = 50.0161;

%计算我以为的世界坐标到二维坐标的转换2d->3d;
DjCamMat = [3073.8 0 2000;
            0 3067.1 1125;
            0 0 1]; 



imagePoint_your_know = [1995;498;1]; %像素齐次坐标2d

wcPoint =  Re_c'* (Zc*inv(DjCamMat)*imagePoint_your_know - T)
cv_wcPoint =  Rcv_e_c'* (Zc*inv(DjCamMat)*imagePoint_your_know - T)

world_cor = [16;9;0];
pixel_cor = DjCamMat*(Re_c*world_cor+T);
pixel_cor(1) =pixel_cor(1)/pixel_cor(3);
pixel_cor(2) =pixel_cor(2)/pixel_cor(3);
pixel_cor(3) =1;

cv_pixel_cor = DjCamMat*(Rcv_e_c*world_cor+T);
cv_pixel_cor(1) =cv_pixel_cor(1)/cv_pixel_cor(3);
cv_pixel_cor(2) =cv_pixel_cor(2)/cv_pixel_cor(3);
cv_pixel_cor(3) = 1;

pixel_cor
cv_pixel_cor



