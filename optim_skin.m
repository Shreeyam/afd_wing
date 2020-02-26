function [thickness,fval,exitflag,output,cLast] = ...
    optim_skin(t0,b,G,taumax,spanwise_steps,componentname,opts,dens_n,dens_r,dens_w,...
                Sw, t, afpoly, tc, fspar, bspar, MTOW, f, n, Vw, Ww, afcx, aff, M0)
% Function calls nested fmincon to optimize for skin thickness
% FORMAT : [u,fval,exitflag,output] = optim_skin(t0,G,taumax,opts)
% INPUT :
%   (many parameters)
%   SFBMout : structure containing the three outputs from function SFBM
% Yuri Shimane, 2020/02/24

% declare global variables for speed
tLast = [];
fvalLast = [];
cLast = [];

% objective function, nested below
objf = @objfun;
% constraint function, nested below
cfun = @nlcon;
% lower and upper bounds
lb = [4.3;     % min thickness of tn [mm] --> from Crit. buckiling
      1;     % min thickness of tr [mm] (free)
      1];    % min thickness of tw [mm] --> from Bending moment!
ub = 10^3 * ones(3,1); % set max skin thickness [mm]

% % prepare bending moment constraint on h_w... interpolate bending moment
% yloc = linspace(0,b/2,spanwise_steps);
% p = polyfit(SFBMout.y(3:length(SFBMout.y),1),SFBMout.BM(3:length(SFBMout.y),1),4);
% BM_at_yloc = polyval(p,yloc);

% call fmincon
[thickness,fval,exitflag,output] = fmincon(objf,t0,[],[],[],[],lb,ub,cfun,opts);

% ... nested functions below ...
    % ===== objective function ===== %
    function fval = objfun(thickness)        
        % check if computation is necessary
        if ~isequal(thickness,tLast)
            % if t is not equal to tLast, calculate shear along span
            [fvalLast, cLast] = ...
                calc_shear_func(thickness,G,spanwise_steps,b,taumax,componentname,dens_n,dens_r,dens_w,...
                Sw, t, afpoly, tc, fspar, bspar, MTOW, f, n, Vw, Ww, afcx, aff, M0);
            tLast = thickness;
        end
        % return objective function value
        fval = fvalLast;
    end

    % ===== non-linear constraint function ===== %
    function [c,ceq] = nlcon(thickness)
        % check if computation is necessary
        if ~isequal(thickness,tLast)
            % if t is not equal to tLast, calculate shear along span
            [fvalLast, cLast] = ...
                calc_shear_func(thickness,G,spanwise_steps,b,taumax,componentname,dens_n,dens_r,dens_w,...
                Sw, t, afpoly, tc, fspar, bspar, MTOW, f, n, Vw, Ww, afcx, aff, M0);
            tLast = thickness;
        end
        c = cLast;
        ceq = []; % no equality constraints
    end
    
end


