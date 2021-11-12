date : 2021/10/11
content: 以cBathy作为参考，用二维矩阵来存放timestack数据，每列是一个(x,y)点对应。
列对应(x,y)点的关系以伪代码表示成如下：
col = 1;
for x_id = 1 : x_end
    for y_id = 1 : y_end
        ...
        res(:, col) = data;
        col = col + 1;
    end
end