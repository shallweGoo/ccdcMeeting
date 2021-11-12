### 如何由exif得到NED坐标系到CAMERA坐标系下的旋转矩阵





飞机在天上的欧拉角由exif信息得出：

![Snipaste_2021-05-04_16-04-29](F:\workSpace\matlabWork\seaBathymetry\imagProcess\ortho\ProcessFromVideo\CoreFunctions\photogrammetryFunctions\shallwe_version\readme\Snipaste_2021-05-04_16-04-29.png)

​				  																					**图1 EXIF信息**

其中所有的角度都是与NED坐标系所对应的夹角。

经过测试得到大疆机体坐标系与相机坐标系的关系下图所示：

![](F:\workSpace\matlabWork\seaBathymetry\imagProcess\ortho\ProcessFromVideo\CoreFunctions\photogrammetryFunctions\shallwe_version\readme\机体坐标系和相机坐标系说明.png)

​																									**图2 机体与相机坐标系的说明**



实际上要得到NED到CAMERA的旋转矩阵$R_{ned}^{camera}$，需要明确两个问题

1. **$R_{ned}^{camera}$如何计算。**
2. **EXIF上记录的CAMERA的姿态角所代表的意义。**



​	对于**$R_{ned}^{camera}$如何计算**这个问题，经过推导可以由
$$
R_{ned}^{camera} = R_b^{camera}·R_{ned}^b
$$
得到。即要求NED到机体坐标系b的旋转矩阵$R_{ned}^b$,以及机体坐标系b到CAMERA坐标系下的旋转矩阵$R_b^{camera}$，**在保持静止的情况下，经过测试$R_b^{camera}$的关系如上所示。用动态欧拉角来表示（旋转顺序为：Z->Y->X）来表示就是$yaw=\pi/2，pitch=0,roll=\pi/2$,**带入动态欧拉角对应的旋转矩阵即可。而$R_{ned}^b$的关系就是由imu提供的，也就是EXIF所记录的：Pitch,Yaw,Roll这三个信息。



**EXIF上记录的CAMERA的姿态角所代表的意义。**

​	上面只是描述了**静止状态下**机体坐标系和相机坐标系的关系，在实际拍摄中，相机是可以调节俯仰的。也就是说CameraPitch描述了X轴转动的角度。简单来说此时CameraPitch为绕相机坐标系下X轴旋转的角度（-35.6），按照欧拉角的定义，应该为Roll,但是大疆飞机里面实际上是用了机体坐标系，那么对应过去就是绕机体坐标系Y轴旋转的角度，则在机体坐标中称为Pitch(-35.6)。

​	对于CameraYaw也是如此，在机体坐标系下是绕机体坐标系Z轴旋转的角度，而在相机坐标系下实际上是为绕相机坐标系Y轴旋转的角度。







综上，在计算$R_{ned}^{camera}$时要理清欧拉角的关系。以上图为例，从NED到b坐标系的旋转矩阵$R_{ned}^b$以**Z->Y->X的动态旋转顺序**就为
$$
yaw= -122.8°，pitch =10.4°，roll = 2.5°
$$
而$R_b^{camera}$以**Z->Y->X的动态旋转顺序**
$$
yaw= 90°，pitch =0°，roll = \pi/2-35.6°
$$
$roll = \pi/2-35.6°$可以模拟一下旋转过程就可以知道。