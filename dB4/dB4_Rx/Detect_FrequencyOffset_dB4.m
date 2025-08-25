function [FreqOffset_Course, FreqOffset_Fine] = Detect_FrequencyOffset_dB4(DetFlag, Signal_Dec)

% 1. Determine Course Frequency Offset - FFT Filtering is used
%--------------------------------------------------------------------------

% 1a. Get the start position of the packet
StartOfPacket = find(DetFlag, 1, 'first');
x_n = Signal_Dec(1, StartOfPacket:StartOfPacket+4095);

% 1b. fft filter out tones not around 129 and 385
NumSections         = 1;
SectionLength       = 4096;
H_m                 = zeros(1, SectionLength);
H_m(1, 1:450)        = ones(1, 450); %Passband for pos freqs
H_m(1, end-448:end)  = ones(1, 449); %Passband for neg freqs

HannLength     = 512;
HanningWindow  = hann(HannLength)';
FrontMask      = HanningWindow(1, 1:HannLength/2);
BackMask       = HanningWindow(1, (1+HannLength/2):HannLength);
TotalMask      = [FrontMask, ones(1, SectionLength-HannLength), BackMask];
y2_n           = zeros(1, length(x_n));

for SectionIndex = 0:(NumSections-1)
  Range          = (1:SectionLength) + SectionIndex*(SectionLength - HannLength/2);
  Section        = x_n(1, Range) .* TotalMask;
  DFT_Section    = fft(Section);
  Y_m            = DFT_Section .* H_m;
  OutputSection  = ifft(Y_m);
  y2_n(1, Range) = y2_n(1, Range) + OutputSection;
end

%  1c. Use the first spectral peak at 129 (480kHz) to determine course offset
Y_m               = abs(Y_m);
[~, maxIndx]      = max(Y_m(1, 1:179)); % shouldn't have to go near 179
FreqOffset_Course = (maxIndx - 130) * 15.36e6/4096;

%figure(3);
%plot(1:length(y2_n), real(y2_n)); hold on; plot(1:length(y2_n), imag(y2_n));
%title('PreambleA after FFT filter and then IFFT');

%figure(4);
%stem(real(Y_m)); hold on; stem(imag(Y_m));
%title('PreambleA FFT -> Index 129 used for course freq Offset Determination');

% 2. Determine Fine Frequency Offset - Autocorrelation is used
%--------------------------------------------------------------------------

% 2a. Correct the Filtered PreambleA with course correction
n = 1:length(y2_n);
NCO_Signal = exp(-1i*2*pi*n*FreqOffset_Course/15.36e6);
y3_n = y2_n .* NCO_Signal;    

AutoCorr_Est   = zeros(1, length(y3_n));
Delay32        = zeros(1, 32);  
SlidingAverage = zeros(1, 64);

for i = 1:length(y3_n)
  x_n_Input_32     = Delay32(1, 32);
  Delay32(1, 2:32) = Delay32(1, 1:31);
  Delay32(1, 1)    = y3_n(1, i);

  Temp = y3_n(1, i)*conj(x_n_Input_32);
  SlidingAverage(1, 2:64) = SlidingAverage(1, 1:63);
  SlidingAverage(1, 1) = Temp;
  AutoCorr_Est(1, i) = sum(SlidingAverage)/64;
end

Theta = angle(AutoCorr_Est(550:3500));
FO = Theta*15.36e6/(2*pi*32);

FreqOffset_Fine = mean(FO);

%figure(15);
%plot(1:length(AutoCorr_Est)-1, AutoCorr_Est(1, 1:end-1));
%title('AutoCorr Estimate');

%figure(16);
%plot(1:length(Theta)-1, Theta(1, 1:end-1));
%title('Theta from AutoCorr Estimate');

%figure(17);
%plot(1:length(FO)-1, FO(1, 1:end-1));
%title('Frequency Offset');

end



