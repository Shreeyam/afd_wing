% Wing parameters

componentname = 'wing';

AR = 9;
t = 0.5;
lambda = 15;
Sw = 43.85;
mac = 2.29;
cr = mac*(3/2)*(1+t)/(1+t+t^2);
ct = t*cr;
tc = 0.139; % Thickness-to-chord ratio
b = 19.87;

fspar = 0.25;
bspar = 0.7;

Vw = 0.5 * cr^2 * ct^2 * tc^2 * b; % Wing volume
Ww = 441.2 * 9.81/2; % Wing weight (441.2kg: total wing)