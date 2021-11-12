% 该函数用于计算整列的深度,浅海水深
% f和c都由列向量表示
function seaDepth = calDepth(c, f)
    const = 2*pi;
    seaDepth = (c./f/const).*atanh(const/10*c.*f);
end

