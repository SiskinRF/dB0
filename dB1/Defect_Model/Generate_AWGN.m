function Noise = Generate_AWGN(Input, SNR)

MeanSquare = (1/length(Input))*(Input*Input');
NoisePower = MeanSquare/(10^(SNR/10));
STDNoise   = sqrt(NoisePower);

Noise      = STDNoise*(0.70711*randn(1, length(Input)) + ...
                     j*0.70711*randn(1, length(Input)));

end