% Test Mapper

x = [0; 0; 0; 1; 1; 1; 1; 0; 1; 1; 0; 1; 0; 0];

% x might ned to be x' depending on how used. Be careful when doing this
% with complex numbers
y = MapperQAM_dB4(x, 4);


z = DemapperQPSK_dB4(y);