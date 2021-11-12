% worldµÄÐÅÏ¢

function world_info = getWorldInfo(params, pic_info)
    world_info.crossShoreRange = (pic_info.row - 1) * params.dxm;
    world_info.longShoreRange = (pic_info.col - 1) * params.dxm;
    world_info.x = 0 : params.dxm : world_info.longShoreRange;
    world_info.y = 0 : params.dxm : world_info.crossShoreRange;
end