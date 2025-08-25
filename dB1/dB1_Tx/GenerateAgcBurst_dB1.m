% The AGC burst is used at the receiver to allow for fast detection of the
% signal magnitude. This is done with a Zadoff-Chu sequence that allows for
% a wideband signal with low peak to average power ratio.

function AgcBurst = GenerateAgcBurst_dB1(SampleRate)
  
  assert(SampleRate == 15.36e6 || SampleRate == 30.72e6, "Invalid SampleRate");

  % AGC burst lasts 100 or 200 samples (approx 6.5usec).
  if (SampleRate == 15.36e6)
    NumberOfSamplesToRetain = 100;
  else
    NumberOfSamplesToRetain = 200;
  end
  
  % Define Zadoff-Chu Sequence
  Nzc         = 887;          % Force broadband waveform
  ScPositive  = ceil(Nzc/2);  % The number of positive subcarriers including 0Hz
  ScNegative  = floor(Nzc/2); % The number of negative subcarriers
  u1          = 54;           % This could be a different number
  n           = 0:Nzc-1;      % Discrete time indices

  % Generate the Zadoff-Chu sequence
  zc          = exp(-1j*pi*u1*n.*(n+1)/Nzc);
  
  % Take a 887 point DFT
  AgcBurstDft = fft(zc);
  
  % Map the DFT output into the IFFT
  if(SampleRate == 15.36e6)
    IFFT_InputBuffer = zeros(1, 1024);
  else
    IFFT_InputBuffer = zeros(1, 2048);
  end

  IFFT_InputBuffer(1, 1:ScPositive)         = AgcBurstDft(1, 1:ScPositive);
  IFFT_InputBuffer(1, end-ScNegative+1:end) = AgcBurstDft(1, end-ScNegative+1:end);
  IFFT_InputBuffer(1,1)                     = 0; % Null out the DC term

  AgcBurstFull                            = ifft(IFFT_InputBuffer);

  % Retain only 100 or 200 samples
  AgcBurst = (length(AgcBurstFull)/Nzc) * AgcBurstFull(1, 1:NumberOfSamplesToRetain);

end

