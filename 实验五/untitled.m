% 16QAM调制解调误码率仿真与理论比较

clear all;
close all;
clc;

% 参数设置
M = 16;                     % 调制阶数 (16QAM)
k = log2(M);                % 每个符号的比特数
numBits = 1e6;              % 总比特数(建议至少1e6以获得可靠结果)
snr_dB = 0:2:20;            % 信噪比范围(dB)
numSnr = length(snr_dB);    % SNR点数

% 生成随机比特流
dataBits = randi([0 1], numBits, 1);

% 将比特流分组为k比特的符号
dataInMatrix = reshape(dataBits, length(dataBits)/k, k);

% 将二进制转换为十进制(用于调制)
dataSymbolsIn = bi2de(dataInMatrix);

% 16QAM调制
modulatedSignal = qammod(dataSymbolsIn, M, 'UnitAveragePower', true);

% 预分配存储空间
berSimulated = zeros(1, numSnr);
berTheoretical = zeros(1, numSnr);

% 循环不同SNR值
for i = 1:numSnr
    % 添加AWGN噪声
    snr = snr_dB(i);
    noisySignal = awgn(modulatedSignal, snr, 'measured');
    
    % 16QAM解调
    dataSymbolsOut = qamdemod(noisySignal, M, 'UnitAveragePower', true);
    
    % 将解调后的符号转换回比特
    dataOutMatrix = de2bi(dataSymbolsOut, k);
    dataBitsOut = reshape(dataOutMatrix, numBits, 1);
    
    % 计算误码率
    [numErrors, berSimulated(i)] = biterr(dataBits, dataBitsOut);
    
    % 计算理论误码率
    berTheoretical(i) = berawgn(snr, 'qam', M);
end

% 绘制结果
figure;
semilogy(snr_dB, berSimulated, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
semilogy(snr_dB, berTheoretical, 'r*-', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('16QAM调制系统误码率性能');
legend('仿真误码率', '理论误码率', 'Location', 'southwest');

% 设置坐标轴范围
axis([min(snr_dB) max(snr_dB) 1e-6 1]);

% 显示网格
set(gca, 'YScale', 'log');
set(gca, 'GridLineStyle', ':');
set(gca, 'XMinorGrid', 'on');
set(gca, 'YMinorGrid', 'on');