function  [posterior,out] = invert_VBA(Y,U,theModel)  

% input: subject number, 
% order: 1 if ON first 2 if OFF first 
% COND: 1 for Reward Learning and 2 for Effort learning 
% DISPLAY 1 for display 
% theModel: structure for the model to invert

% OUTPUT : standard inversion output
% - posterior
% - out

% --- loading the data 

Ntrials = size(Y,2); % across all blocks and sessions total 40*8 = 320 trials 
Nsessions = 8; 
ntrial = 25;


% ------------------------------------
% -- Declare initial model

dim_data = 2; 
dim_output = 1; % binary choice output 

% structure for single session 

dim = struct('n',2,... % 2 Q hidden states for each condition: left,right X reward effort   
    'p',dim_output,... % total output dimension
    'n_theta',2,...  % alphaR, alphaE, modulators for alphaR and alphaE, kR, kE 
    'n_phi',1,... % observation parameters beta/discount and their modulators in ON 
    'u',dim_data,... % data dimension per session
    'n_t',Ntrials); 


options.DisplayWin = 1; % DISPLAY; % display inversion
options.GnFigs = 0;
options.binomial = 1; % Dealing with binary data
options.isYout = zeros(1,Ntrials); 
options.dim = dim;
options.inG=[]; % optional information used in the observation and evolution functions 
options.inF.theModel = theModel;

% ------------------------------------
f_fname =@transition_f; % handle of the shared evolution function
g_fname =@emission_f;

%%%%%%%%% ==================== specify the priors for the parameters ================== %%%%%%%%%%%%%%%%%%%%%%%%%% 

% observation parameters beta and gamma 
priors.muPhi= zeros(dim.n_phi,1); %  + .5;  
priors.SigmaPhi= 1*eye(dim.n_phi); % large variance on initial beta and gamma  

% evolution parameters 
priors.muTheta = zeros(dim.n_theta,1); %  + .5;
priors.SigmaTheta= 1*eye(dim.n_theta);

if theModel == 0
    priors.SigmaTheta(2,2)=0;
end


x0 = zeros(2,1);   
priors.muX0 = x0; 
% priors.muX0 =repmat(x0,Nsessions,1); % Nsessions
priors.SigmaX0=0*eye(dim.n); % dim_e.n no variance for priors

% No state noise for deterministic update rules
priors.a_alpha = Inf; % Inf 
priors.b_alpha = 0; % 0 

options.priors = priors; 
options.extended=1; 
options.skipf(1) = 1;

%%%% -------- Extend to multiple sessions ------ %%%%%%
% options.multisession.fixed.X0='all'; initial states x0 vary  
options.multisession.fixed.theta='all'; % [1:4]; % all params are fixed 
options.multisession.fixed.phi='all';   

options.multisession.split =repmat(ntrial,1,Nsessions);  % number of sessions 4 conditions x 3 sessions = 12 
% options_e.priors = priors;

% Feedback necessity -- optional to calculate the PE after 
options.skipf = zeros(1,Ntrials);
options.skipf(1:ntrial:end) = 1; % for multisession you have to put it by hand at the beginning of each session 
% identity mapping from x0 to x1 because the first transistion state is ill defined (no feedback for choice 1)  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MODEL INVERSION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[posterior,out] = VBA_NLStateSpaceModel(Y,U,f_fname,g_fname,dim,options);

