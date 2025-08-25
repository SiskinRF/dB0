% Use this program to edit a captured waveform from Pluto SDR
% Save the wanted portion to a .m file for use by dB3_Simulator.m

bfr.Filename = 'C://Users//rkucb//Desktop//SiskinRF//dB3//PlutoData_dB3.bb';

bfr = comm.BasebandFileReader(bfr.Filename, 'SamplesPerFrame', 65000);

PacketPluto = bfr();
bfr.release();

figure(2)
plot(1:65000, real(PacketPluto(1:65000,1))); hold on;
plot(1:65000, imag(PacketPluto(1:65000,1)));
title('Packet - SDR Captured Packet');

% In this partucular example I want samples 10,770 - 20,790
PacketPlutoTrim = PacketPluto(16265:36055);

figure(3)
plot(1:length(PacketPlutoTrim), real(PacketPlutoTrim(:,1))); hold on;
plot(1:length(PacketPlutoTrim), imag(PacketPlutoTrim(:,1)));
title('Packet - SDR Captured Packet Trimmed');

% Save to a .mat file
FilenameMat = 'C://Users//rkucb//Desktop//SiskinRF//dB3//PlutoData_dB3.mat';
save(FilenameMat,'PacketPlutoTrim' , '-v4');