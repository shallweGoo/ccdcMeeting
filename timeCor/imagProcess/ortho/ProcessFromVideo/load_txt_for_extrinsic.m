%该函数将飞行日志txt中的数据提取出来，获取经纬高信息俯仰角
%获取相机的xyz

function XYZ = load_txt_for_extrinsic(o_llh,file_name)
    datas = load(file_name);
    llh = [datas(:,1), datas(:,2), datas(:,4)];
    XYZ = gcpllh2NED(o_llh,llh);
    XYZ = XYZ';
end

