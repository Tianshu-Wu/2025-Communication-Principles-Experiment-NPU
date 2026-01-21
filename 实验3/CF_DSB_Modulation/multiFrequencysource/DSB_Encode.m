%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            DSB_Encode.m
%  Description:         双边带调制    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameter List:       
%       Output Parameter
%           y1  调制信号
%           y2  载波信号
%           y3  已调信号
%           y4 加高斯白噪声
%           y5 带通滤波后
%           y6 调制后信号 过乘法器后信号
%           Si 解调器输入端信号功率
%           Ni 解调器输入端噪声功率
%           So 解调器输出端信号功率
%           No 解调器输出端噪声功率 
%       Input Parameter
%           A   调制信号幅度
%           F   调制信号频率
%           Fc  载波频率
%           N   采样点数
%           fs  采样频率
%           snr=10信道输入信噪比/dB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  History
%    1. Date:           2018-05-30
%       Author:         tony.liu
%       Version:        1.1 
%       Modification:   初稿
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y1,y2,y3,y4,y5,y6,Si,Ni,So,No] = DSB_Encode(A,F,F_L,Fc,N,fs,snr)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%生成调制信号
dt=1/fs;
t=0:dt:(N-1)*dt;
y1=A*sin(2*pi*F*t)+A*sin(2*pi*F_L*t); 	%调制信号

y2=cos(2*pi*Fc*t);      %载波
y3=y2.*y1;              %乘载波

% P=10;       % 功率为10dBw。    p=10*log10（P/w）dbw;

%     y = wgn(1,N,p,'linear');   %产生一个1行fs列的高斯白噪声的矩阵，p以W为单位指定输出噪声的强度
%     y_average=mean(y);
%     n0=periodogram(y,[],'onesided',512,fs);         %  白噪声单边功率谱密度n0
%% 信道加噪
Psig = var(y3);
Pnoi = Psig*10^(-snr/10);
awgn_noise = sqrt(Pnoi)*randn(size(y3));
y=awgn_noise;
n0=periodogram(y,[],'onesided',512,fs);    %  白噪声单边功率谱密度n0
y4=y+y3;


%% 带通滤波器
% wsl=2*pi*(Fc-Fc)/fs;     %阻带上截止叫角频率
% wpl=2*pi*(Fc-Fc/2)/fs;      %通带上截止叫角频率
% wph=2*pi*(Fc+Fc/2)/fs;      %通带带下截止叫角频率
% wsh=2*pi*(Fc+Fc)/fs;      %阻带下截止叫角频率
% 
% % B=min((wpl-wsl),(wsh-wph));    %最小过渡带宽度
% B=min((wpl-wsl),(wsh-wph));
% N=ceil(11*pi/B);                 %滤波器阶数（根据布莱克曼窗计算的滤波器阶数）
% 
% %%计算滤波器系数
% wl=(wsl+wpl)/2/pi;
% wh=(wsh+wph)/2/pi;
% wc=[wl,wh];                 %设置理想带通截止频率    ;
% 
% b=fir1(N-1,wc,blackman(N));         %设置滤波器系数
% b_l2 = fix(length(b)/2);
% len= length(y4);
% x_bandpass1 = conv(y4,b);
% y5(1:len) = x_bandpass1(b_l2 : b_l2 + len -1);   %去除滤波器延时


[y5] =DSB_bandpass(y4,Fc,fs,F);

Si=mean(y3.^2);
Ni=mean(n0)*2*F;
in_SNR=Si/Ni

So=mean((y1/2).^2);
No=mean(n0/4)*2*F;
out_SNR=So/No

G=out_SNR/in_SNR

y6=y2.*y5;%与相干载波相乘



end

