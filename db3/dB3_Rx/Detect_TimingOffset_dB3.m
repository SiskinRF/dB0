function PeakPosition = Detect_TimingOffset_dB3(Signal_Dec)

%- Generate local copy of Preamble B for cross correlation
PreambleB_Local = GeneratePreambleB_dB3(1.92e6);

% cross correlation of PreambleB and Signal_Dec
N                    = length(Signal_Dec);
L                    = length(PreambleB_Local);
Output               = zeros(1, length(Signal_Dec));
ShiftRegister        = zeros(1, L);
PreambleB_Local_Flip = fliplr(PreambleB_Local);
PeakPosition         = 0;
PeakValue            = 0;

for i = 1:N
  ShiftRegister(1, 2:L) = ShiftRegister(1, 1:(L-1));
  ShiftRegister(1, 1)   = Signal_Dec(1, i);
  Output(1, i)          = ShiftRegister*PreambleB_Local_Flip';

  if(abs(Output(1, i)) > abs(PeakValue))
    PeakValue = Output(1, i);
    PeakPosition = i;
  end
end

figure(4);
plot(1:length(Output), real(Output));
title('Result of Crosscorrelation of Preamble B and RX Signal');

end