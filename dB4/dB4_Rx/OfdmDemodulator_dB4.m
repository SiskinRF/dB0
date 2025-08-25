function ResourceGrid = OfdmDemodulator_dB4(InputSequence, StartTime)

% 1. zero pad to prevent overflow for StartTime
InputSequence = [InputSequence zeros(1, 400)]; 

FFT_Size           = 1024;
CP_Length          = 128;
OfdmSymbolLength   = CP_Length + FFT_Size;
NumOfdmSymbols     = floor(length(InputSequence)/OfdmSymbolLength);
ResourceGrid       = zeros(600, 80);

% 2. OFDM Demodulation Process
FFT_Time     = StartTime;

for i = 0:NumOfdmSymbols - 1
  FFT_Time      = FFT_Time + CP_Length;
  EarlySample   = FFT_Time;

  Range         = EarlySample:(EarlySample + FFT_Size - 1);
  Samples       = InputSequence(1, Range + 1);
  FFT_Output    = fft(Samples, FFT_Size);

  Pos_Index_Range = 1:1:300;
  Neg_Index_Range = 724:1:1023;
  
  Pos_Range = 300:599;
  Neg_Range = 0:299;
  ResourceGrid(Pos_Range + 1, i + 1) = FFT_Output(1, Pos_Index_Range + 1);
  ResourceGrid(Neg_Range + 1, i + 1) = FFT_Output(1, Neg_Index_Range + 1);

  FFT_Time = FFT_Time + 1024;
end

% 3. scaling
for i = 1:NumOfdmSymbols
  ResourceGrid(:,i) = ResourceGrid(:,i) / sqrt(1024);
  ResourceGrid(:,i) = ResourceGrid(:,i) / sqrt(2);
end

%for i = 0:NumOfdmSymbols - 1
for i = 0:2    
  figure(5);
  plot(real(ResourceGrid(:,i+1)), imag(ResourceGrid(:,i+1)), 'k.', 'MarkerSize', 10);
  grid on; xlabel('real'); ylabel('imag'); axis([-2.5 2.5 -2.5 2.5]);
  title('Received Constellations Before Equalization');
end

end