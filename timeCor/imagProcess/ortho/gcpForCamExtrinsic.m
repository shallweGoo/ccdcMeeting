function [Re2c,Tvec] = gcpForCamExtrinsic(camIntrinsic,gcp_objectPoints,gcp_imagePoints)
    [rvec,Tvec,~] = cv.solvePnP(gcp_objectPoints,gcp_imagePoints,camIntrinsic.mat,'DistCoeffs',camIntrinsic.dist);
    Re2c = cv.Rodrigues(rvec);
end

