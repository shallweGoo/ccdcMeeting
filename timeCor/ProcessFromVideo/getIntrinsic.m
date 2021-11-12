load('F:\workSpace\matlabWork\seaBathymetry\imagProcess\ortho\phantom4rtk_video.mat');

intrinsics = [];
% intrinsics = cat(2,intrinsics,calibrationSession.CameraParameters.ImageSize(2));
% intrinsics = cat(2,intrinsics,calibrationSession.CameraParameters.ImageSize(1));
% 
% intrinsics = cat(2,intrinsics,calibrationSession.CameraParameters.PrincipalPoint);
% intrinsics = cat(2,intrinsics,calibrationSession.CameraParameters.FocalLength);
% 
% 
% intrinsics = cat(2,intrinsics,calibrationSession.CameraParameters.RadialDistortion);
% intrinsics = cat(2,intrinsics,calibrationSession.CameraParameters.TangentialDistortion);
% intrinsics = cat(2,intrinsics,0);

% save('./neededData/intrinsicMat_phantom4rtk','intrinsics');


intrinsics = cat(2,intrinsics,cameraParams.ImageSize(2));
intrinsics = cat(2,intrinsics,cameraParams.ImageSize(1));

intrinsics = cat(2,intrinsics,cameraParams.PrincipalPoint);
intrinsics = cat(2,intrinsics,cameraParams.FocalLength);


intrinsics = cat(2,intrinsics,cameraParams.RadialDistortion);
intrinsics = cat(2,intrinsics,cameraParams.TangentialDistortion);
intrinsics = cat(2,intrinsics,0);
save('./neededData/intrinsicMat_phantom4rtk','intrinsics');