function [OutputSymbols] = Mapper(InputBits, Mod_Size)
% Modulation Format: 0,1,3 -> BPSK, QPSK, 16QAM
persistent BPSK_LUT QPSK_LUT QAM16_LUT

if(isempty(BPSK_LUT))
   BPSK_LUT  = [-1 - 0j; 1 + 0j];                                        % [0;1] 
   QPSK_LUT  = 1/sqrt(2)* [-1 - 1i; -1 + 1i;  1 - 1i;  1 + 1i];          % [00;01;10;11]
   QAM16_LUT = 1/sqrt(10.6)*[-3 - 3*1i; -3 - 1i; -3 + 1i; -3 + 3*1i; ...  
                             -1 - 3*1i; -1 - 1i; -1 + 1i; -1 + 3*1i; ...   
                              1 - 3*1i;  1 - 1i;  1 + 1i;  1 + 3*1i; ...   
                              3 - 3*1i;  3 - 1i;  3 + 1i;  3 + 3*1i];    %  [0000;0001;0010;0011; 0100;0101;0110;0111; 1000;1001;1010;1011; 1100;1101;1110;1111]
end

if(Mod_Size == 2)
  ModulationFormat = 0;
elseif(Mod_Size == 4)
  ModulationFormat = 1;
else
  ModulationFormat = 3; %(Mod_Size == 8);
end

NumberOfSymbols = length(InputBits)/(ModulationFormat + 1);
OutputSymbols   = zeros(1,NumberOfSymbols);

for i = 1:NumberOfSymbols
  Start = 1 + (i - 1)*(ModulationFormat + 1);
  Stop  = Start + ModulationFormat;
  Bit_Group = InputBits(Start:Stop,1);
    
  switch(ModulationFormat)
    case 0
      Code   = Bit_Group(1,1) + 1;
      Symbol = BPSK_LUT(Code, 1);
    case 1
      Code   = Bit_Group(2,1)*2 + Bit_Group(1,1) + 1;
      Symbol = QPSK_LUT(Code, 1);  
    case 3
      Code   = Bit_Group(4,1)*8 + Bit_Group(3,1)*4 ...
               + Bit_Group(2,1)*2 + Bit_Group(1,1) + 1;
      Symbol = QAM16_LUT(Code, 1);
  end
  
  OutputSymbols(1,i) = Symbol;
end

end