function Rotate = d_Euler2Rotate(yaw,pitch,roll) %该方式为动态欧拉角旋转,旋转矩阵不同,按xyz旋转,此时为坐标左乘的结果
   %得到的是右乘矩阵，对应列变换
   %应该是一个
   yaw = yaw*pi/180;
   pitch = pitch*pi/180;
   roll = roll*pi/180;
   Rx = [1 0 0;
         0 cos(roll) -sin(roll);
         0 sin(roll) cos(roll)];%绕x轴旋转的为滚动角
   Ry = [cos(pitch) 0 sin(pitch);
         0 1 0;
         -sin(pitch) 0 cos(pitch)];%绕y轴旋转的为俯仰
   Rz = [cos(yaw) -sin(yaw) 0;
         sin(yaw) cos(yaw) 0;
         0 0 1];
   Rotate = Rz*Ry*Rx;
   
end