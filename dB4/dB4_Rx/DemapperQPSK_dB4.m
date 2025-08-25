function output = DemapperQPSK_dB4(input)

output = zeros((length(input)*2), 1);

cnt = 1;

for i = 1:length(input)
  if (input(i, 1) == -0.7071-0.7071i)
    output(cnt, 1)   = 0;
    output(cnt+1, 1) = 0;

  elseif (input(i, 1) == 0.7071-0.7071i)
    output(cnt, 1)   = 0;
    output(cnt+1, 1) = 1;

  elseif (input(i, 1) == 0.7071+0.7071i)
    output(cnt, 1)   = 1;
    output(cnt+1, 1) = 1;
  
  else
    output(cnt, 1)   = 1;
    output(cnt+1, 1) = 0;
  end

  cnt = cnt + 2;
end

end