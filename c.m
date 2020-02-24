function out = c(y, Sw, t, b)
    % Chord length at y
    out = (2 * Sw)/((1 + t) * b) * (1 - (1 - t)/(b) .* (2 .* y));
end