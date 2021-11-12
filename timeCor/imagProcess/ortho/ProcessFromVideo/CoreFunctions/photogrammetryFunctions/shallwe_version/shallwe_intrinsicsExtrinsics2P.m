function [P, K, R, IC] = shallwe_intrinsicsExtrinsics2P(intrinsics, extrinsics)


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

% w2n_roll = world2ned(1);
% w2n_pitch = world2ned(2);
% w2n_yaw = world2ned(3);
% 
% R_world2ned = shallwe_angles2R(w2n_roll,w2n_pitch,w2n_yaw);
% 
% 
% n2b_roll = ned2b(1);
% n2b_pitch = ned2b(2);
% n2b_yaw = ned2b(3);
% 
% R_ned2b = shallwe_angles2R(n2b_roll,n2b_pitch,n2b_yaw);
% 
% R_b2camera = shallwe_angles2R(90,0,90); %这个是机体旋转到相机坐标系的角度
% 
% R = R_b2camera*R_ned2b*R_world2ned;%现实坐标系到相机坐标系的旋转矩阵


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%先是NED和CAMERA坐标系的互换，最后把NED换为WORLD%%%%%%%%%%%%%%%
roll= extrinsics(4);
pitch=extrinsics(5);
yaw=extrinsics(6);
% R = shallwe_angles2R(roll,pitch,yaw);
R = shallwe_angles2R(roll, pitch, yaw);


% camera_world = [-76.7568,-12.6039,101.8405];


%% Section 3: Format EO into Translation Matrix
x=extrinsics(1);
y=extrinsics(2);
z=extrinsics(3);

IC = [eye(3) [-x -y -z]'];



%% Section 4: Combine K, Rotation, and Translation Matrix into P
P = K*R*IC;
P = P/P(3,4); %单应性矩阵可以以3行4列的那个元素进行归一化
end
