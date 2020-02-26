function Vw = calc_Vw(Sw, t, tc, b)

y = linspace(0, b/2);
c = vfrac(tc, y, Sw, t, b/2, 1);

Vw = trapz(y, c);

end

