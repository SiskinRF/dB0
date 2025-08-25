function Remainder = GenerateCRC(Message, CRC_Gen)

% Message = [1 1 1 0 1 1 0 1 1 1 0 1 1 0 1 1 1 0 1 1 0 1 1 1];
% CRC_Gen = 'Gen16';

switch(CRC_Gen)
  case 'Gen24'
    Polynomial = [1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1];
  case 'Gen16'
    Polynomial = [1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
  case 'Gen10'
    Polynomial = [1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1];
  case 'Gen3'
    Polynomial = [1, 1, 0, 1];   
end

% 1. Error checking
[MessageRows, MessageColumns] = size(Message);

% 2. Compute the CRC process

% Create a temporary message by appending length(Polynomial) - 1 zeros to
% the original message
TempMessage = [Message, zeros(1, length(Polynomial)-1)];

for i = 1:length(Message)
  Range = i:(i+length(Polynomial)-1);
  if(TempMessage(1,i) ~= 0)
    TempMessage(1, Range) = mod(TempMessage(1, Range) + Polynomial, 2);
  end
  if(sum(TempMessage) == 0)
    break;
  end
end

% CRC remainder as a row vector
Remainder = TempMessage(1, (end - length(Polynomial) + 2): end);

% Change the remainder to a column vector if the original message was also
% a column vector.
if(MessageColumns == 1)
  Remainder = Remainder.';
end

end