function output = Descrambler_dB2(id, input) 

NumberOfOutputBits   = length(input);
Sequence             = GoldCodeGenerator_WB(id, NumberOfOutputBits);
output               = mod((input + Sequence), 2);

end