addpath(genpath('./veta_watershed'));
IMData4SymmetricVoting_1={'YTMA140-1_HE_good_1.png'};

for i=1:length(IMData4SymmetricVoting_1)
    curIMName=IMData4SymmetricVoting_1{i};
    curIM=imread(curIMName);
    curIMsize=size(curIM);
    [curIM_norm] = normalizeStaining(curIM);
    curIM_normRed=curIM_norm(:,:,1);
    %% using multi resolution watershed
    p.scales=[4:2:8]; % this depends on your nulcei size, suggest use 6:16 for 40x magnification for lung cancer, and 4:8 for 20x magnification image. 
    disp('begin nuclei segmentation using watershed');
    [nuclei, properties] = nucleiSegmentationV2(curIM_normRed,p);
    
    figure;imshow(curIM);hold on;
    for k = 1:length(nuclei)
        plot(nuclei{k}(:,2), nuclei{k}(:,1), 'g-', 'LineWidth', 2);
    end
    hold off;    
end