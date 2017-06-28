function [gx] = emission_f(x,P,u,in)
% get likelihood for model
% data
beta = 1/(cdf('Normal',P(1),0,1)*0.8 + 0.2); % 1/P(1);

p_0   = 1/(1 + exp(-beta*(x(1) - x(2))));

gx    = 1 - p_0;
end

 