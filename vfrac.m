function out = vfrac(tc, y, Sw, t, b, Vw)
    % compute volume per unit length fraction
    out = (tc * c(y, Sw, t, b) .* 2)/(Vw);
end