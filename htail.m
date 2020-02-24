% H-tail parameters

componentname = 'htail';

AR = 5.2;    % H-tail aspect ratio
t = 0.6;     % H-tail taper tatio
lambda = 20; % H-tail sweep [deg]
Sw = 10.82;  % H-tail area
mac = 1.44;  % H-tail MAC
cr = mac*(3/2)*(1+t)/(1+t+t^2);   % H-tail root chord ratio
ct = t*cr;    % H-tail tip chord ratio
tc = 0.12;    % H-tailThickness-to-chord ratio
b = 7.5;      % H-tail span
fspar = 0.25; % H-tail spar num.: same as wing
bspar = 0.7;  % H-tail spar num.: same as wing
M0 = 0;       % H-tail zero-lift moment

% compute volume and weight
Vw = 1;                     % H-tail volume % TODO: FIX this, find an analytical expression?
Ww = 146.0 * 9.81/2;        % H-tail load on half of H-tail (146kg: total Htail)

