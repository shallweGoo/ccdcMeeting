%ned和用相机的exif信息所得到的欧拉角
function [R] = my_angles2R(roll,pitch,yaw)
    R1 = subR_z(yaw);
    R2 = subR_z(pi/2) * R1;
    R = subR_x(pi/2 - pitch)* R2;

end

function R = subR_x(rad)
R(1 , 1) = 1;
R(1 , 2) = 0;
R(1 , 3) = 0;
R(2 , 1) = 0;
R(2 , 2) = cos(rad);
R(2 , 3) = sin(rad);
R(3 , 1) = 0;
R(3 , 2) = -sin(rad);
R(3 , 3) = cos(rad);
end

function R = subR_y(rad)
R(1 , 1) = cos(rad);
R(1 , 2) = 0;
R(1 , 3) = -sin(rad);
R(2 , 1) = 0;
R(2 , 2) = 1;
R(2 , 3) = 0;
R(3 , 1) = sin(rad);
R(3 , 2) = 0;
R(3 , 3) = cos(rad);
end

function R = subR_z(rad)
R(1 , 1) = cos(rad);
R(1 , 2) = sin(rad);
R(1 , 3) = 0;
R(2 , 1) = -sin(rad);
R(2 , 2) = cos(rad);
R(2 , 3) = 0;
R(3 , 1) = 0;
R(3 , 2) = 0;
R(3 , 3) = 1;
end




