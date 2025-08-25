% 1. Configue which channel model impairments to model: 0/1 => exclude/include
%--------------------------------------------------------------------------

Mode.Multipath    = 0;
Mode.Freq_Offset  = 0;
Mode.ThermalNoise = 0;
%Mode.PhaseNoise   = 0;
Mode.IQ_Imbalance = 0;
Mode.TimingOffset = 0;
Mode.TimingDrift  = 0;

% 2. Values for channel impairments
%--------------------------------------------------------------------------

Settings.SampleRate       = 3.84e6;     % (Tx uses 256 point FFT)

Settings.MultipathModel   = 1;           % 0/1 Custom FIR Taps/Matlab Rician Channel

% For Multipath Model 0 - No Doppler
Settings.NumberOfTaps     = 40;          
Settings.DelaySpread      = 7.0e-6;

% For Multipath Model 1 - Matlab Rician Channel
Settings.KFactor          = 2;
Settings.DopplerFreq      = 400;
Settings.Delays           = [-1.0, 0.05, 0.20, 0.23, 0.5, 1.6, 2.3, 3.0, 4.0, 5.0]*1e-6;
Settings.Power            = [-3.0, -1.0, 0.0, 0.0, 0.0, -3.0, -5.0, -7.0, -7.0, -9.0];

Settings.SNR_dB                = 15;          % Thermal Noise
%Settings.PhaseNoiseProfile     = 0;
Settings.FrequencyOffset       = 29000;
Settings.PhaseImbalance        = pi/2000;     % radians
Settings.AmplitudeImbalance_dB = -0.1;        % dB
Settings.Sample_Offset         = -1;
Settings.Drift_ppm             = -80;

% 3. Simulation Controls
%--------------------------------------------------------------------------

Packet_Source  = 0;  % 0 = Simulated / 1 = SDR
HalfBandFilter = 0;  % 0 = No / 1 = Yes
CorrectOffset  = 1;  % 0 = No / 1 = Yes
Time_Advance   = -2;  % Time in samples into cyclic prefix (left) from start of symbol
PCAflag        = 0;  % 0 = No / 1 = Use Principle Component Analysis in Equalizer
LLR_Correction = 0;  % 0 = No / 1 = Use LLR correction bor symbol to bit decision

% 4. Build a packet to transmit
%--------------------------------------------------------------------------
  
% 4a. Construct Preamble
Preamble = ConstructPreamble_dB2(Settings.SampleRate);

% 4b. Construct resource grid with test signals
[Tx_ResourceGrid, RefSignals, TBLK, TBLK_CNTL] = ConstructResourceGrid_dB2();

% 4c. Modulate the packet to transmit
[Payload, Tx_evm] = OfdmModulator_dB2(Tx_ResourceGrid, Settings.SampleRate);
Payload = sqrt(256)*Payload; %check if need this to scale when using Pluto SDR

if(Packet_Source == 0)
  Packet = [Preamble Payload zeros(1, 200)];

  %figure(1);
  %plot(1:length(Packet), real(Packet(1:end))); hold on;
  %plot(1:length(Packet), imag(Packet(1:end)));
  %title('Tx Packet');

else
  % Use recorded packet from Pluto SDR
  bfr = comm.BasebandFileReader('PlutoData_NB.bb', 'SamplesPerFrame', 2^16);

  %steps = 2;
  %ts = dsp.TimeScope('SampleRate', 40e6, ...
  %                   'TimeSpan', 2^16/40e6*steps, ...
  %                   'BufferLength', 2^16*steps);

  Packet = bfr()';
  %ts(bfr());
  release(bfr);

  figure(1);
  plot(1:65536, imag(Packet(1,:))); hold on; plot(1:65536, real(Packet(1,:)));
  title('Packet - SDR Captured');

end

% 5. Channel Defect model
%--------------------------------------------------------------------------

Packet = Defect_Model_WB(Packet, Settings, Mode);

% 6. Process received packet
%--------------------------------------------------------------------------

% 6a. Decimation filter
if (HalfBandFilter == 1)
  N = 31;
  n = 0:N-1;
  Arg = n/2 - (N-1)/4;
  Hann = hann(length(n) + 2)';
  h = sinc(Arg).*(Hann(1,2:end-1) .^1);
  Packet = filter(h, 1, Packet);
end

Packet_Dec = 2*Packet(1, 1:2:end);

% 6b. Packet Detection
PacketDetFlag = Packet_Detector_dB2(Packet_Dec);

figure(2);
plot(1:length(Packet_Dec), imag(Packet_Dec(1:end))); hold on
plot(1:length(Packet_Dec), real(Packet_Dec(1:end))); hold on
plot(1:length(PacketDetFlag), real(PacketDetFlag));
title('Rx Packet - Decimated 1.92MHZ');

% 6c. Frequency Offset Determination and Correction
if (CorrectOffset == 1)
  [FreqOffset_Course, FreqOffset_Fine] = Detect_FrequencyOffset_dB2(PacketDetFlag, Packet_Dec);

  n = 1:length(Packet_Dec);
  NCO_Signal = exp(-1i*2*pi*n*FreqOffset_Course/1.92e6);
  Packet_Dec = Packet_Dec .* NCO_Signal;

  NCO_Signal = exp(-1i*2*pi*n*FreqOffset_Fine/1.92e6);
  Packet_Dec = Packet_Dec .* NCO_Signal;
end

% 6d. Timing Offset Determination and Correction
PeakPosition = Detect_TimingOffset_dB2(Packet_Dec);
Payload_Dec  = Packet_Dec(PeakPosition+1:end);
 
% 6e. Demodulation
Rx_ResourceGrid = OfdmDemodulator_dB2(Payload_Dec, Time_Advance);

% 6f. Equalization
[Rx_Signal_Eq, Rx_Signal_Eq_Eigen, RsCinrdB, h_chan, h_chan_Eigen] = ...
Equalizer_dB2(Tx_ResourceGrid, Rx_ResourceGrid, PCAflag);

if (PCAflag == 1)
  Rx_Signal_Eq =  Rx_Signal_Eq_Eigen;
end

% 6g. Basic BPSK demapping
if (LLR_Correction == 0)
  [Rx_Signal_Eq, Rx_evm] = SymbolDecision_BPSK_dB2(Rx_Signal_Eq);
else
  [Rx_Signal_Eq, Rx_evm] = SymbolDecision_BPSK_LLR_dB2(Rx_Signal_Eq, h_chan);
end

% 6h. Pull Rx Msg from Rx_Signal_Eq
[RxTBLK_CNTL, RxTBLK, RxCRC] = DeConstructResourceGrid_dB2(Rx_Signal_Eq); 


% 7. Performance Evaluation
%--------------------------------------------------------------------------

% 7a. Compare Tx with Rx

if (isequal(TBLK_CNTL, RxTBLK_CNTL))
  disp('Success! TBLK_CNTL and RxTBLK_CNTL are the same!');
else
  disp('Error! TBLK_CNTL and RxTBLK_CNTL do not match');
end

if (isequal(TBLK, RxTBLK))
  disp('Success! Tx and Rx are the same!');
else
  disp('Error! Tx and Rx do not match');
end

% 7b. Calculate EVM
ErrorVectors  = Tx_evm(1,1:end) - Rx_evm(1,1:end);
Avg_VectorPwr = (1/length(ErrorVectors))*(ErrorVectors*ErrorVectors');
EVM           = 10*log10(Avg_VectorPwr/1);
disp(['EVM = ' num2str(EVM) 'dB']);







