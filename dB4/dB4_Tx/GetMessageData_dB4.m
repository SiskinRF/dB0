function [SCWRD, TBLK]  = GetMessageData_dB4()

% Message uses LDPC Encoding. Code Rate = 1/2 972 -> 1944

% TBLK      - Transport Block
% DBLK      - Data Block
% CBLK      - Code Block
% CBLK_INLV - Interleaved Code Block
% CWRD      - Code Word
% SCWRD     - Scrambled Code Word

% 1. Make 78 test messages.
%--------------------------------------------------------------------------
TBLK = zeros(37, 78);

for SymbolNum = 1:78
  TBLK(1:2:37, SymbolNum) = 1;
end

% 2. Calculate CRC and append to message to create DBLK
% -------------------------------------------------------------------------
CRC  = zeros(3, 78);
DBLK = zeros(40, 78);

for SymbolNum = 1:78
  CRC(:, SymbolNum) = GenerateCRC(TBLK(:, SymbolNum)', 'Gen3');
  DBLK(1:37, SymbolNum) = TBLK(:, SymbolNum);
  DBLK(38:40, SymbolNum) = CRC(:, SymbolNum);
end

% 3. BCC encode (CodeRate=1/3 Use Tail-Biting)
% -------------------------------------------------------------------------
CBLK = zeros(120, 78);

PolynomialsOct   = [133, 171, 165];
ConstraintLength = 7;

for SymbolNum = 1:78
  CBLK(:, SymbolNum) = ...
  ConvolutionalEncoder(DBLK(:, SymbolNum)', ConstraintLength, PolynomialsOct, true, 'Hard');
end

% 4. Interleave
% -------------------------------------------------------------------------
CBLK_INV = zeros(120, 78);

for SymbolNum = 1:78
  CBLK_INV(:, SymbolNum) = InterleaveCntl(CBLK(:, SymbolNum)', 1);
end

% 5. Rate Match (Repetition)
%--------------------------------------------------------------------------
CWRD = zeros(600, 78);

for SymbolNum = 1:78
  CWRD(1:120, SymbolNum)   = CBLK_INV(:, SymbolNum);
  CWRD(121:240, SymbolNum) = CBLK_INV(:, SymbolNum);
  CWRD(241:360, SymbolNum) = CBLK_INV(:, SymbolNum);
  CWRD(361:480, SymbolNum) = CBLK_INV(:, SymbolNum);
  CWRD(481:600, SymbolNum) = CBLK_INV(:, SymbolNum);
end

% 6. Scramble
%--------------------------------------------------------------------------
SCWRD = zeros(600, 78);

id        = 103; %this can be changed to whatever. Fixed for now

for SymbolNum = 1:78
  SCWRD(:, SymbolNum) = Scrambler_WB(id, CWRD(:, SymbolNum)');
end

end
