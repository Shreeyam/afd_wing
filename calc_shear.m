%% Shear load calculation
% Yuri Shimane, 2020/02/24

%% Load information from sims.m
clear;
sims;  % run sims.m
%close all;
tic;
disp('Optimization of skin thicknesses...')

%% Run optimizer for tn, tr, tw
close all;  % close figures...
disp('Optimizing for tn,tr,tw...')
optstart = toc;
% define number of discretization step along wing
spanwise_steps = 16; % modify to number of ribs 16 / 9 / 2
% run material property
al2024t3;
% initial guess
t0 = [3.61 * ones(spanwise_steps,1); 
      1 * ones(spanwise_steps,1);
      1 * ones(spanwise_steps,1)];
% densities
dens_n = density_kgm3 * 10^-9; % [kg/mm^3]
dens_r = density_kgm3 * 10^-9; % [kg/mm^3]
dens_w = density_kgm3 * 10^-9; % [kg/mm^3]

% optimizer option
opts = optimoptions('fmincon','Display','iter','MaxFunctionEvaluations',2000,...
        'MaxIterations',1e2,'ConstraintTolerance',1e-01,...
        'FiniteDifferenceType','forward','FiniteDifferenceStepSize',1e-8);

[topt,fval,exitflag,output,cineq] = ...
    optim_skin(t0,b,G,taumax,spanwise_steps,componentname,opts,dens_n,dens_r,dens_w,...
    Sw, t, afpoly, tc, fspar, bspar, MTOW, f, n, Vw, Ww, afcx, aff, M0);
% Iter displays: https://uk.mathworks.com/help/optim/ug/iterative-display.html#f92519
% Feasibility > Maximum constraint violation, where satisfied inequality constraints count as 0
% First-order optim > First-order optimality measure (should be 0)

optend = toc;

% optimal thickness: [10.5345; 1.1479; 12.3411] [mm]
fprintf('Optimization took %f sec\n',optend - optstart);  % 245 seconds...
fprintf('Total mass required: %f [kg]\n',fval)

%% plotting results of skin analysis
% discretize wing
yloc = linspace(0,b/2,spanwise_steps); % [m]
figure(81)
clf
hold on
plot(yloc,topt(1:spanwise_steps,1))
plot(yloc,topt(spanwise_steps+1:2*spanwise_steps,1))
plot(yloc,topt(2*spanwise_steps+1:3*spanwise_steps,1))
xlabel('Spanwise location [m]'); ylabel('Thickness [mm]');
legend('tn','tr','tw')
improvePlot();

% save workspace
save( filename )

