function [dcmat, invdcmat] = doublecellmat(Ar,An,tw,tn,tr,Sn,Sr,h_w,G)
% Function computes double-cell matrix and its inverse to solve 
% shear flow in aircraft wing
% Yuri Shimane. 2020/02/24
% =================================================== %
% FORMAT : [dcmat, invdcmat] = doublecellmat(Ar,An,tw,tn,tr,d,P,Sn,Sr,h_w,G,T)
% INPUT :
%   (many)
% OUTPUT :
%   dcmat : 3x3 matrix, dcmat * q = Loads
%   invdcmat : inverse of dcmat, solves for shear flows [qn, qr qw]'
%   load rhs : load right hand side
% =================================================== %

% first row of matrix
eq1 = [2*An, 2*Ar, 0];

% second row of matrix
eq2 = [h_w, -h_w, -h_w];

% third row of matrix
eq31 =  ( 1/(2*G*An) ) * (Sn/tn);
eq32 = -Sr/tr * 1/(2*G*Ar);
eq33 =  ( h_w/(2*tw*G) ) * (1/An + 1/Ar);
eq3 = [eq31, eq32, eq33];

% construct matrix dcmat
dcmat = [eq1; eq2; eq3];

% invert matrix dcmat
invdcmat = inv(dcmat);

end


