function [output, evm] = SymbolDecision_BPSK_LLR_dB1(input, ChanResp)

% 1. Create a grid that labels each resource element by type used to map
%--------------------------------------------------------------------------

% 1a. Designate type of signal for each resource element
PayloadSymbols = zeros(600, 80);

ResourceElement_DC   = 10; 
ResourceElement_Ref  = 20;
ResourceElement_Cntl = 30;
ResourceElement_Dat  = 40;
ResourceElement_Unsd = 50;

% 1b. Designate DC elements
for SymbolNum = 1:80
  PayloadSymbols(300:301, SymbolNum) = ResourceElement_DC;
end

% 1c. Designate data elements
for SymbolNum = 4:2:80
  PayloadSymbols(1:299, SymbolNum)   = ResourceElement_Dat;
  PayloadSymbols(302:600, SymbolNum) = ResourceElement_Dat;
end

% 1d. Designate reference elements
for SymbolNum = 1:2:79
  PayloadSymbols(1:299, SymbolNum)   = ResourceElement_Ref;
  PayloadSymbols(302:600, SymbolNum) = ResourceElement_Ref;
end

% 1e. Designate control elements in symbol 2
PayloadSymbols(1:299, 2)   = ResourceElement_Cntl;
PayloadSymbols(302:482, 2)  = ResourceElement_Cntl;

% 1f. Designate tail of data symbol 39 elements in symbol 2
PayloadSymbols(523:600, 2)   = ResourceElement_Dat;

% 1g. Designate unused elements in symbol 2
PayloadSymbols(483:522, 2) = ResourceElement_Unsd;

% 2. Calculate LLR corrected bits
%--------------------------------------------------------------------------

output = zeros(600, 80);

GridNum = 1;
for SymbolNum = 2:2:80
  output(:, SymbolNum) = 4 * real(input(:, SymbolNum)) .* ChanResp(:, GridNum) .* conj(ChanResp(:, GridNum));
  GridNum = GridNum + 1;
end

for j = 2:2:80
  for i = 1:600
    if (real(input(i,j)) < -0.01)
      output(i, j) = -1 + 0j;
    elseif (real(input(i,j)) > 0.01)
      output(i, j) = 1 + 0j;
    else
      output(i, j) = 0 + 0j;
    end
  end
end

% 3. Vector containing only data, cntl, unsd signals for EVM calculation
%--------------------------------------------------------------------------
evm = zeros(1, 23880);

cnt = 1;
for SymbolNum = 2:2:80
  for ElementNum = 1:600
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