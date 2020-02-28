%% Plotting load cases

% house keep
clear; close all; clc;

% load data 1
load('loadcase1_wing.mat')

figure(1002)
subplot(1,2,1)
plot(SFBMout.y, SFBMout.shearF/1000,'-o')
hold on
grid on;
ylabel('Shear force [kN]')
xlabel('Spanwise location [m]')

subplot(1,2,2)
plot(SFBMout.y, SFBMout.BM/1000,'-o')
hold on
grid on;
ylabel('Bending moment [kN.m]')
xlabel('Spanwise location [m]')

% load data 1
load('loadcase2_wing.mat')
figure(1002)
subplot(1,2,1)
plot(SFBMout.y, SFBMout.shearF/1000,'-x')
hold on
grid on;
ylabel('Shear force [kN]')
xlabel('Spanwise location [m]')

subplot(1,2,2)
plot(SFBMout.y, SFBMout.BM/1000,'-x')
hold on
grid on;
ylabel('Bending moment [kN.m]')
xlabel('Spanwise location [m]')

%improvePlot;

