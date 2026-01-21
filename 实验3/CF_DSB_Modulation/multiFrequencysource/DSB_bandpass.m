
function [x_bp] =DSB_bandpass(x,Fc,fs,F)

wsl=2*pi*(Fc-2*F)/fs;    %阻带上截止角频率
wpl=2*pi*(Fc-1*F)/fs;  %通带上截止角频率
wph=2*pi*(Fc+1*F)/fs;  %通带带下截止角频率
wsh=2*pi*(Fc+2*F)/fs;    %阻带下截止角频率

B=min((wpl-wsl),(wsh-wph));  %最小过渡带宽度
N=ceil(11*pi/B);             %滤波器阶数（根据布莱克曼窗计算的滤波器阶数）

%% 计算滤波器系数
wl=(wsl+wpl)/2/pi;
wh=(wsh+wph)/2/pi;
wc=[wl,wh];     %设置理想带通截止频率
b=fir1(N-1,wc,blackman(N));         %设置滤波器系数

b_l2 = fix(length(b)/2);
len= length(x);
x_bandpass1 = conv(x,b);
x_bp(1:len) = x_bandpass1(b_l2 : b_l2 + len -1);%去除滤波器延时
end
