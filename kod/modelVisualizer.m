function hScatter = modelVisualizer(modelInput, X_grid, Y_grid, Z_grid, target, properties, useGPU)
%MODELVISUALIZER Voxel-based scatter visualizer (Kompatibilný s fyzickými mriežkami)
%   Vstupy:
%     modelInput - 3D matica dát (Volume)
%     X_grid, Y_grid, Z_grid - Priestorové súradnice z DICOMPlanesToVolume
%     target - Rukoväť na konkrétne osi (app.UIAxes)
%     properties - Štruktúra s nastaveniami
%     useGPU - Logická premenná pre zapnutie Parallel Computing Toolboxu
arguments
    modelInput
    X_grid
    Y_grid
    Z_grid
    target
    properties = struct('cull',4,'maskThreshold',0,'multiplier',10,'cmapName',"gray",'markerBaseSize',1)
    useGPU = false
end

%% --- Input handling ---
% Bezpečnejšie vyhodnotenie, ak príde useGPU ako string z UI dropdownu
if ischar(useGPU) || isstring(useGPU)
    useGPU = strcmpi(useGPU, 'On') || strcmpi(useGPU, 'True');
end

%% --- Optional GPU Acceleration ---
if useGPU
    modelInput = gpuArray(modelInput);
    X_grid = gpuArray(X_grid);
    Y_grid = gpuArray(Y_grid);
    Z_grid = gpuArray(Z_grid);
end

%% properties
if ~isfield(properties,'cull'), properties.cull = 4; end
if ~isfield(properties,'maskThreshold'), properties.maskThreshold = 0; end
if ~isfield(properties,'multiplier'), properties.multiplier = 10; end
if ~isfield(properties,'markerBaseSize'), properties.markerBaseSize = 1; end
if ~isfield(properties,'cmapName'), properties.cmapName = "gray"; end

%% --- Sampling grid (FYZICKÉ SÚRADNICE) ---
% Namiesto umelého ndgrid podvzorkujeme priamo reálne DICOM milimetre
X_samp = X_grid(1:properties.cull:end, 1:properties.cull:end, 1:end);
Y_samp = Y_grid(1:properties.cull:end, 1:properties.cull:end, 1:end);
Z_samp = Z_grid(1:properties.cull:end, 1:properties.cull:end, 1:end);
sampledVol = modelInput(1:properties.cull:end, 1:properties.cull:end, 1:end);

x = X_samp(:);
y = Y_samp(:);
z = Z_samp(:);
intensities = sampledVol(:);

% Uvoľnenie pamäte
clear X_samp Y_samp Z_samp sampledVol;

%% --- Intensity threshold -> transparency ---
% --- PRIDANÉ OŠETRENIE: ~isnan() preskočí prázdne miesta medzi rezmi
mask = (intensities > properties.maskThreshold) & ~isnan(intensities);

x = x(mask);
y = y(mask);
z = z(mask);
intensities = intensities(mask);

%% --- Marker size scaling ---
% markerSizes = 1 + properties.multiplier * properties.cull * intensities;
markerSizes = properties.markerBaseSize;

%% --- Colormap mapping ---
% Poistka pre britskú vs americkú angličtinu (MATLAB uprednostňuje gray)
cName = char(properties.cmapName);
if strcmpi(cName, 'grey'), cName = 'gray'; end
cmap = feval(cName, 256);

minVal = min(intensities(:), [], 'all', 'omitnan');
maxVal = max(intensities(:), [], 'all', 'omitnan');

% Poistka, ak by prah odstránil úplne všetky dáta
if isempty(intensities)
    hScatter = scatter3(target, [], [], [], 's');
    return;
end

if minVal == maxVal
    rgb = repmat(cmap(end,:), numel(intensities), 1);
else
    rgb = interp1(linspace(minVal, maxVal, 256), cmap, intensities, 'linear');
end

%% parcomp gather
if useGPU
    x = gather(x);
    y = gather(y);
    z = gather(z);
end

%% --- 3D scatter plot ---
hScatter = scatter3(target, x, y, z, ...
    'SizeData', markerSizes, ...
    'CData', rgb, ...
    'Marker', 's', ...
    'MarkerFaceColor', 'flat', ...
    'MarkerEdgeColor', 'none'); % Vypnutie mriežky okolo bodov pre čistejší oblak

axis(target, 'equal'); % Zabezpečí, že milimeter na X = milimeter na Z

end