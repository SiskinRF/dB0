% Generate a test signal and continuously transmit

tx                    = sdrtx('Pluto');
tx.CenterFrequency    = 2.300e9;
tx.Gain               = -10;
tx.BasebandSampleRate = 3.84e6;

Preamble = ConstructPreamble_dB3(tx.BasebandSampleRate);

[Tx_ResourceGrid, RefSignals, TBLK, TBLK_CNTL] = ConstructResourceGrid_dB3();

[Payload, Tx_evm] = OfdmModulator_dB3(Tx_ResourceGrid, tx.BasebandSampleRate);

Payload = sqrt(256)*Payload; %check if need this to scale when using Pluto SDR

wave = [Preamble Payload zeros(1, 500)]';

tx.transmitRepeat(wave);
