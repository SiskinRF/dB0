function output = Demapper(input)

% only good for BPSK for now
output = zeros(length(input), 1);

for i = 1:length(input)
  if (input(i, 1) == -1)
    output(i, 1) = 0;
  else
    output(i, 1) = 1;
  end
end

end