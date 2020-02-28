%% Shear load calculation
% house keeping
clear;
tic;
% ============ MODIFY ============ %
% Load information from sims.m
sims_LoadCase2;  % run appropriate load case
close all;       % closing plots since they clutter the screen...
al6061t6;        % choose appropriate material
% define number of discretization step along wing
spanwise_steps = 9; % modify to number of ribs 16 / 9 / 2
% MIN NOSE CELL THICKNESS
tncon = 2.6; % [mm]
% Max. number of function evaluation by fmincon for skin thicknesses optim.
maxfunceval = 2000;
% ================================ %

% run Bending Moment optimizer, which returns min. condition (usually 1mm) for tw as variable twopt
calc_twBM;

disp('Optimization of skin thicknesses...')

%% Run optimizer for tn, tr, tw
close all;  % close figures...
disp('Optimizing for tn,tr,tw...')
optstart = toc;
% initial guess
t0 = [tncon * ones(spanwise_steps,1); 
      1 * ones(spanwise_steps,1);      % free EXCEPT IN LOAD CASE 3?
      twopt * ones(spanwise_steps,1)];
% densities
dens_n = density_kgm3 * 10^-9; % [kg/mm^3]
dens_r = density_kgm3 * 10^-9; % [kg/mm^3]
dens_w = density_kgm3 * 10^-9; % [kg/mm^3]

% optimizer option
opts = optimoptions('fmincon','Display','iter','MaxFunctionEvaluations',maxfunceval,...
        'MaxIterations',3e2,'ConstraintTolerance',1e-01,...
        'FiniteDifferenceType','forward','FiniteDifferenceStepSize',1e-8);

[topt,fval,exitflag,output,cineq] = ...
    optim_skin(t0,b,G,taumax,spanwise_steps,componentname,opts,dens_n,dens_r,dens_w,...
    Sw, t, afpoly, tc, fspar, bspar, MTOW, f, n, Vw, Ww, afcx, aff, M0);
% Iter displays: https://uk.mathworks.com/help/optim/ug/iterative-display.html#f92519
% Feasibility > Maximum constraint violation, where satisfied inequality constraints count as 0
% First-order optim > First-order optimality measure (should be 0)

optend = toc;
% optimal thickness
fprintf('Optimization took %f sec\n',optend - optstart);
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
workspacename = strcat('optskins_workspace_',componentname,'_',materialname);
save( workspacename );


