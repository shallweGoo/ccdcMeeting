%该函数用于计算旋转矩阵Rec = Ref*Rfc
%Rec为现实坐标系到相机坐标的旋转矩阵
%Ref为现实坐标到机体坐标的旋转矩阵
%Rfc为机体坐标到相机坐标的旋转矩阵

%输入的角度为相机的欧拉角,由EXIF信息得到，要好好理解一下exif里面的每个旋转角的意义，是由NED转到CAMERA坐标系的旋转矩阵
function [R] = shallwe_angles2R(roll,pitch,yaw,mode)
    if nargin <= 3
        mode = 1;
    end
    
    if mode == 1  %动态欧拉角旋转矩阵
        R = varible_rm(pi/2+roll,pitch,pi/2+yaw);
    else
        R = static_rm(roll,pi/2+pitch,pi/2+yaw);
    end

end


function R = static_rm(roll,pitch,yaw)
    c1 = cos(roll);
    c2 = cos(pitch);
    c3 = cos(yaw);
    s1 = sin(roll);
    s2 = sin(pitch);
    s3 = sin(yaw);
    %静态欧拉角ZYX旋转规则，外旋,Rz*Ry*Rx,旋转顺序为：Z->Y->X
    R = [
            c3*c2, s3*c1+c3*s2*s1, s3*s1-c3*s2*c1;
            -s3*c2 , c3*c1-s3*s2*s1 , c3*s1+s3*s2*c1;
            s2 , -c2*s1, c2*c1
        ];

end

function R = varible_rm(roll,pitch,yaw)
    c1 = cos(roll);
    c2 = cos(pitch);
    c3 = cos(yaw);
    s1 = sin(roll);
    s2 = sin(pitch);
    s3 = sin(yaw);
    
    %动态欧拉角ZYX旋转,内旋，旋转顺序为：Z->Y->X,Rx*Ry*Rz
    R = [
        c2*c3,c2*s3,-s2;
        s1*s2*c3-c1*s3,s1*s2*s3+c1*c3,s1*c2;
        c1*c3*s2+s1*s3,c1*s2*s3-s1*c3,c1*c2
    ];

end



