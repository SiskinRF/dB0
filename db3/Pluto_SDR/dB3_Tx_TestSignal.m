% Generate a test signal and continuously transmit

tx                    = sdrtx('Pluto');
tx.CenterFrequency    = 2.305e9;
tx.Gain               = -10;
tx.BasebandSampleRate = 3.84e6;

NumberOfSamples  = 10000;
CosineFrequencyA = 240000;
CosineFrequencyB = 480000;
n                = 0:1:NumberOfSamples-1;
  
% PreambleA = 2*pi*CosineFrequencyA*n*(1/tx.BasebandSampleRate) + ...
%             2*pi*CosineFrequencyB*n*(1/tx.BasebandSampleRate) + 2*pi/4;

PreambleA = 2*pi*CosineFrequencyB*n*(1/tx.BasebandSampleRate);

wave = complex(cos(PreambleA), sin(PreambleA)).';

tx.transmitRepeat(wave);
