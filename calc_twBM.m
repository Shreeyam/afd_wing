%% script calls fmincon function for optimizing front-spar thickness over BM const.
% Load information from sims.m
% clear;
% sims_LoadCase1;  % run sims.m
% call material
% al2024t3;
% close all;
% tic;

disp('Optimization of skin thickness of front spar...')

%% Run optimizer
% optimizer option
optsBM = optimoptions('fmincon','Display','iter','MaxFunctionEvaluations',200,...
        'MaxIterations',5e2,'ConstraintTolerance',1.0000e-02,...
        'FiniteDifferenceType','forward','FiniteDifferenceStepSize',1e-8);
% initial guess
tw0BM = 1.2; % [mm]
spanwise_stepsBM = 30;
[twopt,fvalBM,exitflagBM,outputBM] = ...
    optim_twBM(tw0BM,sigma_yield,SFBMout,spanwise_stepsBM,Sw,t,b,fspar,afpoly,optsBM);
fprintf('Requirement on front spar thickness tw: %f [mm]\n',fvalBM)


