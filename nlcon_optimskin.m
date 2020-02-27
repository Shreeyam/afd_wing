% function [c,ceq] = nlcon_optimskin(thickness)
    % check if computation is necessary
%     if ~isequal(thickness,tLast)
        % if t is not equal to tLast, calculate shear along span
        thickness = t0;
        
        [fvalLast, cLast] = ...
            calc_shear_func(thickness,G,spanwise_steps,b,taumax,componentname,dens_n,dens_r,dens_w,...
            Sw, t, afpoly, tc, fspar, bspar, MTOW, f, n, Vw, Ww, afcx, aff, M0);
%         tLast = thickness;
%     end
    c = cLast;
    ceq = []; % no equality constraints
% end