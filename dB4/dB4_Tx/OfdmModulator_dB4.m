function [Sample_Output, evm] = OfdmModulator_dB4(ResourceGrid, SampleRate)

% 1. Modulation Procedure
%--------------------------------------------------------------------------

% 1a. Definitions
[NumSubcarriers, NumOfdmSymbols] = size(ResourceGrid);

assert(NumSubcarriers == 600, "Invalid number of subcarriers.");

if(SampleRate == 15.36e6)
  IFFT_Size = 1024;
  CP_Length = 128;
else
  IFFT_Size = 2048;
  CP_Length = 256;
end

OfdmSymbolLength = CP_Length + IFFT_Size;

% 1b. Defined by the resource grid
PosSubCarriers = 300:599;
NegSubCarriers = 0:299;

% 1c. Map CarrierIndices to IFFT input
PosIfftIndices = 1:300;
if(IFFT_Size == 1024)
  NegIfftIndices = 724:1023;
else
  NegIfftIndices = 1748:2047;
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

if (SampleRate == 15.36e6)
  Sample_Output = Sample_Output * sqrt(1024);
else
  Sample_Output = Sample_Output * sqrt(2048);
end

% 2. Create a grid that labels each resource element by type used to map
%--------------------------------------------------------------------------

% 2a. Designate type of signal for each resource element
PayloadSymbols = zeros(600, 80);

ResourceElement_DC   = 10; 
ResourceElement_Ref  = 20;
ResourceElement_Cntl = 30;
ResourceElement_Dat  = 40;
ResourceElement_Unsd = 50;

% 2b. Designate DC elements
for SymbolNum = 1:80
  PayloadSymbols(300:301, SymbolNum) = ResourceElement_DC;
end

% 2c. Designate data elements
for SymbolNum = 4:2:80
  PayloadSymbols(1:299, SymbolNum)   = ResourceElement_Dat;
  PayloadSymbols(302:600, SymbolNum) = ResourceElement_Dat;
end

% 2d. Designate reference elements
for SymbolNum = 1:2:79
  PayloadSymbols(1:299, SymbolNum)   = ResourceElement_Ref;
  PayloadSymbols(302:600, SymbolNum) = ResourceElement_Ref;
end

% 2e. Designate control elements in symbol 2
PayloadSymbols(1:299, 2)    = ResourceElement_Cntl;
PayloadSymbols(302:482, 2)  = ResourceElement_Cntl;

% 2f. Designate tail of data symbol 39 elements in symbol 2
PayloadSymbols(523:600, 2)  = ResourceElement_Dat;

% 2g. Designate unused elements in symbol 2
PayloadSymbols(483:522, 2)  = ResourceElement_Unsd;

% 3. Create vector for use in evm calculation
%--------------------------------------------------------------------------

evm = zeros(1, 23880);

cnt = 1;
for SymbolNum = 1:80
  for ElementNum = 1:600
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

