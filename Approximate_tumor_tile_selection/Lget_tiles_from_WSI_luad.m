% this script assume that we have all the tiles from each WSI (in a single folder) and try to
% pick out 1 representative tile for each WSI, the image name list will be
% generated for downstream processing on HPC or local machine
% assumption: the folder contains only 20x or 40x images
%             save the 20x magnification tile
% 2018 Aug. 9, 2018 by Cheng Lu
set(0, 'DefaultFigureVisible', 'off');

str_image_local='Z:\data\TCGA-LUAD-hist-DX\';
%str_QCmask_hpc='Z:\data\TCGA-LUAD-hist-DX\HistoQC\mask_use\';
str_QCmask_hpc = 'C:\Users\rinad\Desktop\ccipd\featureExtraction\lusc_tiling_Cheng\more_than_one_luad\';
%str_folder_eye_check='Z:\home\rina\LUAD_10_tiles_eye_check\';
str_folder_eye_check = 'C:\Users\rinad\Desktop\ccipd\featureExtraction\lusc_tiling_Cheng\luad_eye_check\';
num_tile_size=[2000 2000];% the size of the tile to be saved
num_tile_to_get=10;

%LcreateFolder(str_folder_eye_check);

% Load openslide library
openslide_load_library();
disp(['OpenSlide version: ',openslide_get_version()])

num_mag_to_save=40; % the magnification of the tile to be saved, now only support 20x

%save_path_parent = 'Z:\home\rina\LUAD_10_tiles\';
save_path_parent = 'C:\Users\rinad\Desktop\ccipd\featureExtraction\lusc_tiling_Cheng\luad_tiled\';
str_folder_save = save_path_parent ;
%LcreateFolder(str_folder_save);

dir_mask=dir([str_QCmask_hpc '*.png']);
for i=1:length(dir_mask)
    
     %new folders for each group of sliced images
    folder_save_child = fullfile(save_path_parent,sprintf('%s', dir_mask(i).name(1:12)));
    fprintf('Processing %s \n', folder_save_child);
    mkdir(folder_save_child);

    fprintf('on %d/%d image\n',i,length(dir_mask));
    idx_mag=[];
    curID=dir_mask(i).name;
    tmp=strsplit(curID,'_mask');
    curID=tmp{1};
    %     im_info=imfinfo([str_image_local curID]);
    
    % Open whole-slide image
    slidePtr = openslide_open([str_image_local curID]);
    % Get whole-slide image properties
    [mppX, mppY, width, height, numberOfLevels, ...
        downsampleFactors, objectivePower] = openslide_get_slide_properties(slidePtr);
    downsampleFactors=round(downsampleFactors);
    % Display properties
    %     disp(['mppX: ',num2str(mppX)])
    %     disp(['mppY: ',num2str(mppY)])
    %     disp(['width: ',num2str(width)])
    %     disp(['height: ',num2str(height)])
    %     disp(['number of levels: ',num2str(numberOfLevels)])
    % %     disp(['downsample factors: ',num2str(downsampleFactors)])
    %     disp(['objective power: ',num2str(objectivePower)])
    if objectivePower==40 || mppX<0.26 %~isempty(idx_mag)% this is a 40x image I uesed | because of the mistake of the image information regarding the objective power (example: TCGA-05-4244-01Z-00-DX1.d4ff32cd-38cf-40ea-8213-45c2b100ac01.svs)%~isempty(idx_mag)% this is a 40x image
        if numberOfLevels>3
            [ARGB] = openslide_read_whole_level_im(slidePtr,'level',3);
            %             factor_tilepicing=8;
            factor_tilepicing=downsampleFactors(4);
        end
        if numberOfLevels==3
            [ARGB] = openslide_read_whole_level_im(slidePtr,'level',2);
            %             factor_tilepicing=4;
            factor_tilepicing=downsampleFactors(3);
        end
        
        if numberOfLevels<3
            continue;
        end
    else% this is a 20x image % i=127
        if numberOfLevels==3
            [ARGB] = openslide_read_whole_level_im(slidePtr,'level',2);
            factor_tilepicing=downsampleFactors(3);
        else
            continue;
        end
    end
    
    cur_im_lowres=ARGB(:,:,2:4);
    % Display RGB part
    %     figure(1)
    %     imshow(cur_im_lowres);
    %     set(gcf,'Name','WSI','NumberTitle','off')
    
    % read the mask_use
    cur_im_bw_QC=imread([str_QCmask_hpc curID '_mask_use.png']);
    cur_im_bw_QC=imresize(cur_im_bw_QC,[size(cur_im_lowres,1) size(cur_im_lowres,2)]);
    %         LshowBWonIM(cur_im_bw_QC,cur_im_lowres(:,:,1),1);
    %         LshowBWonIM(cur_im_bw_QC,cur_im_lowres(:,:,2));
    %         LshowBWonIM(cur_im_bw_QC,cur_im_lowres(:,:,3));
    
    % begin to pick a tile and save it
    flag_s=1;
    %     I_show
    R=cur_im_lowres(:,:,1);
    %get ink mask
    bw_R_ink=R<100;%show(bw_R_ink)
    
    bw_R=R<180;%show(bw_R)%show(R) show(cur_im_bw_QC)
    bw_R=cur_im_bw_QC&bw_R&~bw_R_ink;
    % LshowBWonIM(bw_R,R,2);
    
    %%% save the high mag tile into folder
    bw_tile_out=bw_R;
    set_tiles_HH_all=[];
    idx_tiles=0;
    counter = 1;
    while idx_tiles<num_tile_to_get
  %         num_tile_to_get=num_tile_to_get-1;
        idx_tiles=idx_tiles+1;
        bw_R=bw_R&bw_tile_out;
        if objectivePower==40 || mppX<0.26 %~isempty(idx_mag)% this is a 40x image I uesed | because of the mistake of the image information regarding the objective power (example: TCGA-05-4244-01Z-00-DX1.d4ff32cd-38cf-40ea-8213-45c2b100ac01.svs)%~isempty(idx_mag)% this is a 40x image
            if num_mag_to_save==20
                [set_tiles_HH,protion_HH]=LselectBestTile_sliding_window_method_v2(bw_R,cur_im_bw_QC,round(num_tile_size(1)/factor_tilepicing*2),cur_im_lowres,0);
                set_tiles_HH_all(idx_tiles,:)=set_tiles_HH;
