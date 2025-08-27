function varargout = normalizeData(varargin)
%NORMALIZEDATA Summary of this function goes here
%   Detailed explanation goes here
%% reskalovanie
pocetArgs = nargin;

varargout = cell(1, pocetArgs);  % Preallocate output cell

for k = 1:pocetArgs
    varargout{k} = rescale(varargin{k});
end
end