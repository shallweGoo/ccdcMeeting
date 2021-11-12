该版本为ccdc会议论文版本，里面参数暂不改变，上传至[github](https://github.com/shallweGoo/ccdcMeeting)地址，采用的是mainV2版本。

1. ## 流程

   - **对视频进行下采样，滤波，正射变换等处理（ProcessFromVideo/mainOrtho.m）**

     设置好需要采集的视频路径，列出论文里面的与该文件相关的参数，可以看ccdcVideoParameters.m文件（路径可能有出入，需要根据实际存放路径修改）

   - **对正射图片进行数据采集（mainMakeTimeStack.m）**

     获得区域的地理坐标xyz, 采集的时间t, 和像素强度堆栈信号data。相关参数都在mainMakeTimeStack.m里面，可以设置像素分辨率和距离间隔。

   - **算法主体（mainV2.m）**

     算法主体主要是phantom4里面的配置需要改一下，之后直接运行即可。

2. ## 结果和对比

   运行cmpGroundTruth.m即可，里面有一些参数需要改，并且不是可以完全运行的，可能会在某个地方报错。
   
3. ## 重要参数

   位于ccdcPhantom4.m，记得把phantom4.m里面的参数改ccdcPhantom4.m版本的。
