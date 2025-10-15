function [figureData] = modelVisualizer(modelInput,sample,multiplier,where,alphaThreshold,cmap)
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

x = x(mask);
y = y(mask);
z = z(mask);
intensities = intensities(mask);

% Marker size scales with intensity (brighter = larger)
markerSizes = 1+multiplier*sample*intensities;  % adjust scaling factor as needed

cmap_function = feval(cmap, 256);
min_val = min(intensities(:), [], 'all', 'omitnan');
max_val = max(intensities(:), [], 'all', 'omitnan');

if min_val == max_val
    rgb_matrix = cmap_function(1,:);
else
    rgb_matrix = interp1(linspace(min_val, max_val, 256), cmap_function, intensities);
end

figureData=scatter3(where,x,y,z,markerSizes,rgb_matrix,'MarkerFaceColor','flat');
end