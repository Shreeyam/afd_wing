function K = kcalc(a, b, R, t)
%KCALC Summary of this function goes here
%   Detailed explanation goes here

x0 = b/sqrt(R * t);
contour = a / b;

x = 0:2:20;

k10 = [8.2, 9, 12, 17, 23, 29, 37, 45, 53.5, 62, 70.5];
k15 = [6.5, 7, 9, 13, 18, 24, 30, 37, 44, 52, 59];
k20 = [6, 6.5, 8, 12, 17, 22, 27, 34, 40, 47, 54];
k30 = [5.5, 6, 7, 11, 16, 20, 25, 30, 36, 42, 48];
k200 = [5, 5.5, 6, 10 13, 16, 19.5, 23, 26, 29, 32];

% Horrible code incoming
if(contour <= 1)
    z1 = interp1(x, k10, x0);
    
    K = z1;
elseif(contour >= 1 && contour < 1.5)
    z1 = interp1(x, k10, x0);
    z2 = interp1(x, k15, x0);
    
    alpha = (contour - 1)/0.5;
    
    K = (1 - alpha) * z1 + alpha * z2;
elseif (contour > 1.5 && contour <= 2)
    z1 = interp1(x, k15, x0);
    z2 = interp1(x, k20, x0);
    
    alpha = (contour - 1.5)/0.5;
    
    K = (1 - alpha) * z1 + alpha * z2;
elseif(contour > 2 && contour <= 3)
    z1 = interp1(x, k20, x0);
    z2 = interp1(x, k30, x0);
    
    alpha = (contour - 2);
    
    K = (1 - alpha) * z1 + alpha * z2; 
elseif(contour > 3 && contour <= 20)
    z1 = interp1(x, k30, x0);
    z2 = interp1(x, k200, x0);
    
    alpha = (contour - 3)/17;
    
    K = (1 - alpha) * z1 + alpha * z2; 
else
    K = 1;
end


end

