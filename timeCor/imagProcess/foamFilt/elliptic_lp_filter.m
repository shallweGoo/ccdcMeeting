%设计一个椭圆滤波器过滤泡沫区域（实际上可以不用椭圆滤波器）
function H = elliptic_lp_filter(height,width,f_M,f_m,theta,n)

H = zeros(width,height);
%转成弧度
theta = theta*pi/180;

for i=1:width
    for j=1:height
        H(i,j) = 1/(1 + ((((i*cos(theta)+j*sin(theta))/f_M)^2) + ((-i*cos(theta)+j*sin(theta))/f_m)^2)^n);
    end
end

end
