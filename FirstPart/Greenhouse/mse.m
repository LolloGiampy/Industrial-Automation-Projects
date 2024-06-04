function [mse] = mse(expectedTemp,measuredTemp)
    % this function computes the mean square error between two arrays of
    % numbers (in this case temperatures of our modules) 
    sumOfValues = 0;
    for i = 1:length(expectedTemp)
        sumOfValues = sumOfValues + (expectedTemp(i) - measuredTemp(i)).^2;
    end
    mse = sumOfValues/length(expectedTemp);
end

