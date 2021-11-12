%修正潮位
%输入参数为潮位的单位m，正负数

function fix_h = tidyFix(h, tide)
    fix_h = h + tide;
end