function [fx] = transition_f(x,P,u,in)
% get likelihood for model

% a : the actions
% z : the correct actions

fx = x; 
if in.theModel == 0
    alpha_p = cdf('Normal',P(1),0,1); % ./(1+exp(-P(1))); % P(1);
    alpha_m = cdf('Normal',P(1),0,1); % P(1) 
else
    alpha_p = cdf('Normal',P(1),0,1); % 1./(1+exp(-P(1))); % P(1) 
    alpha_m = cdf('Normal',P(2),0,1); % 1./(1+exp(-P(2))); % P(2) 
end


action   = u(1);
high_rew = u(2);


% loglik
if action == high_rew
    fx(action + 1) = x(action + 1) + alpha_p * (1 - x(action + 1));
else
    fx(action + 1) = x(action + 1) + alpha_m * (- 1 - x(action + 1));
end
end

