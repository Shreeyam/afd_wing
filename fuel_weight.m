function out = fuel_weight(tc, y, Sw, t, b, Vw, Wf)
    out = vfrac(tc, y, Sw, t, b, Vw) * -Wf;
end