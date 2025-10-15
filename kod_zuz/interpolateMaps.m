function [Volume] = interpolateMaps(axial,coronal,sagittal,interp_address)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% vytvorenie interpolacnej matice
res=1; %interpolacne rozlisenie - 1 je bez zmeny, >1 je zmensenie, <1 je zvacsenie

% [x_ax,y_ax,z_ax]=ndgrid(1:size(axial,1),1:size(axial,2),1:size(axial,3));
% [x_cor,y_cor,z_cor]=ndgrid(1:size(coronal,1),1:size(coronal,2),1:size(coronal,3));
% [x_sag,y_sag,z_sag]=ndgrid(1:size(sagittal,1),1:size(sagittal,2),1:size(sagittal,3));

%urcenie najvacsich rozmerov v pripade ze su snimky alebo sady snimok nejak
%odlisne
max_x=max([size(axial,1),size(coronal,1),size(sagittal,1)]);
max_y=max([size(axial,2),size(coronal,2),size(sagittal,2)]);
max_z=max([size(axial,3),size(coronal,3),size(sagittal,3)]);

[x,y,z]=ndgrid(1:res:max_x,1:res:max_y,1:res:max_z);

%%samotna interpolacia
% interp_axial=interp3(x_ax,y_ax,z_ax,cast(axial,'double'),x,y,z,'makima');
% interp_coronal=interp3(x_cor,y_cor,z_cor,cast(coronal,'double'),x,y,z,'makima');
% interp_sagittal=interp3(x_sag,y_sag,z_sag,cast(sagittal,'double'),x,y,z,'makima');
% interp_axial = interp3(cast(axial,'double'),x,y,z,'makima');
% interp_coronal = interp3(cast(coronal,'double'),x,y,z,'makima');
% interp_sagittal = interp3(cast(sagittal,'double'),x,y,z,'makima');
% 
% interpVolume=(interp_axial+interp_coronal+interp_sagittal)/3;
% interpVolume=normalizeData(interpVolume);

Volume=(axial+coronal+sagittal)/3;
Volume=normalizeData(Volume);
niftiwrite(Volume,interp_address);
end

