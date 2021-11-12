function gridPlot(grid_pic)
% grid_pic为1m分辨率的矩阵
    
    cmap = colormap( 'jet' );
    colormap( flipud( cmap ) );  % 创建颜色

    row = size(grid_pic,1);
    col = size(grid_pic,2);

    %shading flat;
    
    pcolor(1:col,1:row,grid_pic);
    caxis([0 5]); %设置深度的显示范围
    set(gca, 'ydir', 'nor');
    axis equal;
    axis tight;
    h = colorbar('peer', gca);
    set(h, 'ydir', 'rev');
    set(get(h,'title'),'string', 'h (m)');
    set(gca,'ydir','reverse');
    % set(gca,'XTick',1:col,'YTick',1:row);  % 设置坐标
    % axis image xy;  % 沿每个坐标轴使用相同的数据单位，保持一致
%     title('海底地形图V');
end