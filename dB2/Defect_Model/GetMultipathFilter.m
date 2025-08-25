function FIR_Taps = GetMultipathFilter(SampleRate, DelaySpread, N)

Ts           = 1/SampleRate;  % sampling period in seconds
Trms         = DelaySpread;   % spread in seconds
n            = 0:N-1;
ExpVariance = exp(-n*Ts/Trms);
FIR_Taps     = zeros(1,N);

for i = 1:N
  FIR_Taps(1,i) = sqrt(ExpVariance(1,i))*randn(1,1) + ...
                  1i*sqrt(ExpVariance(1,i))*randn(1,1);
end

end