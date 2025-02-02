% Load models & data
clear all;
arInit

%Load full model or reduced
arLoadModel('model_expl4_full');
% arLoadModel('model_expl4_red');

%Load Data
arLoadData('data_expl4');
arCompileAll();

%Calibrate Model
arFit
%Print model parameters
arPrint

%Save model
arSave

%Calculate parameter of k_on for full model or reduced model
arPLEInit
ple(2)

% for full model, plot trajectories along PLE
ar.model(1).qPlotYs(:)=0;
ar.model(1).qPlotXs(:)=1;
arPLETrajectories(2)

%fixing k_on for reduced model, since its structurally non-identifiable
%arSetPars('k_on',0,2,1,-5,3)
%arFit
