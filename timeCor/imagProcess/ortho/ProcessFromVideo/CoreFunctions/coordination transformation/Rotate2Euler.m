%静态欧拉角定义，得到先前定义过的欧拉角，要得到c1->c2的欧拉角，输入应该为c2->c1的旋转矩阵
% 该方式为z-x-y顺规的欧拉角，右乘矩阵
function eulerAngle = Rotate2Euler(Rotate)
    yaw = atan(Rotate(2,1)/Rotate(1,1))*180/pi; %偏航，按照原本欧拉角的定义
    pitch = asin(-Rotate(3,1))*180/pi;
    roll = atan(Rotate(3,2)/Rotate(3,3))*180/pi;
    eulerAngle(1) = yaw;
    eulerAngle(2) = pitch;
    eulerAngle(3) = roll;
end

