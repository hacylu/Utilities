%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is for showing the countour of the mask on the image
% LshowBWonIM(mask,IM,figNo)
% Input:
%   -im     given image
%   -mask   mask indicates the ROI
%   
% (c) Edited by Cheng Lu, 
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  3rd, Aug, 2011
% If you have any problem feel free to contact me.
% Please address questions or comments to: hacylu@yahoo.com

% Terms of use: You are free to copy,
% distribute, display, and use this work, under the following
% conditions. (1) You must give the original authors credit. (2) You may
% not use or redistribute this work for commercial purposes. (3) You may
% not alter, transform, or build upon this work. (4) For any reuse or
% distribution, you must make clear to others the license terms of this
% work. (5) Any of these conditions can be waived if you get permission
% from the authors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LshowBWonIM(mask,IM,figNo)

		       
subplot('position',[0 0 1 1]); % Use the whole window

        
if nargin<3
    show(IM); hold on;
else
    scrsz = get(0,'ScreenSize');
     figure(figNo);
%     set(gcf, 'Position',[ 1 1 scrsz(3)/2 scrsz(4)]);
%     figure(figNo);
    imshow(IM,[],'InitialMagnification',100);  hold on;
%     imshow(IM,[],'InitialMagnification','fit');  hold on;

end
%% get contour of the mask
B = bwboundaries(mask,4);
 for i=1:length(B)
     curB=B{i};
%      plot(curB(:,2),curB(:,1),'r','LineWidth',3);
     plot(curB(:,2),curB(:,1),'y','LineWidth',1);
 end
    axis('image'); axis('off');
hold off;
end