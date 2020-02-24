function out = fuel_weight(y, Sw, t, b, Vw, Wf)
    out = vfrac(y, Sw, t, b, Vw) * -Wf;
end