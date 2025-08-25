% Capture a test signal and write it to a file (if uncommented)
bfw.Filename = 'C://Users//rkucb//Desktop//SiskinRF//dB3//PlutoData_dB3.bb';

rx = sdrrx('Pluto');
rx.CenterFrequency    = 2.300e9;
rx.BasebandSampleRate = 3.84e6;
rx.GainSource = 'AGC Fast Attack';
rx.SamplesPerFrame = 65000;

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
plot(1:65000, real(data(1:65000,1))); hold on; plot(1:65000, imag(data(1:65000,1)));

bfw = comm.BasebandFileWriter(bfw.Filename, rx.BasebandSampleRate, rx.CenterFrequency);
bfw(data(:, 1));
bfw.release();


