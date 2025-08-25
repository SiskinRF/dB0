% Capture a test signal and write it to a file

rx = sdrrx('Pluto');
rx.CenterFrequency    = 2.305e9;
rx.BasebandSampleRate = 3.84e6;
rx.GainSource = 'AGC Fast Attack';
rx.SamplesPerFrame = 50000;

data = zeros(rx.SamplesPerFrame, 1);

[d, valid, of] = rx();

if ~valid
  warning('Data Invalid');
elseif of
  warning('Overflow occurred');
else
  data(:, 1) = d;
end

figure(1)
plot(1:500, real(data(1:500,1))); hold on; plot(1:250, imag(data(1:250,1)));


