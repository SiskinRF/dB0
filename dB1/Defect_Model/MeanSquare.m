function rval = MeanSquare(val)

rval = (1/length(val))*sum(val.* conj(val));

end