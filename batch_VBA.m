% addpath('../functions/')
% addpath(genpath('/Users/csmfindling/VBA-toolbox/')) % TOCHANGE

clear all
close all
clc

datapath = pwd; 
modellist = [0 1]; 

theModel = modellist(2); 

cd('D:\Projects\model_comparison-master\2_armed_bandit\code\var_bayes')

experiment = load('../../data/simulations/matlab/effectsize_2/simul_0.mat')
% data
U = [double(reshape(experiment.actions,8*25,1)) reshape(experiment.high_rew,8*25,1)]'; 
Y = double(reshape(experiment.actions,8*25,1)'); 

[posterior,out] = invert_VBA(Y,U,theModel)  

