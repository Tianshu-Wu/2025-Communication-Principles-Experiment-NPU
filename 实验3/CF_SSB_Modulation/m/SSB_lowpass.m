%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            SSB_bandpass.m
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
function [ x_lowpass,noisy ] =SSB_lowpass( x,fs,F)

  
    ws=F;                    %通带截止频率
    ws1=1.5*F;                  %阻带起始频率
    wt=2*pi*ws/fs;                  %经采样后的通带截止角频率
    wz=2*pi*ws1/fs;                 %阻带的起始频率
    wc=(wt+wz)/2;                   %归一化后的滤波器截止频率
    N=ceil(6.6*pi/(wz-wt));         %t=(n-1)/2;
    b=fir1(N-1,wc/pi,hanning(N));   %滤波器时域函数,滤波系数   
 

    b_l2 = fix(length(b)/2);
    len= length(x);
    x_lowpass1 = conv(x,b);
    x_lowpass(1:len) = x_lowpass1(b_l2 : b_l2 + len -1);


end
