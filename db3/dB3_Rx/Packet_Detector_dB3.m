function PacketDetFlag = Packet_Detector_dB3(RX_Input)

persistent Detection_Flag;

%--------------------------------------------------------------------------
% 1. Low Pass Filter the preamble improves detection

%Fpass = 275 kHz, Fstop = 600kHz, Apass = 1dB, Astop = 60dB
h = [-0.0022,   -0.0177,   -0.0505,   -0.0619,    0.0184,    0.1969, ...
      0.3561,    0.3561,    0.1969,    0.0184,   -0.0619,   -0.0505, ...
     -0.0177,   -0.0022];

RX_Input = filter(h, 1, RX_Input);

%figure(10);
%plot(1:1000, real(RX_Input(1:1000))); hold on; plot(1:1000, imag(RX_Input(1:1000)));

%figure(11);
%plot(1:1000, real(Test(1:1000))); hold on; plot(1:1000, imag(Test(1:1000)));

%--------------------------------------------------------------------------
% 2. Search for packet

SA_Len = 16; % Sliding Average Length

AutoCorrEst       = zeros(1, length(RX_Input));
Comparison_Ratio  = zeros(1, length(RX_Input));
PacketDetFlag     = zeros(1, length(RX_Input));
Delay16            = zeros(1, 16);
SlidingAverage1   = zeros(1, SA_Len); % For the autocorr estimate
SlidingAverage2   = zeros(1, SA_Len); % For the variance estimate
Detection_Flag    = 0;

for i = 1:length(RX_Input)
  RX_Input_16      = Delay16(1,16);
  Delay16(1,2:16)  = Delay16(1,1:15);
  Delay16(1,1)     = RX_Input(1,i);

  % Compute absolute value of autocorrelation estimate
  Temp                        = RX_Input(1,i) * conj(RX_Input_16);
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
  if (Comparison_Ratio(1,i) > 0.78)
    Detection_Flag = 1;
  elseif (Comparison_Ratio(1,i) < 0.65)
    Detection_Flag = 0;
  end
  PacketDetFlag(1,i) = Detection_Flag;

% figure(12);
% plot(1:length(Comparison_Ratio), Comparison_Ratio);
% title('Packet Detector - Comparison Ratio');
% 
% figure(13);
% plot(1:length(PacketDetFlag), PacketDetFlag);
% title('Packet Detector -  Packet Detect Flag');

end
end