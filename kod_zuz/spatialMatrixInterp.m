function [interpVolume] = spatialMatrixInterp(axial,coronal,sagittal,cor_address,sag_address,needsRegistration)
%SPATIALMATRIXINTERP tato funkcia obsahuje interpolacnu metodu pre
%trojrozmerne matice
%   Detailed explanation goes here
%% registracia koronalneho a sagittalneho rezu (trva dlho! obcas az ~25 min)
if needsRegistration==true
    coronal_reg=registerMedicalVolumes(coronal,axial);
    sagittal_reg=registerMedicalVolumes(sagittal,axial);
    write(coronal_reg,cor_address);
    write(sagittal_reg,sag_address);
    coronal=coronal_reg;
    sagittal=sagittal_reg;
end

%% filtering
% coronal=medfilt3(coronal);
% sagittal=medfilt3(sagittal);

%% resampling
coronal_res=resample(coronal,axial.VolumeGeometry);
sagittal_res=resample(sagittal,axial.VolumeGeometry);

%% reoriented
coronal=coronal_res;
sagittal=sagittal_res;

%% vytvorenie interpolacnej matice
res=0.25; %interpolacne rozlisenie - 1 je bez zmeny, >1 je zmensenie, <1 je zvacsenie

[x_ax,y_ax,z_ax]=meshgrid(1:size(axial.Voxels,1),1:size(axial.Voxels,2),1:size(axial.Voxels,3));
[x_cor,y_cor,z_cor]=meshgrid(1:size(coronal.Voxels,1),1:size(coronal.Voxels,2),1:size(coronal.Voxels,3));
[x_sag,y_sag,z_sag]=meshgrid(1:size(sagittal.Voxels,1),1:size(sagittal.Voxels,2),1:size(sagittal.Voxels,3));

% %urcenie najvacsich rozmerov v pripade ze su snimky alebo sady snimok nejak
% %odlisne
max_x=max([size(axial.Voxels,1),size(coronal.Voxels,1),size(sagittal.Voxels,1)]);
max_y=max([size(axial.Voxels,2),size(coronal.Voxels,2),size(sagittal.Voxels,2)]);
max_z=max([size(axial.Voxels,3),size(coronal.Voxels,3),size(sagittal.Voxels,3)]);
% 
[x,y,z]=meshgrid(1:res:max_x,1:res:max_y,1:res:max_z);
% 
% %%samotna interpolacia
interp_axial=interp3(x_ax,y_ax,z_ax,axial.Voxels,x,y,z,'cubic');
interp_coronal=interp3(x_cor,y_cor,z_cor,coronal.Voxels,x,y,z,'cubic');
interp_sagittal=interp3(x_sag,y_sag,z_sag,sagittal.Voxels,x,y,z,'cubic');

interpVolume=(interp_axial+interp_coronal+interp_sagittal)/3;
end

