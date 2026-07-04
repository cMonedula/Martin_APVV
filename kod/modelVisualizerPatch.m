function [figureData] = modelVisualizerPatch(modelInput,sample,multiplier,where,alphaThreshold,cmap)
%MODELVISUALIZER plots 3D point cloud data using the highly optimized PATCH function.

%   NOTE: MarkerSize is now a single scalar, as PATCH does not accept an array of sizes.

[X,Y,Z]=ndgrid(1:sample:size(modelInput,1),1:sample:size(modelInput,2),1:sample:size(modelInput,3));
x = X(:);
y = Y(:);
z = Z(:);
clear X Y Z;

sampledInput=modelInput(1:sample:end,1:sample:end,1:sample:end);
intensities=sampledInput(:);

% --- Filtering Steps ---

% 1. Filter out all non-finite data (NaN/Inf)
valid_data_mask = isfinite(intensities);

x = x(valid_data_mask);
y = y(valid_data_mask);
z = z(valid_data_mask);
intensities = intensities(valid_data_mask);

% 2. Threshold: remove very dark voxels (simulate transparency)
mask = intensities > alphaThreshold;

x = x(mask);
y = y(mask);
z = z(mask);
intensities = intensities(mask);

% Check if the filtered vectors are empty
if isempty(x)
    % Set figureData to an empty patch handle and return immediately.
    % This is the safest way to prevent the size mismatch error.
    figureData = patch(where, 'XData', [], 'YData', [], 'ZData', [], 'CData', []);
    return;
end

% --- Marker Size Calculation ---

% Calculate a single representative marker size, as PATCH requires a scalar.
% We'll use the average of the dynamic sizes you calculated previously.
markerSizes = 1+multiplier*sample*intensities;
uniformMarkerSize = mean(markerSizes, 'all');

% --- Color Matrix Calculation: The Final Fix ---

% N is the current number of points after filtering
N = length(intensities);

% Get the N x 3 Colormap (cmap_function is the lookup table)
cmap_function = feval(cmap, 256);

% Calculate the data range, excluding NaN/Inf
min_val = min(intensities(:), [], 'all', 'omitnan');
max_val = max(intensities(:), [], 'all', 'omitnan');

% % Handle the uniform/empty case
% if isempty(min_val) || min_val == max_val
%     % If uniform, assign a mid-gray value (0.5) to all points
%     normalized_intensities = repmat(0.5, N, 1);
% else
%     % Normalize the vector
%     normalized_intensities = (intensities - min_val) / (max_val - min_val);
% end
% 
% % 2. Create the N x 3 RGB Matrix
% % Since R=G=B for grayscale, we replicate the normalized vector three times.
% rgb_matrix = [normalized_intensities, normalized_intensities, normalized_intensities];

% 1. Handle Empty or Uniform Data (CRITICAL for size matching)
if N == 0
    % Return an empty matrix if there are no points
    rgb_matrix = []; 
elseif min_val == max_val || isempty(min_val) 
    % Data is uniform, so all points get the same color.
    % We MUST create an N x 3 matrix using repmat.
    % We use the middle color of the map (128th row) as the representative color.
    uniform_color = cmap_function(round(size(cmap_function, 1)/2), :);
    rgb_matrix = repmat(uniform_color, N, 1);
else
    % 2. TrueColor Assignment via Interpolation
    % Create the N x 3 RGB matrix: one unique color row for each intensity value
    reference_range = linspace(min_val, max_val, 256);
    rgb_matrix = interp1(reference_range, cmap_function, intensities);
end

% --- PATCH Plotting ---

figureData = patch(where, 'XData', x, 'YData', y, 'ZData', z, ...
                   'Marker', '.', ...
                   'MarkerFaceColor', 'flat', ...
                   'FaceVertexCData', rgb_matrix, ... % The N x 3 TrueColor data
                   'FaceColor', 'none', ...
                   'EdgeColor', 'none');

% The axis and view settings should be moved to your calling script (userInterface)
% to avoid overwriting settings when plotting the second overlay.

end