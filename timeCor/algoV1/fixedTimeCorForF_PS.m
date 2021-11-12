function targetF = fixedTimeCorForF_PS(currentCol,picInfo,cpsdVar)
%FIXEDTIMECORFORF_PS 该函数为固定时间方法要进行的海浪的频率，就采用本身的功率谱进行频率的
%计算，而不去寻找另一个功率谱
    targetF = nan(picInfo.row,1);
    for i = 1:picInfo.row
            orgSignal = picInfo.afterFilter{i,currentCol};
            targetF(i) = ForMidPoint_f(orgSignal,orgSignal,cpsdVar);
    end
end

