function Output = GoldCodeGenerator_WB(c_init, NumberOfOutputBits)

% Polynomial and initial conditions based off of LTE standard
%FirstPolynomial  = [1 zeros(1,27) 1 0 0 1];
%SecondPolynomial = [1 zeros(1,27) 1 1 1 1];
FirstInitialCond = [0 zeros(1,29) 1];
Shift            = 1600;

% Convert c_init to SecondInitialCond
Init = zeros(31, 1);
for i = 1:31 % convert number to bit vector
  if(bitand(c_init, 2^(i-1)) ~= 0)
    Init(i,1) = 1;
  end
end
SecondInitialCond = fliplr(Init.');

% Initialize and shift the Gold code generator
Output      = zeros(NumberOfOutputBits, 1);
TotalLength = Shift + NumberOfOutputBits;
Reg1        = [zeros(1, TotalLength) FirstInitialCond];
Reg2        = [zeros(1, TotalLength) SecondInitialCond];
EndLocation = TotalLength;

for i = 1:Shift
  Mod1 = mod( Reg1(1, EndLocation+28) + Reg1(1, EndLocation+31), 2);
  Mod2 = mod( Reg2(1, EndLocation+28) + Reg2(1, EndLocation+29) + ...
              Reg2(1, EndLocation+30) + Reg2(1, EndLocation+31), 2);
  Reg1(1, EndLocation) = Mod1;
  Reg2(1, EndLocation) = Mod2;
  EndLocation = EndLocation - 1;
end

% Produce the scrambling bits
for i = 1:NumberOfOutputBits
  Output(i, 1) = mod(Reg1(1, EndLocation + 31) + Reg2(1, EndLocation + 31), 2);
  Mod1 = mod(Reg1(1, EndLocation + 28) + Reg1(1, EndLocation + 31), 2);
  Mod2 = mod( Reg2(1, EndLocation+28) + Reg2(1, EndLocation+29) + ...
              Reg2(1, EndLocation+30) + Reg2(1, EndLocation+31), 2);
  Reg1(1, EndLocation) = Mod1;
  Reg2(1, EndLocation) = Mod2;
  EndLocation = EndLocation - 1;
end

end