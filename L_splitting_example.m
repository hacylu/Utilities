tileSize = [2048, 2048]; % has to be a multiple of 16.

str_folder='Z:\OSU_Oral_OropharyngealTMA\Ventana\40XTMAsAPR2019\TMAs_OralCavity\all_imgs\';

str_savepath='K:\OSU_Oral_OropharyngealTMA\Ventana\40XTMAsAPR2019\TMAs_OralCavity\all_imgs\2048@40x\'; 
LcreateFolder(str_savepath);
im_format='*.jpg';

% should be the QC folder, but we process all here
% list_image_to_compute=dir('/mnt/projects/CSE_BME_AXM788/data/CCF_OropharyngealCarcinoma/HistoQC/Ventana/*.tif');
list_image_to_compute=dir([str_folder im_format]);

T_filesize=4000000;%should check this mannually

dirim=dir([str_folder im_format]);
% only compute the images after histoQC
list_image_to_compute=[list_image_to_compute.name];
%% begin to split the image
% please remove the output data folder before rerun the code
% for i=1:length(dirim)
parfor i=1:length(dirim)
    fprintf('On %d/%dth image\n',i,length(dirim));
    input_svs_file=dirim(i).name;    
    %%% need to find where level of the image you want to process
    ff=imfinfo([str_folder input_svs_file]);
    [~,input_svs_page]=max([ff.Width]);
    
    if ~strcmp(im_format,'*.tif')
        I=imread([str_folder input_svs_file]);
        imwrite(I,[str_folder input_svs_file(1:end-3) 'tif']);
        input_svs_file_ori=input_svs_file;
        input_svs_file=[input_svs_file(1:end-3) 'tif'];
    else
        input_svs_file_ori=input_svs_file;
    end

%     input_svs_page=3; %the page of the svs file we're interested in loading
    % check if the image is compuatable
    if contains(list_image_to_compute,input_svs_file_ori)        
        [~,baseFilename,~]=fileparts(input_svs_file);
        if exist(sprintf('%s%s/',str_savepath,baseFilename),'dir')
            dirpng=dir([str_savepath,baseFilename,'/*.png']);
            %         dirpng=dir([str_savepath,baseFilename,'\*.png']);
            size_png=[dirpng.bytes];
            idx_bad=find(size_png<T_filesize);% based on file size
            if isempty(idx_bad)
                % ff=imfinfo([str_folder input_svs_file]);
                %     svs_adapter =PagedTiffAdapter_withfilter([str_folder input_svs_file],input_svs_page); %create an adapter which modulates how the large svs file is accessed
                svs_adapter =PagedTiffAdapter([str_folder input_svs_file],input_svs_page); %create an adapter which modulates how the large svs file is accessed
                
                %     fprintf('\\.png')
                % tic
                %     LcreateFolder(sprintf('%s%s\\',str_savepath,baseFilename));
                LcreateFolder(sprintf('%s%s/',str_savepath,baseFilename));
                
                %     fun=@(block) imwrite(block.data,sprintf('%s%s\\%s_x%d_y%d.png',str_savepath,baseFilename,baseFilename,block.location(1),block.location(2))); %make a function which saves the individual tile with the row/column information in the filename so that we can refind this tile later
                fun=@(block) imwrite(block.data,sprintf('%s%s/%s_x%d_y%d.png',str_savepath,baseFilename,baseFilename,block.location(1),block.location(2))); %make a function which saves the individual tile with the row/column information in the filename so that we can refind this tile later
                
                blockproc(svs_adapter,tileSize,fun); %perform the splitting
                % toc
                %% do the file cleaning here
                dirpng=dir([str_savepath,baseFilename,'/*.png']);
                %         dirpng=dir([str_savepath,baseFilename,'\*.png']);
                size_png=[dirpng.bytes];
                idx_bad=find(size_png<T_filesize);% based on file size
                
                %     str=[dirpng(idx_bad).name];
                %     str_r=[str_savepath baseFilename '/' str];
                %     str_r=strrep(str_r,'.png',['.png ' str_savepath baseFilename '/']);
                %     tmp=strsplit(str_r,' ');
                for j=1:length(idx_bad)
                    str=dirpng(idx_bad(j)).name;
                    delete([str_savepath baseFilename '/' str]);
                end
                %     delete
                %     feval(@delete, str_r);
                %     eval(['delete ' str_r]);
            end
        else
            svs_adapter =PagedTiffAdapter([str_folder input_svs_file],input_svs_page); %create an adapter which modulates how the large svs file is accessed
            
            %     fprintf('\\.png')
            % tic
            %     LcreateFolder(sprintf('%s%s\\',str_savepath,baseFilename));
            LcreateFolder(sprintf('%s%s/',str_savepath,baseFilename));
            
            %     fun=@(block) imwrite(block.data,sprintf('%s%s\\%s_x%d_y%d.png',str_savepath,baseFilename,baseFilename,block.location(1),block.location(2))); %make a function which saves the individual tile with the row/column information in the filename so that we can refind this tile later
            fun=@(block) imwrite(block.data,sprintf('%s%s/%s_x%d_y%d.png',str_savepath,baseFilename,baseFilename,block.location(1),block.location(2))); %make a function which saves the individual tile with the row/column information in the filename so that we can refind this tile later
            
            blockproc(svs_adapter,tileSize,fun); %perform the splitting
            % toc
            %% do the file cleaning here
            dirpng=dir([str_savepath,baseFilename,'/*.png']);
            %         dirpng=dir([str_savepath,baseFilename,'\*.png']);
            size_png=[dirpng.bytes];
            idx_bad=find(size_png<T_filesize);% based on file size
            
            for j=1:length(idx_bad)
                str=dirpng(idx_bad(j)).name;
                delete([str_savepath baseFilename '/' str]);
            end
        end
    else
        fprintf('image %s is not in the computable image list, ignored...\n',input_svs_file_ori);
    end
    if ~strcmp(im_format,'*.tif')
        delete([str_folder input_svs_file]);
    end
end