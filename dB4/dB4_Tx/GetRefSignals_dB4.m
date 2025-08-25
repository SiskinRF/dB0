function RefSignalsScrambled = GetRefSignals_dB1()

RefSignals            = zeros(1, 23920);
RefSignals(1:2:23920) = 1;

id                    = 103;
RefSignalsScrambled   = Scrambler_WB(id, RefSignals); 

end