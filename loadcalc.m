function load_vect = loadcalc(M0,lift,d_lift,W_struct,d_Wstruct,W_fuel,d_fuel,d_sc)
% Function calculates load vector; torque is about shear-centre (sc)
% Yuri Shimane, 2020/02/24
% ================================================= %
% FORMAT : load_vect = loadcalc(M0,lift,d_lift,W_struct,d_Wstruct,W_fuel,d_fuel,d_sc)
% CAUTION : WEIGHTS SHOULD ALL BE PROVIDED AS POSITIVE VALUES
% CONVENTION : Force +ve upward, Torque +ve counter-clockwise
% INPUT
%   M0        : zero-lift moment of wing
%   lift      : +ve lift force [N]
%   d_lift    : lift force moment acting point from leading edge [m]
%   W_struct  : +ve structural weight [N]
%   d_Wstruct : sructural weight acting point from leading edge [m]
%   W_fuel    : +ve fuel weight [N]
%   d_Wfuel   : fuel weight acting point from leading edge [m]
%   d_sc      : location of shear-centre from leading edge [m]
% OUTPUT
%   load_vect : 3x1 load vector [Torque; Load; 0]
% ================================================= %

% combine loads
Load = lift - W_struct - W_fuel;

% compute sturcture torque
T_struct = -W_struct * (d_Wstruct - d_sc);  % should be +ve
% compute lift torque
T_lift = lift * (d_lift - d_sc);            % should be -ve
% compute fuel torque (0 of d_Wfuel = d_sc)
T_fuel = -W_fuel * (d_fuel - d_sc);         % should be 0

% combine torques
Torque = M0 + T_struct + T_lift + T_fuel;

% construct load vector
load_vect = [Torque; Load; 0];

end