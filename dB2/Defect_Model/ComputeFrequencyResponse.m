%--------------------------------------------------------------------------
function FreqResponse = ComputeFrequencyResponse(ChannelModel, f, Time)

FreqResponse = zeros(size(f));
NumPaths     = size(ChannelModel, 1);

for p = 1:NumPaths
  Cp    = ChannelModel(p,1);
  Tau_p = ChannelModel(p,2);
  f_p   = ChannelModel(p,3);
  FreqResponse = FreqResponse + Cp * exp(-1j*2*pi*Tau_p*f) .* exp(1j*2*pi*f_p*Time);
  %FreqResponse = FreqResponse + Cp * exp(-1j*2*pi*Tau_p*f) .* exp(-1j*2*pi*f_p*Time);
end