记录流程顺序

1、downSampleFromVideo 对应A0

2、getGcpInfo_UV(对应B)->getGcpInfo_World（自己添加）

3、matchGcp（整合gcp的信息）对应C

4、getScpInfo（获取稳定点的信息，如果采用模板匹配就不用这个）对应E

5、calcFollowedExtrinsic（利用scp或者模板计算每帧图像的外参） 对应F

6、chooseRoi（选择感兴趣的区域，以自建世界坐标系（local）为基准） 对应D_grid;

7、pixelImg 得到像素图,对应G2

8、rotImg 用于旋转像素图 量产最终的结果图







不使用控制点的方案，在matchGcp和calcFollowedExtrinsic这两个函数里面需要修改，
在matchGcp中原本是用gcp的UV坐标和实际坐标XYZ来进行非线性拟合从而进行计算外参中的roll,yaw,pitch的，此时用了相机的姿态角，那么就要