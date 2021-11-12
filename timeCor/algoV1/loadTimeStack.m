function pic_info = loadTimeStack(id, fold_path, params) 
    pic_info.id = id;
    pic_info.file_path =  fold_path+"\变换后图片"+pic_info.id+"\";% 图像文件夹路径
    pic_info.all_pic = string(ls(pic_info.file_path));%直接包括所有的文件名
    pic_info.all_pic = pic_info.all_pic(3:end);
    pic_info.pic_num = size(pic_info.all_pic, 1);%统计所有照片的数量

%     src=imread(pic_info.file_path+pic_info.all_pic(1));
%     clear src;

    pic_info.prm = params.dxm;               %单位米,pixel resolution meter
    load(fold_path+"\变换后图片"+ pic_info.id +"相关处理\最终元胞数据\data_cell_det&nor.mat");
    load(fold_path+"\变换后图片"+ pic_info.id +"相关处理\最终元胞数据\after.mat");
    load(fold_path+"\变换后图片"+ pic_info.id +"相关处理\最终元胞数据\before.mat");
    pic_info.afterFilter = usefulData;
    pic_info.timelag_before = beforeData;
    pic_info.timelag_after = afterData;
    [pic_info.row, pic_info.col, ~] = size(pic_info.afterFilter);
    
    clear usefulData;
    clear beforeData;
    clear afterData;
    
end