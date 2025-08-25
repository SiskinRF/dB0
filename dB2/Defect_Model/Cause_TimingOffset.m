function output = Cause_TimingOffset(input, SampleDelay)

SampleStep  = 1;
InputIndex  = 1:length(input);
OutputIndex = 1 + SampleDelay:SampleStep:length(input);

output = interp1(InputIndex, input, OutputIndex, 'spline');

end