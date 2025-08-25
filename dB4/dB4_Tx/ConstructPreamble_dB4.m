function Preamble = ConstructPreamble_dB4(SampleRate)

  % Scalings determined by eyeballing the packet from Fig1
  ScalingAGC = 1.1;
  ScalingA   = 0.8;
  
  AgcBurst  = GenerateAgcBurst_dB4(SampleRate) * ScalingAGC;
  PreambleA = GeneratePreambleA_dB4(SampleRate) * ScalingA;
  PreambleB = GeneratePreambleB_dB4(SampleRate);

  Preamble = [AgcBurst PreambleA PreambleB];

%plot(1:length(AgcBurst), real(AgcBurst)); hold on; plot(1:length(AgcBurst), imag(AgcBurst));
%plot(1:length(PreambleA), real(PreambleA)); hold on; plot(1:length(PreambleA), imag(PreambleA));
%plot(1:length(PreambleB), real(PreambleB)); hold on; plot(1:length(PreambleB), imag(PreambleB));
%figure(2);
%plot(1:length(Preamble), real(Preamble)); hold on; plot(1:length(Preamble), imag(Preamble));

end