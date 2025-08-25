function output = Cause_TimingDrift(input, Drift_ppm)

SampleStep  = 1 + Drift_ppm/1e6;
InputIndex  = 1:length(input);
OutputIndex = 1 + SampleStep:SampleStep:length(input);

output = interp1(InputIndex, input, OutputIndex, 'spline');

end