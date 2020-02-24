function S = cell_circumference(afpoly,chord,cfrac)
% Yuri Shimane, 2020/02/24
% ================================================================ %
% Function calculates cell circumference over discretized airfoil
% INPUT
%   afpoly : polyshape object of airfoil, with unit chord length
%   chord  : physical chord length (by default set to 1)
%   cfrac  : fraction location along chord up to which circumference is
%            calculated; for cfrac = 1, entire circumference is of entire
%            airfoil
% OUTPUT
%   S     : cell circumference
% ================================================================ %

if nargin == 1
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
upper_p = polyfit(upper_x,upper_y,9);
lower_p = polyfit(lower_x,lower_y,9);
% create array to integrate up to cfrac
x_interp = linspace(0,cfrac,300)';
upper_y_interp = polyval(upper_p,x_interp);
lower_y_interp = polyval(lower_p,x_interp);

% scale x coordinates with chord
x_interp = x_interp * chord;
% scale y coordinates with chord, t/c
upper_y_interp = upper_y_interp * chord;
lower_y_interp = lower_y_interp * chord;

% compute distance between each consecutive points along the airfoil
if chord == 1   %... ugly work around in case chord == 1
    upper_S = zeros(length(x_interp)-2, 1);
    lower_S = zeros(length(x_interp)-2, 1);
    for i = 1:length(x_interp)-2
        upper_S(i,1) = sqrt( ( upper_y_interp(i,1) - upper_y_interp(i+1,1) )^2 + ...
                             ( x_interp(i,1) - x_interp(i+1,1) )^2 );
        lower_S(i,1) = sqrt( ( lower_y_interp(i,1) - lower_y_interp(i+1,1) )^2 + ...
                             ( x_interp(i,1) - x_interp(i+1,1) )^2 );
    end
else
    upper_S = zeros(length(x_interp)-1, 1);
    lower_S = zeros(length(x_interp)-1, 1);
    for i = 1:length(x_interp)-1
    upper_S(i,1) = sqrt( ( upper_y_interp(i,1) - upper_y_interp(i+1,1) )^2 + ...
                         ( x_interp(i,1) - x_interp(i+1,1) )^2 );
    lower_S(i,1) = sqrt( ( lower_y_interp(i,1) - lower_y_interp(i+1,1) )^2 + ...
                         ( x_interp(i,1) - x_interp(i+1,1) )^2 );
    end
end

S = sum(upper_S) + sum(lower_S);


% de-bug plots
figure(101)
plot(upper_x,upper_y,'xb')
hold on
plot(lower_x,lower_y,'xr')
axis equal

figure(102)
plot(x_interp,upper_y_interp,'xb')
hold on
plot(x_interp,lower_y_interp,'xr')
axis equal

disp(2*chord);

% shift airfoil upward to be robust against flip in +/- in the y-axis
% upper_y = upper_y + 10;
% lower_y = lower_y + 10;
% % integrate
% upper_area = trapz(x_interp,upper_y);
% lower_area = trapz(x_interp,lower_y);
% % unit-chord area
% area_unit = upper_area - lower_area;
% % convert to physical area
% area = area_unit * chord^2 * tc;

end

