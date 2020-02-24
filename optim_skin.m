%% Skin thickness optimization
% Yuri Shimane, 2020/02/24

%% Load information from sims.m
clear;
sims;  % run sims.m
close all;
disp('Optimization of skin thicknesses...')

%% Double-cell wing torque / bending moment
% skin thickness - variable!
tw = 1.6;  % [mm]
tn = 1.2;  % [mm]
tr = 1.2;  % [mm]

% material parameter
G = 25000;     % shear modulus [N/mm^2]
% G = G_Nmm * 10^6;  % convert to SI [N/m^2]

% discretize wing
spanwise_steps = 30;
yloc = linspace(0,b,spanwise_steps);
% initialize
% c_y = zeros(1,spanwise_steps);
% An  = zeros(1,spanwise_steps);
% Ar  = zeros(1,spanwise_steps);
% Sn  = zeros(1,spanwise_steps);
% Sr  = zeros(1,spanwise_steps);
% h_w = zeros(1,spanwise_steps);
% d_fspar = zeros(1,spanwise_steps);

% Iterate over wingspan
for i = 1:1%spanwise_steps
    % chord length at given spanwise location
    c_y(1,i) = c(yloc(1,i), Sw, t, b);   % [m]
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
    lift     = Lift_perSpan(yloc(1,i), b, MTOW, f, n);
    W_struct = struct_weight(tc, yloc(1,i), Sw, t, b, Vw, Ww);
    W_fuel   = fuel_weight(tc, yloc(1,i), Sw, t, b, Vw, Ww);
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
    tau(1,1) = q(1,1) / tn;   % [N/mm^2]
    tau(2,1) = q(2,1) / tr;   % [N/mm^2]
    tau(3,1) = q(3,1) / tw;   % [N/mm^2]
    fprintf('tau [N/mm^2]: \n tau_n = %f\n tau_r = %f\n tau_w = %f\n',tau)
    
    % check:
    check_P = (q(1,1) - q(2,1) - q(3,1))*h_w;
    check_T = 2*An*q(1,1) + 2*Ar*q(2,1);
    
end



    
% need parameters B (boom area), H (spar height), A (enclosed area), T, Sy

% 1. Find torque from bending moment 
% T = 2 * An * qn + 2 * Ar * qr
% 2. Do vertical equilibrium to get another formula
% P = (qn - qw - qr) * hw (P is vertical force)
% 3. final equation for shear flow comes from twist angle
% d(theta)/d(x) is the same => 1/(2GAn) * (Sn * qn/tn + hw * qw /tw) = 1/(2GAn) * (Sr * qr/tr + hw * qw /tw)
% From here, we can construct a matrix equation for qn, qw, qr and solve along for the shear flow, and compare it to the material selection

