%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            DSB_bandpass.m
%  Description:         低通滤波器
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameter List:       
%       Output Parameter
%           x_lowpass   输出信号
%       Input Parameter
%           x      输入信号
%           fs     采样频率
%           f      信号频率
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ x_lowpass ] =DSB_lowpass( x,fs,f)

    ws=1*f;                    %通带截止频率
    ws1=2.5*f;                  %阻带起始频率
    wt=2*pi*ws/fs;                  %通带截止角频率
    wz=2*pi*ws1/fs;                 %阻带的起始角频率
    wc=(wt+wz)/2;                   %归一化后的滤波器截止频率
    B=wz-wt;                    %过渡带宽度
    N=ceil(6.6*pi/B);          %滤波器阶数
    b=fir1(N-1,wc/pi,hanning(N));   %滤波器时域函数,滤波系数,该函数采用hanning窗实现低通滤波   
 
    b_l2 = fix(length(b)/2);
    len= length(x);
    x_lowpass1 = conv(x,b);
    x_lowpass(1:len) = x_lowpass1(b_l2 : b_l2 + len -1);%去除滤波器延时


end
