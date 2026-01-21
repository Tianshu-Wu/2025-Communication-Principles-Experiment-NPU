%% 3.PCM13 折线译码 (优化版)
y1 = cell2mat(struct2cell(load('a13_moddata_all.mat'))); 

% 译码处理
[outData1] = PCM_13Decode(y1(1,:));
[outData2] = PCM_13Decode(y1(2,:));
[outData3] = PCM_13Decode(y1(3,:));

% === 新增噪声抑制处理 ===
% 设计低通滤波器 (6阶巴特沃斯，截止频率3400Hz)
[b, a] = butter(6, 3400/(sampleVal/2), 'low');

% 滤波处理 (仅处理含噪信号)
outData2_filtered = filtfilt(b, a, outData2);  % 零相位滤波
outData3_filtered = filtfilt(b, a, outData3);

% === 结果可视化 ===
figure(4)
subplot(311); plot(t1, outData1); title('无噪声译码信号');
subplot(312); plot(t1, outData2_filtered); title('5dB噪声抑制后');
subplot(313); plot(t1, outData3_filtered); title('20dB噪声抑制后');

% === 保存音频并播放 ===
% 无噪声
audiowrite('noiseless.wav', outData1, sampleVal);
% 抑噪处理后的含噪音频
audiowrite('noise5dB_suppressed.wav', outData2_filtered, sampleVal); 
audiowrite('noise20dB_suppressed.wav', outData3_filtered, sampleVal);

% 播放结果 (MATLAB执行)
disp('播放5dB噪声抑制效果:');
sound(outData2_filtered, sampleVal);
pause(length(outData2_filtered)/sampleVal + 1); % 等待播放完成

disp('播放20dB噪声抑制效果:');
sound(outData3_filtered, sampleVal);