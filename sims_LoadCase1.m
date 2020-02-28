%% sims - LOAD CASE 1
% Housekeeping
clc;
close all;
clear;
addpath(genpath('./SFBM'))

%% Parameters
Vinf = 237.4; % cruise velocity [m/s]
ac;
wing;
% htail;
% vtail;

%% Discretisation

n = 10;
load_factor = 2.5;
y = linspace(0, b/2, n);

% Fuel y - assume 10% b penalty

%% Forces
if strcmp(componentname,'wing')
    load = Lift_perSpan(y, b/2, MTOW, f, load_factor) + struct_weight(tc, y, Sw, t, b/2, Vw, Ww) + fuel_weight(tc, y, Sw, t, b/2, Vw, Ww);
elseif strcmp(componentname,'htail')
    tailload = 0.5 * 0.3796 * Vinf^2 * CL_tail^2;
    load = Lift_perSpan(y, b/2, tailload, f, load_factor) + struct_weight(tc, y, Sw, t, b/2, Vw, Ww);
elseif strcmp(componentname,'vtail')
    load = struct_weight(tc, y, Sw, t, b/2, Vw, Ww);
end

% plot total lift
lifttest = Lift_perSpan(y, b/2, MTOW, f, load_factor);
figure(105)
plot(y,lifttest);
xlabel('Span [m]'); ylabel('Lift [N]')
improvePlot;   % --- how do I run this?
% calculate just lift force --- this gives value for both wings..??
Lift_total_N = trapz(y,lifttest);
% calculate just weight
weighttest = struct_weight(tc, y, Sw, t, b/2, Vw, Ww);
weight_total_N = trapz(y,weighttest);


%% Torsion
% wing case
if strcmp(componentname,'wing')
    airfoil = readtable('sc20714.dat', 'HeaderLines', 3);
% h-tail case
else %elseif strcmp(componentname,'htail')
    airfoil = readtable('n0012.dat', 'HeaderLines', 3);
end

afx = airfoil.Var1;
afy = airfoil.Var2;

afx(length(afx)/2:end) = afx(end:-1:length(afx)/2);
afy(length(afx)/2:end) = afy(end:-1:length(afx)/2);

% create polyshape object from x, y coordinates
afpoly = polyshape(afx, afy);

% Centre of structural mass - structural weight acting point
[afcx, afcy] = centroid(afpoly);

% Centre of flexure (flexural axis) - shear centre
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

[SFBMout.y, SFBMout.shearF, SFBMout.BM] = SFBM('Athena Wing',[b/2, 0],{'DF',load,y});
dirname = strcat('loadcase1_',componentname,'.mat');
save(dirname,'SFBMout')
sfbm_originalplot(SFBMout)

%% find torque and bending momment (double cell tube calculation)

    
% need parameters B (boom area), H (spar height), A (enclosed area), T, Sy

% 1. Find torque from bending moment 
% T = 2 * An * qn + 2 * Ar * qr
% 2. Do vertical equilibrium to get another formula
% P = (qn - qw - qr) * hw (P is vertical force)
% 3. final equation for shear flow comes from twist angle
% d(theta)/d(x) is the same => 1/(2GAn) * (Sn * qn/tn + hw * qw /tw) = 1/(2GAn) * (Sr * qr/tr + hw * qw /tw)
% From here, we can construct a matrix equation for qn, qw, qr and solve along for the shear flow, and compare it to the material selection




