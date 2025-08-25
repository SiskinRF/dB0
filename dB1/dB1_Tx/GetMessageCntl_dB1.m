function [SCWRD, TBLK] = GetMessageCntl_dB1()

% TBLK      - Transport Block
% DBLK      - Data Block
% CBLK      - Code Block
% CBLK_INLV - Interleaved Code Block
% CWRD      - Code Word
% SCWRD     - Scrambled Code Word

% 1. Make a test message % ('ABC' in ASCII with prepended 0 in front of each char)
%--------------------------------------------------------------------------
TBLK = [0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1];

% 2. Calculate CRC and append to message to create DBLK
% -------------------------------------------------------------------------
CRC  = GenerateCRC(TBLK, 'Gen16');
DBLK = [TBLK CRC];

% 3. BCC encode (CodeRate=1/3 Use Tail-Biting)
% -------------------------------------------------------------------------
PolynomialsOct   = [133, 171, 165];
ConstraintLength = 7;
CBLK = ConvolutionalEncoder(DBLK, ConstraintLength, PolynomialsOct, true, 'Hard');

% 4. Interleave
% -------------------------------------------------------------------------
CBLK_INV = InterleaveCntl(CBLK, 1);

% 5. Rate Match (Repetition)
%--------------------------------------------------------------------------
CWRD = [CBLK_INV CBLK_INV CBLK_INV CBLK_INV];

% 6. Scramble
%--------------------------------------------------------------------------
id        = 103; %this can be changed to whatever. Fixed for now
SCWRD     = Scrambler_WB(id, CWRD);

end
