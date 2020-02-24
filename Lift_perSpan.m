function out = Lift_perSpan(y, b, MTOW, f, n)
% function computes lift per unit span
% FORMAT : out = Lift_perSpan(y, b, MTOW, f, n)
    % TODO: Justify values of safety and load factor. From the report?
    out = (2 * f * n * MTOW)/(pi * b^2) .* sqrt(b^2 - y.^2);
end