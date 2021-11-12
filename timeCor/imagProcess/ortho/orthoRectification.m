%原图像为灰度图，输出也为灰度图
function res = orthoRectification(camIntrinsic,orgPicInfo,Re_c_old,Re_c_new)

%透视变换矩阵
H = camIntrinsic.mat*Re_c_new*Re_c_old'*inv(camIntrinsic.mat);
x_min = 1e9;
x_max = -1e9;
y_min = 1e9;
y_max = -1e9;

[src.row ,src.col] = size(orgPicInfo);

for i = 1:src.row
    for j = 1:src.col
         temp = H*[j,i,1]';
         temp(1) = round(temp(1)/temp(3)); % 四舍五入
         temp(2) = round(temp(2)/temp(3)); % 四舍五入
         x_min = min(temp(1),x_min);
         x_max = max(temp(1),x_max);
         y_min = min(temp(2),y_min);
         y_max = max(temp(2),y_max);
    end
end

inv_H = inv(H);

dst.row = y_max - y_min + 1; %目标图像所具有的行数
dst.col = x_max - x_min + 1; %目标图像所具有的列数
if(dst.row > 1e9 || dst.col > 1e9)
    error('cannot do OrthoRectification because of dst_row or/and dst_col was out of range');
end

dst.pixel = zeros(dst.row,dst.col); %目标图像的大小

% 从目标图像变换过去
  for i = 1+y_min:dst.row+y_min
      for j = 1+x_min:dst.col+x_min
          dst2src = inv_H*[j,i,1]';
          dst2src(1) = round(dst2src(1)/dst2src(3)); % 四舍五入
          dst2src(2) = round(dst2src(2)/dst2src(3)); % 四舍五入
          if(dst2src(1)>=1 && dst2src(2)>=1 && dst2src(2)<= src.row && dst2src(1)<= src.col)
            dst.pixel(i-y_min,j-x_min) = orgPicInfo(dst2src(2),dst2src(1));
          end
      end
  end
    res = uint8(dst.pixel);
    
% imshow(res);

 

 



