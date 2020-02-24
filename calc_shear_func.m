function [fval, c_ineq] = calc_shear_func(thickness,G,spanwise_steps,b,taumax,componentname)
% Function called within optim_skin for skin optimization

% call data
if strcmp(componentname,'wing')
    wing;
elseif strcmp(componentname,'htail')
    htail;
end
% ... very ugly sorry
load('sims_workspace.mat')

% deconstruct thickness by components
tn = thickness(1,1);  % [mm]
tr = thickness(2,1);  % [mm]
tw = thickness(3,1);  % [mm]

% discretize wing
yloc = linspace(0,b,spanwise_steps);
% initialize
c_y = zeros(1,spanwise_steps);
An  = zeros(1,spanwise_steps);
Ar  = zeros(1,spanwise_steps);
Sn  = zeros(1,spanwise_steps);
Sr  = zeros(1,spanwise_steps);
h_w = zeros(1,spanwise_steps);
% d_fspar = zeros(1,spanwise_steps);
vol_skin_per_span = zeros(3,spanwise_steps);
vol_totalskin_per_span = zeros(1,spanwise_steps);
c_ineq = zeros(spanwise_steps*3,1);
ii = 1;
% Iterate over wingspan
for i = 1:spanwise_steps-1   % work only up to right before tip to avoid matrix singularity
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
    [~, invdcmat] = doublecellmat(Ar(1,i),An(1,i),tw,tn,tr,Sn(1,i),Sr(1,i),h_w(1,i),G);
    
    % compute shear flow in order : n, r, w
    q = invdcmat * rhs_load; 
          
    % compute shear in orde : n, r, w
    tau(1,1) = q(1,1) / tn;   % [N/mm^2]
    tau(2,1) = q(2,1) / tr;   % [N/mm^2]
    tau(3,1) = q(3,1) / tw;   % [N/mm^2]
%     fprintf('tau [N/mm^2]: \n tau_n = %f\n tau_r = %f\n tau_w = %f\n',tau)
    
    % check:
%     check_P = (q(1,1) - q(2,1) - q(3,1))*h_w;
%     check_T = 2*An*q(1,1) + 2*Ar*q(2,1);
    
    % calculate volume per unit span
    vol_skin_per_span(1,i) = tn * Sn(1,i);  % [mm^3]
    vol_skin_per_span(2,i) = tr * Sr(1,i);  % [mm^3]
    vol_skin_per_span(3,i) = tw * h_w(1,i); % [mm^3]
    vol_totalskin_per_span(1,i) = vol_skin_per_span(1,i) + ...
    vol_skin_per_span(2,i) + vol_skin_per_span(3,i);  % [mm^3]
    
    % calculate non-linear equality constraints
    c_ineq(ii,1)   = tau(1,1) - taumax;
    ii = ii + 1; % update ii
    c_ineq(ii+1,1) = tau(2,1) - taumax;
    ii = ii + 1; % update ii
    c_ineq(ii+2,1) = tau(3,1) - taumax;
    ii = ii + 1; % update ii
    
end

% compute total volume
fval = sum(vol_totalskin_per_span);

end