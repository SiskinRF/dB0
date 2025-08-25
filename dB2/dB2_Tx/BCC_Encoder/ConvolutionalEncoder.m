function EncodedBits = ConvolutionalEncoder(InputBits,          ... % 0s and 1s   
                                            ConstraintLength,   ... % Number of memory elements + 1
                                            PolynomialsOct,     ... % Lte -> [133, 171, 165]
                                            TailBitingFlag,     ... % True or False
                                            ModeString)     % Hard, SoftNonInverting, SoftInverting
                                        
% The number of output bits per input bits = 1/EncoderRate
NumOutBitsPerInBit = length(PolynomialsOct);  

% Translate the polynomials from octal form to binary vector form
% In Lte, the PolynomialsOct are [133, 171, 165] in oct and [1'011'011, 1'111'001, 1'110'101] in binary
PolynomialsBin = zeros(length(PolynomialsOct), ConstraintLength);
PolynomialsOct = PolynomialsOct(:); % Guarantee a column vector
for i = 1:length(PolynomialsOct)
  PolynomialsBin(i, :) = oct2poly(PolynomialsOct(i, 1));  
end              

% Is the convolutional encoder/decoder of the Tail-biting type?
if(TailBitingFlag == true)
  % The initial register state of the encoder must be equal to the last ConstraintLength -1 Input bits.
  Reg  = fliplr(InputBits(1, end - ConstraintLength + 2:end));
else
  % The initial register state of the encoder must be equal to all zeros.
  Reg  = zeros(1, ConstraintLength - 1);
end

% Run the convoluational encoder
EncodedBits = zeros(1, length(InputBits) * NumOutBitsPerInBit);
for i = 1:length(InputBits)
  InputBit   = InputBits(1,i);
  OutputBits = zeros(1, NumOutBitsPerInBit);
  for b = 1:NumOutBitsPerInBit       % Compute each output bit
    OutputBits(1,b) = mod( sum([InputBit, Reg] .* PolynomialsBin(b, :)),  2); 
  end
  Range                 = NumOutBitsPerInBit*(i-1) + (1:NumOutBitsPerInBit);  
  EncodedBits(1, Range) = OutputBits;
  Reg                   = [InputBit, Reg(1,1:ConstraintLength-2)];
end

% Format the output bits
if( strcmp(ModeString, 'SoftNonInverting') == 1)
  EncodedBits = 2* EncodedBits - 1;             % Maps from 0/1 to +1/-1
elseif( strcmp(ModeString, 'SoftInverting') == 1)
  EncodedBits = -(2* EncodedBits - 1);          % Maps from 0/1 to -1/+1
elseif (~strcmp(ModeString, 'Hard') == 1)         % No reformatting if ModeString == 'Hard'
 error('Unsupported Mode String'); 
end

end