function sparheight = sparheight_calc(psobj,tc,chord,cfrac)
% Yuri Shimane, 2020/02/24
% ================================================================ %
% Function calculates spar height at given location of the airfoil
% INPUT
%   psobj : polyshape object of airfoil, with unit chord length
%   tc    : thickness-to-chord ratio (by default set to 1)
%   chord : physical chord length (by default set to 1)
%   cfrac : fraction location along chord to calculate spar-height
% OUTPUT
%   y     : spar height
% ================================================================ %

if nargin == 1
    tc = 1;
    chord = 1;  % by default, calculate airfoil area for unit chord
    cfrac = 1;  % by default, return entire area
end

k = 1;
l = 1;
for i = 1:length(psobj.Vertices)-1
    if psobj.Vertices(i,1) <= psobj.Vertices(i+1,1)
        upper_x(k,1) = psobj.Vertices(i,1);
        upper_y(k,1) = psobj.Vertices(i,2);
        k = k + 1;
    else
        lower_x(l,1) = psobj.Vertices(i,1);
        lower_y(l,1) = psobj.Vertices(i,2);
        l = l+1;
    end
end
% reverse order of lower arrays
lower_x = flipud(lower_x);
lower_y = flipud(lower_y);
% interpolate functions as symbolic object
upper_p = polyfit(upper_x,upper_y,5);
lower_p = polyfit(lower_x,lower_y,5);

% calculate y-coordinates of upper and lower surfaces at cfrac
upper_y = polyval(upper_p,cfrac);
lower_y = polyval(lower_p,cfrac);

% shift y-values upward just in case
upper_y = upper_y + 10;
lower_y = lower_y + 10;

% calculate spar-height, rescaling with chord length
sparheight = (upper_y - lower_y) * chord;

end

