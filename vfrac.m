function out = vfrac(y, Sw, t, b, Vw)
    % compute volume fraction
    out = (c(y, Sw, t, b) .* 2)/(Vw);
end