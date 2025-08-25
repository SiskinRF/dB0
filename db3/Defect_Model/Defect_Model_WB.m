function TX_Output = Defect_Model_WB(TX_Output, Settings, Mode)

% Multipath model -> No doppler for now
if (Mode.Multipath == 1)
  if(Settings.MultipathModel == 0)
    SampleRate       = Settings.SampleRate;
    DelaySpread      = Settings.DelaySpread;
    N                = Settings.NumberOfTaps;
    FIR_Taps         = GetMultipathFilter(SampleRate, DelaySpread, N);
    TX_Output        = filter(FIR_Taps, 1, TX_Output);
    VarOutput        = var(TX_Output);
    TX_Output        = TX_Output ./ sqrt(VarOutput);

  elseif(Settings.MultipathModel == 1)
    SampleRate       = Settings.SampleRate;
    KFactor          = Settings.KFactor;
    DopplerFreq      = Settings.DopplerFreq;
    Delays           = Settings.Delays;
    Power            = Settings.Power;
    TX_Output = Delay_Doppler_Channel(SampleRate, KFactor, DopplerFreq, Delays, Power, TX_Output);
    TX_Output = TX_Output';
  end
end

% Add thermal noise
if (Mode.ThermalNoise == 1)
  SNR              = Settings.SNR_dB;
  TX_Output        = TX_Output + Generate_AWGN(TX_Output, SNR);
  %Packet = awgn(Packet,SNR);
end

% Add frequency offset
if (Mode.Freq_Offset  == 1)
  FrequencyOffset  = Settings.FrequencyOffset; %Hz
  SampleRate       = Settings.SampleRate;
  OffsetSignal     = exp(1i*2*pi*(1:length(TX_Output))*FrequencyOffset/SampleRate);
  TX_Output        = TX_Output .* OffsetSignal;
end

% Add IQ imbalance
if (Mode.IQ_Imbalance == 1)
  AmplitudeImbalance_db = Settings.AmplitudeImbalance_dB;
  PhaseImbalance        = Settings.PhaseImbalance;
  IGain                 = 10^(0.5*AmplitudeImbalance_db/20);
  QGain                 = 10^(-0.5*AmplitudeImbalance_db/20);
  TX_Output = IQImbalance(TX_Output, PhaseImbalance, IGain, QGain);
end

% Add timing offset
if (Mode.TimingOffset == 1)
  SampleOffset = Settings.Sample_Offset;
  TX_Output = Cause_TimingOffset(TX_Output, SampleOffset);
end

% Add timing drift
if (Mode.TimingDrift == 1)
  Drift = Settings.Drift_ppm;
  TX_Output = Cause_TimingDrift(TX_Output, Drift);
end


end