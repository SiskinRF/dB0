function RefSignalsScrambled = GetRefSignals_dB2()

RefSignals            = zeros(1, 980);
RefSignals(1:2:980) = 1;

id                    = 103;
RefSignalsScrambled   = Scrambler_WB(id, RefSignals); 

end