%--------------------------------------------------------------------------
% 1. Set the reference signal coordinates and channel model

SubcarrierSpacing = 15e3;       % Hz
OfdmSymbolPeriod  = 160/1.92e6; % Sec
Frequencies       = [-36:2:-2, 2:2:36, -36:2:-2, 2:2:36 ...
                     -36:2:-2, 2:2:36, -36:2:-2, 2:2:36 ...
                     -36:2:-2, 2:2:36, -36:2:-2, 2:2:36 ...
                     -36:2:-2, 2:2:36, -36:2:-2, 2:2:36 ...
                     -36:2:-2, 2:2:36, -36:2:-2, 2:2:36 ...
                     -36:2:-2, 2:2:36, -36:2:-2, 2:2:36 ...
                     -36:2:-2, 2:2:36, -36:2:-2, 2:2:36 ...
                     -36:2:-2, 2:2:36 ] *SubcarrierSpacing; 

Times             = [zeros(1,36),   1*ones(1,36),  2*ones(1,36),  3*ones(1,36), ...
                     4*ones(1,36),  5*ones(1,36),  6*ones(1,36),  7*ones(1,36), ...
                     8*ones(1,36),  9*ones(1,36), 10*ones(1,36), 11*ones(1,36), ...
                     12*ones(1,36), 13*ones(1,36), 14*ones(1,36)]*OfdmSymbolPeriod;

DelayRange        = [-1.0e-6 9e-6];
DopplerRange      = [-3000 3000];

%--------------------------------------------------------------------------
% 2. Compute the frequency response for a large set of channel conditions

DelayStep      = (DelayRange(1,2) - DelayRange(1,1)) / 25;
DopplerStep    = (DopplerRange(1,2) - DopplerRange(1,1)) / 25;
DelayVector    = DelayRange(1,1):DelayStep:DelayRange(1,2);
DopplerVector  = DopplerRange(1,1):DopplerStep:DopplerRange(1,2);
NumChannels    = length(DelayVector)*length(DopplerVector);
NumCoordinates = length(Frequencies);

FreqResponseMatrix  = zeros(NumChannels, NumCoordinates);
NumChannelCondition = 0;

for A = 1:length(DelayVector)
  Delay = DelayVector(1,A);

  for B = 1:length(DopplerVector)

    NumChannelCondition = NumChannelCondition + 1;
    Doppler             = DopplerVector(1,B);
    StartAngle          = rand(1,1)*2*pi;

    for Position = 1:NumCoordinates
      Frequency         = Frequencies(1,Position);
      Time              = Times(1,Position);
      C_Scalar          = exp(1j*StartAngle);
      AngleDueToDelay   = -2*pi*Frequency*Delay;
      C_Delay           = exp(1j*AngleDueToDelay);
      AngleDueToDoppler = 2*pi*Doppler*Time;
      C_Doppler         = exp(1j*AngleDueToDoppler);
      C_FreqResponse    = C_Scalar*C_Delay*C_Doppler;

      FreqResponseMatrix(NumChannelCondition,Position) = C_FreqResponse;
    end
  end
end

%--------------------------------------------------------------------------
% 3. Compute the covariance matrix and the eigen value decomposition

CovarianceM  = cov(conj(FreqResponseMatrix));
[V,D]        = eig(CovarianceM);
EigenVectors = V;
EigenValues  = diag(D);

figure(1);
stem(EigenValues, 'k'); grid on;
title('EigenValues - Data Extent Along each Principle Component');

%--------------------------------------------------------------------------
% 4. Generate a typical frequency response and force a particular CINR

ChannelCondition = [ 1.00 + 0.00j,   0.0e-6,   -1050; ...
                     0.30 - 0.70j,  -1.25e-6,  -1000; ...
                     0.20 + 0.20j,   2.25e-6,   -950; ...
                     0.10 + 0.10j,   3.25e-6,   -600; ...
                     0.05 + 0.04j,   4.25e-6,   -600];

FreqResponse = ComputeFrequencyResponse(ChannelCondition(:,:), Frequencies, Times);

% Force a particular reference signal CINR (carrier to interference and noise ratio)
FreqResponsePower = MeanSquare(FreqResponse);
RsCinrdB          = 5;
RsCinrLinear      = 10^(RsCinrdB/10);
NoisePower        = FreqResponsePower/RsCinrLinear;
GaussianNoise     = 0.7071*sqrt(NoisePower)*...
                    (randn(1, length(FreqResponse)) + ...
                  1j*randn(1, length(FreqResponse)));
RawFreqResponse   = (FreqResponse + GaussianNoise).'; % Convert to column vector

