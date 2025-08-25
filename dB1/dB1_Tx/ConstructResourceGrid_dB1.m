function [TxGrid, RefSignals, TBLK, TBLK_CNTL] = ConstructResourceGrid_dB1()

% 1. Get resource element values and map to BPSK symbols
%--------------------------------------------------------------------------

% 1a. Get cntl message to Tx and get original message for comparision.
[SCWRD_CNTL, TBLK_CNTL] = GetMessageCntl_dB1();

% 1b. Get data messages to Tx and get original message for comparison.
[SCWRD, TBLK] = GetMessageData_dB1();
SCWRD_DATA    = reshape(SCWRD, 1, []);

% 1c. Get scrambled reference signals
RefSignals = GetRefSignals_dB1();

% 1d. Get unused signals - available for future use
UNUSED = GetMessageUnused_dB1();

% 1e. Map bits to BPSK symbols
RefSymbols  = Mapper(RefSignals, 2);
CntlSymbols = Mapper(SCWRD_CNTL, 2);
DatSymbols  = Mapper(SCWRD_DATA', 2);
UnsdSymbols = Mapper(UNUSED', 2);

% 2. Build the Resource Grid
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
PayloadSymbols(1:299, 2)   = ResourceElement_Cntl;
PayloadSymbols(302:482, 2)  = ResourceElement_Cntl;

% 2f. Designate tail of data symbol 39 elements in symbol 2
PayloadSymbols(523:600, 2)   = ResourceElement_Dat;

% 2g. Designate unused elements in symbol 2
PayloadSymbols(483:522, 2) = ResourceElement_Unsd;

% 2h. Populate the resource grid
DatCnt  = 1;
RefCnt  = 1;
CntlCnt = 1;
UnsdCnt = 1;
DcCnt   = 1;
TxGrid = zeros(600, 80);

for SymbolNum = 3:80
  for ElementNum = 1:600
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

    elseif (ElementType == ResourceElement_Unsd)
      TxGrid(ElementNum, SymbolNum) = UnsdSymbols(1, UnsdCnt);
      UnsdCnt = UnsdCnt + 1;
    
    else
      % do nothing
    end
  end
end

for SymbolNum = 1:2
  for ElementNum = 1:600
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

    elseif (ElementType == ResourceElement_Unsd)
      TxGrid(ElementNum, SymbolNum) = UnsdSymbols(1, UnsdCnt);
      UnsdCnt = UnsdCnt + 1;
    
    else
      % do nothing
    end
  end
end

end

