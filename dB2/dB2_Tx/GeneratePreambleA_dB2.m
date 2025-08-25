% Preamble A is used to:
% Detect presence of a packet
% Determine frequency offset of the packet

function PreambleA = GeneratePreambleA_dB2(SampleRate)

  assert(SampleRate == 1.92e6 || SampleRate == 3.84e6, "Invalid SampleRate");

  if (SampleRate == 1.92e6)
    NumberOfSamples = 650;
  else
    NumberOfSamples = 1300;
  end
 
  %Construct the Preamble in time domain
  CosineFrequencyA = 240000;
  CosineFrequencyB = 480000;
  n = 0:1:NumberOfSamples-1;
  
  PreambleA = cos(2*pi*CosineFrequencyA*n*(1/SampleRate)) + ...
              cos(2*pi*CosineFrequencyB*n*(1/SampleRate) + 2*pi/4);


end
