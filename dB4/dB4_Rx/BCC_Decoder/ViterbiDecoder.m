function DecodedBits = ViterbiDecoder(EncodedBits,        ...    
                                      ConstraintLength,   ... % Number of memory elements + 1
                                      PolynomialsOct,     ... % Lte -> [133, 171, 165]
                                      TailBitingBool,     ... % True - for TailBiting mode
                                      ModeString)             % Hard, SoftNonInverting, SoftInverting

% 0. Change input bit format to SoftNonInverting.                                 
if(strcmp(ModeString, 'Hard'))
  EncodedBits = 2*EncodedBits - 1;  % Convert to non inverting softbits  (0/1 -> -1/+1)
elseif(strcmp(ModeString, 'SoftInverting'))
  EncodedBits = -EncodedBits;       % Convert to non inverting softbits  (+1/-1 -> -1/+1)
elseif(~strcmp(ModeString, 'SoftNonInverting'))
  error('Unsupported ModeString');
end    

%  ----------------------------------------------------------------------
% 1. Initializations before we run the Viterbi Decoder loop
%  1a. Initialize Constants
NumberOfStates     = 2 ^ (ConstraintLength - 1);
NumOutBitsPerInBit = length(PolynomialsOct); 
                                        
% 1b. Translate the polynomials from octal form to binary vector form
% In Lte, the PolynomialsOct are [133, 171, 164] in oct thus [1'011'011, 1'111'001, 1'110'101] in binary
PolynomialsBin = zeros(NumOutBitsPerInBit, ConstraintLength);
PolynomialsOct = PolynomialsOct(:); % Guarantee a column vector
for i = 1:length(PolynomialsOct)
  PolynomialsBin(i, :) = oct2poly(PolynomialsOct(i, 1));  
end              

% 1c. We will now build two matrices each featuring dimensions NumberOfStates by NumOutBitsPerInBit
% The first  matrix holds the encoder output for state i with input bit = 0.   
% The second matrix holds the encoder output for state i with input bit = 1.   
% We pre-build these matrices for speed so that during the Viterbi loop we don't continually have
% to recalculate the same values. In the process we change the bits to SoftNoninverting.
EncoderOutputForInput0 = zeros(NumberOfStates, NumOutBitsPerInBit);
EncoderOutputForInput1 = zeros(NumberOfStates, NumOutBitsPerInBit);
for i = 0:NumberOfStates-1
  StateBin = de2bi(i, ConstraintLength - 1, 'left-msb');  % The state as a bin vector => 11dec = ..01011b
  for b = 1:NumOutBitsPerInBit     
    EncoderOutputForInput0(i+1, b) = mod( sum([0, StateBin] .* PolynomialsBin(b, :)),  2) * 2 - 1; 
    EncoderOutputForInput1(i+1, b) = mod( sum([1, StateBin] .* PolynomialsBin(b, :)),  2) * 2 - 1; 
  end
end

% 1d. Build the Traceback matrix. The first column of the traceback matrix indicates the state
% we are in at the very start.
NumDecoderOutputBits = length(EncodedBits)/NumOutBitsPerInBit;
DecodedBits          = zeros(1, NumDecoderOutputBits);
TraceBackUnit        = zeros(NumberOfStates, NumDecoderOutputBits);

% 1e. Define the PathMetric Array. The path with the largest path metric is the winner. The Viterbi
% decoder always assumes that the encoder (at the transmitter) started in state 0. For Tail biting
% mode, this is not true. We will find a work around for this mode.
PathMetricArray       = -1000*ones(NumberOfStates, 1);
PathMetricArray(1,1)  = 0;               % We favor state 0 (the first element in the vector)
PathMetricCopy        = PathMetricArray; % We need a copy of the array for update purposes
PathMetricMatrix      = zeros(NumberOfStates, NumDecoderOutputBits + 1); % For debugging purposes only.
PathMetricMatrix(:,1) = PathMetricArray;  % It's nice to see how the path metrics progress in time.
                      
