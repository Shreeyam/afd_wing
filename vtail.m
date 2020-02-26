% V-tail parameters

componentname = 'vtail';

AR = 1.2;    % V-tail aspect ratio
t = 0.8;     % V-tail taper tatio
lambda = 40; % V-tail sweep [deg]
Sw = 4.80;   % V-tail area
mac = 2.00;  % V-tail MAC
cr = mac*(3/2)*(1+t)/(1+t+t^2);   % V-tail root chord ratio
ct = t*cr;    % V-tail tip chord ratio

tc = 0.12;    % V-tail Thickness-to-chord ratio

b = 2.4;      % V-tail span
fspar = 0.25; % V-tail spar num.: same as wing
bspar = 0.7;  % V-tail spar num.: same as wing
M0 = 0;       % V-tail zero-lift moment

% compute volume and weight
Vw = calc_Vw(Sw, t, tc, b); % V-tail volume
Ww = 120.2 * 9.81/2;        % V-tail load on half of H-tail (146kg: total Htail)

