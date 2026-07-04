function handles = visualizeMRIandT2(mriVol, t2Vol, varargin)
% VISUALIZEMRIANDT2  Hybrid voxel renderer: MRI volume + toggleable T2 overlay.
%
%   handles = visualizeMRIandT2(mriVol, t2Vol, Name,Value, ...)
%
% Required inputs:
%   mriVol  - 3D array (MRI intensities, expected double/ single, 0..1 or similar)
%   t2Vol   - 3D array same size as mriVol (T2 map or similar)
%
% Name-Value options (defaults):
%   'Sample'      : 2             (downsampling factor; integer >=1)
%   'MarkerScale' : 10            (base point size)
%   'AlphaMRI'    : 0.6           (global alpha multiplier for MRI layer, 0-1)
%   'AlphaT2'     : 0.9           (global alpha multiplier for T2 layer, 0-1)
%   'CmapMRI'     : 'gray'        (colormap name or handle for MRI)
%   'CmapT2'      : 'hot'         (colormap name or handle for T2 overlay)
%   'T2Threshold' : []            (optional threshold for T2 to show; [] = automatic)
%   'Parent'      : gca          (axes handle where to plot)
%
% Returns a struct 'handles' with handles to scatter objects and ui controls:
%   handles.hMRI, handles.hT2, handles.btnToggleT2, handles.sldAlphaMRI, ...
%
% -------------------------------------------------------------------------
% Implementation notes:
%  - Uses gpuArray for preprocessing (downsample, masks, color mapping) to speed up
%    large volumes. scatter3 uses CPU arrays, so we gather only the reduced arrays.
%  - Marker transparency is controlled by MarkerFaceAlpha = 'flat' and AlphaData.
%  - To update parameters programmatically, change properties on the returned handles.
% -------------------------------------------------------------------------

% Parse inputs
p = inputParser;
addRequired(p,'mriVol', @(x) isnumeric(x) && ndims(x)==3);
addRequired(p,'t2Vol',  @(x) isnumeric(x) && ndims(x)==3);
addParameter(p,'Sample',2,@(x) isnumeric(x)&&isscalar(x)&&x>=1);
addParameter(p,'MarkerScale',10,@(x) isnumeric(x)&&isscalar(x)&&x>0);
addParameter(p,'AlphaMRI',0.6,@(x) isnumeric(x)&&isscalar(x)&&x>=0&&x<=1);
addParameter(p,'AlphaT2',0.9,@(x) isnumeric(x)&&isscalar(x)&&x>=0&&x<=1);
addParameter(p,'CmapMRI','gray');
addParameter(p,'CmapT2','hot');
addParameter(p,'T2Threshold',[], @(x) isempty(x)|| (isnumeric(x)&&isscalar(x)));
addParameter(p,'Parent',gca);
parse(p,mriVol,t2Vol,varargin{:});
opts = p.Results;

ax = opts.Parent;
fig = ancestor(ax,'figure');

% Ensure data are single precision for GPU efficiency
mriVol = single(mriVol);
t2Vol  = single(t2Vol);

if ~isequal(size(mriVol), size(t2Vol))
    error('mriVol and t2Vol must be the same size.');
end

% Normalize volumes to [0,1] (robust)
mriVol = mriVol - min(mriVol(:));
if max(mriVol(:))>0
    mriVol = mriVol ./ max(mriVol(:));
end
t2Vol = t2Vol - min(t2Vol(:));
if max(t2Vol(:))>0
    t2Vol = t2Vol ./ max(t2Vol(:));
end

% Create GPU arrays for heavy ops
useGPU = canUseGPU();
if useGPU
    gMRI = gpuArray(mriVol);
    gT2  = gpuArray(t2Vol);
else
    gMRI = mriVol;
    gT2  = t2Vol;
end

% Downsample with given sample factor (initially)
sample = max(1, round(opts.Sample));
[xGrid,yGrid,zGrid, mriVals, t2Vals] = gatherReducedPoints(gMRI, gT2, sample, useGPU);

% Compute colors (on GPU if possible), then gather to CPU arrays
[colorsMRI, alphaMRI] = mapColorsAndAlpha(mriVals, opts.CmapMRI, opts.AlphaMRI, useGPU);
[colorsT2,  alphaT2 ] = mapColorsAndAlpha(t2Vals,  opts.CmapT2,  opts.AlphaT2,  useGPU);

