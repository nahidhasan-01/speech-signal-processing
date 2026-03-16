%% =========================================================================
% Course: Digital Signal Processing (DSP)
% Project: Speech Signal – Noise, Bandpass Filter, Compression, Normalizing, Amplifying
% Group size: 4 (each member owns one block)
% Date: 13/11/2025
%% =========================================================================

clc; clear; close all;

%% 1. Load Voice Recording (.m4a / .mp3)
[audio, fs] = audioread('dsp voice.mp3');   % <--- your file name
audio = audio(:,1);                         % make mono
t = (0:length(audio)-1)/fs;

disp('Playing original audio...');
sound(audio, fs);
audiowrite('audio_original.wav', audio, fs);

figure;
plot(t, audio, 'LineWidth', 1.2); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Original Voice Recording');
saveas(gcf, 'plot_original_signal.png');

%% 2. Add Noise (white + sinusoidal interference)
SNR_dB = 15;                                % 10–20 dB => clearly noisy

% ---- manual AWGN (no Communications Toolbox needed) ----
signal_power = mean(audio.^2);
SNR_linear   = 10^(SNR_dB/10);
noise_power  = signal_power / SNR_linear;
noise        = sqrt(noise_power) * randn(size(audio));
audio_noisy  = audio + noise;
% --------------------------------------------------------

f_hum   = 5000;                             % high-freq tone
amp_hum = 0.05 * max(abs(audio));
sin_noise = amp_hum * sin(2*pi*f_hum*t).';
audio_noisy_hum = audio_noisy + sin_noise;

disp('Playing noisy audio...');
sound(audio_noisy_hum, fs);
audiowrite('audio_noisy.wav', audio_noisy_hum, fs);

figure;
subplot(2,1,1); plot(t, audio); grid on; title('Original Audio');
subplot(2,1,2); plot(t, audio_noisy_hum); grid on; title('Noisy Audio');
saveas(gcf, 'plot_noisy_signal.png');

%% 3. FFT of Noisy Signal
N = length(audio_noisy_hum);
f = (0:N-1)*(fs/N);
X_noisy = fft(audio_noisy_hum);

figure;
plot(f, abs(X_noisy), 'LineWidth', 1.2); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title('FFT of Noisy Voice');
xlim([0 fs/2]);
saveas(gcf, 'plot_fft_noisy.png');

%% ======================== 4. PROCESSING CHAIN ============================
% Stage 1: Band-pass FIR filter (Member 1)
% Stage 2: Compressor          (Member 2)
% Stage 3: Normalizer          (Member 3)
% Stage 4: Amplifier           (Member 4)
% Stage 5: Final Low-pass      (extra denoising)

%% 4.1 Band-pass FIR Filter  (voice band ~300–3400 Hz)
f_low = 300;                       % lower cutoff
f_high = 3400;                     % upper cutoff
order_bp = 200;                    % higher order => sharper
b_bp = fir1(order_bp, [f_low f_high]/(fs/2), ...
            'bandpass', hamming(order_bp+1));

audio_bp = filter(b_bp, 1, audio_noisy_hum);
audiowrite('audio_bandpass.wav', audio_bp, fs);

figure;
subplot(2,1,1); plot(t, audio_noisy_hum); grid on;
title('Noisy Audio');
subplot(2,1,2); plot(t, audio_bp); grid on;
title('After Band-pass Filter (300–3400 Hz)');
saveas(gcf, 'plot_bandpass_signal.png');

%% 4.2 Dynamic Range Compressor (simple soft limiter)
thresh = 0.3;          % 0–1
ratio  = 4;            % compression ratio

x_in = audio_bp;       % compress band-passed signal
mag  = abs(x_in);
sgn  = sign(x_in);
y_comp = x_in;

idx = mag > thresh;
y_comp(idx) = sgn(idx) .* (thresh + (mag(idx)-thresh)/ratio);

audio_comp = y_comp;
audiowrite('audio_compressed.wav', audio_comp, fs);

