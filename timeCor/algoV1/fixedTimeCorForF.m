%row为当前所在的行数
%idx为经过计算所得到每一点的互相关最大值所在的点
function targetF = fixedTimeCorForF(idx,currentCol,picInfo,cpsdVar)
    targetF = nan(picInfo.row,1);
    for i = 1:picInfo.row
        if( ~isnan(idx(i)))
            orgSignal = picInfo.afterFilter{i,currentCol};
            targetSignal = picInfo.afterFilter{i-idx(i)+1,currentCol}; 
            targetF(i) = ForMidPoint_f(orgSignal,targetSignal,cpsdVar);
        end
    end
       
end

