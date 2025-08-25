function RefSignalsScrambled = GetRefSignals_dB3()

RefSignals            = zeros(1, 1960);
RefSignals(1:2:980) = 1;

id                    = 103;
RefSignalsScrambled   = Scrambler_WB(id, RefSignals); 

end