

该文件夹程序主要在于参考[论文](https://smartech.gatech.edu/handle/1853/19793)中所用的消除foam（白色泡沫）的方法，论文题目为：Nonlinear Bathymetry Inversion Based on Wave Property Estimation from Nearshore Video Imagery



**思路**：

​	拟跳过frame-differenced这个步骤，因为已经进行过相关图像的处理。

​	直接实施**Butterworth filter as an elliptic low-pass filter**这个步骤。

​	滤波器公式为：
$$
H(u,v) = \frac {1}{1+[(\frac {u\cdot cos\theta+v\cdot sin\theta}{f_M})^2+(\frac {-u\cdot cos\theta+v\cdot sin\theta}{f_m})^2]^n}
$$
​	其中根据经验可得到：

​	
$$
f_M = 0.3;f_m = 0.07;n = 3
$$


​	 $\theta$ 的角度由图像的频谱得出（其实这一步我也不是很理解），具体可以看一下论文。

