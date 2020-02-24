function out = vfrac(y, Sw, t, b, Vw)
    out = (c(y, Sw, t, b) .* 2)/(Vw);
end