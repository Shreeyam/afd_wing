% Wing parameters

componentname = 'wing';

AR = 9;      % wing aspect ratio
t = 0.5;     % wing taper ratio
lambda = 15; % wing sweep [deg]
Sw = 43.85;  % wing area
mac = 2.29;  % wing MAC
cr = mac*(3/2)*(1+t)/(1+t+t^2); % wing root chord length
ct = t*cr;   % wing tip chord length
tc = 0.139;  % wing thickness-to-chord ratio
b = 19.87;   % wing span
fspar = 0.25;
bspar = 0.7;
M0 = 0;      % wing zero-lift moment ___ FIXME!!

% compute volume and weight
Vw = 0.5 * cr^2 * ct^2 * tc^2 * b; % Wing volume
Ww = 441.2 * 9.81/2; % Wing weight (441.2kg: total wing)