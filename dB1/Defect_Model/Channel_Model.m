% This needs to be refined so that the multipath model includes doppler
% Right now 5-May-25 this is not used in the model


%--------------------------------------------------------------------------
% 1. Channel Model

ChannelCondition = [ 0.50 + 0.00j,   0.00e-6,    650; ...
                     1.00 - 0.00j,   0.50e-6,  -100; ...
                     0.50 + 0.00j,   2.50e-6,    750; ...
                     0.20 + 0.00j,   4.50e-6,   650];

%--------------------------------------------------------------------------
% 2. Compute frequency response

f    = -1.5e6:15000:1.5e6;
Time = 0.001*ones(1, length(f));
FreqResponse = ComputeFrequencyResponse(ChannelCondition(:,:), f, Time);

figure(1);
subplot(2,1,1);
plot(f, real(FreqResponse), 'k-o', 'Markersize', 3); grid on; hold on;
plot(f, imag(FreqResponse), 'b-d', 'Markersize', 3);
xlabel('Subcarrier Frequency');
title('Real and Imaginary Portions of the Frequency Response of the Channel');
legend('Real','Imag');

%--------------------------------------------------------------------------
% 3. Compute impulse response

N = 201;
n = 0:1:N-1;
 
IDFT_Out = zeros(1, length(n));
for i = 1:N
 m = i - 1;
 f = m/N;
 AnalysisTone = exp(1i*2*pi*n*f);
 IDFT_Out = IDFT_Out + FreqResponse(1,i)*AnalysisTone;
end

IDFT_Out = IDFT_Out ./ N;

TimeResponse = [IDFT_Out(1, 101:end), IDFT_Out(1,1:100)];
Time         = (-100:100)/(15000*200);

subplot(2,1,2);
stem(Time, abs(TimeResponse), 'k'); grid on; hold on;
xlabel('Time (sec)');
title('Abs Value Channel Impulse Response');

% %Mask = [ones(1,6) zeros(1,44) ones(1, 3)];
% f    = -1.5e6:15000:1.5e6;
% FFT  = fft(IDFT_Out);
% figure(22);
% plot(f, real(FFT), 'r'); grid on; hold on;
% plot(f, imag(FFT), 'b');
