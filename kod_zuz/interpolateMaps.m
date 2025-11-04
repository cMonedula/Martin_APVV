function [interpVolume] = interpolateMaps(axial, coronal, sagittal, interp_address)
    
    %% 1. Define Common Query Grid
    res = 1; 
    max_x = max([size(axial,1), size(coronal,1), size(sagittal,1)]);
    max_y = max([size(axial,2), size(coronal,2), size(sagittal,2)]);
    max_z = max([size(axial,3), size(coronal,3), size(sagittal,3)]);
    
    % Create query grid (ndgrid is correct)
    % x varies along rows (Dim 1)
    % y varies along columns (Dim 2)
    [x, y, z] = ndgrid(1:res:max_x, 1:res:max_y, 1:res:max_z);

    %% 2. Interpolation
    % Cast to double for interpolation
    axial = double(axial);
    coronal = double(coronal);
    sagittal = double(sagittal);

    % THE X/Y SWAP FIX:
    % interp3(V, Xq, Yq, Zq, ...)
    % V's implicit X-axis is Dim 2 (cols) -> needs your 'y' query
    % V's implicit Y-axis is Dim 1 (rows) -> needs your 'x' query
    
    disp('Interpolating axial...');
    interp_axial = interp3(axial, y, x, z, 'makima');
    
    disp('Interpolating coronal...');
    interp_coronal = interp3(coronal, y, x, z, 'makima');
    
    disp('Interpolating sagittal...');
    interp_sagittal = interp3(sagittal, y, x, z, 'makima');
    
    %% 3. Averaging
    
    disp('Averaging...');
    interp_stack = cat(4, interp_axial, interp_coronal, interp_sagittal);
    
    % Use mean with 'omitnan' (your original code was correct here)
    interpVolume = mean(interp_stack, 4, 'omitnan');

    %% 4. NaN-Safe Normalization (Replaces normalizeData)
    
    disp('Normalizing...');
    
    % Find min/max *ignoring* any NaN values
    minVal = min(interpVolume(:), [], 'omitnan');
    maxVal = max(interpVolume(:), [], 'omitnan');
    
    if minVal == maxVal
        % Handle case of a flat volume (or all NaNs)
        interpVolume(~isnan(interpVolume)) = 0; 
    else
        % Perform normalization
        interpVolume = (interpVolume - minVal) / (maxVal - minVal);
    end

    % Finally, set any remaining NaNs (where all 3 inputs were NaN) to 0
    interpVolume(isnan(interpVolume)) = 0;
    
    %% 5. Save
    niftiwrite(single(interpVolume), interp_address);
    disp('Done.');
end