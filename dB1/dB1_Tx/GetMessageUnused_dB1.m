function unused = GetMessageUnused_dB1()

rng(8); % fixed seed
unused = randi([0 1], 1, 44);

% Dont really need to do this with randomly genereated message, but done
% in case these resource elements will be used one day.

%id        = 103; %this can be changed to whatever. Fixed for now
%sunused   = Scrambler_WB(id, unused);


end