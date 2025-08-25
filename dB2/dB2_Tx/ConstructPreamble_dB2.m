function Preamble = ConstructPreamble_dB2(SampleRate)

  AgcBurst  = GenerateAgcBurst_dB2(SampleRate);
  PreambleA = GeneratePreambleA_dB2(SampleRate);
  PreambleB = GeneratePreambleB_dB2(SampleRate);

  Preamble = [AgcBurst PreambleA PreambleB];

%plot(1:length(AgcBurst), real(AgcBurst)); hold on; plot(1:length(AgcBurst), imag(AgcBurst));
%plot(1:length(PreambleA), real(PreambleA)); hold on; plot(1:length(PreambleA), imag(PreambleA));
%plot(1:length(PreambleB), real(PreambleB)); hold on; plot(1:length(PreambleB), imag(PreambleB));
%figure(2);
%plot(1:length(Preamble), real(Preamble)); hold on; plot(1:length(Preamble), imag(Preamble));
%title('Preamble');

end