function hScatter = modelVisualizerOld(modelInput, sample, multiplier, where, alphaThreshold, cmapName, useGPU)
%MODELVISUALIZER Enhanced voxel-based MRI/T2 scatter visualizer
%   Supports GPU acceleration, transparency, and easy on/off overlays.

%% --- Input handling ---
if nargin < 7
    useGPU = false;
else
    if strcmp('Off',useGPU) == 0
        useGPU = false;
    else
        useGPU = true;
    end
end

%% --- Optional GPU Acceleration ---
if useGPU
    modelInput = gpuArray(modelInput);
end

%% --- Sampling grid ---
[X, Y, Z] = ndgrid(1:sample:size(modelInput,1), ...
                  1:sample:size(modelInput,2), ...
                  1:sample:size(modelInput,3));

x = X(:);  y = Y(:);  z = Z(:);

clear X Y Z;

%% --- Sample volume intensities ---
sampledVol = modelInput(1:sample:end, 1:sample:end, 1:sample:end);
intensities = sampledVol(:);

%% --- Intensity threshold -> transparency ---
mask = intensities > alphaThreshold;

x = x(mask);
y = y(mask);
z = z(mask);
intensities = intensities(mask);

%% --- Optional "smart decimation" ---
% lower-intensity points are more likely to be dropped (keeps edges sharp)
decimStrength = 0;  % 0=no decimation, 0.3=strong
if decimStrength > 0
    dropProb = decimStrength * (1 - intensities ./ max(intensities));
    keepMask = rand(size(dropProb)) > dropProb;
    
    x = x(keepMask);
    y = y(keepMask);
    z = z(keepMask);
    intensities = intensities(keepMask);
end

%% --- Marker size scaling ---
markerSizes = 1 + multiplier * sample * intensities;
% markerSizes = 1 + multiplier * sample;

%% --- Colormap mapping ---
cmap = feval(cmapName, 256);
minVal = min(intensities(:), [], 'all', 'omitnan');
maxVal = max(intensities(:), [], 'all', 'omitnan');

if minVal == maxVal
    rgb = repmat(cmap(end,:), numel(intensities), 1);
else
    rgb = interp1(linspace(minVal, maxVal, 256), cmap, intensities, 'linear');
end

%% --- 3D scatter plot ---
hScatter = scatter3(where, x, y, z, ...
    'SizeData', markerSizes, ...
    'CData', rgb, ...
    'Marker', 's', ...
    'MarkerFaceColor', 'flat');
% hScatter.MarkerFaceAlpha = 0.5;   % overall transparency
% hScatter.MarkerEdgeAlpha = 0.0;

end