% If a T2 threshold is provided, mask T2 points below it
if ~isempty(opts.T2Threshold)
    t2mask = (t2Vals >= opts.T2Threshold);
    xGridT2 = xGrid(t2mask); yGridT2 = yGrid(t2mask); zGridT2 = zGrid(t2mask);
    colorsT2 = colorsT2(t2mask,:);
    alphaT2 = alphaT2(t2mask);
else
    xGridT2 = xGrid; yGridT2 = yGrid; zGridT2 = zGrid;
end

% Create axes plot
cla(ax);
hold(ax,'on');

% MRI scatter (background anatomical volume)
hMRI = scatter3(ax, xGrid, yGrid, zGrid, opts.MarkerScale, colorsMRI, 'filled', 'MarkerFaceAlpha','flat');
% Set per-point alpha
set(hMRI, 'AlphaData', alphaMRI, 'MarkerEdgeAlpha', '0');

% T2 scatter (overlay)
hT2 = scatter3(ax, xGridT2, yGridT2, zGridT2, opts.MarkerScale, colorsT2, 'filled', 'MarkerFaceAlpha','flat');
set(hT2, 'AlphaData', alphaT2, 'MarkerEdgeAlpha', '0');

% Visual niceties
axis(ax,'image');
view(ax,3);
xlabel(ax,'X'); ylabel(ax,'Y'); zlabel(ax,'Z');
grid(ax,'off');
material(ax,'dull');
camlight(ax,'headlight');
lighting(ax,'gouraud');

% Ensure OpenGL renderer (better GPU/point performance)
try
    set(fig, 'Renderer', 'opengl');
catch
end

% Create UI controls (toggle, sliders)
btnToggleT2 = uicontrol(fig,'Style','pushbutton','String','Toggle T2', ...
    'Units','normalized','Position',[0.01 0.01 0.10 0.05],...
    'Callback', @(s,e) toggleT2Callback(hT2));

sldAlphaMRI = uicontrol(fig,'Style','slider','Min',0,'Max',1,'Value',opts.AlphaMRI, ...
    'Units','normalized','Position',[0.12 0.01 0.20 0.05],...
    'Callback', @(s,e) setAlphaCallback(hMRI, s.Value, colorsMRI));

lblMRI = uicontrol(fig,'Style','text','String','MRI alpha','Units','normalized','Position',[0.12 0.06 0.20 0.03]);

sldAlphaT2 = uicontrol(fig,'Style','slider','Min',0,'Max',1,'Value',opts.AlphaT2, ...
    'Units','normalized','Position',[0.33 0.01 0.20 0.05],...
    'Callback', @(s,e) setAlphaCallback(hT2, s.Value, colorsT2));

lblT2 = uicontrol(fig,'Style','text','String','T2 alpha','Units','normalized','Position',[0.33 0.06 0.20 0.03]);

% Downsample slider (interactive quality/speed)
sldSample = uicontrol(fig,'Style','slider','Min',1,'Max',8,'Value',sample,'SliderStep',[1/7 1/7], ...
    'Units','normalized','Position',[0.54 0.01 0.20 0.05],...
    'Callback', @(s,e) resampleCallback(round(s.Value)));

lblSample = uicontrol(fig,'Style','text','String',sprintf('Downsample = %d', sample),...
    'Units','normalized','Position',[0.54 0.06 0.20 0.03]);

% Pack handles for return
handles.hMRI = hMRI;
handles.hT2  = hT2;
handles.btnToggleT2 = btnToggleT2;
handles.sldAlphaMRI = sldAlphaMRI;
handles.sldAlphaT2  = sldAlphaT2;
handles.sldSample    = sldSample;
handles.lblSample    = lblSample;

