%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            AM_bandpass.m
%  Description:         带通滤波器
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameter List:       
%       Output Parameter
%           x_bp         输出信号
%       Input Parameter
%           x	         输入信号
%           Fc           载波频率
%           fs           采样率
%           Rb           信号频率
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 带通滤波器
function [x_bp] =AM_bandpass(x,Fc,fs,Rb)

wsl=2*pi*(Fc-1.5*Rb)/fs;    %阻带上截止角频率
wpl=2*pi*(Fc-1*Rb)/fs;  %通带上截止角频率
wph=2*pi*(Fc+1*Rb)/fs;  %通带带下截止角频率
wsh=2*pi*(Fc+1.5*Rb)/fs;    %阻带下截止角频率

B=min((wpl-wsl),(wsh-wph));  %最小过渡带宽度
N=ceil(11*pi/B);             %滤波器阶数（根据布莱克曼窗计算的滤波器阶数）

%% 计算滤波器系数
wl=(wsl+wpl)/2/pi;
wh=(wsh+wph)/2/pi;
wc=[wl,wh];     %设置理想带通截止频率
b=fir1(N-1,wc,blackman(N));         %设置滤波器系数

freq=fft(b);%对carrier做N点FFT，结果为N点的复值，每一个点对应一个频率点
N=length(b);

freqPixel=fs/N;%频率分辨率，即点与点之间频率单位
%w=-N/2:1:N/2-1;  %频率分辨率为1，即fs=N
w=(-N/2:1:N/2-1)*freqPixel;

b_l2 = fix(length(b)/2);
len= length(x);
x_bandpass1 = conv(x,b);%卷积
x_bp(1:len) = x_bandpass1(b_l2 : b_l2 + len -1);%去除滤波器延时
end