%--------------------------------------------------------------------------
% Step 5. 

% Compute separator1 and separator2
MaxEigenValue       = max(EigenValues);
SeperatorThreshold1 = 0.02  * MaxEigenValue;                  % Good for RS_CINR < 15dB)
SeperatorThreshold2 = 0.001 * MaxEigenValue;                  % Good for RS-CINR > 15dB
Seperator1          = sum(EigenValues > SeperatorThreshold1); % Number of principle components
Seperator2          = sum(EigenValues > SeperatorThreshold2); % retained for the estimate

SignalComponentOfEstimate1  = zeros(NumCoordinates, 1);
NoiseComponentOfEstimate1   = zeros(NumCoordinates, 1);
SignalComponentOfEstimate2  = zeros(NumCoordinates, 1);
NoiseComponentOfEstimate2   = zeros(NumCoordinates, 1);

for EigIndex = 1:NumCoordinates
     EigenVector     = EigenVectors(:, EigIndex);
     Norm            = sum(RawFreqResponse .* conj(EigenVector)) / ...
                      (sum(conj(EigenVector).*EigenVector));
     if(EigIndex >  NumCoordinates - Seperator1)
         % Build the signal component of the frequency response. Note that the eigenvectors 
         % belonging to the signal components will have some noise as well. 
         SignalComponentOfEstimate1 = SignalComponentOfEstimate1 + Norm * EigenVector;
     else
         % Compute the noise belonging to those eigenvectors that do not belong to the signal 
         % component of the noisy raw frequency response. We use this to compute the RS-CINR.
         NoiseComponentOfEstimate1  = NoiseComponentOfEstimate1  + Norm * EigenVector; 
     end

     if(EigIndex >  NumCoordinates - Seperator2)
         SignalComponentOfEstimate2 = SignalComponentOfEstimate2 + Norm * EigenVector;
     else
         NoiseComponentOfEstimate2  = NoiseComponentOfEstimate2  + Norm * EigenVector; 
     end
end   

% Compute RS-CINR for Seperator1
TotalNoisePower1  = MeanSquare(NoiseComponentOfEstimate1)  ...
                    * NumCoordinates / (NumCoordinates - Seperator1);
TotalSignalPower1 = MeanSquare(SignalComponentOfEstimate1) ...
                    - TotalNoisePower1 * Seperator2/NumCoordinates;
RsCinrdB1         = 10*log10(TotalSignalPower1/TotalNoisePower1);

% Compute RS-CINR for Seperator2
TotalNoisePower2  = MeanSquare(NoiseComponentOfEstimate2)  ...
                    * NumCoordinates / (NumCoordinates - Seperator2);
TotalSignalPower2 = MeanSquare(SignalComponentOfEstimate1) ...
                    - TotalNoisePower1 * Seperator2/NumCoordinates;
RsCinrdB2         = 10*log10(TotalSignalPower2/TotalNoisePower2);

% Only choose the results of seperator2 only if its RS-CINR results is truely better
if(real(RsCinrdB2) > (real(RsCinrdB1) + 1))
   RsCinrdB        = real(RsCinrdB2);    % Results for seperator1
   ChannelEstimate = SignalComponentOfEstimate2;
else 
   RsCinrdB        = real(RsCinrdB1);    % Results for seperator2
   ChannelEstimate = SignalComponentOfEstimate1;
end

figure(2);
subplot(2,1,1);
plot(Frequencies, real(FreqResponse), 'k', 'Linewidth', 2); grid on; hold on;
plot(Frequencies, real(RawFreqResponse), 'k:o', 'Markersize', 4);
plot(Frequencies, real(SignalComponentOfEstimate1), 'k--', 'Linewidth', 2);
title('Real Component of The Ideal, Raw and Estimated Frequency Response');
legend('Ideal (no Noise)', 'Raw (with Noise)', 'Estimate');
xlabel('Frequency in Hz');
axis([-0.6e6 0.6e6 -3 3]);
subplot(2,1,2);
plot(Frequencies, imag(FreqResponse), 'k', 'Linewidth', 2); grid on; hold on;
plot(Frequencies, imag(RawFreqResponse), 'k:o', 'Markersize', 4);
plot(Frequencies, imag(SignalComponentOfEstimate1), 'k--', 'Linewidth', 2);
title('Imaginary Component of The Ideal, Raw and Estimated Frequency Response');
legend('Ideal (no Noise)', 'Raw (with Noise)', 'Estimate');
xlabel('Frequency in Hz');
axis([-0.6e6 0.6e6 -3 3]);







