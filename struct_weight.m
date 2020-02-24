% structural weight per unit span
function out = struct_weight(tc, y, Sw, t, b, Vw, Ww)
    out = vfrac(tc, y, Sw, t, b, Vw) * -Ww;
end