# Speech Signal Processing in MATLAB  
### Noise Addition, Band-Pass Filtering, Compression, Normalization, Amplification, and Low-Pass Denoising

This project was developed for a **Digital Signal Processing (DSP)** university course. It demonstrates a complete speech signal processing pipeline using MATLAB, starting from a recorded voice sample and applying multiple DSP techniques to improve the signal quality.

The project takes a speech recording, adds artificial noise, analyzes the noisy signal in both time and frequency domains, and then processes it through a chain of stages including **band-pass filtering**, **dynamic range compression**, **normalization**, **amplification**, and a **final low-pass filter**. It also includes **downsampling** to demonstrate aliasing and **spectrogram analysis** to visualize time-frequency behavior.

---

## Project Objectives

- Load and analyze a recorded speech signal
- Add white noise and sinusoidal interference
- Observe the effect of noise in time and frequency domains
- Apply FIR filtering to isolate the speech band
- Compress the dynamic range of the signal
- Normalize and amplify the processed signal
- Apply final low-pass filtering for extra denoising
- Demonstrate aliasing through downsampling
- Compare spectrograms at each processing stage

---

## Processing Pipeline

The signal passes through the following stages:

1. **Original Speech Input**  
   Load the recorded audio file and convert it to mono.

2. **Noise Addition**  
   Add:
   - White Gaussian noise with **15 dB SNR**
   - A **5 kHz sinusoidal interference** to simulate hum/noise

3. **FFT Analysis**  
   Apply Fast Fourier Transform to inspect the noisy signal in the frequency domain.

4. **Band-Pass FIR Filter**  
   Keep only the main speech frequency range:
   - **300 Hz to 3400 Hz**
   - FIR filter with **Hamming window**
   - Filter order: **200**

5. **Dynamic Range Compression**  
   Reduce excessive peaks using:
   - Threshold: **0.3**
   - Compression ratio: **4:1**

6. **Normalization**  
   Scale the compressed signal to a target peak value:
   - Target peak: **0.9**

7. **Amplification**  
   Increase loudness safely:
   - Gain: **1.5**
   - Clipping protection included

8. **Final Low-Pass FIR Filter**  
   Further reduce high-frequency noise:
   - Cutoff frequency: **2000 Hz**
   - Filter order: **250**

9. **Downsampling**  
   Downsample the noisy signal by a factor of **4** to demonstrate aliasing.

10. **Spectrogram Analysis**  
    Visualize the signal at different stages using spectrograms.

---

## MATLAB Code Features

- Uses `audioread()` to load audio
- Converts stereo audio to mono
- Saves processed audio using `audiowrite()`
- Generates multiple plots and spectrograms
- Uses FIR filters designed with `fir1()` and `hamming()`
- Demonstrates both time-domain and frequency-domain DSP concepts

---

## Input File

Make sure your voice file is placed in the same folder as the MATLAB script.

Expected input file name:

```matlab
dsp voice.mp3