function [P, K, R, IC] = my_intrinsicsExtrinsics2P(intrinsics, extrinsics)


%% Section 1: Format IO into K matrix
fx=intrinsics(5);
fy=intrinsics(6);
c0U=intrinsics(3);
c0V=intrinsics(4);


%按照自己的内参矩阵进行定义
K = [fx 0 c0U;
    0 fy c0V;
    0  0 1];



%% Section 2: Format EO into Rotation Matrix R

% 定义自己的旋转矩阵
roll= extrinsics(4);
pitch=extrinsics(5);
yaw=extrinsics(6);
[R] = my_angles2R(roll,pitch,yaw);



%% Section 3: Format EO into Translation Matrix
x=extrinsics(1);
y=extrinsics(2);
z=extrinsics(3);

IC = [eye(3) [-x -y -z]'];



%% Section 4: Combine K, Rotation, and Translation Matrix into P
P = K*R*IC;
P = P/P(3,4); %单应性矩阵可以以3行4列的那个元素进行归一化
end
