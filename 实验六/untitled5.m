clc;
clear;
close all;

%% 参数设置
bitNum = 100;                % 比特数
bitRate = 1e6;               % 比特率(1Mbps)
sampleRate = 20e6;           % 采样率(提高采样率以获得更好的眼图)
samplesPerBit = sampleRate/bitRate;  % 每比特采样点数
filtCutoff = 2e6;            % 窄带滤波器截止频率(2MHz)
pulseShapeType = 'rectangular'; % 脉冲成形类型: 'rectangular'或'raised-cosine'

%% 1. 生成100bit随机数据源
rng(42); % 固定随机种子以确保结果可重现
dataBits = randi([0 1], 1, bitNum);
fprintf('原始数据: ');
disp(dataBits(1:min(10, bitNum))); % 只显示前10bit

%% 2. CMI编码
cmiEncoded = [];
for i = 1:bitNum
    if dataBits(i) == 1
        cmiEncoded = [cmiEncoded, [1 0]]; % "1"编码为"10"
    else
        % "0"交替编码为"00"或"11"
        if mod(length(cmiEncoded), 4) == 0
            cmiEncoded = [cmiEncoded, [1 1]];
        else
            cmiEncoded = [cmiEncoded, [0 0]];
        end
    end
end

%% 3. 脉冲成形
% 创建脉冲成形滤波器
if strcmpi(pulseShapeType, 'raised-cosine')
    % 升余弦滤波器
    rolloff = 0.5; % 滚降系数
    span = 6; % 滤波器跨度(符号数)
    shapeFilter = rcosdesign(rolloff, span, samplesPerBit/2, 'normal');
else
    % 矩形脉冲
    shapeFilter = ones(1, samplesPerBit/2);
end

% 应用脉冲成形
cmiWaveform = upfirdn(cmiEncoded, shapeFilter, samplesPerBit/2, 1);
t = (0:length(cmiWaveform)-1)/sampleRate;

%% 4. 全波整流
rectified = abs(cmiWaveform);

%% 5. 窄带滤波
% 设计窄带滤波器(低通)
[b, a] = butter(6, filtCutoff/(sampleRate/2), 'low');
filtered = filtfilt(b, a, rectified);

%% 6. 提取峰值位置
% 寻找局部最大值
[peaks, locs] = findpeaks(filtered, 'MinPeakHeight', max(filtered)*0.3, 'MinPeakDistance', samplesPerBit*0.8);

% 计算峰值对应的bit位置
bitPositions = ceil(locs/(samplesPerBit));

%% 7. 绘制眼图
figure('Name', '眼图分析', 'Position', [100, 100, 800, 600]);

% 眼图参数
symbolPeriod = samplesPerBit/2; % CMI编码后每个符号的采样点数
eyeDuration = 2; % 眼图显示2个符号周期
offset = 5; % 跳过开始的瞬态部分

% 准备眼图数据
eyeData = cmiWaveform(offset*symbolPeriod+1:end);
numGroups = floor(length(eyeData)/(eyeDuration*symbolPeriod));
eyeMatrix = reshape(eyeData(1:numGroups*eyeDuration*symbolPeriod),...
                   eyeDuration*symbolPeriod, numGroups);

% 时间轴(归一化到符号周期)
timeAxis = linspace(0, eyeDuration, eyeDuration*symbolPeriod);

% 绘制眼图
subplot(2,1,1);
plot(timeAxis, eyeMatrix, 'b');
title('脉冲成形后信号的眼图');
xlabel('时间(符号周期)');
ylabel('幅度');
grid on;
hold on;

% 添加参考线
plot([0.5, 0.5], ylim, 'r--', 'LineWidth', 1.5);
plot([1.0, 1.0], ylim, 'r--', 'LineWidth', 1.5);
plot([1.5, 1.5], ylim, 'r--', 'LineWidth', 1.5);
plot(xlim, [0, 0], 'k--', 'LineWidth', 1.0);

% 计算并绘制眼开度
eyeOpening = min(max(eyeMatrix(round(0.45*symbolPeriod):round(0.55*symbolPeriod), :), [], 2));
eyeLevel = mean(eyeOpening);
text(0.5, eyeLevel*1.1, sprintf('眼开度: %.2f', eyeLevel), 'FontSize', 10);

%% 结果显示
subplot(2,1,2);
plot(t, filtered);
hold on;
plot(locs/sampleRate, peaks, 'ro');
title('窄带滤波后信号与峰值位置');
xlabel('时间(s)');
ylabel('幅度');
xlim([0 t(end)]);
grid on;

% 原始信号显示
figure('Name', '信号处理流程', 'Position', [100, 100, 1000, 800]);
subplot(4,1,1);
stem(dataBits, 'filled');
title('原始数据比特');
xlim([0 bitNum+1]);
grid on;

subplot(4,1,2);
plot(t, cmiWaveform);
title('CMI编码及脉冲成形波形');
xlabel('时间(s)');
ylabel('幅度');
xlim([0 t(end)]);
grid on;

subplot(4,1,3);
plot(t, rectified);
title('全波整流后信号');
xlabel('时间(s)');
ylabel('幅度');
xlim([0 t(end)]);
grid on;

subplot(4,1,4);
plot(t, filtered);
hold on;
plot(locs/sampleRate, peaks, 'ro');
title('窄带滤波后信号与峰值位置');
xlabel('时间(s)');
ylabel('幅度');
xlim([0 t(end)]);
grid on;

fprintf('检测到的峰值位置对应的比特间隔: ');
disp(unique(bitPositions));