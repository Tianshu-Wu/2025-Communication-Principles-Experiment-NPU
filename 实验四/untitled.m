%% 参数设置
clear; clc;
bit_length = 256;          % 比特长度
fc = 1228800;              % 载波频率 (Hz)
Fs = 10 * fc;              % 采样频率 (10倍载波频率)
Ts = 1/Fs;                 % 采样间隔
samples_per_bit = Fs / fc; % 每比特采样点数
t_bit = (0:bit_length*samples_per_bit-1)*Ts; % 时间向量

%% 1. 生成随机比特并进行PSK调制
bits = randi([0 1], 1, bit_length); % 随机比特序列

% BPSK调制: 0 -> -1, 1 -> 1
baseband = repelem(2*bits-1, samples_per_bit); 

% 生成载波 (初始相位0度)
carrier = cos(2*pi*fc*t_bit);
modulated = baseband .* carrier;

%% 2. 加入10dB噪声并解调（载波初始相位180度）
SNR_dB = 10; % 信噪比

% 添加高斯白噪声
signal_power = mean(modulated.^2);
noise_power = signal_power / (10^(SNR_dB/10));
noise = sqrt(noise_power) * randn(size(modulated));
noisy_signal = modulated + noise;

% 解调（使用180度相移载波）
demod_carrier = cos(2*pi*fc*t_bit + pi); % 180度相移
demodulated = noisy_signal .* demod_carrier;

% 低通滤波（移动平均滤波器）
filter_len = samples_per_bit;
h = ones(1, filter_len)/filter_len;
filtered = conv(demodulated, h, 'same');

% 抽样判决
sampled = filtered(round(samples_per_bit/2):samples_per_bit:end);
received_bits = sampled > 0;

% 计算误码数
errors = sum(bits ~= received_bits);
fprintf('在%d dB SNR下误码数: %d\n', SNR_dB, errors);

%% 3. 不同信噪比下误码统计
SNR_range = -5:20; % 信噪比范围(-5dB到20dB)
error_counts = zeros(size(SNR_range));

for i = 1:length(SNR_range)
    SNR_dB = SNR_range(i);
    
    % 添加噪声
    noise_power = signal_power / (10^(SNR_dB/10));
    noise = sqrt(noise_power) * randn(size(modulated));
    noisy_signal = modulated + noise;
    
    % 解调
    demodulated = noisy_signal .* demod_carrier;
    filtered = conv(demodulated, h, 'same');
    sampled = filtered(round(samples_per_bit/2):samples_per_bit:end);
    received_bits = sampled > 0;
    
    % 统计误码
    error_counts(i) = sum(bits ~= received_bits);
end

% 绘制误码率曲线
figure;
plot(SNR_range, error_counts, 'bo-', 'LineWidth', 1.5);
xlabel('信噪比 (dB)');
ylabel('误码数');
title('不同信噪比下的误码数');
grid on;

%% 4. 绘制-5dB和20dB波形图
plot_SNRs = [-5, 20]; % 需要绘制的信噪比
symbols_to_plot = 5;  % 绘制的符号数
samples_to_plot = samples_per_bit * symbols_to_plot;

for k = 1:length(plot_SNRs)
    SNR_dB = plot_SNRs(k);
    
    % 添加噪声
    noise_power = signal_power / (10^(SNR_dB/10));
    noise = sqrt(noise_power) * randn(size(modulated));
    noisy_signal = modulated + noise;
    
    % 解调
    demodulated = noisy_signal .* demod_carrier;
    filtered = conv(demodulated, h, 'same');
    
    % 创建新图形
    figure('Position', [100, 100, 1000, 800]);
    
    % 基带信号 (CH1)
    subplot(3,1,1);
    plot(t_bit(1:samples_to_plot)*1e6, baseband(1:samples_to_plot), 'b', 'LineWidth', 1.5);
    title(['基带信号 (CH1) - ' num2str(SNR_dB) ' dB']);
    xlabel('时间 (\mus)');
    ylabel('幅度');
    ylim([-1.5 1.5]);
    grid on;
    
    % 已调信号
    subplot(3,1,2);
    plot(t_bit(1:samples_to_plot)*1e6, modulated(1:samples_to_plot), 'r', 'LineWidth', 1);
    title(['已调信号 - ' num2str(SNR_dB) ' dB']);
    xlabel('时间 (\mus)');
    ylabel('幅度');
    grid on;
    
    % 解调信号 (CH2)
    subplot(3,1,3);
    plot(t_bit(1:samples_to_plot)*1e6, filtered(1:samples_to_plot), 'g', 'LineWidth', 1.5);
    hold on;
    plot(t_bit(1:samples_to_plot)*1e6, baseband(1:samples_to_plot), 'b--', 'LineWidth', 1);
    title(['解调信号 (CH2)与基带比较 - ' num2str(SNR_dB) ' dB']);
    xlabel('时间 (\mus)');
    ylabel('幅度');
    legend('解调信号', '原始基带');
    grid on;
    
    % 输出CH1和CH2数据用于示波器
    CH1 = baseband(1:samples_to_plot);
    CH2 = filtered(1:samples_to_plot);
    time_axis = t_bit(1:samples_to_plot);
    save(['oscilloscope_data_' num2str(SNR_dB) 'dB.mat'], 'time_axis', 'CH1', 'CH2');
end