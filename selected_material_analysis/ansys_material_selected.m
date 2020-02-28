%% selected material analysis

% house keeping
clear; 
close all;
clc;
addpath('../');

component = 'htail';

if strcmp(component,'wing')
    load('optskins_workspace_wing_al7044t7751.mat');
elseif strcmp(component,'htail')
    load('optskins_workspace_htail_al7044t7751.mat');
elseif strcmp(component,'vtail')
    load('optskins_workspace_vtail_al7044t7751.mat');
end
% store thicknesses
tn_al = topt(1:spanwise_steps,1);
tr_al = topt(spanwise_steps+1:2*spanwise_steps,1);
tw_al = topt(2*spanwise_steps+1:3*spanwise_steps,1);
% plot skin thickness
% discretize wing
yloc_al = linspace(0,b/2,spanwise_steps); % [m]
save('alum_data.mat','yloc_al','tn_al','tr_al','tw_al');

clear;

%% cfrp
component = 'htail';

if strcmp(component,'wing')
    load('optskins_workspace_wing_cfrpwovenqi.mat');
elseif strcmp(component,'htail')
    load('optskins_workspace_htail_cfrpwovenqi.mat');
elseif strcmp(component,'vtail')
    load('optskins_workspace_vtail_cfrpwovenqi.mat');
end

% store thicknesses
tn_cf = topt(1:spanwise_steps,1);
tr_cf = topt(spanwise_steps+1:2*spanwise_steps,1);
tw_cf = topt(2*spanwise_steps+1:3*spanwise_steps,1);
% plot skin thickness
% discretize wing
yloc_cf = linspace(0,b/2,spanwise_steps); % [m]

% cfrp - data correction
if strcmp(component,'htail')
    tn_cf(3,1) = tn_cf(3,1) * 1/4;
    tr_cf(3,1) = tr_cf(3,1) * 1/4;
    tw_cf(3,1) = tw_cf(3,1) * 1/4;
elseif strcmp(component,'vtail')
    tn_cf(2,1) = tn_cf(2,1) * 1/6;
    tr_cf(2,1) = tr_cf(2,1) * 1/6;
    tw_cf(2,1) = tw_cf(2,1) * 1/6;
end

save('cfrp_data.mat','yloc_cf','tn_cf','tr_cf','tw_cf');
clear;
%% Load data re-generated
load('alum_data.mat');
load('cfrp_data.mat')



%% plot
figure(11)
clf
hold on
% alum
plot(yloc_al,tn_al,'-','color','#0072BD')
plot(yloc_al,tr_al,'-','color','#D95319')
plot(yloc_al,tw_al,'-','color','#77AC30')
% cfrp
plot(yloc_cf,tn_cf,':b')
plot(yloc_cf,tr_cf,':r')
plot(yloc_cf,tw_cf,':g')
xlabel('Spanwise location [m]'); ylabel('Thickness [mm]');
legend('Al t_n','Al t_r','Al t_w','Comp t_n','Comp t_r','Comp t_w')
improvePlot();



