function area = afarea(afpoly,tc,chord,cfrac)
% Yuri Shimane, 2020/02/24
% ================================================================ %
% Function calculates area of airfoil / cell (optinally up to a certain location
% in chord length)
% INPUT
%   afpoly : polyshape object of airfoil, with unit chord length
%   tc     : thickness-to-chord ratio
%   chord  : physical chord length (by default set to 1)
%   cfrac  : fraction along chord length to integrate [0;1]
% OUTPUT
%   area  : area of airfoil
% ================================================================ %

if nargin == 1
    tc = 1;
    chord = 1;  % by default, calculate airfoil area for unit chord
    cfrac = 1;  % by default, return entire area
end

k = 1;
l = 1;
for i = 1:length(afpoly.Vertices)-1
    if afpoly.Vertices(i,1) <= afpoly.Vertices(i+1,1)
        upper_x(k,1) = afpoly.Vertices(i,1);
        upper_y(k,1) = afpoly.Vertices(i,2);
        k = k + 1;
    else
        lower_x(l,1) = afpoly.Vertices(i,1);
        lower_y(l,1) = afpoly.Vertices(i,2);
        l = l+1;
    end
end
% reverse order of lower arrays
lower_x = flipud(lower_x);
lower_y = flipud(lower_y);
% interpolate functions as symbolic object
upper_p = polyfit(upper_x,upper_y,5);
lower_p = polyfit(lower_x,lower_y,5);
% create array to integrate
x_integrate = linspace(0,cfrac,100);
upper_y = polyval(upper_p,x_integrate);
lower_y = polyval(lower_p,x_integrate);
% shift airfoil upward to be robust against flip in +/- in the y-axis
upper_y = upper_y + 10;
lower_y = lower_y + 10;
% integrate
upper_area = trapz(x_integrate,upper_y);
lower_area = trapz(x_integrate,lower_y);
% unit-chord area
area_unit = upper_area - lower_area;
% convert to physical area
area = area_unit * chord^2 * tc;

end

