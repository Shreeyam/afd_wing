function [twopt,fval,exitflag,output] = ...
    optim_twBM(tw0,sigma_yield,SFBMout,spanwise_steps,Sw,t,b,fspar,afpoly,opts)
% Function optimizes tw [mm] that can withstand bending moment
% Yuri Shimane, 2020/02/25

% declare global variables for speed
twLast = [];
fvalLast = [];
cLast = [];

% objective function, nested below
objf = @objfun;
% constraint function, nested below
cfun = @nlcon;
% lower and upper bounds
lb = 1;    % set min skin thickness [mm]
ub = 10^3; % set max skin thickness [mm]

% call fmincon
[twopt,fval,exitflag,output] = fmincon(objf,tw0,[],[],[],[],lb,ub,cfun,opts);


% NESTED FUNCTIONS
    % objective function
    function fval = objfun(tw)
        fval = tw;
    end
    
    % non-linear constraints
    function  [c,ceq] = nlcon(tw)
        % discretize wing
        yloc = linspace(0,b/2,spanwise_steps);
        
        % prepare bending moment constraint on tw... interpolate bending moment
        % ... might need fixing for htail?
        p = polyfit(SFBMout.y(3:length(SFBMout.y),1),SFBMout.BM(3:length(SFBMout.y),1),4);
        BM_at_yloc = polyval(p,yloc)';  % [kN.m]
        % convert to Nmm
        BM_at_yloc = BM_at_yloc * 10^3; % [N.m]
        BM_at_yloc = BM_at_yloc / 10^3; % [N.mm]
        
        % initialize
        c   = zeros(spanwise_steps-1,1);
        c_y = zeros(1, spanwise_steps-1);
        h_w = zeros(1, spanwise_steps-1);
        Iyy = zeros(1, spanwise_steps-1);
        for i = 1:spanwise_steps-1
            % chord length at given spanwise location
            c_y(1,i) = chord_y(yloc(1,i), Sw, t, b/2);   % [m]
            % compute front spar height (at fspar location)
            h_w(1,i) = sparheight_calc(afpoly,c_y(1,i),fspar) * 10^3; % [mm]
            % compute Iyy
            Iyy(1,i) = wingIyy(100,20,h_w(1,i),tw); % [mm^4]
            % compute inequality condition
            c(i,1) = abs( BM_at_yloc(i,1) * tw / Iyy(1,i) ) - sigma_yield;  
        end
        % no equality constraints
        ceq = [];
    end

end
