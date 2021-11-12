% clear all;
close all;
f1 = 0.3;
f2 = 1;
f3 = 1.5;
fs = 4;
t = 0:1/fs:100-1/fs;%¸ÕºÃ²É1s
Signal1 = sin(2*pi*f1*t);
Signal2 = sin(2*pi*f2*t);
Signal3 = sin(2*pi*f3*t);
SumSignal = Signal1+ Signal2 +Signal3;
% figure(1);
% plot(t,SumSignal);

SumSignal_FFT = fft(SumSignal);
SumSignal_FFT = SumSignal_FFT/length(SumSignal_FFT);
SumSignal_FFT(2:end) = 2* SumSignal_FFT(2:end);

N = length(SumSignal);
frequence = (0:N/2-1)*fs/N;
% figure(2);
% plot(frequence,abs(SumSignal_FFT(1:length(frequence))));

%ÂË²¨
waveFilter_BP = load('waveFilter_BP.mat');
AfterLpfData = filter(waveFilter_BP.waveFilter_BP,1,SumSignal);
figure(3);
plot(t,AfterLpfData,'r');
hold on;
plot(t,SumSignal,'b');

AfterLpfData_fft = fft(AfterLpfData);
AfterLpfData_fft = AfterLpfData_fft/length(AfterLpfData_fft);
AfterLpfData_fft(2:end) = 2* AfterLpfData_fft(2:end);

figure(2);
plot(frequence,abs(SumSignal_FFT(1:length(frequence))),'b');
hold on;
plot(frequence,abs(AfterLpfData_fft(1:length(frequence))),'r');



