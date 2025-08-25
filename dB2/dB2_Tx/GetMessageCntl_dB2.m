function [SCWRD, TBLK] = GetMessageCntl_dB2()

% TBLK      - Transport Block
% DBLK      - Data Block
% CBLK      - Code Block
% CBLK_INLV - Interleaved Code Block
% CWRD      - Code Word
% SCWRD     - Scrambled Code Word

% 1. Make some values up
%--------------------------------------------------------------------------
TBLK = [0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0];

% 2. Scramble
%--------------------------------------------------------------------------
id        = 103; %this can be changed to whatever. Fixed for now
SCWRD     = Scrambler_WB(id, TBLK);

end
