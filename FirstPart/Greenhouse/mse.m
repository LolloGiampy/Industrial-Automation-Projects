function mse = mse(eTempModule)
%Compute the Mean Square Error (MSE) of the module 
% temperature with respect to the desired one
%Input
% eTempModule : error of the module temperature with respect to the desired
% one over the simulation horizon
mse = mean((eTempModule).^2);
end