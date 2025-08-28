function [figureData] = modelVisualizer(modelInput,sample,multiplier,where,alphaThreshold)
%MODELVISUALIZER moj maly plotik
%   pozor, zere pamat horsie ako alzheimer

[X,Y,Z]=ndgrid(1:sample:size(modelInput,1),1:sample:size(modelInput,2),1:sample:size(modelInput,3));
x = X(:);
y = Y(:);
z = Z(:);
clear X Y Z;

sampledInput=modelInput(1:sample:end,1:sample:end,1:sample:end);

intensities=sampledInput(:);

% Threshold: remove very dark voxels (simulate transparency)
% alphaThreshold = 0.25;  % adjust this value to control "opacity"
mask = intensities > alphaThreshold;

x = x(mask); y = y(mask); z = z(mask);
intensities = intensities(mask);

% Marker size scales with intensity (brighter = larger)
markerSizes = 1+multiplier*sample*intensities;  % adjust scaling factor as needed

figureData=scatter3(where,x,y,z,markerSizes,intensities,'filled');
% axis([1 size(modelInput,1) 1 size(modelInput,2) 1 size(modelInput,3)]);
axis(where,'equal');
xlabel(where,'X'); ylabel(where,'Y'); zlabel(where,'Z');
colormap(where,'gray'); colorbar(where);
% title(where,'3D MRI so simulovanou priehladnostou');
title(where,'');
set(where,'Color','k');  %cierne pozadie
view(where,3);
end