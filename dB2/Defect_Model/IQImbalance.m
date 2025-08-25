function Output = IQImbalance(Input, IQPhaseError, I_Gain, Q_Gain)

I = real(Input);
Q = imag(Input);

% Simulate phase imbalance
I_Temp = I + Q*sin(IQPhaseError);
Q_Temp = Q*cos(IQPhaseError);

% Simulate amplitude imbalance
I_Out = I_Gain*I_Temp;
Q_Out = Q_Gain*Q_Temp;

Output = I_Out + j*Q_Out;

end