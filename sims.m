%% Housekeeping

clc;
close all;
clear;
addpath(genpath('./SFBM'))

%% Parameters
ac;
wing;
% htail;

%% Discretisation

n = 5;
y = linspace(0, b/2, n);

% Fuel y - assume 10% b penalty

%% Forces
if strcmp(componentname,'wing')
    load = Lift_perSpan(y, b/2, MTOW, f, n) + struct_weight(y, Sw, t, b/2, Vw, Ww) + fuel_weight(y, Sw, t, b/2, Vw, Ww);
elseif strcmp(componentname,'htail')
    load = Lift_perSpan(y, b/2, MTOW, f, n) + struct_weight(y, Sw, t, b/2, Vw, Ww);
end

%% Torsion
% wing case
if strcmp(componentname,'wing')
    airfoil = readtable('sc20714.dat', 'HeaderLines', 3);
% h-tail case
elseif strcmp(componentname,'htail')
    airfoil = readtable('n0012.dat', 'HeaderLines', 3);
end

afx = airfoil.Var1;
afy = airfoil.Var2;

afx(length(afx)/2:end) = afx(end:-1:length(afx)/2);
afy(length(afx)/2:end) = afy(end:-1:length(afx)/2);

% create polyshape object from x, y coordinates
afpoly = polyshape(afx, afy);

% Centre of structural mass
[afcx, afcy] = centroid(afpoly);

% Centre of flexure (flexural axis)
aff = (fspar + bspar)/2;

%% Plot torsion

% plotting airfoil
figure; hold on;
plot(afpoly, 'LineWidth', 2.5);
plot(afcx, afcy, 'x');
plot(aff, 0, 'x');
% Spars

grid;
axis equal tight;
improvePlot;

%% Sim

SFBM('Athena Wing',[b/2, 0],{'DF',load,y});

return
%% find torque and bending momment (double cell tube calculation)
% discretize wing
spanwise_steps = 30;
yloc = linspace(0,b,spanwise_steps);
% initialize
c_y = zeros(1,spanwise_steps);
An  = zeros(1,spanwise_steps);
Ar  = zeros(1,spanwise_steps);
h_w = zeros(1,spanwise_steps);
d   = zeros(1,spanwise_steps);
% Iterate over wingspan
for i = 1:spanwise_steps
    % chord length at given spanwise location
    c_y(1,i) = c(yloc(1,i), Sw, t, b);
    % An : nose cell area, between 0 and fspar
    An(1,i) = afarea(afpoly,tc,c_y(1,i),fspar);
    % Ar : rectangular cell area, between fspar and bspar
    Ar(1,i) = afarea(afpoly,tc,c_y(1,i),bspar) - An(1,i);
    % compute front spar height (at fspar location)
    h_w(1,i) = sparheight_calc(afpoly,c_y(1,i),fspar);
    % compute distance to shear centre
    sc_frac = (fspar + bspar)/2;
    d(1,i) = (sc_frac - fspar)*c_y(1,i);
    
    % compute load
    loadcalc(M0,lift,d_lift,W_struct,d_Wstruct,W_fuel,d_fuel,d_sc)
    
    % build matrix relating shear flow and loads 
    % WILL HAVE ISSUES!!! Havent defined Sn, Sr
    [~, invdcmat] = doublecellmat(Ar,An,tw,tn,tr,Sn,Sr,h_w,G);
    
    % shear flow 
    q = invdcmat * rhs_loads; 
    

          
    
end


    
% need parameters B (boom area), H (spar height), A (enclosed area), T, Sy

% 1. Find torque from bending moment 
% T = 2 * An * qn + 2 * Ar * qr
% 2. Do vertical equilibrium to get another formula
% P = (qn - qw - qr) * hw (P is vertical force)
% 3. final equation for shear flow comes from twist angle
% d(theta)/d(x) is the same => 1/(2GAn) * (Sn * qn/tn + hw * qw /tw) = 1/(2GAn) * (Sr * qr/tr + hw * qw /tw)
% From here, we can construct a matrix equation for qn, qw, qr and solve along for the shear flow, and compare it to the material selection




