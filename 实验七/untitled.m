clc
clear
%% 1.读取本地 wav 文件
filePath='D:\Matlab\bin\Project\Principle of 
Communication\CF_VoicePCMEncode\m\Windows XP.wav';%需要根据 XSRP 软件安装位置
作出修改%wav 文件可选择 1000-6000,2000-9000，4000-6000 不同频率范围的文件
[y,Fs]=audioread(filePath);
y=y';
yCh1=y(1,:);%取一组声道数据
figure(1)
dt=1/Fs;
t=0:dt:(length(yCh1)-1)*dt;
plot(yCh1);
title('wav 音频信号波形');
%% 2.PCM 13 折线编码
%% 2.1 抽样
sampleVal=8000;%8k 抽样率
[sampleData,a13_moddata]=PCM_13Encode(yCh1,Fs,sampleVal);
figure(2)
dt1=1/sampleVal;
t1=0:dt1:(length(sampleData)-1)*dt1;
78
plot(sampleData);
title('wav 音频信号抽样后的波形');
a13_moddata1=awgn(a13_moddata,5);%对编码数据加 5dB 噪声
a13_moddata2=awgn(a13_moddata,20);%对编码数据加 20dB 噪声
a13_moddata_all = [a13_moddata;a13_moddata1;a13_moddata2];
for i = 2:3
 for j = 1:length(a13_moddata)%给添加噪声后的编码进行处理
 if a13_moddata_all(i,j) > -0.5 && a13_moddata_all(i,j) < 0.5
 a13_moddata_all(i,j) = 0;%-0.5~0.5 范围内为 0
 else
 a13_moddata_all(i,j) = 1;%其余为 1
 end
 end
end
figure(3)
subplot(311);
plot(a13_moddata_all(1,:));
axis([0 200 -0.1 1.1]);
title('编码后无噪声 bit 数据');
subplot(312);
plot(a13_moddata_all(2,:));
axis([0 200 -0.1 1.1]);
title('编码后 SNR=5dBbit 数据');
subplot(313);
plot(a13_moddata_all(3,:));
axis([0 200 -0.1 1.1]);
title('编码后 SNR=20dBbit 数据');
pathname=['D:\Matlab\bin\Project\Principle of 
Communication\CF_VoicePCMEncode\m\','\','a13_moddata_all.mat'];
save(pathname,'a13_moddata_all');
%% 3.PCM13 折线译码
y1=cell2mat(struct2cell(load('a13_moddata_all'))); 
[outData1] = PCM_13Decode(y1(1,:));
[outData2] = PCM_13Decode(y1(2,:));
[outData3] = PCM_13Decode(y1(3,:));
figure(4)
plot(t1,outData1);
title('无噪声译码还原后的数据');
audiowrite('new Windows XP1.wav',outData1,sampleVal);
figure(5)
plot(t1,outData2);
title('SNR 为 5dB 译码还原后的数据');
audiowrite('new Windows XP2.wav',outData2,sampleVal);
figure(6)
plot(t1,outData3);
title('SNR 为 20dB 译码还原后的数据');
audiowrite('new Windows XP3.wav',outData3,sampleVal);