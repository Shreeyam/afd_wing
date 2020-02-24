function out = fuel_weight(tc, y, Sw, t, b, Vw, Wf)
% function computes fuel weight per unit span
% FOMRAT: out = fuel_weight(tc, y, Sw, t, b, Vw, Wf)
    out = vfrac(tc, y, Sw, t, b, Vw) * -Wf;
end