%如果要求的是C1->C2坐标的旋转矩阵，固定轴旋转,则此时输入的角度应该是C2->C1的欧拉角，正负方向由右手定则所决定。
%也可以输入C1->C2坐标的旋转角，此时要得到C1->C2的旋转矩阵需要获得的结果转置。
%该方式为静态欧拉角旋转，这种方式不会出现万向锁
function Rotate = Euler2Rotate(yaw,pitch,roll) 
   yaw = yaw*pi/180;
   pitch = pitch*pi/180;
   roll = roll*pi/180;
   Rx = [1 0 0;
         0 cos(roll) sin(roll);
         0 -sin(roll) cos(roll)];%绕x轴旋转的为滚动角
   Ry = [cos(pitch) 0 -sin(pitch);
         0 1 0;
         sin(pitch) 0 cos(pitch)];%绕y轴旋转的为俯仰
   Rz = [cos(yaw) sin(yaw) 0;
         -sin(yaw) cos(yaw) 0;
         0 0 1];
   Rotate = Rz'*Ry'*Rx';
end
