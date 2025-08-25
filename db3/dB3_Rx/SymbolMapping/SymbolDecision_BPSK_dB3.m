function [output, evm] = SymbolDecision_BPSK_dB3(input)

% 1. Create a grid that labels each resource element by type used to map
%--------------------------------------------------------------------------

% 1a. Designate type of signal for each resource element
PayloadSymbols = zeros(72, 56);

ResourceElement_DC   = 10; 
ResourceElement_Ref  = 20;
ResourceElement_Cntl = 30;
ResourceElement_Dat  = 40;

% 1b. Designate DC elements
for SymbolNum = 1:56
  PayloadSymbols(36:37, SymbolNum) = ResourceElement_DC;
end

% 1c. Designate data elements
for SymbolNum = 4:2:56
  PayloadSymbols(1:35, SymbolNum)  = ResourceElement_Dat;
  PayloadSymbols(38:72, SymbolNum) = ResourceElement_Dat;
end

% 1d. Designate reference elements
for SymbolNum = 1:2:55
  PayloadSymbols(1:35, SymbolNum)  = ResourceElement_Ref;
  PayloadSymbols(38:72, SymbolNum) = ResourceElement_Ref;
end

% 1e. Designate control elements in symbol 2
PayloadSymbols(1:35, 2)   = ResourceElement_Cntl;
PayloadSymbols(38:42, 2)  = ResourceElement_Cntl;

% 1f. Designate tail of data symbol in symbol 2
PayloadSymbols(43:72, 2)  = ResourceElement_Dat;

% 2. Basic BPSK demapping - hard decision
%--------------------------------------------------------------------------
output = zeros(72, 56);

for j = 2:2:56
  for i = 1:72
    if (real(input(i,j)) < -0.01)
      output(i, j) = -1 + 0j;
    elseif (real(input(i,j)) > 0.01)
      output(i, j) = 1 + 0j;
    else
      output(i, j) = 0 + 0j;
    end
  end
end

% 3. Vector containing only data and cntl signals for EVM calculation
%--------------------------------------------------------------------------
evm = zeros(1, 1960);

cnt = 1;
for SymbolNum = 2:2:56
  for ElementNum = 1:72
    ElementType = PayloadSymbols(ElementNum, SymbolNum);

    if (ElementType == ResourceElement_Dat)
      evm(1, cnt) = output(ElementNum, SymbolNum);
      cnt = cnt + 1;

    elseif (ElementType == ResourceElement_Cntl)
      evm(1, cnt) = output(ElementNum, SymbolNum);
      cnt = cnt + 1;

    else
      % do nothing
    end    
  end
end

end