% 2. Let's start the Viterbi Decoder Loop (Outer Loop)
for OutputBitIndex = 1:NumDecoderOutputBits
  Range         = (OutputBitIndex-1)*NumOutBitsPerInBit + (1:NumOutBitsPerInBit);
  ReceivedBits  = EncodedBits(1, Range);  % Grab NumOutBitsPerInBit encoded bits
    
  % Run through each state (Inner Loop)
  for StateAsInt = 0:NumberOfStates/2 - 1
    % 2a. We will process two states per loop iteration. StateA and StateB
    % No matter what the previous state before StateA was, it's input bit was  0.
    StateAAsInt = StateAsInt;
    % No matter what the previous state before StateB was, it's input bit was 1.
    StateBAsInt = StateAAsInt + NumberOfStates/2;
        
    % 2b. We could only have gotten to StateA via two other States.
    % Interestingly enough, the two states that lead to StateA, also lead to StateB.
    % One of the states has a lower integer value, and one has a higher integer value
    PreviousLowerStateAsInt = 2*StateAsInt;
    PreviousUpperStateAsInt = 2*StateAsInt + 1;
        
    % -------------------------------------------------------------------------------------
    % 2c. Compute branch and path metrics for StateA. 
    % Let's first find the encoder outputs generated during the transition from these two
    % previous states to StateA. Remember, because StateAAsInt is always < NumberOfStates/2, 
    % the input bit to get to StateA must have been a 0.
    EncoderOutputLower = EncoderOutputForInput0(PreviousLowerStateAsInt + 1, :);
    EncoderOutputUpper = EncoderOutputForInput0(PreviousUpperStateAsInt + 1, :);
        
    % New path metric = old path metric + branch metric
    BranchMetricLower  = sum(ReceivedBits .* EncoderOutputLower);
    BranchMetricUpper  = sum(ReceivedBits .* EncoderOutputUpper);
    NewPathMetricLower = PathMetricArray(PreviousLowerStateAsInt+1,1) + BranchMetricLower;
    NewPathMetricUpper = PathMetricArray(PreviousUpperStateAsInt+1,1) + BranchMetricUpper;
        
    % 2d. And the survivor is????
    if(NewPathMetricLower >= NewPathMetricUpper)
      SurvivorPathMetric         = NewPathMetricLower;
      SurvivorPreviousStateAsInt = PreviousLowerStateAsInt;
    else
      SurvivorPathMetric         = NewPathMetricUpper;
      SurvivorPreviousStateAsInt = PreviousUpperStateAsInt;
    end
    TraceBackUnit(StateAAsInt + 1, OutputBitIndex) = SurvivorPreviousStateAsInt;
    PathMetricCopy(StateAAsInt + 1, 1)             = SurvivorPathMetric; 

    % -------------------------------------------------------------------------------------
    % Compute branch and path metrics for StateB. 
    EncoderOutputLower = EncoderOutputForInput1(PreviousLowerStateAsInt + 1, :);
    EncoderOutputUpper = EncoderOutputForInput1(PreviousUpperStateAsInt + 1, :);
        
    % New path metric = old path metric + branch metric
    BranchMetricLower  = sum(ReceivedBits .* EncoderOutputLower);
    BranchMetricUpper  = sum(ReceivedBits .* EncoderOutputUpper);
    NewPathMetricLower = PathMetricArray(PreviousLowerStateAsInt+1,1) + BranchMetricLower;
    NewPathMetricUpper = PathMetricArray(PreviousUpperStateAsInt+1,1) + BranchMetricUpper;
        
    % And the survivor is????
    if(NewPathMetricLower >= NewPathMetricUpper)
      SurvivorPathMetric         = NewPathMetricLower;
      SurvivorPreviousStateAsInt = PreviousLowerStateAsInt;
    else
      SurvivorPathMetric         = NewPathMetricUpper;
      SurvivorPreviousStateAsInt = PreviousUpperStateAsInt;
    end
      TraceBackUnit(StateBAsInt + 1, OutputBitIndex) = SurvivorPreviousStateAsInt;
      PathMetricCopy(StateBAsInt + 1, 1)             = SurvivorPathMetric; 
  end
  % Copy the updated path metrics into the original array
  PathMetricArray = PathMetricCopy;
  PathMetricMatrix(:,OutputBitIndex + 1) = PathMetricArray;
end

% 3. Work your way backwards through the trace back unit
% If the transmitted bit stream has padding bits that forced the encoder into the zero state
% then we know to start the trace back from state 0. If we don't know what the finat state was, 
% then begin the traceback from the state with the largest (best) path metric.
FinalStateAsInt = 0;
if(TailBitingBool == true)
  [~, Temp] = max(PathMetricArray);
  FinalStateAsInt = Temp - 1;
end

% Start the traceback
CurrentStateAsInt   = FinalStateAsInt;
for CurrentOutputBitIndex = NumDecoderOutputBits:-1:1
  if(CurrentStateAsInt < NumberOfStates/2); LastBitEnteringEncoder = 0;
  else;                                     LastBitEnteringEncoder = 1; end
  DecodedBits(1, CurrentOutputBitIndex) = LastBitEnteringEncoder;
    
  % The CurrentStateAsInt is now the previous state as indicated by the trace back unit
  CurrentStateAsInt       = TraceBackUnit(CurrentStateAsInt + 1, CurrentOutputBitIndex);  
end

end