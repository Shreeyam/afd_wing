function out = struct_weight(tc, y, Sw, t, b, Vw, Ww)
% function computes structural weight per unit span
% FORMAT : out = struct_weight(tc, y, Sw, t, b, Vw, Ww)
    out = vfrac(tc, y, Sw, t, b, Vw) * -Ww;
end