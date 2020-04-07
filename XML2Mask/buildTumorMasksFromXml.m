clear;clc;

%imgFolder='Z:\data\CCF_OropharyngealCarcinoma\Ventana\';
imgFolder='Z:\data\Kaisar_OP\Ventana_KA_Slides\';

%annotFolder='D:\German\Data\Oroph_CCF\annot_patoroc\';
%annotFolder='D:\German\Data\Oroph_CCF\annotations\lymphoid_tissue_Paula\';
annotFolder='D:\German\Data\Oroph_Kaisar\xml_annot\';

%tissueMaskFolder='D:\German\Data\Oroph_CCF\masks\tissue_masks\';
tissueMaskFolder='D:\German\Data\Oroph_Kaisar\masks\tissue_masks\';

tissueMaskExt='.png';

%outFolder='D:\German\Data\Oroph_CCF\masks\tumor_masks\';
%outFolder='D:\German\Data\Oroph_CCF\masks\lymphoid_tissue_masks\';
outFolder='D:\German\Data\Oroph_Kaisar\masks\tumor_masks\';

files=dir([annotFolder '*.xml']);
numFiles=length(files);

%%-- Negative list: Only non-tumor areas were annotated
negativeList={};
%negativeList={'CCFOP20','CCFOP21','CCFOP22','CCFOP24','CCFOP25','CCFOP27',...
%    'CCFOP30','CCFOP31','CCFOP34','CCFOP37','CCFOP42','CCFOP43','CCFOP45',...
%    'CCFOP47','CCFOP54','CCFOP56','CCFOP58','CCFOP60','CCFOP63','CCFOP72',...
%    'CCFOP75','CCFOP77','CCFOP78','CCFOP80',};


for i=1:numFiles
    imgName=erase(files(i).name,'.xml');
    try
        outFile=[outFolder imgName '.png'];
        
        %if exist(outFile,'file')~=2 
            info=imfinfo([imgFolder imgName '.tif']);
            tissueMask=double(imfill(imread([tissueMaskFolder imgName tissueMaskExt]),'holes'));
            annot=getAnnotation_ASAPformat([annotFolder files(i).name]);
            
            [~,ind] = max(cat(1,info.Height));
            [h,w,~]=size(tissueMask);
            M=buildMaskFromPoly(annot,info(ind).Height/h,h,w);
            
            if ismember(imgName,negativeList)
                M=tissueMask-M*255;
            end
            
            imwrite(M,outFile);
        %end
    catch ex
        fprintf('Error processing image %s: %s\n',imgName,ex.message);
    end
end