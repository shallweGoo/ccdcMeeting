%该函数用于得到两个时间堆栈，0s时和滞后时,fixed_time的单位为秒,afterFilter取了原图像中100：1100的图片
function [TimeStack1,TimeStack2] = getTimeStack(picInfo,col,fixed_time)
    if mod(fixed_time,picInfo.timeInterval) ~= 0
        error("you need to reselect fixed_time in interval time's integer multiple");
    end
    pixelInfo = picInfo.afterFilter(:,col);%想要得到这一列的堆栈
    temp = zeros(picInfo.row,size(picInfo.afterFilter{1,1},2));
    %得到了该列所有的时间序列
    for i = 1:picInfo.row
        temp(i,:) = pixelInfo{i,:};
    end
    TimeStack1 = temp(:,1:end-fixed_time/picInfo.timeInterval);
    TimeStack2 = temp(:,fixed_time/picInfo.timeInterval+1:end);
end

