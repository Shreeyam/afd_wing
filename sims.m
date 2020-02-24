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
    load = L(y, b/2, MTOW, f, n) + struc(y, Sw, t, b/2, Vw, Ww) + fuel(y, Sw, t, b/2, Vw, Ww);
elseif strcmp(componentname,'htail')
    load = L(y, b/2, MTOW, f, n) + struc(y, Sw, t, b/2, Vw, Ww);
end

%% Torsion
% wing
if strcmp(componentname,'wing')
    airfoil = readtable('sc20714.dat', 'HeaderLines', 3);
% h-tail
elseif strcmp(componentname,'htail')
    airfoil = readtable('n0012.dat', 'HeaderLines', 3);
end

afx = airfoil.Var1;
afy = airfoil.Var2;

afx(length(afx)/2:end) = afx(end:-1:length(afx)/2);
afy(length(afx)/2:end) = afy(end:-1:length(afx)/2);

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

%% find torque and bending momment
% An : nose cell area, between 0 and fspar
% Ar : rectangular cell area, between fspar and bspar
    
    
% need parameters B (boom area), H (spar height), A (enclosed area), T, Sy

% 1. Find torque from bending moment 
% T = 2 * An * qn + 2 * Ar * qr
% 2. Do vertical equilibrium to get another formula
% P = (qn - qw - qr) * hw (P is vertical force)
% 3. final equation for shear flow comes from twist angle
% d(theta)/d(x) is the same => 1/(2GAn) * (Sn * qn/tn + hw * qw /tw) = 1/(2GAn) * (Sr * qr/tr + hw * qw /tw)
% From here, we can construct a matrix equation for qn, qw, qr and solve along for the shear flow, and compare it to the material selection



%% Nested function

function out = L(y, b, MTOW, f, n)
    % TODO: Justify values of safety and load factor. From the report?
    out = (2 * f * n * MTOW)/(pi * b^2) .* sqrt(b^2 - y.^2);
end

function out = c(y, Sw, t, b)
    out = (2 * Sw)/((1 + t) * b) * (1 - (1 - t)/b .* y);
end

function out = vfrac(y, Sw, t, b, Vw)
    out = (c(y, Sw, t, b) .* 2)/(Vw);
end

function out = struc(y, Sw, t, b, Vw, Ww)
    out = vfrac(y, Sw, t, b, Vw) * -Ww;
end

function out = fuel(y, Sw, t, b, Vw, Wf)
    out = vfrac(y, Sw, t, b, Vw) * -Wf;
end