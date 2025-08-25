function ScrambledSequence = Scrambler_WB(id, SequenceToScramble) 

SequenceToScramble = SequenceToScramble';

NumberOfOutputBits = length(SequenceToScramble);
Sequence = GoldCodeGenerator_WB(id, NumberOfOutputBits);

ScrambledSequence = mod((SequenceToScramble + Sequence), 2);

end