data=load('cliInfo.mat');

FUtime=data.cliInfo.time;
death=logical(data.cliInfo.death);

addpath(genpath('/Users/chenglu/Nutstore/PathImAnalysis_Program/Program/Miscellaneous/survival_analysis'));

cens=zeros(length(death),1);
logrank([FUtime(death) cens(death)],[FUtime(~death) cens(~death)],0.05,1);



