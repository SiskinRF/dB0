function [Sample_Output, evm] = OfdmModulator_dB3(ResourceGrid, SampleRate)

% 1. Modulation Procedure
%--------------------------------------------------------------------------

% 1a. Definitions
[NumSubcarriers, NumOfdmSymbols] = size(ResourceGrid);
assert(NumSubcarriers == 72, "Invalid number of subcarriers.");

if(SampleRate == 1.92e6)
  IFFT_Size = 128;
  CP_Length = 32;
else
  IFFT_Size = 256;
  CP_Length = 64;
end

OfdmSymbolLength = CP_Length + IFFT_Size;

% 1b. Defined by the resource grid
PosSubCarriers = 36:71;
NegSubCarriers = 0:35;

% 1c. Map CarrierIndices to IFFT input
PosIfftIndices = 1:36;
if(IFFT_Size == 128)
  NegIfftIndices = 92:127;
else
  NegIfftIndices = 220:255;
end
  
% 1d. OFDM Modulation
Sample_Output  = zeros(1, NumOfdmSymbols * OfdmSymbolLength);
IFFT_Input     = zeros(IFFT_Size, 1);

Sample_OutputIndex = 1; % Due to Matlab indexing (otherwise = 0)
for i = 0:NumOfdmSymbols - 1
  OfdmSymbol = zeros(1, OfdmSymbolLength);
  
  IFFT_Input(PosIfftIndices + 1, 1) = ResourceGrid(PosSubCarriers + 1, i+1);
  IFFT_Input(NegIfftIndices + 1, 1) = ResourceGrid(NegSubCarriers + 1, i+1);
  IFFT_Output                       = ifft(IFFT_Input);
 
  % Fetch the cyclic prefix and place at the start of the OFDM symbol
  CyclicPrefix                   = IFFT_Output(IFFT_Size - CP_Length + 1:end, 1);
  OfdmSymbol(1, 1:CP_Length)     = CyclicPrefix.';
  OfdmSymbol(1, CP_Length+1:end) = IFFT_Output.';
  
  % Place the OfdmSymbol into the output buffer and update the index into the output sequence
  Sample_Output(1, Sample_OutputIndex:Sample_OutputIndex + OfdmSymbolLength - 1) = OfdmSymbol;
  Sample_OutputIndex = Sample_OutputIndex + OfdmSymbolLength;
end

% 2. Create a grid that labels each resource element by type used to map
%--------------------------------------------------------------------------

% 2a. Designate type of signal for each resource element
PayloadSymbols = zeros(72, 56);

ResourceElement_DC   = 10; 
ResourceElement_Ref  = 20;
ResourceElement_Cntl = 30;
ResourceElement_Dat  = 40;

% 2b. Designate DC elements
for SymbolNum = 1:56
  PayloadSymbols(36:37, SymbolNum) = ResourceElement_DC;
end

% 2c. Designate data elements
for SymbolNum = 4:2:56
  PayloadSymbols(1:35, SymbolNum)  = ResourceElement_Dat;
  PayloadSymbols(38:72, SymbolNum) = ResourceElement_Dat;
end

% 2d. Designate reference elements
for SymbolNum = 1:2:55
  PayloadSymbols(1:35, SymbolNum)  = ResourceElement_Ref;
  PayloadSymbols(38:72, SymbolNum) = ResourceElement_Ref;
end

% 2e. Designate control elements in symbol 2
PayloadSymbols(1:35, 2)   = ResourceElement_Cntl;
PayloadSymbols(38:42, 2)  = ResourceElement_Cntl;

% 2f. Designate tail of data symbol in symbol 2
PayloadSymbols(43:72, 2) = ResourceElement_Dat;

% 3. Create vector for use in evm calculation
%--------------------------------------------------------------------------

evm = zeros(1, 1960);

cnt = 1;
for SymbolNum = 1:56
  for ElementNum = 1:72
    ElementType = PayloadSymbols(ElementNum, SymbolNum);

    if (ElementType == ResourceElement_Dat)
      evm(1, cnt) = ResourceGrid(ElementNum, SymbolNum);
      cnt = cnt + 1;

    elseif (ElementType == ResourceElement_Cntl)
      evm(1, cnt) = ResourceGrid(ElementNum, SymbolNum);
      cnt = cnt + 1;
    
    else
      % do nothing
    end  
  end
end

end

