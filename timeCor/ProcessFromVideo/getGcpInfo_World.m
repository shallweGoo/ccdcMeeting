function [gcpInfo_world, uav_local] = getGcpInfo_World(step2) 
% 该函数用于获取gcp在自建坐标系下的坐标，要求有顺序的输入
% 输入参数为gcp_llh(gps),o_llh(原点gps),cmPara(相机参数)
% 借助了gps(经纬高llh) -> 东北天(enu) -> 北东地(ned) -> 自建坐标系(new)这样的一个流程,原点需要自选
%
    

    gcp_llh = step2.world.gcp_llh;
    o_llh = step2.world.o_llh;

    savePath = step2.world.savePath;
    
    if(isfield(step2.world,'uav_llh'))
        uav_llh = step2.world.uav_llh;
    end
    
    gcpInfo_world = gcpllh2NED(o_llh, gcp_llh); % gcp->enu 这个函数在之前的文件夹
    gcpInfo_world = gcpInfo_world';
%     gpcInfo_local = ned2local(o_llh, gcpInfo_world);
    
    uav_pos_world = gcpllh2NED(o_llh, uav_llh); % gcp->ned 这个函数在之前的文件夹
    uav_pos_world = uav_pos_world';
    uav_local = ned2local(uav_pos_world, step2);
    
    disp(['uav loal pos ' num2str(uav_local)]);
    
    if isempty(savePath) ~= 1
        saveName = 'gcpInfo';
        save([savePath saveName '_world'],'gcpInfo_world','uav_pos_world');
    end
    
        
end


% 输入为ned坐标
function local = ned2local(target_ned, step2)
    euler_ned2new = step2.world.euler_ned2new;    

    yaw = euler_ned2new(1);
    pitch = euler_ned2new(2);
    roll = euler_ned2new(3);
    
    Rotate_ned2new = Euler2Rotate(yaw, pitch, roll); 
    Rotate_ned2new = Rotate_ned2new'; %获取ned->new的旋转矩阵
    
    local = Rotate_ned2new * target_ned';
    local = local';
end

