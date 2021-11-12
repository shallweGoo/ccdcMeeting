R_sta = shallwe_angles2R(90,0,45,1);
R_vol = shallwe_angles2R(90,0,90,2);

e1 = [1,0,0]';
e2 = [0,1,0]';
e3 = [0,0,1]';

m = [e1,e2,e3];
r_s = R_sta*m;
r_v = R_vol*m;