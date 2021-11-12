%%intrinsicsExtrinsicsToP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function creates a camera P matrix from a specified camera
%  extrinsics and intrinsics. Note, output P is normalized for homogenous
%  coordinates.


%  Input:
%  intrinsics = 1x11 Intrinsics Vector Formatted as in A_formatIntrinsics

%  extrinsics = 1x6 Vector representing [ x y z azimuth tilt swing] of the camera.
%  XYZ should be in the same units as xyz points to be converted and azimith,
%  tilt, and swing should be in radians.


%  Output:
%  P= [4 x 4] transformation matrix to convert XYZ coordinates to distorted
%  UV coordinates.

%  K=  [ 3 x 3] K matrix to convert XYZc Coordinates to distorted UV coordinates

%  R = [3 x 3] Matrix to rotate XYZ world coordinates to Camera Coordinates XYZc

%  IC =[ 4 x3] Translation matrix to translate XYZ world coordinates to Camera Coordinates XYZc



%  Required CIRN Functions:
%  None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P, K, R, IC] = intrinsicsExtrinsics2P( intrinsics, extrinsics )


%% Section 1: Format IO into K matrix
fx=intrinsics(5);
fy=intrinsics(6);
c0U=intrinsics(3);
c0V=intrinsics(4);

K = [-fx 0 c0U;
    0 -fy c0V;
    0  0 1];
%这种方式是因为定义的UV坐标系和相机坐标系的xy方向不同，书上的相机坐标系为x,y分别和u,v方向相同。
%故在此fx,fy都加上了负号            






%% Section 2: Format EO into Rotation Matrix R
% Here, a rotation matrix from World XYZ to Camera (subscript C, not UV) is
% needed. The following code uses CIRN defined angles to formulate an R
% matrix. However, if a user would like to define R differently with
% different angles, this is where that modifcation would occur. Any R that
% converts World to XYZc would work correctly.

azimuth= extrinsics(4);
tilt=extrinsics(5);
swing=extrinsics(6);
[R] = my_angles2R(azimuth,tilt,swing);


%添加一种计算旋转矩阵的方式









%% Section 3: Format EO into Translation Matrix
x=extrinsics(1);
y=extrinsics(2);
z=extrinsics(3);

IC = [eye(3) [-x -y -z]'];
% camera_world= [x y z]';
% 
% R*camera_world




%% Section 4: Combine K, Rotation, and Translation Matrix into P
P = K*R*IC;
P = P/P(3,4); %单应性矩阵可以以3行4列的那个元素进行归一化


end