figure;
subplot(2,1,1); plot(t, audio_bp); grid on;
title('Before Compression (Band-passed)');
subplot(2,1,2); plot(t, audio_comp); grid on;
title('After Compression');
saveas(gcf, 'plot_compressed_signal.png');

%% 4.3 Normalizer (set max amplitude to target_peak)
target_peak = 0.9;
audio_norm = audio_comp / max(abs(audio_comp)) * target_peak;
audiowrite('audio_normalized.wav', audio_norm, fs);

figure;
subplot(2,1,1); plot(t, audio_comp); grid on;
title('Before Normalization (Compressed)');
subplot(2,1,2); plot(t, audio_norm); grid on;
title('After Normalization');
saveas(gcf, 'plot_normalized_signal.png');

%% 4.4 Amplifier (extra loudness with clipping protection)
gain = 1.5;                              % try 1.5 or 2.0
audio_amp = audio_norm * gain;
audio_amp = audio_amp / max(abs(audio_amp));   % avoid clipping
audiowrite('audio_amplified.wav', audio_amp, fs);

figure;
subplot(3,1,1); plot(t, audio_norm); grid on;
title('Normalized');
subplot(3,1,2); plot(t, audio_amp); grid on;
title('After Amplifier (+gain)');
subplot(3,1,3); plot(t, audio_noisy_hum); grid on;
title('Reference: Noisy Audio');
saveas(gcf, 'plot_amplified_signal.png');

%% 4.5 Final Low-Pass Filter (extra noise reduction at the end)
fc_lp = 2000;                     % low-pass cutoff (Hz) slightly below Nyquist for speech
order_lp = 250;
b_lp = fir1(order_lp, fc_lp/(fs/2), 'low', hamming(order_lp+1));

audio_lp_final = filter(b_lp, 1, audio_amp);
audiowrite('audio_lowpass_final.wav', audio_lp_final, fs);

figure;
subplot(2,1,1); plot(t, audio_amp); grid on;
title('Before Final Low-Pass (Amplified Signal)');
subplot(2,1,2); plot(t, audio_lp_final); grid on;
title('After Final Low-Pass Filter');
saveas(gcf, 'plot_lowpass_final_signal.png');

%% ======================== 5. DOWNSAMPLING (Aliasing) =====================
down_factor = 4;
audio_down = downsample(audio_noisy_hum, down_factor);
fs_down = fs / down_factor;
audiowrite('audio_downsampled.wav', audio_down, fs_down);

%% ======================= 6. SPECTROGRAM ANALYSIS ========================
figure;
spectrogram(audio, 256, 250, 256, fs, 'yaxis');
title('Spectrogram: Original Audio'); colorbar;
saveas(gcf, 'plot_spectrogram_original.png');

figure;
spectrogram(audio_noisy_hum, 256, 250, 256, fs, 'yaxis');
title('Spectrogram: Noisy Audio'); colorbar;
saveas(gcf, 'plot_spectrogram_noisy.png');

figure;
spectrogram(audio_bp, 256, 250, 256, fs, 'yaxis');
title('Spectrogram: Band-pass Filtered'); colorbar;
saveas(gcf, 'plot_spectrogram_bandpass.png');

figure;
spectrogram(audio_comp, 256, 250, 256, fs, 'yaxis');
title('Spectrogram: Compressed'); colorbar;
saveas(gcf, 'plot_spectrogram_compressed.png');

figure;
spectrogram(audio_norm, 256, 250, 256, fs, 'yaxis');
title('Spectrogram: Normalized'); colorbar;
saveas(gcf, 'plot_spectrogram_normalized.png');

figure;
spectrogram(audio_amp, 256, 250, 256, fs, 'yaxis');
title('Spectrogram: Amplified'); colorbar;
saveas(gcf, 'plot_spectrogram_amplified.png');

figure;
spectrogram(audio_lp_final, 256, 250, 256, fs, 'yaxis');
title('Spectrogram: Final Low-Pass Filtered'); colorbar;
saveas(gcf, 'plot_spectrogram_lowpass_final.png');