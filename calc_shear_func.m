function [fval, c_ineq] = ...
    calc_shear_func(thickness,G,spanwise_steps,b,taumax,componentname,dens_n,dens_r,dens_w,...
    Sw, t, afpoly, tc, fspar, bspar, MTOW, f, n, Vw, Ww, afcx, aff, M0)
% Function called within optim_skin for skin optimization

% deconstruct thickness by components
tn = thickness(1:spanwise_steps, 1);  % [mm]
tr = thickness(spanwise_steps+1:2*spanwise_steps, 1);  % [mm]
tw = thickness(2*spanwise_steps+1:3*spanwise_steps, 1);  % [mm]

% discretize wing
yloc = linspace(0,b/2,spanwise_steps); % [m]

% initialize
c_y = zeros(1,spanwise_steps-1);
An  = zeros(1,spanwise_steps-1);
Ar  = zeros(1,spanwise_steps-1);
Sn  = zeros(1,spanwise_steps-1);
Sr  = zeros(1,spanwise_steps-1);
h_w = zeros(1,spanwise_steps-1);

% d_fspar = zeros(1,spanwise_steps);
vol_skin_per_span = zeros(3,spanwise_steps-1);
vol_totalskin_per_span = zeros(1,spanwise_steps-1);
c_ineq = zeros((spanwise_steps-1)*3,1);
ii = 1;
% Iterate over wingspan
for i = 1:spanwise_steps-1   % work only up to right before tip to avoid matrix singularity
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
    
    % compute load per unit span [N]
    lift     = Lift_perSpan(yloc(1,i), b/2, MTOW, f, n);
    W_struct = struct_weight(tc, yloc(1,i), Sw, t, b/2, Vw, Ww);
    W_fuel   = fuel_weight(tc, yloc(1,i), Sw, t, b/2, Vw, Ww);
    % compute distance from leading-edge to acting point of loads
    d_lift    = 0.25 * c_y(1,i);    % lift acting at quarter-chord point
    d_Wstruct = afcx * c_y(1,i); % structural weight acting point
    d_Wfuel   = aff * c_y(1,i);  % fuel acting at shear-centre (assumption)
    % compute distance from leading-edge to shear-centre
    d_sc = aff * c_y(1,i);
    % compute rhs vector of load [N] (and torque [Nm])
    rhs_load = loadcalc(M0,lift,d_lift,W_struct,d_Wstruct,W_fuel,d_Wfuel,d_sc);
    % convert units for torque -- shuold be [e7, e4, 0]
    rhs_load(1,1) = rhs_load(1,1) * 10^3; % [N.mm]
    
    % build matrix relating shear flow and loads
    [dcmat, invdcmat] = doublecellmat(Ar(1,i),An(1,i),tw(i,1),tn(i,1),tr(i,1),Sn(1,i),Sr(1,i),h_w(1,i),G);
    
    % compute shear flow in order : n, r, w
    q(:,i) = invdcmat * rhs_load; 
          
    % compute shear in order : n, r, w
    tau(1,1) = q(1,i) / tn(i,1);   % [N/mm^2]
    tau(2,1) = q(2,i) / tr(i,1);   % [N/mm^2]
    tau(3,1) = q(3,i) / tw(i,1);   % [N/mm^2]

    % check:
    check_T = 2*An(1,i)*q(1,i) + 2*Ar(1,i)*q(2,i);  % --- rhs_load(1,1)
    check_P = (q(1,i) - q(2,i) - q(3,i))*h_w(1,i);  % --- rhs_load(2,1)
    
    % calculate volume per unit span
    vol_skin_per_span(1,i) = tn(i,1) * Sn(1,i);  % [mm^2]
    vol_skin_per_span(2,i) = tr(i,1) * Sr(1,i);  % [mm^2]
    vol_skin_per_span(3,i) = tw(i,1) * h_w(1,i); % [mm^2]
    vol_totalskin_per_span(1,i) = vol_skin_per_span(1,i) + ...
                vol_skin_per_span(2,i) + vol_skin_per_span(3,i);  % [mm^2]
    
    % ===== NON-LINEAR INEQUALITY CONSTRAINTS ===== %   
    % calculate shear constraints on tn, tr, tw
    c_ineq(ii,1) = abs(tau(1,1)) - taumax;
    ii = ii + 1; % update ii
    c_ineq(ii,1) = abs(tau(2,1)) - taumax;
    ii = ii + 1; % update ii
    c_ineq(ii,1) = abs(tau(3,1)) - taumax;
    ii = ii + 1; % update ii
    
end

% figure(102)
% hold on
% plot(yloc(1:29),abs(q(1,:)))
% plot(yloc(1:29),abs(q(2,:)))
% plot(yloc(1:29),abs(q(3,:)))
% yline(taumax,'--k');

% compute volume per part (multiply by unit span) [mm^3] !b is in meters!
vol_per_skin = ((b*10^3/2)/spanwise_steps) * [sum(vol_skin_per_span(1,:));  % should be to e7
                sum(vol_skin_per_span(2,:));
                sum(vol_skin_per_span(3,:))];

% compute mass [kg]; density is in [kg/mm^3] * [mm^3]
mass_per_skin = [dens_n * vol_per_skin(1,1);
                 dens_r * vol_per_skin(2,1);
                 dens_w * vol_per_skin(3,1)];
             
% objective function is my total mass
fval = sum(mass_per_skin);

end
