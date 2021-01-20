%% nmb60@case.edu
% plot pretty breast clustergram for MICCAI
clear
load('vangogh_ftrs_scaled_for_MICCAI.mat')

%% this section is all about making the struct RowLabels to add ground truth labels to clustergram
x=num2cell(pcr(trainInd),1);
color = {};
for ii = 1:length(x)
    if x{ii}==1
        color{ii} = 'b';
    else
        color{ii} = 'r';
        
    end
    x{ii} = num2str(x{ii});
end

RowLabels = struct; % struct used to add ground truth labels along rows
RowLabels.Labels = x; 
RowLabels.Colors = color; 

%% Actually plot the clustergram
% CGobj = clustergram(ftrs(trainInd,:), 'RowLabels', pcr(trainInd),'rowpdist','spearman','LabelsWithMarkers',true,'RowLabelsColor',RowLabels,'colormap','redbluecmap','colormap',linspecer,'DisplayRange',1);
CGobj = clustergram(ftrs(trainInd,:), 'RowLabels', pcr(trainInd),'rowpdist','spearman','LabelsWithMarkers',true,'RowLabelsColor',RowLabels,'colormap','redbluecmap','DisplayRange',1);


