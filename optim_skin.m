%% find torque and bending momment (double cell tube calculation)
% skin thickness otpimization

% % house keep
clear; clc;
sims;
close all;

% skin thickness - variable!
tw = 0;
tn = 0;
tr = 0;

% material parameter
G_Nmm = 25000;     % shear modulus [N/mm^2]
G = G_Nmm * 10^6;  % convert to SI [N/m^2]

% discretize wing
spanwise_steps = 30;
yloc = linspace(0,b,spanwise_steps);
% initialize
c_y = zeros(1,spanwise_steps);
An  = zeros(1,spanwise_steps);
Ar  = zeros(1,spanwise_steps);
h_w = zeros(1,spanwise_steps);
d_fspar = zeros(1,spanwise_steps);

% Iterate over wingspan
for i = 1:spanwise_steps
    % chord length at given spanwise location
    c_y(1,i) = c(yloc(1,i), Sw, t, b);
    % An : nose cell area, between 0 and fspar
    An(1,i) = afarea(afpoly,tc,c_y(1,i),fspar);
    % Ar : rectangular cell area, between fspar and bspar
    Ar(1,i) = afarea(afpoly,tc,c_y(1,i),bspar) - An(1,i);
    
    % compute cell circumference Sn, Sr
    
    
    % compute front spar height (at fspar location)
    h_w(1,i) = sparheight_calc(afpoly,c_y(1,i),fspar);
    
    % compute distance from front spar to shear-centre
    sc_frac = (fspar + bspar)/2;
    d_fspar(1,i) = (sc_frac - fspar)*c_y(1,i);
    
    % compute load per unit span
    lift     = Lift_perSpan(yloc(1,i), b, MTOW, f, n);
    W_struct = struct_weight(yloc(1,i), Sw, t, b, Vw, Ww);
    W_fuel   = fuel_weight(yloc(1,i), Sw, t, b, Vw, Ww);
    % compute distance from leading-edge to acting point of loads
    d_lift = 0.25 * c_y(1,i);  % lift acting at quarter-chord point
    d_Wstruct = afcx * c_y(1,i); % structural weight acting point
    d_Wfuel   = aff * c_y(1,i);  % fuel acting at shear-centre (assumption)
    % compute distance from leading-edge to shear-centre
    d_sc = aff * c_y(1,i);
    % compute rhs vector of loads (and torque)
    rhs_load = loadcalc(M0,lift,d_lift,W_struct,d_Wstruct,W_fuel,d_Wfuel,d_sc);
    
    % build matrix relating shear flow and loads
    % WILL HAVE ISSUES!!! Havent defined Sn, Sr
     [~, invdcmat] = doublecellmat(Ar(1,i),An(1,i),tw,tn,tr,Sn,Sr,h_w(1,i),G);
    
    % compute shear flow 
%     q = invdcmat * rhs_loads; 
          
    
end



    
% need parameters B (boom area), H (spar height), A (enclosed area), T, Sy

% 1. Find torque from bending moment 
% T = 2 * An * qn + 2 * Ar * qr
% 2. Do vertical equilibrium to get another formula
% P = (qn - qw - qr) * hw (P is vertical force)
% 3. final equation for shear flow comes from twist angle
% d(theta)/d(x) is the same => 1/(2GAn) * (Sn * qn/tn + hw * qw /tw) = 1/(2GAn) * (Sr * qr/tr + hw * qw /tw)
% From here, we can construct a matrix equation for qn, qw, qr and solve along for the shear flow, and compare it to the material selection