% nested callbacks -------------------------------------------------------
    function toggleT2Callback(hObj)
        % toggle visibility
        if strcmp(get(hObj,'Visible'),'on')
            set(hObj,'Visible','off');
        else
            set(hObj,'Visible','on');
        end
    end

    function setAlphaCallback(hObj, globalAlpha, baseColors)
        % scale alpha stored in AlphaData by new slider value
        % We originally stored alpha per-point in alphaMRI/alphaT2; recompute a flat scaled alpha.
        n = size(baseColors,1);
        % Use globalAlpha as uniform alpha weighting across points; keep some per-point variability if desired
        alphaVec = repmat(globalAlpha, n, 1);
        set(hObj, 'AlphaData', alphaVec);
    end

    function resampleCallback(newSample)
        % Recompute reduced points with new downsampling. This is the expensive op.
        set(handles.lblSample, 'String', sprintf('Downsample = %d', newSample));
        drawnow;
        % compute again using GPU if available
        [xGrid2,yGrid2,zGrid2, mriVals2, t2Vals2] = gatherReducedPoints(gMRI, gT2, newSample, useGPU);
        [colorsMRI2, alphaMRI2] = mapColorsAndAlpha(mriVals2, opts.CmapMRI, get(handles.sldAlphaMRI,'Value'), useGPU);
        [colorsT22, alphaT22 ] = mapColorsAndAlpha(t2Vals2,  opts.CmapT2,  get(handles.sldAlphaT2,'Value'), useGPU);
        % update MRI scatter
        set(handles.hMRI, 'XData', xGrid2, 'YData', yGrid2, 'ZData', zGrid2, 'CData', colorsMRI2, 'SizeData', opts.MarkerScale);
        set(handles.hMRI, 'AlphaData', repmat(get(handles.sldAlphaMRI,'Value'), numel(mriVals2), 1));
        % update T2 scatter
        set(handles.hT2, 'XData', xGrid2, 'YData', yGrid2, 'ZData', zGrid2, 'CData', colorsT22, 'SizeData', opts.MarkerScale);
        set(handles.hT2, 'AlphaData', repmat(get(handles.sldAlphaT2,'Value'), numel(t2Vals2), 1));
    end

end

% -------------------------- helper functions ------------------------------
function tf = canUseGPU()
% quick check for GPU availability
try
    g = gpuDevice();
    tf = ~isempty(g) && g.DeviceSupported;
catch
    tf = false;
end
end

function [xg, yg, zg, mVals, tVals] = gatherReducedPoints(gMRI, gT2, sample, useGPU)
% Downsample grids and gather reduced 1D arrays of coordinates and intensities.
% Inputs gMRI, gT2 may be gpuArray or CPU arrays.

sz = size(gMRI);
% coordinate indices
ix = 1:sample:sz(1);
iy = 1:sample:sz(2);
iz = 1:sample:sz(3);

% create grid on GPU or CPU
if useGPU
    [X,Y,Z] = ndgrid(gpuArray(ix), gpuArray(iy), gpuArray(iz));
    smallMRI = gMRI(ix,iy,iz);
    smallT2  = gT2(ix,iy,iz);
else
    [X,Y,Z] = ndgrid(ix,iy,iz);
    smallMRI = gMRI(ix,iy,iz);
    smallT2  = gT2(ix,iy,iz);
end

% flatten and optionally mask low-intensity MRI voxels (to reduce points)
mVals = smallMRI(:);
tVals = smallT2(:);

% mask out near-zero MRI voxels to reduce point count (keeps structure)
mMask = mVals > 0.02;  % small threshold to reduce black background points
% ensure some points remain
if nnz(mMask) < 100
    mMask = true(size(mMask));
end

% Apply mask to all arrays
xg = gather(X(mMask));
yg = gather(Y(mMask));
zg = gather(Z(mMask));
mVals = gather(mVals(mMask));
tVals = gather(tVals(mMask));
end

function [rgb, alphaVec] = mapColorsAndAlpha(intens, cmapNameOrHandle, globalAlpha, useGPU)
% Map intensity values [0..1] to RGB using provided colormap and create alpha per point.
% If intens is empty, return empty arrays.

if isempty(intens)
    rgb = zeros(0,3);
    alphaVec = zeros(0,1);
    return;
end

ncol = 256;
% get cmap on CPU (colormap returns per-call matrix)
if isa(cmapNameOrHandle,'char') || isa(cmapNameOrHandle,'string')
    cmapFcn = str2func(char(cmapNameOrHandle));
    cmapMat = cmapFcn(ncol);
elseif isa(cmapNameOrHandle,'function_handle')
    cmapMat = cmapNameOrHandle(ncol);
else
    cmapMat = colormap(ncol); % fallback
end

% intens may be GPU or CPU array; bring to CPU for interp1
if useGPU
    intens_cpu = gather(intens(:));
else
    intens_cpu = intens(:);
end

% clamp and map
intens_cpu = min(max(intens_cpu, 0), 1);
idx = round(intens_cpu * (ncol-1)) + 1;
idx(idx<1) = 1; idx(idx>ncol) = ncol;

rgb = cmapMat(idx, :);

% alpha: base alpha proportional to intensity but scaled by globalAlpha
alphaVec = intens_cpu * globalAlpha;
% floor so completely dark voxels stay nearly invisible
alphaVec(alphaVec < 0.02*globalAlpha) = 0.02*globalAlpha;

end