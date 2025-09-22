function [originalRegistered,mapRegistered] = coregisterMapToOrigin(original_fixed,original_moving,map_moving,moving_address,map_address)
%SPATIALMATRIXINTERP tato funkcia obsahuje interpolacnu metodu pre
%trojrozmerne matice
%   Detailed explanation goes here
%% registracia jedneho rezu mapy podla jeho korespondujuceho rezu originalnej snimky ktory registrujeme k axialnemu rezu originalnej snimky
%normalizacia
[original_fixed,original_moving,map_moving]=normalizeData(original_fixed,original_moving,map_moving);

[optimizer,metric]=imregconfig('monomodal');
optimizer.MaximumStepLength=0.00625;
transform=imregtform(original_moving,original_fixed,'affine',optimizer,metric,'DisplayOptimization',true);
original_reg=imwarp(original_moving,transform);
map_reg=imwarp(map_moving,transform);
% niftiwrite(original_reg,moving_address);
niftiwrite(map_reg,map_address);
originalRegistered=original_reg;
mapRegistered=map_reg;
end

