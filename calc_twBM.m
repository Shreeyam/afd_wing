%% script calls fmincon function for optimizing front-spar thickness over BM const.
% Load information from sims.m
clear;
sims_LoadCase1;  % run sims.m
close all;
tic;

disp('Optimization of skin thickness of front spar...')

%% Run optimizer
% optimizer option
opts = optimoptions('fmincon','Display','iter','MaxFunctionEvaluations',200,...
        'MaxIterations',5e2,'ConstraintTolerance',1.0000e-02,...
        'FiniteDifferenceType','forward','FiniteDifferenceStepSize',1e-8);
% initial guess
tw0 = 1.2; % [mm]
% call material
al2024t3;
spanwise_steps = 30;
[twopt,fval,exitflag,output] = ...
    optim_twBM(tw0,sigma_yield,SFBMout,spanwise_steps,Sw,t,b,fspar,afpoly,opts);
fprintf('Requirement on front spar thickness tw: %f [mm]\n',fval)


