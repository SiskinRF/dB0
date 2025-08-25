function [TxGrid, RefSignals, TBLK, TBLK_CNTL] = ConstructResourceGrid_dB3()

% 1. Populate resource element values and map to BPSK symbols
%--------------------------------------------------------------------------

% 1a. Get cntl signals (20 Data Resource Elements in OFDM symbol 2)
[SCWRD_CNTL, TBLK_CNTL] = GetMessageCntl_dB3();

% 1b. Get message to Tx. Also get original message for comparision.
[SCWRD, TBLK] = GetMessageData_dB3();

% 1c. Get scrambled reference signals (540 Reference Resource Elements)
RefSignals = GetRefSignals_dB3();

% 1d. Map bits to BPSK symbols
RefSymbols  = Mapper(RefSignals, 2);
CntlSymbols = Mapper(SCWRD_CNTL, 2);
DatSymbols  = Mapper(SCWRD, 2);

% 2. Build the Resource Grid
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

% 2g. Populate the resource grid
DatCnt  = 1;
RefCnt  = 1;
CntlCnt = 1;
DcCnt   = 1;
TxGrid = zeros(72, 56);

for SymbolNum = 3:56
  for ElementNum = 1:72
    ElementType = PayloadSymbols(ElementNum, SymbolNum);

    if (ElementType == ResourceElement_Ref)
      TxGrid(ElementNum, SymbolNum) = RefSymbols(1, RefCnt);
      RefCnt = RefCnt + 1;

    elseif (ElementType == ResourceElement_Dat)
      TxGrid(ElementNum, SymbolNum) = DatSymbols(1, DatCnt);
      DatCnt = DatCnt + 1;

    elseif (ElementType == ResourceElement_Cntl)
      TxGrid(ElementNum, SymbolNum) = CntlSymbols(1, CntlCnt);
      CntlCnt = CntlCnt + 1;
    
    elseif (ElementType == ResourceElement_DC)
      TxGrid(ElementNum, SymbolNum) = 0;
      DcCnt = DcCnt + 1;

    else
      % do nothing
    end
  end
end

for SymbolNum = 1:2
  for ElementNum = 1:72
    ElementType = PayloadSymbols(ElementNum, SymbolNum);

    if (ElementType == ResourceElement_Ref)
      TxGrid(ElementNum, SymbolNum) = RefSymbols(1, RefCnt);
      RefCnt = RefCnt + 1;

    elseif (ElementType == ResourceElement_Dat)
      TxGrid(ElementNum, SymbolNum) = DatSymbols(1, DatCnt);
      DatCnt = DatCnt + 1;

    elseif (ElementType == ResourceElement_Cntl)
      TxGrid(ElementNum, SymbolNum) = CntlSymbols(1, CntlCnt);
      CntlCnt = CntlCnt + 1;
    
    elseif (ElementType == ResourceElement_DC)
      TxGrid(ElementNum, SymbolNum) = 0;
      DcCnt = DcCnt + 1;

    else
      % do nothing
    end
  end
end
 
end

