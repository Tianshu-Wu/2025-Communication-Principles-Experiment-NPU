%%---------------------------Student Program-----------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % LabName:             DSB调制解调实验
% % Task:                根据例程，计算制度增益G
% % Programming tips:   1.制度增益G=输出端信噪比/输入端信噪比
% %                     2.输出信噪比
% %                       =解调器输出有用信号平均功率/解调器输出噪声平均功率
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

A = 5;      %调制信号幅度
F=10000;   %调制信号频率
Fc=50000;  %载波频率
N=30720;    %采样点数
%snr=5;     %信道输入信噪比/dB
%% 1.调制
%%生成调制信号
dt=1/fs;
t=0:dt:(N-1)*dt;
y1=A*sin(2*pi*F*t); 	%调制信号
y2=cos(2*pi*Fc*t);      %载波
y3=y2.*y1;              %乘载波

xx = 1;
snr_start = -5;
gap = 0.1;
snr_end = 10;
snr_number = (snr_end-snr_start)/gap+1;
G = zeros(1,snr_number);
G_theory = zeros(1,snr_number);
%% 2.信道加噪
for snr = snr_start:gap:snr_end
    
y4=awgn(y3,snr);%加噪声后信号
n0=periodogram(y4-y3,[],'onesided',512,fs);      %  白噪声单边功率谱密度n0
P = fs/512 * (sum(n0) - 0.5*(n0(1) + n0(end)));% 积分获得噪声功率
%% 3.过带通滤波器
[y5] =DSB_bandpass(y4,Fc,fs,F);

%% 4.解调
[Y] =DSB_Decode(y5,y2,F,fs);
Y_t = DSB_Decode(y3,y2,F,fs);
Err = Y_t-Y;
% powerY = bandpower(Y);
% powerN = bandpower(y4-y3);
% snri = 10^(snr/10);
% snro = 10*log10(powerY/powerN);
PY = bandpower(Y);%求功率
powerY = sum(abs(Y).^2)/N;%求功率
powerN = sum(abs(Err).^2)/N;%求功率
snri = 10^(snr/10);
snro = 10*log10(powerY/P);
G(xx) = snro/snri;
G_theory(xx) = 2;
xx = xx+1;
end
snr = snr_start:gap:snr_end;
plot(snr,G,'-r',snr,G_theory,'-b');
title('DSB理论调制制度增益G和仿真调制制度增益G对比')
xlabel('输入信号信噪比SNR(dB)')
ylabel('调制制度增益G')
legend('仿真值','理论值');
%% 5.输出波形
%软件仿真波形
% figure(1)
% subplot(311);
% dt=1/fs;
% t=0:dt:(30720-1)*dt;
% plot(t,y1);title('调制信号')
% xlabel('时间(s)');ylabel('幅值(v)');
% subplot(312);
% plot(t,y2);title('载波');
% xlabel('时间(s)');ylabel('幅值(v)');
% subplot(313);
% plot(t,y3);title('已调信号');
% xlabel('时间(s)');ylabel('幅值(v)');
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

%%---------------------------Student Program End-------------------------%%

