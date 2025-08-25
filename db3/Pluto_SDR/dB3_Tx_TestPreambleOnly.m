% Generate a test signal and continuously transmit

tx                    = sdrtx('Pluto');
tx.CenterFrequency    = 2.305e9;
tx.Gain               = -10;
tx.BasebandSampleRate = 3.84e6;

Preamble = ConstructPreamble_dB3(tx.BasebandSampleRate);

wave = [Preamble zeros(1, 500)]';

tx.transmitRepeat(wave);
