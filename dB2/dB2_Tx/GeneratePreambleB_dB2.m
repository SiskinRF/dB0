% PreambleB is used at the receiver to aquire timing
% This is done with a Zadoff-Chu sequence that has good auto-correlation
% behavior. The received waveform is correlated against a copy of Preamble
% B

function PreambleB = GeneratePreambleB_dB2(SampleRate)
  
  assert(SampleRate == 1.92e6 || SampleRate == 3.84e6, "Invalid SampleRate");

  % Preamble B lasts 160 or 320 samples including cyclic prefix (83.3usec).
  if (SampleRate == 1.92e6)
    NumberOfSamplesToRetain = 128;
  else
    NumberOfSamplesToRetain = 256;
  end

  % Define Zadoff-Chu Sequence
  Nzc         = 128;           % Waveform bandwidth is less than that of AGC
  ScPositive  = ceil(Nzc/2);  % The number of positive subcarriers including 0Hz
  ScNegative  = floor(Nzc/2); % The number of negative subcarriers
  u1          = 34;           % This could be a different number
  n           = 0:Nzc-1;      % Discrete time indices

  % Generate the Zadoff-Chu sequence
  zc          = exp(-1j*pi*u1*n.*(n+1)/Nzc);
  
  % Take DFT
  PreambleBDft = fft(zc);
  
  % Map the DFT output into the IFFT
  if(SampleRate == 1.92e6)
    IFFT_InputBuffer = zeros(1, 128);
  else
    IFFT_InputBuffer = zeros(1, 256);
  end

  IFFT_InputBuffer(1, 1:ScPositive)       = PreambleBDft(1, 1:ScPositive);
  IFFT_InputBuffer(1, end-ScNegative+1:end) = PreambleBDft(1, end-ScNegative+1:end);
  IFFT_InputBuffer(1,1)                   = 0; % Null out the DC term

  PreambleB_Full                            = ifft(IFFT_InputBuffer);

  PreambleB = (length(PreambleB_Full)/Nzc) * PreambleB_Full(1, 1:NumberOfSamplesToRetain);

  if(SampleRate == 1.92e6)
    CP = PreambleB(1, 97:128);
  else
    CP = PreambleB(1, 193:256);
  end

  PreambleB = [CP PreambleB];

end

