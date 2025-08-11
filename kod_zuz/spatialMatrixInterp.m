function [interpVolume] = spatialMatrixInterp(axial,coronal,sagital,cor_address,sag_address)
%SPATIALMATRIXINTERP tato funkcia obsahuje interpolacnu metodu pre
%trojrozmerne matice
%   Detailed explanation goes here
%% registracia koronalneho a sagitalneho rezu (trva dlho! obcas az ~25 min)
[optimizer,metric]=imregconfig('monomodal');
coronal_reg=imregister(coronal,axial,'affine',optimizer,metric);
sagital_reg=imregister(sagital,axial,'affine',optimizer,metric);
niftiwrite(coronal_reg,cor_address);
niftiwrite(sagital_reg,sag_address);

%% vytvorenie interpolacnej matice
res=0.5; %interpolacne rozlisenie - 1 je bez zmeny, >1 je zmensenie, <1 je zvacsenie

[x_ax,y_ax,z_ax]=meshgrid(1:size(axial,1),1:size(axial,2),1:size(axial,3));
[x_cor,y_cor,z_cor]=meshgrid(1:size(coronal,1),1:size(coronal,2),1:size(coronal,3));
[x_sag,y_sag,z_sag]=meshgrid(1:size(sagital,1),1:size(sagital,2),1:size(sagital,3));

%urcenie najvacsich rozmerov v pripade ze su snimky alebo sady snimok nejak
%odlisne
max_x=max([size(axial,1),size(coronal,1),size(sagital,1)]);
max_y=max([size(axial,2),size(coronal,2),size(sagital,2)]);
max_z=max([size(axial,3),size(coronal,3),size(sagital,3)]);

[x,y,z]=meshgrid(1:res:max_x,1:res:max_y,1:res:max_z);

%%samotna interpolacia
interp_axial=interp3(x_ax,y_ax,z_ax,x,y,z,'makima');
interp_coronal=interp3(x_cor,y_cor,z_cor,x,y,z,'makima');
interp_sagital=interp3(x_sag,y_sag,z_sag,x,y,z,'makima');

interpVolume=(interp_axial+interp_coronal+interp_sagital)/3;
end

