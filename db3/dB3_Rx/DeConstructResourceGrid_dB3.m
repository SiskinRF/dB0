function [RxTBLK_CNTL, RxTBLK, RxCRC] = DeConstructResourceGrid_dB3(RxGrid) 

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
PayloadSymbols(43:72, 2)   = ResourceElement_Dat;

% 2. Transfer data, control, and unused signals to the appropriate vector.
%--------------------------------------------------------------------------

DatSignals  = zeros(1920, 1);
CntlSignals = zeros(40, 1);
DatCnt  = 1;
CntlCnt = 1;

% 2a. Populate the data vector
for SymbolNum = 4:2:56
  for ElementNum = 1:72
    ElementType = PayloadSymbols(ElementNum, SymbolNum);

    if (ElementType == ResourceElement_Dat)
      DatSignals(DatCnt, 1)  = RxGrid(ElementNum, SymbolNum);
      DatCnt = DatCnt + 1;

    elseif (ElementType == ResourceElement_Ref)
      % Do nothing
    
    elseif (ElementType == ResourceElement_Cntl)
      % Do nothing
    
    else
      % Do nothing
    end
  end
end

% 2b. Symbol 2 contains dat and cntl signals
SymbolNum = 2;
for ElementNum = 1:72
  ElementType = PayloadSymbols(ElementNum, SymbolNum);

  if (ElementType == ResourceElement_Cntl)
    CntlSignals(CntlCnt, 1) = RxGrid(ElementNum, SymbolNum);
    CntlCnt = CntlCnt + 1;
  
  elseif (ElementType == ResourceElement_Dat)
    DatSignals(DatCnt, 1) = RxGrid(ElementNum, SymbolNum);
    DatCnt = DatCnt + 1;
     
  else
    % Do nothing
  end
end

% 3. Process the Cntl symbols
%--------------------------------------------------------------------------

% 3a. Demap from symbols to bits
CntlBits = Demapper(CntlSignals);

% 3b. Unscramble the Cntl bits
id          = 103;
RxTBLK_CNTL = Descrambler_dB3(id, CntlBits)';

% 4. Process the Dat symbols
%--------------------------------------------------------------------------

% 4a. Demap from symbols to bits
DatBits  = Demapper(DatSignals);

% 4b. Unscramble the Dat bits
RxCWRD = Descrambler_dB3(id, DatBits);

% 4c. Average repetitions
rep1       = RxCWRD(1:120);
rep2       = RxCWRD(121:240);
rep3       = RxCWRD(241:360);
rep4       = RxCWRD(361:480);
rep5       = RxCWRD(481:600);
rep6       = RxCWRD(601:720);
rep7       = RxCWRD(721:840);
rep8       = RxCWRD(841:960);
rep9       = RxCWRD(961:1080);
rep10      = RxCWRD(1081:1200);
rep11      = RxCWRD(1201:1320);
rep12      = RxCWRD(1321:1440);
rep13      = RxCWRD(1441:1560);
rep14      = RxCWRD(1561:1680);
rep15      = RxCWRD(1681:1800);
rep16      = RxCWRD(1801:1920);

RxCBLK_INV = round(((rep1 + rep2 + rep3 + rep4 + rep5 + rep6 + rep7 + rep8 + ...
                     rep9 + rep10 + rep11 + rep12 + rep13 + rep14 + rep15 + ...
                     rep16)/16));

% 4d. Deinterleave
RxCBLK = InterleaveCntl(RxCBLK_INV', 2);

% 4e. BCC Decode
PolynomialsOct   = [133, 171, 165];
ConstraintLength = 7;

RxDBLK = ViterbiDecoder(RxCBLK, ConstraintLength, PolynomialsOct, true, 'Hard');

% 4f. Calculate CRC
RxCRC  = GenerateCRC(RxDBLK, 'Gen16');
RxTBLK = RxDBLK(1:24);

end