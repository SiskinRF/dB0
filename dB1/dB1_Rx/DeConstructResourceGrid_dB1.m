function [RxTBLK_CNTL, RxTBLK, CNTL_CRC, RxCRC] = DeConstructResourceGrid_dB1(RxGrid) 

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


% 2. Transfer data, control, and unused signals to the appropriate vector.
%--------------------------------------------------------------------------

DatSignals  = zeros(23400, 1);
CntlSignals = zeros(480, 1);
UnsdSignals = zeros(40, 1);
DatCnt  = 1;
CntlCnt = 1;
UnsdCnt = 1;

% 2a. Populate the data vector
for SymbolNum = 4:2:80
  for ElementNum = 1:600
    ElementType = PayloadSymbols(ElementNum, SymbolNum);

    if (ElementType == ResourceElement_Dat)
      DatSignals(DatCnt, 1)  = RxGrid(ElementNum, SymbolNum);
      DatCnt = DatCnt + 1;

    elseif (ElementType == ResourceElement_Ref)
      % Do nothing
    
    elseif (ElementType == ResourceElement_Cntl)
      % Do nothing
    
    elseif (ElementType == ResourceElement_Unsd)
      % Do nothing
    
    else
      % Do nothing
    end
  end
end

% 2b. Symbol 2 contains dat, cntl, unsd signals
SymbolNum = 2;
for ElementNum = 1:600
  ElementType = PayloadSymbols(ElementNum, SymbolNum);

  if (ElementType == ResourceElement_Cntl)
    CntlSignals(CntlCnt, 1)  = RxGrid(ElementNum, SymbolNum);
    CntlCnt = CntlCnt + 1;
  
  elseif (ElementType == ResourceElement_Dat)
    DatSignals(DatCnt, 1)  = RxGrid(ElementNum, SymbolNum);
    DatCnt = DatCnt + 1;

  elseif (ElementType == ResourceElement_Ref)
    UnsdSignals(UnsdCnt, 1) = RxGrid(ElementNum, SymbolNum);
    UnsdCnt = UnsdCnt + 1;
    
  elseif (ElementType == ResourceElement_Unsd)
    % Do nothing
    
  else
    % Do nothing
  end
end

% 3. Process the Cntl symbols
%--------------------------------------------------------------------------

% 3a. Demap from symbols to bits
CntlBits = Demapper(CntlSignals);

% 3b. Unscramble the Cntl bits
id      = 103;
RxSCWRD = Descrambler_dB1(id, CntlBits);

% 3c. Unscrambled Cntl bits contains four repetitions. Sum and average
rep1       = RxSCWRD(1:120, 1);
rep2       = RxSCWRD(121:240, 1);
rep3       = RxSCWRD(241:360, 1);
rep4       = RxSCWRD(361:480, 1);

RxCBLK_INV = round(((rep1 + rep2 + rep3 + rep4)/4)');

% 3d. Deinterleave
RxCBLK = InterleaveCntl(RxCBLK_INV, 2);

% 3e. BCC Decode
PolynomialsOct   = [133, 171, 165];
ConstraintLength = 7;
RxDBLK = ViterbiDecoder(RxCBLK, ConstraintLength, PolynomialsOct, true, 'Hard');

% 2e. Calculate CRC and parse out TBLK
CNTL_CRC    = GenerateCRC(RxDBLK(1:24), 'Gen16');
RxTBLK_CNTL = RxDBLK(1:24);


% 4. Process the Dat symbols
%--------------------------------------------------------------------------

% 4a. Demap from symbols to bits
DatBits  = Demapper(DatSignals);

% 4b. Parse out the two scrambled code words and descramble
RxSCWRD2 = zeros(600, 39);
RxCWRD2  = zeros(600, 39);

i = 1;
j = 600;
for SymbolNum = 1:39
  RxSCWRD2(:, SymbolNum) = DatBits(i:j);
  i = i + 600;
  j = j + 600;
end

for SymbolNum = 1:39
  id      = 103;
  RxCWRD2(:, SymbolNum) = Descrambler_dB1(id, RxSCWRD2(:, SymbolNum));
end

% 4c. Average repetitions
RxCBLK_INV2 = zeros(120, 39);

for SymbolNum = 1:39
  rep1       = RxCWRD2(1:120, SymbolNum);
  rep2       = RxCWRD2(121:240, SymbolNum);
  rep3       = RxCWRD2(241:360, SymbolNum);
  rep4       = RxCWRD2(361:480, SymbolNum);
  rep5       = RxCWRD2(481:600, SymbolNum);
  RxCBLK_INV2(:, SymbolNum) = round(((rep1 + rep2 + rep3 + rep4 + rep5)/5)');
end

% 4d. Deinterleave
RxCBLK2 = zeros(120, 39);

for SymbolNum = 1:39
  RxCBLK2(:, SymbolNum) = InterleaveCntl(RxCBLK_INV2(:, SymbolNum)', 2);
end

% 4e. BCC Decode
RxDBLK2 = zeros(40, 39);

PolynomialsOct   = [133, 171, 165];
ConstraintLength = 7;

for SymbolNum = 1:39
  RxDBLK2(:, SymbolNum) = ViterbiDecoder(RxCBLK2(:, SymbolNum)', ConstraintLength, PolynomialsOct, true, 'Hard');
end

% 4f. Calculate CRC
RxCRC  = zeros(3, 39);
RxTBLK = zeros(37, 39);

for SymbolNum = 1:39
  RxCRC(:, SymbolNum) = GenerateCRC(RxDBLK2(1:37, SymbolNum)', 'Gen3');;
  RxTBLK(:, SymbolNum) = RxDBLK2(1:37, SymbolNum);
end

end