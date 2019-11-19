% this function convert the nuclei structure to binary mask
function seg_mask = Lnuclei2mask(img,nuclei)
%seg_mask = convert_bounds2mask(img,bounds)

seg_mask = zeros(size(img,1), size(img,2));
for i = 1:numel(nuclei)
    cur=nuclei{i};
    seg_mask = seg_mask + poly2mask(cur(:,2),cur(:,1),size(img,1),size(img,2));
%     show(seg_mask)
end

