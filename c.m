function out = c(y, Sw, t, b)
    out = (2 * Sw)/((1 + t) * b) * (1 - (1 - t)/b .* y);
end