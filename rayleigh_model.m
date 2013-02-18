% Rayleigh model for segmentation of background noise
function yhat = rayleigh_model(beta, x)

% Set parameters
b1=beta(1);
b2=beta(2);
b3=beta(3);

% Calculate function value
yhat=(b3*x+b1).*exp(-(b3*x+b1).^2/(2*b2.^2))./b2.^2;