function [thickness,fval,exitflag,output] = optim_skin(t0,b,G,taumax,spanwise_steps,componentname,opts)
% Function calls nested fmincon to optimize for skin thickness
% FORMAT : [u,fval,exitflag,output] = optim_skin(t0,G,taumax,opts)
% INPUT :
%   t0 : initial guess thickness, 3x1 formated as [tn; tr; tw] in [mm]
%   G : material shear modulus [N/mm^2]
%   taumax : material max shear stress [N/mm^2]
%   opts : optimizer option
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
lb = 0.5 * ones(3,1);  % set min skin thickness [mm]
ub = 10^3 * ones(3,1); % set max skin thickness [mm]

% call fmincon
[thickness,fval,exitflag,output] = fmincon(objf,t0,[],[],[],[],lb,ub,cfun,opts);

% ... nested functions below ...
    % ===== objective function ===== %
    function [fval] = objfun(thickness)        
        % check if computation is necessary
        if ~isequal(thickness,tLast)
            % if t is not equal to tLast, calculate shear along span
            [fvalLast, cLast] = calc_shear_func(thickness,G,spanwise_steps,b,taumax,componentname);
            tLast = thickness;
        end
        % return objective function value
        fval = fvalLast;
        c = cLast;
    end

    % ===== non-linear constraint function ===== %
    function [c,ceq] = nlcon(thickness)
        % check if computation is necessary
        if ~isequal(thickness,tLast)
            % if t is not equal to tLast, calculate shear along span
            [fvalLast, cLast] = calc_shear_func(thickness,G,spanwise_steps,b,taumax,componentname);
            tLast = thickness;
        end
        % return objective function value
        fval = fvalLast;
        c = cLast;
        ceq = []; % no equality constraints
    end
    
end


