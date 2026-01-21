%%%----------------------------Student Program2---------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%较难%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % LabName:             SSB调制解调实验              
% % Task:                1.计算SSB（上边带）调制解调制度增益G
% % Programming tips:   1.制度增益G=输出端信噪比/输入端信噪比
% %                     2.输出信噪比
% %                       =解调器输出有用信号平均功率/解调器输出噪声平均功率
% %                        解调器输出噪声=解调信号-低通滤波器后输出信号
% %                     3.输入信噪比
% %                       =解调器输入已调信号平均功率/解调器输入噪声平均功率                                                          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
close all
PC_IP = '192.168.1.180';
XSRP_IP = '192.168.1.166';
fs=30720000;% 采样率,硬件系统基准采样率30.72 MHz，fs可配30.72MHz, 3.72Mhz，307.2KHz , 30.72KHz，或其它(要求fs需被30720000整除).fs最大可配30.72MHz,fs最小可配30000Hz
runType=1;%运行方式，0表示仿真，1表示软硬结合

A = 1;      %调制信号幅度
F=10000;       %调制信号频率
Fc=100000;     %载波频率
N=30720  ;  %采样点数
%snr=-10;     %信道输出端信噪比/dB 
%% 1.调制
dt=1/fs;
t=0:dt:(N-1)*dt;
y1=A*sin(2*pi*F*t);	%调制信号

y2=cos(2*pi*Fc*t);      %载波

y3_0 = (1/2)*y1.*y2 +(1/2)*imag(hilbert(y1)).*sin(2*pi*Fc*t);%（下边带）已调信号


xx = 1;
snr_start = -5;
gap = 0.1;
snr_end = 20;
snr_number = (snr_end-snr_start)/gap+1;
G = zeros(1,snr_number);
G_theory = zeros(1,snr_number);
for snr = snr_start:gap:snr_end
%% 2.信道加噪

y4=awgn(y3_0,snr);
n0=periodogram(y4-y3_0,[],'onesided',512,fs)   ;      %  白噪声单边功率谱密度n0
P = fs/512 * (sum(n0) - 0.5*(n0(1) + n0(end)));% 积分获得噪声功率
%% 3.带通滤波器

[y5] =SSB_bandpass(y4,Fc,fs,F);
[y33] =SSB_bandpass(y3_0,Fc,fs,F);
%% 4.解调
x3=y5.*y2;		%乘载波
y3 = y33.*y2;
Y=SSB_lowpass(x3,fs,F);%低通滤波
Y_t = SSB_lowpass(y3,fs,F);
Err = Y-Y_t;
powerY = bandpower(Y);
% % powerN = bandpower(y4-y3);
% % snri = 10^(snr/10);
% % snro = 10*log10(powerY/powerN);
% PY = bandpower(Y);
% powerY = sum(abs(Y).^2)/N;
powerN = bandpower(Err);
snri = 10^(snr/10);
snro = 10*log10(powerY/powerN);
G(xx) = snro/snri;
G_theory(xx)= 1;
xx = xx+1;
end
snr = snr_start:gap:snr_end;
plot(snr,G,'-r',snr,G_theory,'-b');
title('SSB理论调制制度增益G和仿真调制制度增益G对比')
xlabel('输入信号信噪比SNR(dB)')
ylabel('调制制度增益G')
legend('仿真值','理论值');
% figure
% plot(t,Y_t);
% figure
% plot(t,Y);
%% 5.输出波形
%%软件仿真波形
% figure(1)
% dt=1/fs;
% t=0:dt:(N-1)*dt;
% subplot(411);
% plot(t,y1);title('调制信号')
% xlabel('时间(s)');ylabel('幅值(v)');
% subplot(412);
% plot(t,y2);title('载波');
% xlabel('时间(s)');ylabel('幅值(v)');
% subplot(413);
% plot(t,y3_0);title('SSB下边带已调信号');
% freq=fft(y3_0);%对carrier做N点FFT，结果为N点的复值，每一个点对应一个频率点
% freqPixel=fs/N;%频率分辨率，即点与点之间频率单位
% w=(-N/2:1:N/2-1)*freqPixel;%频率
% m_FFT_0=abs(fftshift(freq))./max(abs(fftshift(freq)));% 频谱幅值归一化
% shape_sig_freq_0=w+m_FFT_0*j;%复数
% subplot(414);
% plot(shape_sig_freq_0);title('SSB下边带已调信号频谱');
% 
% figure(2)
% subplot(411)
% plot(t,y4);title('加噪声后信号');
% xlabel('时间(s)');ylabel('幅值(v)');
% subplot(412)
% plot(t,y5);title('带通滤波后信号');
% xlabel('时间(s)');ylabel('幅值(v)');
% subplot(413);
% plot(t,y2);title('载波');
% xlabel('时间(s)');ylabel('幅值(v)');
% subplot(414);
% plot(t,Y);title('解调信号');
% xlabel('时间(s)');ylabel('幅值(v)');

%%%----------------------------Student Program2 End-----------------------%%