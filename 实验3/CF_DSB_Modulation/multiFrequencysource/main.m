%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            main.m
%  Description:         DSB双边带调制
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  History
%    1. Date:           2019-10-10
%       Author:         Man at arms
%       Version:        1.1
%       Modification:   初稿
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
fs=30720000;% 采样率,硬件系统基准采样率30.72 MHz，fs可配30.72MHz, 3.72Mhz，307.2KHz , 30.72KHz，或其它(要求fs需被30720000整除).fs最大可配30.72MHz,fs最小可配30000Hz
runType=1;%运行方式，0表示仿真，1表示软硬结合

A = 5;      %调制信号幅度
F=10000;   %调制信号频率
F_L=8000;% 调制信号叠加频率 
Fc=50000;  %载波频率
N=30720    %采样点数
snr=10;     %信道输入信噪比/dB

%% 调制
[y1,y2,y3,y4,y5,y6,Si,Ni,So,No] = DSB_Encode(A,F,F_L,Fc,N,fs,snr);

%% 解调
[Y] =DSB_Decode(y5,y2,F,fs);

%% 调用DA输出函数
% if  runType==1
%     CH1_data=y1;
%     CH2_data=y3;
%     divFreq=floor(30720000/fs-1);%分频值,999分频系统采样率为30720Hz,  99分频系统采样率为307200Hz, 9分频系统采样率为 3072000Hz,  0分频系统采样率30720000Hz
%     dataNum=N;
%     isGain=1;%增益开关，0表示不对值放大，1表示对值放大
%     DA_OUT(CH1_data,CH2_data,divFreq,dataNum,isGain);%调用此函数之前，确保XSRP开启及线连接正常
% end

%% 画图
figure(1)
subplot(411);
dt=1/fs;
t=0:dt:(30720-1)*dt;
plot(t,y1);title('调制信号')
xlabel('时间(s)');ylabel('幅值(v)');
subplot(412);
plot(t,y2);title('载波');
xlabel('时间(s)');ylabel('幅值(v)');
subplot(413);
plot(t,y3);title('已调信号');
xlabel('时间(s)');ylabel('幅值(v)');
subplot(414);
plot(t,Y);title('解调信号');
xlabel('时间(s)');ylabel('幅值(v)');

figure(2)
subplot(411)
plot(t,y3);title('已调信号');
subplot(412)
plot(t,y4);title('加高斯白噪声信号');
subplot(413)
plot(t,y5);title('过乘法器后信号');
subplot(414)
plot(t,y6);title('带通滤波后信号');
