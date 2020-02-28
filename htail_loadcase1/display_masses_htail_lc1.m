%% display masses
% house keep
clear; close all; clc;

% load data
load('optskins_workspace_htail_al2024t3.mat')
fprintf('%s: %f [kg]\n',materialname,fval)
clear;
load('optskins_workspace_htail_al6061t6.mat')
fprintf('%s: %f [kg]\n',materialname,fval)
clear;
load('optskins_workspace_htail_al7044t7751.mat')
fprintf('%s: %f [kg]\n',materialname,fval)
clear;
load('optskins_workspace_htail_al7075t6.mat')
fprintf('%s: %f [kg]\n',materialname,fval)
clear;
load('optskins_workspace_htail_al8090t851.mat')
fprintf('%s: %f [kg]\n',materialname,fval)
clear;
load('optskins_workspace_htail_cfrpwovenqi.mat')
fprintf('%s: %f [kg]\n',materialname,fval)
clear;

% plot
