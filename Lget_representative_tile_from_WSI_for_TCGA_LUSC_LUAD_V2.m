% str_image_local='Z:\TCGA-LUSC-hist-DX\';
% str_QCmask_hpc='Z:\TCGA-LUSC-hist-DX\HistoQC\mask_use\';
% str_folder_eye_check='Z:\TCGA-LUSC-hist-DX\eye_check\';
% num_tile_size=[2500 2500];% the size of the tile to be saved
% num_tile_to_get=5;
% Lget_tiles_from_WSI(str_image_local,str_QCmask_hpc,num_tile_to_get,num_tile_size,str_folder_eye_check);


str_image_local='Z:\TCGA-LUAD-hist-DX\';
str_QCmask_hpc='Z:\TCGA-LUAD-hist-DX\HistoQC\mask_use\';
str_folder_eye_check='Z:\TCGA-LUAD-hist-DX\eye_check\';
num_tile_size=[2500 2500];% the size of the tile to be saved
num_tile_to_get=5;
Lget_tiles_from_WSI(str_image_local,str_QCmask_hpc,num_tile_to_get,num_tile_size,str_folder_eye_check);