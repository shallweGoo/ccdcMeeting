% 获取图片每一列的时间序列，总共有height*width个时间序列,没考虑时间，在函数外手动考虑提高性能
%参数说明，path为路径，picnum为图片的总数量
function PixeSeries=readData(picInfo)
    PixeSeries = zeros(picInfo.row,picInfo.col,picInfo.picnum);
    %三维数组
        for k = 1:picInfo.picnum
            pixelInfo = imread(strcat(picInfo.file_path,picInfo.allPic(k)));
%             for i = 1:height
               for j = 1:picInfo.col
                    PixeSeries(:,j,k)= pixelInfo(:,j);
               end
%            end
        end               
end

