%sampleFre为采样频率,其实信号不用考虑时间，只考虑一个一个点的幅值就可以，默认使用汉明窗
function f_rep = ForMidPoint_f(signal1,signal2,cpsdVar) 
    %采样频率为人为设置，目前还不知道设为什么，其实采样频率为2hz，即1s采2帧
%     [Cxy,~] = mscohere(signal1,signal2,hamming(100),50,[],sampleFre);%涉及许多与窗函数相关的知识，暂时不知所措
%     
%     [Pxy,F] = cpsd(signal1,signal2,hamming(cpsdVar.windowLen),cpsdVar.winOverLap,cpsdVar.f,cpsdVar.Fs);
    [Pxy,F] = cpsd(signal1,signal2,[],[],[],cpsdVar.Fs);
%     Pxy(Cxy<0.1) =0;
    mag = abs(Pxy);
%     plot(F,mag);
    
    lp = 0;
    rp = 0;
    for i = 1:size(F)
        if(F(i)>=cpsdVar.waveLow)
            lp = i;
            break;
        end
    end
    for i = lp:size(F)
       if(F(i)>=cpsdVar.waveHigh)
            rp = i;
            break;
       end
    end
    validMag = mag(lp:rp,1);
    validF = F(lp:rp,1);
    f_rep = validMag'*validF/sum(validMag);
end