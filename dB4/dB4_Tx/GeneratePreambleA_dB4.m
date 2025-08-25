% Preamble A is used to:
% Detect presence of a packet
% Determine frequency offset of the packet

function PreambleA = GeneratePreambleA_dB4(SampleRate)

  assert(SampleRate == 15.36e6 || SampleRate == 30.72e6, "Invalid SampleRate");

  % Preamble A lasts 5500 or 11000 samples (approx 358usec).
  if (SampleRate == 15.36e6)
    NumberOfSamples = 5500;
  else
    NumberOfSamples = 11000;
  end

  %Construct the Preamble in time domain
  % Repeat 32 and 96 times subcarrier of 15kHz
  CosineFrequencyA = 480000;
  CosineFrequencyB = 1440000;
  n = 0:1:NumberOfSamples-1;
  
  PreambleA = cos(2*pi*CosineFrequencyA*n*(1/SampleRate) + pi/4) + ...
              cos(2*pi*CosineFrequencyB*n*(1/SampleRate) + 3*pi/4);

end
