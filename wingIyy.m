function Iyy = wingIyy(b,t1,D,t2)
% Function calculate wing's Iyy approximating as the spar's Iyy
% INPUT
%   b  : approx 100 mm
%   t1 : approx 20 mm
%   D  : h_w
%   t2 : tw

Iyy = (1/6)*b*t1^3 + (1/2)*b*t1*(D-t1)^2 + (1/12)*t2*(D-2*t1)^3;
end

