function [] = sfbm_originalplot(SFBMout)
% input structure output of SFBM including: 
%   [SFBMout.y, SFBMout.shearF, SFBMout.BM] = SFBM(...);
% SYNTAX: sfbm_originalplot(SFBMout)

figure(1001)
subplot(1,2,1)
plot(SFBMout.y, SFBMout.shearF/1000)
grid on;
ylabel('Shear force [kN]')
xlabel('Spanwise location [m]')

subplot(1,2,2)
plot(SFBMout.y, SFBMout.BM/1000)
grid on;
ylabel('Bending moment [kN.m]')
xlabel('Spanwise location [m]')

improvePlot;

end