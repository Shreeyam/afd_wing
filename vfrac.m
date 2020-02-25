function out = vfrac(tc, y, Sw, t, b, Vw)
    % function computes volume per unit length fraction
    % FORMAT : out = vfrac(tc, y, Sw, t, b, Vw)
    out = (tc * chord_y(y, Sw, t, b) .* 2)/(Vw);
end