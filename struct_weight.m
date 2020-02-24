% structural weight per unit span
function out = struct_weight(y, Sw, t, b, Vw, Ww)
    out = vfrac(y, Sw, t, b, Vw) * -Ww;
end