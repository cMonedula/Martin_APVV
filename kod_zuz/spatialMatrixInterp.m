function [interpVolume] = spatialMatrixInterp(axial,coronal,sagittal,cor_address,sag_address,needsRegistration)
%SPATIALMATRIXINTERP tato funkcia obsahuje interpolacnu metodu pre
%trojrozmerne matice
%   Detailed explanation goes here
%% registracia koronalneho a sagitalneho rezu (trva dlho! obcas az ~25 min)
%normalizacia
% axial=normalize(cast(axial,"double"),"scale");
% coronal=normalize(cast(coronal,"double"),"scale");
% sagital=normalize(cast(sagital,"double"),"scale");

if needsRegistration==true
    [optimizer,metric]=imregconfig('monomodal');
    optimizer.MaximumStepLength=0.00625;
    coronal_reg=imregister(coronal,axial,'affine',optimizer,metric,'DisplayOptimization',true);
    sagittal_reg=imregister(sagittal,axial,'affine',optimizer,metric,'DisplayOptimization',true);
    niftiwrite(coronal_reg,cor_address);
    niftiwrite(sagittal_reg,sag_address);
    coronal=coronal_reg;
    sagittal=sagittal_reg;
end

%% reskalovanie
axial=rescale(axial);
coronal=rescale(coronal);
sagittal=rescale(sagittal);

%% vytvorenie interpolacnej matice
res=0.5; %interpolacne rozlisenie - 1 je bez zmeny, >1 je zmensenie, <1 je zvacsenie

[x_ax,y_ax,z_ax]=meshgrid(1:size(axial,1),1:size(axial,2),1:size(axial,3));
[x_cor,y_cor,z_cor]=meshgrid(1:size(coronal,1),1:size(coronal,2),1:size(coronal,3));
[x_sag,y_sag,z_sag]=meshgrid(1:size(sagittal,1),1:size(sagittal,2),1:size(sagittal,3));

%urcenie najvacsich rozmerov v pripade ze su snimky alebo sady snimok nejak
%odlisne
max_x=max([size(axial,1),size(coronal,1),size(sagittal,1)]);
max_y=max([size(axial,2),size(coronal,2),size(sagittal,2)]);
max_z=max([size(axial,3),size(coronal,3),size(sagittal,3)]);

[x,y,z]=meshgrid(1:res:max_x,1:res:max_y,1:res:max_z);

%%samotna interpolacia
interp_axial=interp3(x_ax,y_ax,z_ax,cast(axial,'double'),x,y,z,'makima');
interp_coronal=interp3(x_cor,y_cor,z_cor,cast(coronal,'double'),x,y,z,'makima');
interp_sagittal=interp3(x_sag,y_sag,z_sag,cast(sagittal,'double'),x,y,z,'makima');

interpVolume=(interp_axial+interp_coronal+interp_sagittal)/3;
end

