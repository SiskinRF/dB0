function PacketDetFlag = Packet_Detector_dB4(RX_Input)

persistent Detection_Flag;

%--------------------------------------------------------------------------
% 1. Low Pass Filter the preamble improves detection

% Fpass = 1.5 MHz, Fstop = 3.0MHz, Apass = 1dB, Astop = 60dB
h = [0.0013,   0.0006,   0.0000,  -0.0015,  -0.0041,  -0.0078, ...
    -0.0123,  -0.0169,  -0.0208,  -0.0226,  -0.0212,  -0.0155, ...
    -0.0049,   0.0106,   0.0304,   0.0529,   0.0762,   0.0978, ...
     0.1153,   0.1268,   0.1308,   0.1268,   0.1153,   0.0978, ...
     0.0762,   0.0529,   0.0304,   0.0106,  -0.0049,  -0.0155, ...
    -0.0212,  -0.0226,  -0.0208,  -0.0169,  -0.0123,  -0.0078, ...
    -0.0041,  -0.0015,   0.0000,   0.0006,   0.0013];

%figure(10);
%plot(1:1000, real(RX_Input(1:1000))); hold on; plot(1:1000, imag(RX_Input(1:1000)));
%title('Packet Detect - Prior to LP Filtering');
 
RX_Input = filter(h, 1, RX_Input);

%figure(11);
%plot(1:1000, real(RX_Input(1:1000))); hold on; plot(1:1000, imag(RX_Input(1:1000)));
%title('Packet Detect - After LP Filtering');


%--------------------------------------------------------------------------
% 2. Search for packet

SA_Len = 256; % Sliding Average Length

AutoCorrEst       = zeros(1, length(RX_Input));
Comparison_Ratio  = zeros(1, length(RX_Input));
PacketDetFlag     = zeros(1, length(RX_Input));
Delay32           = zeros(1, 32);
SlidingAverage1   = zeros(1, SA_Len); % For the autocorr estimate
SlidingAverage2   = zeros(1, SA_Len); % For the variance estimate
Detection_Flag    = 0;

for i = 1:length(RX_Input)
  RX_Input_32      = Delay32(1,32);
  Delay32(1,2:32)  = Delay32(1,1:31);
  Delay32(1,1)     = RX_Input(1,i);

  % Compute absolute value of autocorrelation estimate
  Temp                        = RX_Input(1,i) * conj(RX_Input_32);
  SlidingAverage1(1,2:SA_Len) = SlidingAverage1(1,1:(SA_Len-1));
  SlidingAverage1(1,1)        = Temp;
  AutoCorrEst(1,i)            = sum(SlidingAverage1)/SA_Len;
  AbsAutoCorr_Est             = abs(AutoCorrEst(1,i));

  % Compute variance estimate
  InstPower                    = RX_Input(1,i) * conj(RX_Input(1,i));
  SlidingAverage2(1,2:SA_Len)  = SlidingAverage2(1,1:(SA_Len-1));
  SlidingAverage2(1,1)         = InstPower;
  Variance_Est                 = sum(SlidingAverage2/SA_Len);

  Comparison_Ratio(1,i) = AbsAutoCorr_Est/Variance_Est;

  % Packet Detection flag with hysteresis window
  if (Comparison_Ratio(1,i) > 0.80)
    Detection_Flag = 1;
  elseif (Comparison_Ratio(1,i) < 0.65)
    Detection_Flag = 0;
  end
  PacketDetFlag(1,i) = Detection_Flag;

%figure(12);
%plot(1:length(Comparison_Ratio), Comparison_Ratio);
%title('Packet Detector - Comparison Ratio');
 
%figure(13);
%plot(1:length(PacketDetFlag), PacketDetFlag);
%title('Packet Detector -  Packet Detect Flag');

end
end