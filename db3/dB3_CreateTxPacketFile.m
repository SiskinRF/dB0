% Run dB3_Simulator.m with breakpoint at Defect_Model_WB() so that Packet
% is in the workspace

I = real(Packet);
Q = imag(Packet);

I_int16 = floor(I./(4/(2^16)));
Q_int16 = floor(Q./(4/(2^16)));

fileID = fopen('C://Users//rkucb//Desktop//SiskinRF//dB3//Packet_dB3.bin','w');

A = [I_int16; Q_int16];
fprintf(fileID,'%6d %6d\n', A);

fclose(fileID);

figure(1);
plot(1:length(I_int16), I_int16); hold on; plot(1:length(Q_int16), Q_int16);