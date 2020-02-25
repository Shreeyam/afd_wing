%% Shear load calculation
% Yuri Shimane, 2020/02/24

%% Load information from sims.m
clear;
sims;  % run sims.m
close all;
tic;
disp('Optimization of skin thicknesses...')

%% Double-cell wing torque / bending moment
% skin thickness - variable!
tn = 1.2;  % [mm]
tr = 1.2;  % [mm]
tw = 1.5;  % [mm] must take all the bending moment load!

% material parameter
G = 25000;     % shear modulus [N/mm^2]

% discretize wing
spanwise_steps = 30;
yloc = linspace(0,b/2,spanwise_steps);
% initialize
% c_y = zeros(1,spanwise_steps);
% An  = zeros(1,spanwise_steps);
% Ar  = zeros(1,spanwise_steps);
% Sn  = zeros(1,spanwise_steps);
% Sr  = zeros(1,spanwise_steps);
% h_w = zeros(1,spanwise_steps);
% d_fspar = zeros(1,spanwise_steps);

% Iterate over wingspan
for i = 1:spanwise_steps
    % chord length at given spanwise location
    c_y(1,i) = chord_y(yloc(1,i), Sw, t, b/2);   % [m]
    % An : nose cell area, between 0 and fspar
    An(1,i) = afarea(afpoly,tc,c_y(1,i),fspar) * 10^6;  % [mm^2]
    % Ar : rectangular cell area, between fspar and bspar
    Ar(1,i) = afarea(afpoly,tc,c_y(1,i),bspar) * 10^6 - An(1,i) ;  % [mm^2]
    
    % compute cell circumference Sn, Sr
    Sn(1,i) = cell_circumference(afpoly,c_y(1,i),fspar) * 10^3; % [mm]
    Sr(1,i) = cell_circumference(afpoly,c_y(1,i),1) * 10^3 - Sn(1,i); % [mm]
    
    % compute front spar height (at fspar location)
    h_w(1,i) = sparheight_calc(afpoly,c_y(1,i),fspar) * 10^3; % [mm]
    
    % compute distance from front spar to shear-centre
%     sc_frac = (fspar + bspar)/2;
%     d_fspar(1,i) = (sc_frac - fspar)*c_y(1,i); % [m]
    
    % compute load per unit span
    lift     = Lift_perSpan(yloc(1,i), b/2, MTOW, f, n);
    W_struct = struct_weight(tc, yloc(1,i), Sw, t, b/2, Vw, Ww);
    W_fuel   = fuel_weight(tc, yloc(1,i), Sw, t, b/2, Vw, Ww);
    % compute distance from leading-edge to acting point of loads
    d_lift = 0.25 * c_y(1,i);  % lift acting at quarter-chord point
    d_Wstruct = afcx * c_y(1,i); % structural weight acting point
    d_Wfuel   = aff * c_y(1,i);  % fuel acting at shear-centre (assumption)
    % compute distance from leading-edge to shear-centre
    d_sc = aff * c_y(1,i);
    % compute rhs vector of load [N] (and torque [Nm])
    rhs_load = loadcalc(M0,lift,d_lift,W_struct,d_Wstruct,W_fuel,d_Wfuel,d_sc);
    % convert unit
    rhs_load(1,1) = rhs_load(1,1) * 10^3; % [N.mm]
    
    % build matrix relating shear flow and loads
    [dcmat, invdcmat] = doublecellmat(Ar(1,i),An(1,i),tw,tn,tr,Sn(1,i),Sr(1,i),h_w(1,i),G);
    
    % compute shear flow in order : n, r, w
    q = invdcmat * rhs_load; 
          
    % compute shear in orde : n, r, w
    tau(1,i) = q(1,1) / tn;   % [N/mm^2]
    tau(2,i) = q(2,1) / tr;   % [N/mm^2]
    tau(3,i) = q(3,1) / tw;   % [N/mm^2]
    fprintf('tau [N/mm^2]: \n tau_n = %f\n tau_r = %f\n tau_w = %f\n',tau)
    
    % check:
    check_P = (q(1,1) - q(2,1) - q(3,1))*h_w;
    check_T = 2*An*q(1,1) + 2*Ar*q(2,1);
    
    % calculate volume per unit span
    vol_skin_per_span(1,i) = tn * Sn(1,i);  % [mm^3]
    vol_skin_per_span(2,i) = tr * Sr(1,i);  % [mm^3]
    vol_skin_per_span(3,i) = tw * h_w(1,i); % [mm^3]
    vol_totalskin_per_span = vol_skin_per_span(1,i) + ...
        vol_skin_per_span(2,i) + vol_skin_per_span(3,i);  % [mm^3]
    
end


%% Run optimizer for tn, tr, tw
disp('Optimizing...')
optstart = toc;
% initial guess
t0 = [tn; tr; tw];
% Yield strength [N/mm^2]
sigma_yield = 289; % [MPa] Aluminium 2024-t3
% Max. shear strength [N/mm^2]
UTS = 434; % [MPa] Aluminium 2024-t3:
% https://web.archive.org/web/20060827072154/http://www.alcoa.com/mill_products/catalog/pdf/alloy2024techsheet.pdf
taumax = 0.65*UTS;   % https://en.wikipedia.org/wiki/Shear_strength
% densities
dens_n = 2700 * 10^-9; % [kg/mm^3]
dens_r = 2700 * 10^-9; % [kg/mm^3]
dens_w = 2700 * 10^-9; % [kg/mm^3]

% define number of discretization step along wing
spanwise_steps = 30;

% optimizer option
opts = optimoptions('fmincon','Display','iter','MaxFunctionEvaluations',200,...
        'MaxIterations',5e2,'ConstraintTolerance',1.0000e-02,...
        'FiniteDifferenceType','forward','FiniteDifferenceStepSize',1e-8);

[topt,fval,exitflag,output,cineq] = ...
    optim_skin(t0,b,G,taumax,spanwise_steps,componentname,opts,dens_n,dens_r,dens_w,...
    Sw, t, afpoly, tc, fspar, bspar, MTOW, f, n, Vw, Ww, afcx, aff, M0, ...
    SFBMout, sigma_yield);
% Iter displays: https://uk.mathworks.com/help/optim/ug/iterative-display.html#f92519
% Feasibility > Maximum constraint violation, where satisfied inequality constraints count as 0
% First-order optim > First-order optimality measure (should be 0)

optend = toc;

% optimal thickness: [10.5345; 1.1479; 12.3411] [mm]
fprintf('Optimization took %f sec\n',optend - optstart);  % 245 seconds...
fprintf('Optimal thicknesses [mm]: \n tn = %f\n tr = %f\n tw = %f\n',topt);
fprintf('Total mass required: %f [kg]\n',fval)

