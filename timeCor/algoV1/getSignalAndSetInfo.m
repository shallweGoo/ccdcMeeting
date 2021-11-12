% 构建信号结构体和信息
% 现在都不知道有没有用
function structOfPosAndSignal = getSignalAndSetInfo(picInfo, Height, Width)
    structOfPosAndSignal.y = Height;
    structOfPosAndSignal.x = Width;
    structOfPosAndSignal.signal = picInfo.afterFilter{Height,Width};
end

