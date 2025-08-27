function [figureData] = modelVisualizer(modelInput,sample)
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
alphaThreshold = 0.25;  % adjust this value to control "opacity"
mask = intensities > alphaThreshold;

x = x(mask); y = y(mask); z = z(mask);
intensities = intensities(mask);

% Marker size scales with intensity (brighter = larger)
markerSizes = 1+2*sample*intensities;  % adjust scaling factor as needed

figure;
scatter3(x,y,z,markerSizes,intensities,'filled');
% axis([1 size(modelInput,1) 1 size(modelInput,2) 1 size(modelInput,3)]);
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
colormap('gray'); colorbar;
title('3D MRI so simulovanou priehladnostou');
set(gca, 'Color', 'k');  %cierne pozadie
view(3);
end