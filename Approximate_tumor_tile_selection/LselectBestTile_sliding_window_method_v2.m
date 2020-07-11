% v2 perform the tile selection within certain region by giving the binary
% map(bw_tumor_region)
function [set_tiles_HH,protion_HH]=LselectBestTile_sliding_window_method_v2(bw_ITHmap_HH,bw_tumor_region,siz_window,I_show,flag_s)
% output:
%    set_tiles_HH: record the coordinate of the HH position in a rect
%                  format, [top-left-point_rowindx,top-left-point_columnindx,width,height]
% make the window size odd
if mod(siz_window,2)==0
    siz_window=siz_window+1;
end

bw_ITHmap_HH_f=filter2(ones(siz_window),bw_ITHmap_HH,'same');
% show(bw_ITHmap_HH_f);
[maxV,maxIdxf]=max(bw_ITHmap_HH_f(:));
protion_HH=maxV/siz_window.^2;

[cr,cc]=ind2sub(size(bw_ITHmap_HH_f),maxIdxf);
% set_tiles_HH=[cc-floor(siz_window/2) cr-floor(siz_window/2) siz_window-1 siz_window-1];
set_tiles_HH=[cc-floor(siz_window/2) cr-floor(siz_window/2) siz_window siz_window];

% show(bw_ITHmap_HH);
if flag_s
%     show(imresize(I_show,.5));
    show(I_show);

    hold on;
    plot(cc,cr,'b*','MarkerSize',8);
    rectangle('Position',set_tiles_HH,'EdgeColor','b','LineWidth',3);
    hold off;
end
end