function [registeredVolume] = accuracyRegistration(fixedVolume,movingVolume)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Set a target accuracy threshold (e.g., Mean Squared Error)
targetMSE = 0.0005;
currentMSE = Inf; % Initialize with a high value

[fixedVolume,movingVolume]=normalizeData(fixedVolume,movingVolume);

% Set up initial registration parameters
[optimizer, metric] = imregconfig('monomodal');
optimizer.MaximumIterations = 50;
optimizer.MaximumStepLength = 0.005;
optimizer.MinimumStepLength = 1e-6; 

fprintf('Starting iterative 3D registration...\n');

while currentMSE > targetMSE
    % 1. Perform 3D registration to get the transformation object
    tform = imregtform(movingVolume, fixedVolume, 'affine', optimizer, metric,'DisplayOptimization',true);

    % 2. Apply the transformation to get the registered volume
    % We use imref3d for 3D spatial referencing
    Rfixed = imref3d(size(fixedVolume));
    registeredVolume = imwarp(movingVolume, tform, 'OutputView', Rfixed);

    % 3. Calculate the Mean Squared Error (our accuracy metric)
    currentMSE = immse(registeredVolume, fixedVolume);

    % Display current progress
    fprintf('  Current MSE: %.6f\n', currentMSE);

    % 4. Adjust optimizer settings to allow for refinement in the next iteration
    optimizer.MaximumIterations = optimizer.MaximumIterations + 10;
    optimizer.MinimumStepLength = optimizer.MinimumStepLength / 2;

    % Optional: Add a safety break to prevent an infinite loop
    if optimizer.MaximumIterations > 200
        fprintf('Maximum iterations reached. Exiting loop.\n');
        break;
    end
end

fprintf('Registration complete! Final MSE: %.6f\n', currentMSE);

% Optional: Visualize a slice of the final result to check alignment
figure;
subplot(1, 3, 1);
imshow(fixedVolume(:, :, 25), []);
title('Fixed Slice');

subplot(1, 3, 2);
imshow(registeredVolume(:, :, 25), []);
title('Registered Slice');

subplot(1, 3, 3);
imshowpair(fixedVolume(:, :, 25), registeredVolume(:, :, 25));
title('Overlay');
end

