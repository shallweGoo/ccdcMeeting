% 该函数的作用为画出某一列的所有时间堆栈
% img_path为绝对路径
% col为要画的那一列
function time_stack = plotTimeStack(img_path, col)
    all_pic = string(ls(img_path));%直接包括所有的文件名
    all_pic = all_pic(3:end);
    for i = 1 : length(all_pic)
        src = imread(img_path + all_pic(i));
        time_stack(:,i) = src(:, col);
    end
%     imshow(time_stack);
%     image(time_stack);
%     colorbar;
%     xlabel('x');
%     xlabel('y');
end