%                 bw_tile_out=ones(size(bw_R,1),size(bw_R,2));
                bw_tile_out(set_tiles_HH(2):set_tiles_HH(2)+set_tiles_HH(3)-1,set_tiles_HH(1):set_tiles_HH(1)+set_tiles_HH(4)-1)=0;
%                 saveas(gca,[str_folder_eye_check curID '_tile_selection.png']);
                close all;
                set_tiles_HH_save=set_tiles_HH*factor_tilepicing;
                set_tiles_HH_save(3:4)=num_tile_size*2;
                
                if set_tiles_HH_save(1) + set_tiles_HH_save(3)- 1 >= width
                    set_tiles_HH_save(1)= width-set_tiles_HH_save(3);
                end
                if set_tiles_HH_save(2) + set_tiles_HH_save(4) - 1 >= height
                    set_tiles_HH_save(2)= height-set_tiles_HH_save(4);
                end
                
                [ARGB] = openslide_read_region(slidePtr,set_tiles_HH_save(1),set_tiles_HH_save(2),set_tiles_HH_save(3),set_tiles_HH_save(4),'level',0);
                cur_tile_2_save=ARGB(:,:,2:4);
                cur_tile_2_save=imresize(cur_tile_2_save,0.5);
                set_tiles_HH_save(3:4)=num_tile_size;
            else
                [set_tiles_HH,protion_HH]=LselectBestTile_sliding_window_method_v2(bw_R,cur_im_bw_QC,round(num_tile_size(1)/factor_tilepicing),cur_im_lowres,0);
                set_tiles_HH_all(idx_tiles,:)=set_tiles_HH;
                %                 bw_tile_out=ones(size(bw_R,1),size(bw_R,2));
                bw_tile_out(set_tiles_HH(2):set_tiles_HH(2)+set_tiles_HH(3)-1,set_tiles_HH(1):set_tiles_HH(1)+set_tiles_HH(4)-1)=0;
%                 saveas(gca,[str_folder_eye_check curID '_tile_selection.png']);
                close all;
                set_tiles_HH_save=set_tiles_HH*factor_tilepicing;
                set_tiles_HH_save(3:4)=num_tile_size;
                %             set_tiles_HH_save=set_tiles_HH*factor_tilepicing;
                %             set_tiles_HH_save(3:4)=num_tile_size;
                [ARGB] = openslide_read_region(slidePtr,set_tiles_HH_save(1),set_tiles_HH_save(2),set_tiles_HH_save(3),set_tiles_HH_save(4),'level',0);
                cur_tile_2_save=ARGB(:,:,2:4);
            end
        else% this is a 20x image % i=127 144 is problematic
            [set_tiles_HH,protion_HH]=LselectBestTile_sliding_window_method_v2(bw_R,cur_im_bw_QC,round(num_tile_size(1)/factor_tilepicing),cur_im_lowres,0);
            set_tiles_HH_all(idx_tiles,:)=set_tiles_HH;
            %                 bw_tile_out=ones(size(bw_R,1),size(bw_R,2));
            bw_tile_out(set_tiles_HH(2):set_tiles_HH(2)+set_tiles_HH(3)-1,set_tiles_HH(1):set_tiles_HH(1)+set_tiles_HH(4)-1)=0;
%             saveas(gca,[str_folder_eye_check curID '_tile_selection.png']);
            close all;
            set_tiles_HH_save=set_tiles_HH*factor_tilepicing;
            set_tiles_HH_save(3:4)=num_tile_size;
            [ARGB] = openslide_read_region(slidePtr,set_tiles_HH_save(1),set_tiles_HH_save(2),set_tiles_HH_save(3),set_tiles_HH_save(4),'level',0);
            cur_tile_2_save=ARGB(:,:,2:4);
        end
        %     show(cur_tile_2_save)
        fullfile_name = fullfile(folder_save_child, sprintf('luad_tile%d.png',counter));
        %imwrite(cur_tile_2_save,sprintf('%s%s_xpos%d_ypos%d_w%d_h%d_@%dx.png',folder_save_child,curID(1:12),set_tiles_HH_save(1),set_tiles_HH_save(2),set_tiles_HH_save(3),set_tiles_HH_save(4),num_mag_to_save));
        imwrite(cur_tile_2_save, fullfile_name);
        counter = counter + 1;
    end
    
    
    show(cur_im_lowres);
    hold on;
    for k=1:size(set_tiles_HH_all,1)
        set_tiles_HH=set_tiles_HH_all(k,:);
%             plot(cc,cr,'b*','MarkerSize',8);
        rectangle('Position',set_tiles_HH,'EdgeColor','b','LineWidth',3);
    end
    hold off;
    saveas(gca,[str_folder_eye_check curID(1:12) '_tile_selection.png']);
    
    %}
    
    % Close whole-slide image, note that the slidePtr must be removed manually
    openslide_close(slidePtr)
    clear slidePtr
end

% Unload library
openslide_unload_library
