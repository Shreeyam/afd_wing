%% Housekeeping

clc;
clear;
close all;

%% Load variables

% wing;
htail;
% b = 8;
n_rib = 1:18;
% mac = 1;
% tc = 0.12;

t = 1.2e-3;
% A_d = 0.0036026;

R = mac * 0.5; %sqrt(2 * A_d/pi) * 20;
% R = 1;

%% Structural values

rho_al = 2700; % kg/m^3
rib_thickness = 3e-3;
E = 70e9;
yield_stress = 276e6/2; %0.65 * 289e6;

% a = span length
% b = circumference
% converge on a particular thickness

weight = [];

for n = n_rib
    a = (b/2)/(n + 1);
    bd = 0.25 * mac; % todo: fix

    K = kcalc(a, bd, R, t);
    
    % Critical buckling stress, see until it converges with tresca yield
    % stress (0.65 * UTS)
    tau_cr = K * E * (t/bd)^2;
    t_panel = sqrt(yield_stress * bd^2 / K / E);
%     tcr=max([t, t_panel]);
    tcr = t_panel;
    disp(t_panel);
    weight = [weight, ((2 * mac + (2 * mac * tc)) * b/2 * tcr ...
        + (mac^2 * tc * rib_thickness * n))];
end

plot(n_rib, weight, 'x');

xlabel('N ribs [-]');
ylabel('Normalised weight [-]');

grid;
improvePlot;
    

